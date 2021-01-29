public with sharing class CaseEmailTriggerServiceImpl implements CaseTriggerService{
    CaseTriggerStrategyHelper caseStrat;


    public void beforeInsert(List < Case > newCaseList) {

        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records
        ----------------------------------------------------------------------------------------------*/
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList, null, null, null);
//Method to update the Entitlement Id on the Case Records
        caseStrat.udpateEntitlementDetails();
        //execute this as last method of event. It will update Enquiry Stage time field to ensure field value goes as part of CDC
        caseStrat.updateEmailQueueAndTimeAssignedToAgent();


    }

    public void beforeUpdate(List < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {
        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList, null, newCaseMap, oldCaseMap);
        //This method will check BookingCancellationReason field and update opportunity stage to New if BookingCancellationReason is Post-Pone and previous value of BookingCancellationReason is blank.
        caseStrat.updateEmailQueueAndTimeAssignedToAgent();


    }
    public void afterInsert(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {}
    public void afterUpdate(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {}
}