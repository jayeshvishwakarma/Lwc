/**
* @File Name          : CaseMOSCaseTriggerServiceImpl.cls
* @Description        : Strategy, Implementation class for MI Renewal Record Type.
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
public without sharing class CaseMIRenewalTriggerServiceImpl implements CaseTriggerService{
    CaseTriggerStrategyHelper caseStrat;
    public void beforeInsert(List <Case> newCaseList) {
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null,null,null);
        caseStrat.updateSubject();
    }
    
    public void beforeUpdate(List < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null,newCaseMap,oldCaseMap);
        caseStrat.updateCaseReasonForLost();
    }
    
    public void afterInsert(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null,newCaseMap,oldCaseMap); 
        caseStrat.shareCustomerRecord();
        caseStrat.caseTeamCreation();
    }
    
    public void afterUpdate(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null,newCaseMap,oldCaseMap);
        caseStrat.updateRelatedCaseTasks();
        caseStrat.caseTeamCreation();
    }
}