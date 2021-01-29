/**
* @File Name          : CaseMOSCaseTriggerServiceImpl.cls
* @Description        : Strategy, Implementation class for Vehicle Type.
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
public without sharing class CaseVehicleServiceTriggerServiceImpl implements CaseTriggerService{
    CaseTriggerStrategyHelper caseStrat;
    public void beforeInsert(List <Case> newCaseList) {
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null,null,null);
        caseStrat.updateSubject();
    }
    
    public void beforeUpdate(List < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null,newCaseMap,oldCaseMap);
        caseStrat.updateCaseReasonForLost(); //To be checked.
    }
    
    public void afterInsert(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null,newCaseMap,oldCaseMap); 
        caseStrat.shareCustomerRecord();
        caseStrat.caseTeamCreation();
		  //Added 5th Nov 2020
        caseStrat.addCaseTeamMembers();
    }
    
    public void afterUpdate(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null,newCaseMap,oldCaseMap); 
        caseStrat.caseTeamCreation();
		  //Added 5th Nov 2020
        caseStrat.addCaseTeamMembers();
    }
}