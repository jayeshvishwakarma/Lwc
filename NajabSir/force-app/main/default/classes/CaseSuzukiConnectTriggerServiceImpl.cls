/**
* @File Name          : CaseDIRTriggerServiceImpl.cls
* @Description        : Strategy, Implementation class for Complaints Record Type.
* @Author             : Sunit Kumar Chand
* @Group              :
* @Last Modified By   : Sunit Kumar Chand
* @Last Modified On   : 05-11-2020
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    05/11/2020, 1:14:54 PM     Sunit Chand            Initial Version

**/
public with sharing class CaseSuzukiConnectTriggerServiceImpl implements CaseTriggerService {
	CaseTriggerStrategyHelper caseStrat;
    public void beforeInsert(List < Case > newCaseList) {
        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records
        ----------------------------------------------------------------------------------------------*/
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList, null, null, null);
        caseStrat.updateEscalationDetails(); //Update Escalation Details
    }
    public void beforeUpdate(List < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {
        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList, null, newCaseMap, oldCaseMap);
        caseStrat.updateEscalationDetails(); //Update Escalation Details
        caseStrat.suzukiConnectUpdate();
     }
    public void afterInsert(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {

        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/

        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null, newCaseMap, oldCaseMap);
        /*
        *    Description - Create MC Communication records for Case Escalations.
        *    Parameters - 1 = After Insert, 2 = After Update
        */
        caseStrat.postChatterAndMCRecordsEscalation();
        
    }
    public void afterUpdate(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {


        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/

        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null, newCaseMap, oldCaseMap);
        /*
        *    Description - Create MC Communication records for Case Escalations.
        *    Parameters - 1 = After Insert, 2 = After Update
        */
        caseStrat.postChatterAndMCRecordsEscalation();
        caseStrat.sendChatterNotificationOnQC();
        MCCommunicationService.suzukiConnectMcRecCreation(newCaseList,oldCaseMap); //Method to create MC record post 4 hr of Case creation
        
    }
}