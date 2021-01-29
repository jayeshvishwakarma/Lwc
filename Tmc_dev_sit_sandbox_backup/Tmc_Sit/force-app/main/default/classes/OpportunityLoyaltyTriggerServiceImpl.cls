/**
* @File Name          : OpportunityLoyaltyTriggerServiceImpl.cls
* @Description        : Strategy, Implementation class for Loyalty Enrollment Record Type.
* @Author             : Anuj Kumar
* @Group              :
* @Last Modified By   : Anuj Kumar
* @Last Modified On   : 06/07/2020, 1:14:54 PM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    01/07/2020, 1:14:54 PM     Nitish Bansal            Initial Version

**/
public without sharing class OpportunityLoyaltyTriggerServiceImpl  implements OpportunityTriggerService {
    
    OpportunityTriggerStrategyHelper opths;
    
    private static String LoyalityEnrolmentFollowUpTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(ConstantsUtility.Loyality_Enrolment_FollowUp_RECORDTYPE).getRecordTypeId();

    public void beforeInsert(List < Opportunity > newOppList) {
        
         /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records
        ----------------------------------------------------------------------------------------------*/
        
        opths = OpportunityTriggerStrategyHelper.getInstance(newOppList, null, null);
    
        opths.setStandardPriceBook();
        
        opths.updateGenderAndCustomerType();
        
        //The standard account field will be updated based on the user account record defined for partner users
        //This will enable the visibility of enquiry records based on the Account team defined under the user Account
        opths.updateDealerAndStandardAccount();
        
        //execute this as last method of event. It will update Enquiry Stage time field to ensure field value goes as part of CDC
        opths.setStageTime(ConstantsUtility.OPPORTUNITY_LOYALTY_RECORDTYPE);
        
        //Run the method to ensure that the Enquiry Name is always Customer Name _ RecordType
        opths.updateEnquiryName(ConstantsUtility.NEWLOYALTY_ENQ);
        
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
        //opths.setStandardPriceBook(oppList);
        
        // Call relevant methods in OpportunityTriggerHelper/Handler
        opths.updateGenderAndCustomerType();
        
        //The standard account field will be updated based on the user account record defined for partner users
        //This will enable the visibility of enquiry records based on the Account team defined under the user Account
        opths.updateDealerAndStandardAccount();
        
        //Populate Previous owner on Enquiry
        opths.updatePreviousOwneronEnquiry();
        
        //Prevent mulesoft user from changing status back to New
        opths.preventWrongStageChange();
        
        //execute this as last method of event. It will update Enquiry Stage time field to ensure field value goes as part of CDC
        opths.setStageTime(ConstantsUtility.OPPORTUNITY_LOYALTY_RECORDTYPE);
        
        //executes when Reatil Cancellation Date on Enquiry gets populated
        opths.changeEnquiryStage();
        
        //Run the method to ensure that the Enquiry Name is always Customer Name _ RecordType
        opths.updateEnquiryName(ConstantsUtility.NEWLOYALTY_ENQ);
        opths.uniquenessCheck(); 
    }
    public void afterInsert(list < Opportunity > oppList, Map < Id, Opportunity > newOppMap, Map < Id, Opportunity > oldoppMap) {
        
        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/
        
        opths = OpportunityTriggerStrategyHelper.getInstance(oppList, newOppMap, oldoppMap);
        
        //This method will create Followup Task for an Enquiry
        opths.createEnquiryFollowUp(LoyalityEnrolmentFollowUpTaskRecordTypeId, '', ConstantsUtility.Loyality_Task_TYPE, 0 ,true);
        
        /*
        *    Description - To add Opportunity team members under an Enquiry
        *    Parameters - 1 = After Insert, 2 = After Update
        */
        opths.addOpportunityTeamMembers(True, False);
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
        opths.retriggerEnquiry();
        opths.insertAndUpdateTimeOnCDC();
		opths.updateRelatedOpenActivity();
    }
}