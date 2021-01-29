@isTest
public class AgentWorkTriggerTest {
    @isTest
    static void insertRecords(){
        test.startTest();
        list<ServiceChannel> servChannelList = [SELECT id from ServiceChannel where developerName = 'Case_Service' limit 1];
        Implementation_Strategy__c impObj = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        insert impObj;
        Id complaintRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();
        list<case> caseList = TestDataFactory.createCase(1,complaintRecordTypeId);
        insert caseList;  
        AgentWork agentObj = new AgentWork(WorkItemId = caseList[0].Id,ServiceChannelId = servChannelList[0].Id);
        insert agentObj;
        test.stopTest();
    }
    
}