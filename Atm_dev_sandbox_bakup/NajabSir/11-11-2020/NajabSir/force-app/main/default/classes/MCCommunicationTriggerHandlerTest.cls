/**
* @File Name          : MCCommunicationTriggerHandlerTest.cls
* @Description        : Test Class of the apex class 'MCCommunicationTriggerHandler'
* @Author             : Deepak Kumar
**/
@IsTest
private class MCCommunicationTriggerHandlerTest {
    @testSetup static void createTestData() {
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Transfer', ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID, null);
        caseActions[0].Transfer_Escalation_Date_Time__c =  Datetime.now();
        insert caseActions;
        list<MC_Communication__c> mcCommunications = TestDataFactory.createMCCommData(1,null);
        for(MC_Communication__c mcCommunication:mcCommunications){
            mcCommunication.Type__c = ConstantsUtility.TRANSFER_ESCALATION_MC_TYPE;
            mcCommunication.Escalation_Date_Time__c = Datetime.now().addHours(1);
            mcCommunication.Case_Action__c = caseActions[0].Id;
            mcCommunication.Internal_User__c = UserInfo.getUserId();
        }
        insert mcCommunications;
    }
    
    static testMethod void caseEscalationsFieldUpdateTest() {
        Test.startTest();
        List<MC_Communication__c> mcCommunications = [SELECT Id,Status__c FROM MC_Communication__c WHERE Type__c =: ConstantsUtility.TRANSFER_ESCALATION_MC_TYPE LIMIT 1];
        mcCommunications[0].Status__c = ConstantsUtility.MC_Communication_Status_Picked;
        update mcCommunications;
        Test.stopTest();
    }
    
    //Added by Anas Yar Khan
    static testMethod void updateEscalationLevelOnCaseActionTest() {
        Test.startTest();
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        Implementation_Strategy__c imS = TestDataFactory.createImplementation('CaseMOSCaseTriggerServiceImpl','MOS_Complaints');
        insert imS;
        list<Account> dealerList = TestDataFactory.createBusinessAccount(3, 'Dealer'); 
        dealerList[0].Name = ConstantsUtility.MOS_MASTER_MS_ALLIANZ;
        dealerList[0].MOS_Category__c = 'MOS';
        dealerList[0].Stakeholder_Hierarchy__c = stakeHolderJson;
        dealerList[1].Name = 'Towing User';
        dealerList[1].Stakeholder_Hierarchy__c = stakeHolderJson;
        dealerList[1].MOS_Category__c = 'MOS';
        dealerList[2].Name = 'Towing User 2';
        dealerList[2].MOS_Category__c = 'MOS';
        dealerList[2].Stakeholder_Hierarchy__c = stakeHolderJson;
        insert dealerList;
        List<Contact> conList1 = TestDataFactory.createTestContact(2, dealerList[0].Id);
        conList1[0].Designation__c = 'Team Leader';
        conList1[0].Phone = '7890789056';
        insert conList1;
        
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
        caseList[0].MOS_Case_Stage__c = 'Pending for Out for Service';
        caseList[0].Allocated_Dealer__c = dealerList[0].Id;
        caseList[0].Technician_Id__c = conList1[0].Id;
        INSERT caseList;
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'MOS Follow Up',Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByName().get('MOS Escalations').getRecordTypeId(), caseList[0].Id);
        caseActions[0].Escalation_Level__c = 'Red';
        insert caseActions;
        list<MC_Communication__c> mcCommunications = TestDataFactory.createMCCommData(1,null);
        mcCommunications[0].Case__c = caseList[0].Id;
        mcCommunications[0].Case_Action__c  = caseActions[0].Id;
        mcCommunications[0].Status__c = 'Queued';
        mcCommunications[0].Counter__c = 1;
        insert mcCommunications;
        mcCommunications[0].Status__c = 'Picked';
        update mcCommunications;
        Test.stopTest();
    }
    
    
}