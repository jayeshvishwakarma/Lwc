@isTest 
public class MCallTriggerHandlerTest {
    @isTest
    private static void unitTest(){
        Test.startTest();
        Implementation_Strategy__c imS = TestDataFactory.createImplementation('CaseMOSCaseTriggerServiceImpl','MOS_Complaints');
        insert imS;
        String caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MOS Case').getRecordTypeId(); 
        List<Product2> product = TestDataFactory.createProducts('Variants',1);
        insert product;
        List<Color_Variant_Master__c> colorVariantMaster = TestDataFactory.createColorVarientRealetdToProduct(1,product[0].id);
        insert colorVariantMaster;
        List<Case> caseList = TestDataFactory.createCase(1, caseRecTypeId);
        caseList[0].Color__c = colorVariantMaster[0].id;
        caseList[0].Vehicle_Model__c = 'CI';
        caseList[0].Model__c = 'CI';
        caseList[0].Variant__c = product[0].id;
        caseList[0].MOS_Case_Source__c = 'M-Call';
        caseList[0].Job_Type__c = 'Accidental';
        caseList[0].MOS_Case_Stage__c = 'Pending for Allocation';
        INSERT caseList;
        
        MCall_Event__c mcEvent = new MCall_Event__c();
        mcEvent.Case__c = caseList[0].Id;
        mcEvent.Event_Trigger_Info__c = 'Test';
        insert mcEvent;
    }
}