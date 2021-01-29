/**
* @File Name          : MCCommunicationServiceTest.cls
* @Description        : Test Class of the apex class 'MCCommunicationService'
* @Author             : Gitika
**/
@IsTest
public class dynamicFileUploadControllerTest {
    @testSetup static void createTestData() {
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        list<Account> dealerList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        dealerList[0].Stakeholder_Hierarchy__c = stakeHolderJson;
        insert dealerList;
        list<Category__c> CategoryList= TestDataFactory.createCategories(1,'Primary');
        insert CategoryList;
        List<Implementation_Strategy__c> ImplementationStrategyRecordList = new List<Implementation_Strategy__c>();
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        
        ImplementationStrategyRecordList.add(ImplementationStrategyRecord);
        insert ImplementationStrategyRecordList;
        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(1, ComplaintRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'No';
            c.Case_Type__c='Complaint';
            c.Business_Area__c='Sales';
            c.Channel__c='Arena';
            c.Dealer_Name__c=dealerList[0].id;
            c.Primary_Category_ID__c=CategoryList[0].id;
            c.Stakeholders_JSON__c=stakeHolderJson;
            c.Selected_Hierarchy_Type__c='sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
            c.FCR_Conducted__c = 'Yes' ;
        }
        insert casesList;
    }
    static testMethod void method1() {
        Test.startTest();
        list<case> casesList =[Select Id,OTP_Base_Value__c,Status from Case ];
        dynamicFileUploadController.sendOtp(casesList[0].id);
        casesList[0].OTP_Base_Value__c='234566';
        update casesList[0];
        dynamicFileUploadController.verifyOtp(casesList[0].id,casesList[0].OTP_Base_Value__c,'Resolution Code');
        
        Test.stopTest();
    }
    
    static testMethod void method2() {
        Test.startTest();
        list<case> casesList =[Select Id,Status from Case ];
       
        CaseActionCreation.updateCaseStatusResolved(casesList[0].id);
        
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Closure', ConstantsUtility.CASE_CLOSURE_CASE_ACTION_RECORD_TYPE_ID, casesList[0].Id);
        
        insert caseActions;
        FileUtility__c FileUtilityRecord = TestDataFactory.createFileUtilitySetting('Case_Closure','Case_Closure');
        insert FileUtilityRecord;
        
        List<ContentVersion> cvlist = TestDataFactory.createContentVersion(2,'Closure Mode;Case_Closure');
        
        Insert cvlist;
        list<string> contentdoclist = new list<string>(); 
        
        for(ContentVersion contentver :[SELECT ContentDocumentId FROM ContentVersion] ){
            contentdoclist.add(contentver.ContentDocumentId); 
        }
        List<ContentDocumentLink> ContentDocumentLinklist = new List<ContentDocumentLink>();
        
        for(string str : contentdoclist){
            ContentDocumentLink ContentDocumentLinkrecord1 = TestDataFactory.createContentDocumentLink(str,casesList[0].id);   
            ContentDocumentLinklist.add(ContentDocumentLinkrecord1);
        }
        
        Insert ContentDocumentLinklist;
        
        dynamicFileUploadController.FileWrapper wrapper= new dynamicFileUploadController.FileWrapper();
        List<dynamicFileUploadController.FileWrapper> wrapperList= new List<dynamicFileUploadController.FileWrapper>();
        wrapper.name='test';
        wrapper.documentid=contentdoclist[0];
        wrapperList.add(wrapper);
        string filedata = JSON.serialize(wrapperList);
        update casesList[0];
        string caseDetail = JSON.serialize(casesList[0]);
        
        dynamicFileUploadController.fetchDocumentUploadList(caseActions[0].id,'Case_Closure');
        dynamicFileUploadController.fetchDocumentUploadList(caseActions[0].id,'Legal');
        dynamicFileUploadController.OnUploadFinish(casesList[0].id,filedata,'Closure Mode','Case_Closure',caseDetail,false);
        dynamicFileUploadController.deleteDocList(contentdoclist[0]);
        Test.stopTest();
    }
    static testMethod void method3() {
        Test.startTest();
        list<case> casesList =[Select Id,OTP_Base_Value__c,Status from Case ];
        
        casesList[0].OTP_Base_Value__c='234566';
        casesList[0].OTP_Generated_Time__c=system.now().addminutes(-10);
        update casesList[0];
        dynamicFileUploadController.sendOtp(casesList[0].id);
        
        dynamicFileUploadController.verifyOtp(casesList[0].id,'345678','Resolution Code');
        
        Test.stopTest();
    }
}