@IsTest
public class CaseActionEscalationTimeCtrlTest {
    static testMethod void getEscalationNew() {
        
        Implementation_Strategy__c imS = TestDataFactory.createImplementation('CaseMOSCaseTriggerServiceImpl','MOS_Complaints');
        insert imS;
        Implementation_Strategy__c ImplementationStrategyRecord3 = TestDataFactory.createImplementation('CaseDoNoCallRequestsTriggerServiceImpl','Do_No_Call_Requests');
		insert ImplementationStrategyRecord3;
        
        Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MOS Case').getRecordTypeId(); 
        List<Product2> product = TestDataFactory.createProducts('Variants',1);
        product[0].Model__c = 'CI';
        insert product;
        List<Color_Variant_Master__c> colorVariantMaster = TestDataFactory.createColorVarientRealetdToProduct(1,product[0].id);
        insert colorVariantMaster;
        List<Case> caseList = TestDataFactory.createCase(1, 'MOS_Complaints');
        caseList[0].Color__c = colorVariantMaster[0].id;
        caseList[0].Vehicle_Model__c = 'CI';
        caseList[0].Case_Type__c='MOS';
        caseList[0].Model__c = 'CI';
        
        caseList[0].Variant__c = product[0].id;
        caseList[0].MOS_Case_Source__c = 'M-Call';
        caseList[0].Job_Type__c = 'Accidental';
        caseList[0].MOS_Case_Stage__c = 'Pending for Allocation';
        INSERT caseList;
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, caseList[0].CaseNumber+'-MOS Follow Up',Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByName().get('MOS Escalations').getRecordTypeId(), caseList[0].Id);
        caseActions[0].Escalation_Level__c = 'Red';
        caseActions[0].Escalation_Status__c = 'Active';
        insert caseActions;
        
        list<MC_Communication__c> mcCommunications = TestDataFactory.createMCCommData(1,null);
        mcCommunications[0].Case__c = caseList[0].Id;
        mcCommunications[0].Case_Action__c  = caseActions[0].Id;
        mcCommunications[0].Status__c = 'Queued';
        mcCommunications[0].Counter__c = 1;
        insert mcCommunications;
        
        CaseActionEscalationTimeCtrl.getDetails(caseList[0].id);
        CaseActionEscalationTimeCtrl.getEscalationNew(caseList[0].id);
        
        caseList[0].Escalation_Follow_up__c = null;
        caseList[0].Escalation_Allocation__c = null;
        caseList[0].Escalation_Reach__c = null;
        update caseList;
        
        CaseActionEscalationTimeCtrl.getDetails(caseList[0].id);
        CaseActionEscalationTimeCtrl.getEscalationNew(caseList[0].id);
        
        
    }
}