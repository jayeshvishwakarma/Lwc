/**
* @File Name          : OpportunityVehicleTriggerServiceImpl.cls
* @Description        : Strategy, Implementation class for Vehicle Sales Record Type.
* @Author             : Anuj Kumar
* @Group              :
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 10-20-2020
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    01/07/2020, 1:14:54 PM     Nitish Bansal            Initial Version

**/
public without sharing class OpportunityVehicleTriggerServiceImpl implements OpportunityTriggerService {

    OpportunityTriggerStrategyHelper opths;

    private static String preBookingTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(ConstantsUtility.PRE_BOOKING_FOLLOWUP).getRecordTypeId();

    public void beforeInsert(List < Opportunity > newOppList) {

        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records
        ----------------------------------------------------------------------------------------------*/
        opths = OpportunityTriggerStrategyHelper.getInstance(newOppList, null, null);

        opths.setStandardPriceBook();
		opths.assignNAVEnquirytoHostess();
        opths.updateGenderAndCustomerType();

        //Update Close date on Enquiry from current plus 3 months date
        opths.populateCloseDate(label.Add_Months_to_Enquiry_Close_Date);

        //Change Ownership of Enquiry(Opportunity)to Sales SPOC when Enquiry is of Vehicle Sales Record Type and
        //Enquiry owner is Integration user.
        opths.assignEnquirytoSalesSPOC();

        //Update owner on enquiry if created by dealer callcenter
        OptyAssignDCCRecords.assignDCCCreatedEnquiry(newOppList);        

        //The standard account field will be updated based on the user account record defined for partner users
        //This will enable the visibility of enquiry records based on the Account team defined under the user Account
        opths.updateDealerAndStandardAccount();

        // populateExchangeVehicleEvaluator
        opths.populateExchangeVehicleEvaluator();

        //Update Escalation Fields based on Escalation Matrix
        //This will the populate the notifiers for each levels for both allocated and unallocated enquiries
        opths.updateEscalationFields();

        //execute this as last method of event. It will update Enquiry Stage time field to ensure field value goes as part of CDC
        opths.setStageTime(ConstantsUtility.OPPORTUNITY_VEHICLE_SALES_RECORDTYPE);

        //Run the method to ensure that the Enquiry Name is always Customer Name _ RecordType
        opths.updateEnquiryName(ConstantsUtility.NEWCAR_ENQ);

        //Update the Cusytomer attributes to opportunity
        opths.updateCustomerAttributes(ConstantsUtility.BILL_To_ADDRESS_LINE_FIELD, ConstantsUtility.THIRTY);

        //Method to count the variant changes on enquiry.
        opths.populateVariantChangesCount();

        List<GlobalSwitchOn__c> createAccount = opths.checkAccountPermission;

        if(!createAccount.isEmpty() && createAccount[0].Create_Dummy_Account__c){
            //create dummy customer account in case of no account is populated
            opths.createDummyAccountOnOpportunity();
        }

        //Method to populate default values
        opths.updateFollowupDetailsOnEnquiry(ConstantsUtility.PREBOOKING_FOLLOWUP_TYPE, ConstantsUtility.PREBOOKING_REMINDER_TIME);

        opths.uniquenessCheck();
    }

    public void beforeUpdate(List < Opportunity > oppList, Map < Id, Opportunity > newOppMap, Map < Id, Opportunity > oldoppMap) {
        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/

        opths = OpportunityTriggerStrategyHelper.getInstance(oppList, newOppMap, oldoppMap);
		 //Compare incoming external id with old external id, if same then only update can happen
        opths.checkExternalId();
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

        //This method will check BookingCancellationReason field and update opportunity stage to New if BookingCancellationReason is Post-Pone and previous value of BookingCancellationReason is blank.
        opths.checkBookingCancellationReason();

        //execute this as last method of event. It will update Enquiry Stage time field to ensure field value goes as part of CDC
        opths.setStageTime(ConstantsUtility.OPPORTUNITY_VEHICLE_SALES_RECORDTYPE);

        //executes when Reatil Cancellation Date on Enquiry gets populated
        opths.changeEnquiryStage();

        //Run the method to ensure that the Enquiry Name is always Customer Name _ RecordType
        opths.updateEnquiryName(ConstantsUtility.NEWCAR_ENQ);

        //Method to count the variant changes on enquiry.
        opths.populateVariantChangesCount();

        opths.changeBookingAndRetailDate();

        //send employer status to enq owner
        opths.notifyEnqOwnerAboutEmployerStatus();
        opths.uniquenessCheck();
    }

    public void afterInsert(list < Opportunity > oppList, Map < Id, Opportunity > newOppMap, Map < Id, Opportunity > oldoppMap) {


        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/

        opths = OpportunityTriggerStrategyHelper.getInstance(oppList, newOppMap, oldoppMap);
		opths.assignNAVEnquiryToRestofDealerHostess();
        //Send notifications to SPOC
        opths.notifySpocForDSEAllocation();

        //This method will create Followup Task for an Enquiry
        opths.createEnquiryFollowUp(preBookingTaskRecordTypeId, ConstantsUtility.PRE_BOOKING_FOLLOWUP, ConstantsUtility.PREBOOKING_FOLLOWUP_TYPE, ConstantsUtility.PREBOOKING_REMINDER_TIME,false);

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


        opths.insertAndUpdateTimeOnCDC();
    }

    public void afterUpdate(list < Opportunity > oppList, Map < Id, Opportunity > newOppMap, Map < Id, Opportunity > oldoppMap) {


        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/

        opths = OpportunityTriggerStrategyHelper.getInstance(oppList, newOppMap, oldoppMap);

        //Update SVOC ID on Enquiry and on Account
        opths.updateFieldsUsingSVOCID();

        /*
        *    Description - To add Opportunity team members under an Enquiry
        *    Parameters - 1 = After Insert, 2 = After Update
        */
        opths.addOpportunityTeamMembers(False, True);
        /*
        *    Description - create MC Communication records on DSE Allocation
        *    Parameters - 1 = After Insert, 2 = After Update
        */
        opths.createMCrecordsOnDSEAllocationOrUntagging(False, True);
        /*
        *    Description - Post chatter message and notification for Escalated Enquiries
        *    Parameters - 1 = After Insert, 2 = After Update
        */
        opths.postChatterMessage(False, True);

        // if stage = "Retail" then all the Followup  will be closed .
        opths.closedFollowup();
        opths.closePreBookingFollowups();
        //create Preliminary Checklist related to acctive RFC
        opths.createPreliminaryChecklist();
        //Booking or Retail gets canceled, the respective RFC will also be marked as canceled and inactive
        opths.canceledActiveRFC();

	opths.retriggerEnquiry();
        opths.insertAndUpdateTimeOnCDC();
        opths.updateRelatedOpenActivity();
    }

}