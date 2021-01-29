/**
* @File Name          : OpportunityMSDSTriggerServiceImpl.cls
* @Description        : Strategy, Implementation class for MSDS Record Type.
* @Author             : Saloni Gupta
* @Group              :
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 09-08-2020
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    01/07/2020, 1:14:54 PM     Nitish Bansal            Initial Version

**/
public without sharing class OpportunityMSDSTriggerServiceImpl implements OpportunityTriggerService{

    OpportunityTriggerStrategyHelper opths;

    private static String msdsTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(ConstantsUtility.MSDS_FOLLOW_UP_TASK_REC_TYPE).getRecordTypeId();
    private static String testDriveAssetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get(ConstantsUtility.testDriveAssetRT).getRecordTypeId();


    public void beforeInsert(List < Opportunity > newOppList) {

        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records
        ----------------------------------------------------------------------------------------------*/
        opths = OpportunityTriggerStrategyHelper.getInstance(newOppList, null, null);

        system.debug('beforeInsert******* OpportunityMSDSTriggerServiceImpl');
        opths.setStandardPriceBook();
        opths.updateGenderAndCustomerType();

        //Update owner on enquiry if created by dealer callcenter
        OptyAssignDCCRecords.assignDCCCreatedEnquiry(newOppList);


        //The standard account field will be updated based on the user account record defined for partner users
        //This will enable the visibility of enquiry records based on the Account team defined under the user Account
        opths.updateDealerAndStandardAccount();
        // populateExchangeVehicleEvaluator
        opths.populateExchangeVehicleEvaluator();
        //Change Ownership of Enquiry(Opportunity)to Sales SPOC when Enquiry is of Vehicle Sales Record Type and
        //Enquiry owner is Integration user.
        opths.assignEnquirytoSalesSPOC();
        //Update Escalation Fields based on Escalation Matrix
        //This will the populate the notifiers for each levels for both allocated and unallocated enquiries
        opths.updateEscalationFields();
        //execute this as last method of event. It will update Enquiry Stage time field to ensure field value goes as part of CDC
        opths.setStageTime(ConstantsUtility.MSDS);
        //Run the method to ensure that the Enquiry Name is always Customer Name _ RecordType
        opths.updateEnquiryName(ConstantsUtility.MSDS);

		List<GlobalSwitchOn__c> createAccount = opths.checkAccountPermission;

        if(!createAccount.isEmpty() && createAccount[0].Create_Dummy_Account__c){
            //create dummy customer account in case of no account is populated
            opths.createDummyAccountOnOpportunity();
        }

		//Method to populate default values
        opths.updateFollowupDetailsOnEnquiry(ConstantsUtility.MSDS_FOLLOWUP_TYPE, ConstantsUtility.MSDS_REMINDER_TIME);

        //populate msds corporate code value
        opths.populateMSDSFieldsValues(True, False);
        // populate followup fields
        opths.polulateFollowupMSDSField();
    }


    public void beforeUpdate(List < Opportunity > oppList, Map < Id, Opportunity > newoppMap, Map < Id, Opportunity > oldoppMap) {

         /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/

        opths = OpportunityTriggerStrategyHelper.getInstance(oppList, newOppMap, oldoppMap);
		 //Compare incoming external id with old external id, if same then only update can happen
        opths.checkExternalId();
        system.debug('beforeUpdate******* OpportunityMSDSTriggerServiceImpl');
        // Call relevant methods in OpportunityTriggerHelper/Handler
        opths.updateGenderAndCustomerType();
        //The standard account field will be updated based on the user account record defined for partner users
        //This will enable the visibility of enquiry records based on the Account team defined under the user Account
        opths.updateDealerAndStandardAccount();
        // populateExchangeVehicleEvaluator
        opths.populateExchangeVehicleEvaluator();
        //Populate Previous owner on Enquiry
        opths.updatePreviousOwneronEnquiry();
        //Prevent mulesoft user from changing status back to New
        opths.preventWrongStageChange();
        //Update Escalation Fields based on Escalation Matrix
        opths.updateEscalationFields();
        //execute this as last method of event. It will update Enquiry Stage time field to ensure field value goes as part of CDC
        opths.setStageTime(ConstantsUtility.MSDS);
        //Run the method to ensure that the Enquiry Name is always Customer Name _ RecordType
        opths.updateEnquiryName(ConstantsUtility.MSDS);
        //populate msds corporate code value
        opths.populateMSDSFieldsValues(False,True);

    }
    public void afterInsert(list < Opportunity > oppList, Map < Id, Opportunity > newOppMap, Map < Id, Opportunity > oldoppMap) {

        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/

        opths = OpportunityTriggerStrategyHelper.getInstance(oppList, newOppMap, oldoppMap);

        system.debug('afterInsert******* OpportunityMSDSTriggerServiceImpl');
        //Send notifications to SPOC
        opths.notifySpocForDSEAllocation();
        //This method will create Followup Task for an Enquiry
        opths.createMSDSEnquiryFollowUp(msdsTaskRecordTypeId);

        /*
        *    Description - To add Opportunity team members under an Enquiry
        *    Parameters - 1 = After Insert, 2 = After Update
        */
        opths.addOpportunityTeamMembers(True, False);

        /*
        *    Description - create MC Communication records on DSE Allocation
        *    Parameters - 1 = After Insert, 2 = After Update
        */
        opths.createMCrecordsOnDSEAllocationOrUntagging(True, False);

        /*
        *    Description - Escalations
        *    Parameters - 1 = After Insert, 2 = After Update
        */
        opths.postChatterMessage(True, False);


        //check course value of msds enquiry
        opths.checkCourseOnEnquiry();

        // check the selected vehicle is unavailable at the Dealership
        opths.checkSelectedVehicle(testDriveAssetRecordTypeId);
    }
    public void afterUpdate(list < Opportunity > oppList, Map < Id, Opportunity > newOppMap, Map < Id, Opportunity > oldoppMap) {

        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/
        opths = OpportunityTriggerStrategyHelper.getInstance(oppList, newOppMap, oldoppMap);

        system.debug('afterUpdate******* OpportunityMSDSTriggerServiceImpl');
        //Update SVOC ID on Enquiry and on Account
        opths.updateFieldsUsingSVOCID();

        /*
        *    Description - To add Opportunity team members under an Enquiry
        *    Parameters - 1 = After Insert, 2 = After Update
        */
        opths.addOpportunityTeamMembers(False,True);

        /*
        *    Description - create MC Communication records on DSE Allocation
        *    Parameters - 1 = After Insert, 2 = After Update
        */
        opths.createMCrecordsOnDSEAllocationOrUntagging(False,True);

        /*
        *    Description - Escalations
        *    Parameters - 1 = After Insert, 2 = After Update
        */
        opths.postChatterMessage( False,True);

        // if stage = "Retail" then all the Followup  will be closed .
        opths.closedFollowup();
        //check course value of msds enquiry
        opths.checkCourseOnEnquiry();

        // check the selected vehicle is unavailable at the Dealership
        opths.checkSelectedVehicle(testDriveAssetRecordTypeId);

    }

}