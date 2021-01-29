@isTest
public class AgentWorkTriggerTest {
    @isTest
    static void insertRecords(){
        
        test.startTest();
       	
        //Id systemUser = [SELECT UserId FROM UserServicePresence  WHERE UserId = :UserInfo.getUserId() LIMIT 1].UserId;
        
        list<ServiceChannel> servChannelList = [SELECT id from ServiceChannel where developerName = 'Case_Service' limit 1];
        Implementation_Strategy__c impObj = TestDataFactory.createImplementation('CaseMOSCaseTriggerServiceImpl','MOS_Complaints');
        insert impObj;
        //Id complaintRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MOS_Complaints').getRecordTypeId();
        List<Product2> product = TestDataFactory.createProducts('Variants',2);
        insert product;
        List<Color_Variant_Master__c> colorVariantMaster = TestDataFactory.createColorVarientRealetdToProduct(1,product[0].id);
        insert colorVariantMaster;
        
        list<case> caseList = TestDataFactory.createCase(1,ConstantsUtility.MOS_COMPLAINT_CASE_RECORD_TYPE_ID);
        caseList[0].Color__c = colorVariantMaster[0].id;
        caseList[0].ETA_Time__c = DateTime.now() +1;
        caseList[0].Vehicle_Model__c = 'CI';
        caseList[0].Model__c = 'CI'; 
        caseList[0].Variant__c = product[0].id;
        caseList[0].MOS_Case_Source__c = ConstantsUtility.MOSCaseSourceMCall;
        caseList[0].Job_Type__c = 'Accidental';
        caseList[0].MOS_Case_Stage__c = 'Out for Service';
        caseList[0].ownerId = UserInfo.getUserId();
        insert caseList;  
        
        list<Case_Actions__c> caseActionsOnHold = TestDataFactory.createCaseActions(1, 'Closure', ConstantsUtility.ON_HOLD_CASE_ACTION_RECORD_TYPE_ID, caseList[0].Id);
        
        AgentWork agentObj = new AgentWork(WorkItemId = caseList[0].Id,ServiceChannelId = servChannelList[0].Id,UserId = UserInfo.getUserId());
        insert agentObj;
        
        test.stopTest();  
    }
    


}