/**
* @File Name          : CaseInternalTriggerServiceImpl.cls
* @Description        : Strategy, Implementation class for Internal Case Type.
* @Author             : Anas Yar Khan
* @Group              :
* @Last Modified By   : Anas Yar Khan
* @Last Modified On   : 06/07/2020, 1:14:54 PM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    01/07/2020, 1:14:54 PM     Prabhat Sharma            Initial Version
**/
public without sharing class CaseInternalTriggerServiceImpl implements CaseTriggerService{
    CaseTriggerStrategyHelper caseStrat;
    
    
    public void beforeInsert(List < Case > newCaseList) {
        
        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of CaseTriggerStrategyHelper class
        params          New List of Case Records
        ----------------------------------------------------------------------------------------------*/
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList, null, null, null);
        
        
        //Method to filter out queries/cases which are marked as spam as Mobile or Email
        caseStrat.markOrFilterQueryAsSpam();
        
        
        //Changes the Queue assignment of Cases basis Queue assignment matrix
        caseStrat.updateEmailQueueAndTimeAssignedToAgent();
        
        //Run the method to ensure that the Enquiry Name is always Customer Name _ RecordType
        caseStrat.updateExternalStakeHolder();

        //Run the method to Copy the customer address to case
        caseStrat.copyCustomerAddressOnCase();
    }
    

    public void beforeUpdate(List < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {
        
        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of CaseTriggerStrategyHelper class
        params          New List of Case Records
        ----------------------------------------------------------------------------------------------*/
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList, null, newCaseMap, oldCaseMap);
        
        //Add Methods for Before Update use cases here
        // This Method Will Update QA details
        caseStrat.updateQCInfo();

        
    }
    

    public void afterInsert(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {
        
        
        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of CaseTriggerStrategyHelper class
        params          New List of Case Records
        ----------------------------------------------------------------------------------------------*/
        
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null, newCaseMap, oldCaseMap);
        
        caseStrat.markQueryAsSpam();
        
    }
    
    
    public void afterUpdate(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {
        
        
        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of CaseTriggerStrategyHelper class
        params          New List of Case Records
        ----------------------------------------------------------------------------------------------*/
        
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null, newCaseMap, oldCaseMap);
        
        //Add Methods for After Update use cases here
        
        
    }
}