public without sharing class CaseQueryFeedbackTriggerServiceImpl implements CaseTriggerService{
    CaseTriggerStrategyHelper caseStrat;


    public void beforeInsert(List < Case > newCaseList) {

        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records
        ----------------------------------------------------------------------------------------------*/
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList, null, null, null);

        caseStrat.updateUserAccountonCase();

        caseStrat.udpateEntitlementDetails();

        CaseAssignmentService.assignCasesToStakeHolders(newCaseList, null);
        //Update Close date on Enquiry from current plus 3 months date
        caseStrat.updateEscalationDetails();

        //The standard account field will be updated based on the user account record defined for partner users
        //This will enable the visibility of enquiry records based on the Account team defined under the user Account
        caseStrat.markOrFilterQueryAsSpam();

        //Update Escalation Fields based on Escalation Matrix
        //This will the populate the notifiers for each levels for both allocated and unallocated enquiries
        caseStrat.populateL3AL4AndStatus();

        //execute this as last method of event. It will update Enquiry Stage time field to ensure field value goes as part of CDC
        caseStrat.updateEmailQueueAndTimeAssignedToAgent();
       


    }

    
    public void beforeUpdate(List < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {
        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList, null, newCaseMap, oldCaseMap);
        // Call relevant methods in OpportunityTriggerHelper/Handler
        caseStrat.updateUserAccountonCase();

        // populateExchangeVehicleEvaluator
        caseStrat.updateCaseResolutionTime();

        //Populate Previous owner on Enquiry
        CaseAssignmentService.assignCasesToStakeHolders(newCaseList, oldCasemap);

        //Prevent mulesoft user from changing status back to New
        caseStrat.updatePreviousOwner();

        //Update Escalation Fields based on Escalation Matrix
        caseStrat.updateEscalationDetails();

        //This method will check BookingCancellationReason field and update opportunity stage to New if BookingCancellationReason is Post-Pone and previous value of BookingCancellationReason is blank.
        caseStrat.updateEmailQueueAndTimeAssignedToAgent();

        //execute this as last method of event. It will update Enquiry Stage time field to ensure field value goes as part of CDC
        caseStrat.populateL3AL4AndStatus();

        //Run the method to ensure that the Enquiry Name is always Customer Name _ RecordType
        caseStrat.populateCustomerBasedOnSVOCId();
        caseStrat.updateQCInfo();
 
    }
    
    public void afterInsert(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {

        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/

        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null, newCaseMap, oldCaseMap);

        //Send notifications to SPOC
        CaseSharingService.shareCaseToMembers(newCaseList);

        //This method will create Followup Task for an Enquiry
        caseStrat.postChatterAndMCRecordsEscalation();

        caseStrat.markQueryAsSpam();
        caseStrat.createMCRecordsForATM();       
    }


    public void afterUpdate(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {


        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null, newCaseMap, oldCaseMap);

        //Update SVOC ID on Enquiry and on Account
        CaseSharingService.shareCaseToMembers(newCaseList);
        /*
        *    Description - To add Opportunity team members under an Enquiry
        *    Parameters - 1 = After Insert, 2 = After Update
        */
        caseStrat.postChatterAndMCRecordsEscalation();
        /*
        *    Description - create MC Communication records on DSE Allocation
        *    Parameters - 1 = After Insert, 2 = After Update
        */
        caseStrat.sendChatterNotificationOnQC();
        /*
        *    Description - Post chatter message and notification for Escalated Enquiries
        *    Parameters - 1 = After Insert, 2 = After Update
        */
        caseStrat.markMcCommunicationCancelled();
        caseStrat.createMCRecordsForATM();  
        
    }
}