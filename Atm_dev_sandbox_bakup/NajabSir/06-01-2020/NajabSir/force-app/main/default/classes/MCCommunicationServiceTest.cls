/**
* @File Name          : MCCommunicationServiceTest.cls
* @Description        : Test Class of the apex class 'MCCommunicationService'
* @Author             : Gitika
**/
@IsTest
public class MCCommunicationServiceTest {
    @testSetup static void createTestData() {
        list<User> UserListManager = TestDataFactory.createUserData('Internal','ATM - Corporate Call Centre Agent',null);
        UserListManager[0].MobilePhone='9997898788';
        insert UserListManager;
        list<User> UserList = TestDataFactory.createUserData('Internal','ATM - Corporate Call Centre TL/ Manager',null);
        UserList[0].MobilePhone='9997898789';
        UserList[0].ManagerId=UserListManager[0].id;
        insert UserList;
        list<Product2> Product2List= TestDataFactory.createProducts('Variants',1);
        insert Product2List;
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        list<Account> dealerList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        dealerList[0].Stakeholder_Hierarchy__c = stakeHolderJson;
        insert dealerList;
        list<Category__c> CategoryList= TestDataFactory.createCategories(1,'Primary');
        insert CategoryList;
        List<Recipient_Master__c> RecipientMasterList = TestDataFactory.createRecipientMaster(1,'Sales');
        insert RecipientMasterList;
        List<Recipient_List__c> RecipientList = TestDataFactory.createRecipientList(1,CategoryList[0].id,RecipientMasterList[0].id);
        RecipientList[0].region__c ='C2';
        insert RecipientList;
        Approval_Notification_Setting__c notificationSetting = TestDataFactory.createApprovalNotificationSetting(ConstantsUtility.VOC_NOTIFICATION_DEALER,true);
        notificationSetting.name=ConstantsUtility.VOC_NOTIFICATION_DEALER;
        insert notificationSetting;
        List<Implementation_Strategy__c> ImplementationStrategyRecordList = new List<Implementation_Strategy__c>();
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        Implementation_Strategy__c ImplementationStrategyRecordMSILQuery = TestDataFactory.createImplementation('CaseMSILQueryInternalTriggerServiceImpl','MSIL_Query_Internal');
        Implementation_Strategy__c ImplementationStrategyRecordFeedback = TestDataFactory.createImplementation('CaseQueryFeedbackTriggerServiceImpl','Query_Feedback');
        ImplementationStrategyRecordList.add(ImplementationStrategyRecord);
        ImplementationStrategyRecordList.add(ImplementationStrategyRecordMSILQuery);
        ImplementationStrategyRecordList.add(ImplementationStrategyRecordFeedback);
        insert ImplementationStrategyRecordList;
        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        Id MSIL_Query_InternalRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MSIL_Query_Internal').getRecordTypeId();
        Id Query_FeedbackRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Query_Feedback').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(1, ComplaintRecordType);
        List<case> casesListfeedback = TestDataFactory.createCase(1, Query_FeedbackRecordType);
        List<case> casesListQuery1 = TestDataFactory.createCase(1, Query_FeedbackRecordType);
        List<case> casesListQuery = TestDataFactory.createCase(1, Query_FeedbackRecordType);
        List<case> casesListMSILQuery = TestDataFactory.createCase(1, MSIL_Query_InternalRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'Yes';
            c.Customer_Satisfied_With_FCR__c='No';
            c.Case_Type__c='Complaint';
            c.Business_Area__c='Sales';
            c.Channel__c='Arena';
            c.Dealer_Name__c=dealerList[0].id;
            c.Primary_Category_ID__c=CategoryList[0].id;
            c.Stakeholders_JSON__c=stakeHolderJson;
            c.Selected_Hierarchy_Type__c='sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
            c.Additional_Information__c='Additional_Information__c';
            c.ownerid=UserList[0].id;
            c.model__c='AN';
            c.Variant__c=Product2List[0].id;
        }
        for (case c : casesListfeedback) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'Yes';
            c.Customer_Satisfied_With_FCR__c='No';
            c.Case_Type__c=ConstantsUtility.DEALER_FEEDBACK_CASE_TYPE;
            c.Business_Area__c='Sales';
            c.Channel__c='Arena';
            c.Dealer_Name__c=dealerList[0].id;
            c.Primary_Category_ID__c=CategoryList[0].id;
            c.Stakeholders_JSON__c=stakeHolderJson;
            c.Selected_Hierarchy_Type__c='sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
            c.Additional_Information__c='Additional_Information__c';
            c.ownerid=UserList[0].id;
             c.model__c='AN';
            c.Variant__c=Product2List[0].id;
        }
        casesList.addall(casesListfeedback);
        for (case c : casesListQuery) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'Yes';
            c.Customer_Satisfied_With_FCR__c='Yes';
            c.Case_Type__c='Dealer Query';
            c.Business_Area__c='Sales';
            c.Channel__c='Arena';
            c.Dealer_Name__c=dealerList[0].id;
            c.Primary_Category_ID__c=CategoryList[0].id;
            c.Stakeholders_JSON__c=stakeHolderJson;
            c.Selected_Hierarchy_Type__c='sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
            c.Additional_Information__c='Additional_Information__c';
            c.ownerid=UserList[0].id;
             c.model__c='AN';
            c.Variant__c=Product2List[0].id;
        }
        casesList.addall(casesListQuery);
         for (case c : casesListQuery1) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'Yes';
            c.Customer_Satisfied_With_FCR__c='No';
            c.Case_Type__c='Dealer Query';
            c.Business_Area__c='Sales';
            c.Channel__c='Arena';
            c.Dealer_Name__c=dealerList[0].id;
            c.Primary_Category_ID__c=CategoryList[0].id;
            c.Stakeholders_JSON__c=stakeHolderJson;
            c.Selected_Hierarchy_Type__c='sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
            c.Additional_Information__c='Additional_Information__c';
             c.ownerid=UserList[0].id;
              c.model__c='AN';
            c.Variant__c=Product2List[0].id;
        }
        casesList.addall(casesListQuery1);
        for (case c : casesListMSILQuery) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'Yes';
            c.Customer_Satisfied_With_FCR__c='No';
            c.Case_Type__c='MSIL Query';
            c.Business_Area__c='Sales';
            c.Channel__c='Arena';
            c.Primary_Category_ID__c=CategoryList[0].id;
            c.Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":null,"msilQuery":[{"stakeHolder":"MGR-Brand","refName":"Isha Agnihotri","recordId":"'+Userinfo.getUserId()+'","phone":"","email":"gitika.k@techmatrixconsulting.com"},{"stakeHolder":"MGR-CCC","refName":"Kapil Khanna","recordId":"'+Userinfo.getUserId()+'","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msgp":null,"msds":null,"loyaltyProgram":null,"finance":null,"accessories":null}';
            c.Selected_Hierarchy_Type__c='msilQuery';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
            c.Additional_Information__c='Additional_Information__c';
            c.ownerid=UserList[0].id;
             c.model__c='AN';
            c.Variant__c=Product2List[0].id;
        }
        casesList.addall(casesListMSILQuery);
        insert casesList; 
        casesList[0].Additional_Information__c='Additional_Information__cAdditional_Information__c';
        update  casesList[0]; 
       
    }
    static testMethod void method1() {
        Test.startTest();
        Account acc =[select id from Account];
        Category__c cat =[select id from Category__c];
        string ComplaintId='';
        string QueryFeedbackId='';
        for(case caseRecord : [select id,Case_Type__c,RecordtypeId from case]){
            if(caseRecord.Case_Type__c=='Dealer Query'){
                QueryFeedbackId=caseRecord.id;
            }else if(caseRecord.Case_Type__c=='Complaint'){
               ComplaintId=caseRecord.id; 
            }
            
        }
     
        list<Case_Actions__c> caseActions = new list<Case_Actions__c>();
        list<Case_Actions__c> caseActions1 = new list<Case_Actions__c>();
        list<Case_Actions__c> caseActions2 = new list<Case_Actions__c>();
        
        if(QueryFeedbackId.length()>0){
           caseActions = TestDataFactory.createCaseActions(1, 'Closure', ConstantsUtility.MSIL_QUERY_CLOSURE_CASE_ACTION_RECORD_TYPE_ID,QueryFeedbackId);   
        }
        
        if(ComplaintId.length()>0){
        caseActions1 = TestDataFactory.createCaseActions(1, 'Closure', ConstantsUtility.MSIL_QUERY_CLOSURE_CASE_ACTION_RECORD_TYPE_ID, ComplaintId);
        caseActions2 = TestDataFactory.createCaseActions(1, 'On Hold', ConstantsUtility.MSIL_QUERY_CLOSURE_CASE_ACTION_RECORD_TYPE_ID, ComplaintId);
        caseActions.addall(caseActions1);
        caseActions.addall(caseActions2);   
        }
        
        if(caseActions.size()>0){  
        insert caseActions;  
        }

        Test.stopTest();
    }
    
    static testMethod void method2() {
        
        Test.startTest();   
        Id MSIL_Query_InternalRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MSIL_Query_Internal').getRecordTypeId();
        Category__c cat =[select id from Category__c];
        List<case> casesListMSILQuery = [select id,Region_Code__c,Stakeholders_JSON__c,Selected_Hierarchy_Type__c,RecordtypeId,Tertiary_Category_ID__c,Secondary_Category_ID__c,Primary_Category_ID__c from case where Case_Type__c='MSIL Query'];
        casesListMSILQuery[0].Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":null,"msilQuery":[{"stakeHolder":"MGR-Brand","refName":"Isha Agnihotri","recordId":"'+Userinfo.getUserId()+'","phone":"","email":"gitika.k@techmatrixconsulting.com"},{"stakeHolder":"MGR-CCC","refName":"Kapil Khanna","recordId":"'+Userinfo.getUserId()+'","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msgp":null,"msds":null,"loyaltyProgram":null,"finance":null,"accessories":null}';
        casesListMSILQuery[0].Selected_Hierarchy_Type__c='msilQuery';
        update casesListMSILQuery[0];
        if(casesListMSILQuery.size()>0){
        MCCommunicationService.getStakeHolderMappingForMSILQuery(casesListMSILQuery[0].Stakeholders_JSON__c,casesListMSILQuery[0].Selected_Hierarchy_Type__c);
        MCCommunicationService.mapOfcaseIdWithMapOfStakeHoldersMSILQuery(casesListMSILQuery);
        casesListMSILQuery[0].status='Closed';
        update casesListMSILQuery[0];   
        }

        Test.stopTest();
    }
    static testMethod void method3() {
        Test.startTest();
        list<case> casesList = new list<case>();
         for(case cs : [select id,Additional_Information__c,Status from case where Customer_Satisfied_With_FCR__c='No']){
            cs.Additional_Information__c='Additional_Information__cAdditional_Information__c';
            cs.Status='Closed';
            casesList.add(cs);
        }
        update casesList;
         for(case cs : casesList){
            cs.Status='On Hold';
        }
        update casesList;
         Id businessHourId = label.Business_Hour_Id;
        MCCommunicationService.getNextEscalatedDateTime(businessHourId,system.now(),20);
        Test.stopTest();
    }
}