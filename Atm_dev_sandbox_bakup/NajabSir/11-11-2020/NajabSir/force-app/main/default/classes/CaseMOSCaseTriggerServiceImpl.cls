/**
* @File Name          : CaseMOSCaseTriggerServiceImpl.cls
* @Description        : Strategy, Implementation class for MOS Case Record Type.
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
public without sharing class CaseMOSCaseTriggerServiceImpl implements CaseTriggerService {
    CaseTriggerStrategyHelper caseStrat;
    public void beforeInsert(List <Case> newCaseList) {
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null,null,null);
        CaseTriggerHelper.getData();
        caseStrat.updateFieldsOnMOSCase(true,false,CaseTriggerHelper.getMSAllianzRecord());
        caseStrat.updateCaseMapFields();
    }
    
    public void beforeUpdate(List < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null,newCaseMap,oldCaseMap);
        CaseTriggerHelper.getData();
        CaseTriggerHelper.getStageValidationMetadataRecords();
        caseStrat.updateFieldsOnMOSCase(false,true,CaseTriggerHelper.getMSAllianzRecord());
        
        caseStrat.updateCaseMapFields();
        
    }
    
    public void afterInsert(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {
            caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null,newCaseMap,oldCaseMap);
            CaseTriggerHelper.getCommunicationRecords();
            caseStrat.MOSCaseAfterEvent(true,false,CaseTriggerHelper.getMSAllianzRecord());
    }
    
    public void afterUpdate(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {
            caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null,newCaseMap,oldCaseMap);
            CaseTriggerHelper.getDataForCaseEscalation();
            CaseTriggerHelper.getCommunicationRecords();
            CaseTriggerHelper.getByPassMOSCommunication();
            caseStrat.MOSCaseAfterEvent(false,true,CaseTriggerHelper.getMSAllianzRecord()); 
    }
}