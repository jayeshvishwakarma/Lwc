/**
* @File Name          : CaseActionsTrigger_Test.cls
* @Description        : Test Class of the apex class 'CaseActionsTriggerHandler'
* @Author             : Prabhat Sharma
**/
@IsTest
public class CaseActionsTrigger_Test {
    @testSetup static void createTestData() {
        // Added BY Deepak
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl', 'Complaint');
        insert ImplementationStrategyRecord;
        Implementation_Strategy__c imS = TestDataFactory.createImplementation('CaseMOSCaseTriggerServiceImpl','MOS_Complaints');
        insert imS;
        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        list<Account> businessAccountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        businessAccountList[0].Stakeholder_Hierarchy__c = stakeHolderJson;
        insert businessAccountList;
        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(2, ComplaintRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.Customer__c = personAccountList[0].Id;
            c.Dealer_Name__c = businessAccountList[0].Id;
            c.Stakeholders_JSON__c = stakeHolderJson;
            c.Selected_Hierarchy_Type__c = 'sales';
            c.FCR_Conducted__c = 'Yes';
            c.Origin = ConstantsUtility.EMAIL;
        }
        insert casesList;
        List<Approval_Notification_Setting__c> approval_notification_settings = new List<Approval_Notification_Setting__c>();
        Approval_Notification_Setting__c notificationSetting = TestDataFactory.createApprovalNotificationSetting(ConstantsUtility.Recordtype_On_Hold, true);
        notificationSetting.Name = 'T1';
        approval_notification_settings.add(notificationSetting);
        Approval_Notification_Setting__c notificationSetting2 = TestDataFactory.createApprovalNotificationSetting(ConstantsUtility.Recordtype_On_Hold_Service, true);
        notificationSetting2.Name = 'T2';
        approval_notification_settings.add(notificationSetting2); 
        insert approval_notification_settings;
        
    }
    
    static testmethod void closureFormChanged_test() {
        Test.startTest();
        List<Case> caseList = [SELECT Id FROM Case LIMIT 1];
        List<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(2, 'NCH Legal', ConstantsUtility.ON_HOLD_SERVICE_CASE_ACTION_RECORD_TYPE_ID, caseList[0].Id);
        for (Case_Actions__c caseAction : caseActions) {
            caseAction.Approval_Status__c = 'Approved';
            caseAction.Channel__c = 'Arena';
            caseAction.Case_Type__c = 'Complaint';
            caseAction.Business_Area__c = 'Sales';
            caseAction.Case_Stage__c = 'Pre Sales';
            caseAction.Primary_Category__c = 'Sales Initiation';
            caseAction.Secondary_Category__c = 'Dirty Washroom';
            caseAction.Hold_Till_Date__c = System.today();
            caseAction.Region_Code__c = 'C1';
            caseAction.Case_Source__c = 'NCH';
            caseAction.FCR_Conducted__c = 'No';
            caseAction.Dealer_Code__c = '0813';
            caseAction.Zone__c = 'Central';
            caseAction.Issue_Description__c = 'test';
            caseAction.Gaps_Identified__c = 'Test1';
            caseAction.Action_Taken__c = 'Test2';
            caseAction.Counter_Measure_at_Dealer_Level__c = 'test4';
            caseAction.Timeline_For_Implementation__c = 'test5';
            caseAction.Counter_Measure_at_RO_Level__c = 'test5';
            caseAction.Closure_Form_Not_Changed__c = true;
        }
        caseActions[1].L5_Stakeholder__c = userinfo.getUserId();
        caseActions[1].Hold_Start_Date__c = system.today();
        caseActions[1].Hold_Till_Date__c = system.today() + 12;
        insert caseActions;
        Test.stopTest();
    }
    
    static testmethod void sendChatterNotificationCCPnotResponded_Test() {
        Test.startTest();
        List<Case> caseList = [SELECT Id FROM Case LIMIT 1];
        List<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'NCH Legal', ConstantsUtility.CCP_NOT_RESPONDED_CASE_ACTION_RECORD_TYPE_ID, caseList[0].Id);
        for (Case_Actions__c caseAction : caseActions) {
            caseAction.Approval_Status__c = 'Approved';
            caseAction.Channel__c = 'Arena';
            caseAction.Case_Type__c = 'Complaint';
            caseAction.Business_Area__c = 'Sales';
            caseAction.Case_Stage__c = 'Pre Sales';
            caseAction.Primary_Category__c = 'Sales Initiation';
            caseAction.Secondary_Category__c = 'Dirty Washroom';
            caseAction.Hold_Till_Date__c = System.today();
            caseAction.Region_Code__c = 'C1';
            caseAction.Case_Source__c = 'NCH';
            caseAction.FCR_Conducted__c = 'No';
            caseAction.Dealer_Code__c = '0813';
            caseAction.Zone__c = 'Central';
            caseAction.Issue_Description__c = 'test';
            caseAction.Gaps_Identified__c = 'Test1';
            caseAction.Action_Taken__c = 'Test2';
            caseAction.Counter_Measure_at_Dealer_Level__c = 'test4';
            caseAction.Timeline_For_Implementation__c = 'test5';
            caseAction.Counter_Measure_at_RO_Level__c = 'test5';
            caseAction.Closure_Form_Not_Changed__c = true;
            caseAction.L3A_Stakeholder__c = userinfo.getUserId();
        }
        insert caseActions;
        Test.stopTest();
    }
    static testmethod void methodToUpdateCaseOnHoldWhenloggedInL3L5_Test() {
        Test.startTest();
        List<Case> caseList = [SELECT Id FROM Case LIMIT 1];
        List<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(4, 'NCH Legal', ConstantsUtility.ON_HOLD_CASE_ACTION_RECORD_TYPE_ID, caseList[0].Id);
        for (Case_Actions__c caseAction : caseActions) {
            caseAction.Approval_Status__c = 'In Progress';
            caseAction.Channel__c = 'Arena';
            caseAction.Case_Type__c = 'Complaint';
            caseAction.Business_Area__c = 'Sales';
            caseAction.Case_Stage__c = 'Pre Sales';
            caseAction.Primary_Category__c = 'Sales Initiation';
            caseAction.Secondary_Category__c = 'Dirty Washroom';
            caseAction.Region_Code__c = 'C1';
            caseAction.Case_Source__c = 'NCH';
            caseAction.FCR_Conducted__c = 'No';
            caseAction.Dealer_Code__c = '0813';
            caseAction.Zone__c = 'Central';
            caseAction.Issue_Description__c = 'test';
            caseAction.Gaps_Identified__c = 'Test1';
            caseAction.Action_Taken__c = 'Test2';
            caseAction.Counter_Measure_at_Dealer_Level__c = 'test4';
            caseAction.Timeline_For_Implementation__c = 'test5';
            caseAction.Counter_Measure_at_RO_Level__c = 'test5';
            caseAction.Closure_Form_Not_Changed__c = true;
            caseAction.Hold_Start_Date__c = system.today();
        }
        caseActions[0].L3A_Stakeholder__c = userinfo.getUserId();
        caseActions[0].Hold_Till_Date__c = system.today() + 14;
        caseActions[1].L3A_Stakeholder__c = userinfo.getUserId();
        caseActions[1].Hold_Till_Date__c = system.today() + 27;
        caseActions[1].Reason_For_Hold__c = ConstantsUtility.Delay_in_RC_due_to_RTO_Issue;
        caseActions[2].L4_Stakeholder__c = userinfo.getUserId();
        caseActions[2].Hold_Till_Date__c = system.today() + 27;
        caseActions[3].L5_Stakeholder__c = userinfo.getUserId();
        caseActions[3].Hold_Till_Date__c = system.today();
        insert caseActions;
        caseActions[0].Approval_Status__c = ConstantsUtility.CASE_ACTION_APPROVAL_STATUS_APPROVED ;
        caseActions[0].RecordTypeId = ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID ;
        caseActions[0].Transferred_Dealer_Approver__c = userinfo.getUserId();
        update caseActions ;
        Test.stopTest();
    }
    static testmethod void methodToUpdateCaseOnHoldWhenloggedInL3L5_Test1() {
        Test.startTest();
        List<Case> caseList = [SELECT Id FROM Case LIMIT 1];
        List<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(2, 'NCH Legal', ConstantsUtility.ON_HOLD_CASE_ACTION_RECORD_TYPE_ID, caseList[0].Id);
        for (Case_Actions__c caseAction : caseActions) {
            caseAction.Approval_Status__c = 'Approved';
            caseAction.Channel__c = 'Arena';
            caseAction.Case_Type__c = 'Complaint';
            caseAction.Business_Area__c = 'Sales';
            caseAction.Case_Stage__c = 'Pre Sales';
            caseAction.Primary_Category__c = 'Sales Initiation';
            caseAction.Secondary_Category__c = 'Dirty Washroom';
            caseAction.Hold_Till_Date__c = System.today();
            caseAction.Hold_Till_Date__c = System.today() + 20;
            caseAction.Region_Code__c = 'C1';
            caseAction.Case_Source__c = 'NCH';
            caseAction.FCR_Conducted__c = 'No';
            caseAction.Dealer_Code__c = '0813';
            caseAction.Zone__c = 'Central';
            caseAction.Issue_Description__c = 'test';
            caseAction.Gaps_Identified__c = 'Test1';
            caseAction.Action_Taken__c = 'Test2';
            caseAction.Counter_Measure_at_Dealer_Level__c = 'test4';
            caseAction.Timeline_For_Implementation__c = 'test5';
            caseAction.Counter_Measure_at_RO_Level__c = 'test5';
            caseAction.Closure_Form_Not_Changed__c = true;
            caseAction.Reason_For_Hold__c = ConstantsUtility.Delay_in_RC_due_to_RTO_Issue;
            caseAction.L3A_Stakeholder__c = userinfo.getUserId();
        }
        caseActions[1].RecordTypeId = ConstantsUtility.MSIL_QUERY_CLOSURE_CASE_ACTION_RECORD_TYPE_ID;
        insert caseActions;
        Test.stopTest();
    }
    static testMethod void method3() {
        Test.startTest();
        List<Case> caseList = [SELECT Id FROM Case LIMIT 1];
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Closure123', ConstantsUtility.DNE_CASE_ACTION_RECORD_TYPE_ID, caseList[0].Id);
        group g1 = [
            SELECT Id, Name, DeveloperName, Email, Type
            FROM Group
            where Type = :ConstantsUtility.QUEUE
            And DeveloperName = :ConstantsUtility.ASSIGNMENT_QUEUE
        ];
        caseActions[0].Current_Approver__c = g1.id;
        caseActions[0].ownerid = userinfo.getUserId();
        insert caseActions;
        Test.stopTest();
    }
    static testmethod void insertSpamRecord_Test() {
        Test.startTest();
        List<Case> caseList = [SELECT Id FROM Case LIMIT 1];
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Closure123', ConstantsUtility.SPAM_CASE_ACTION_RECORD_TYPE_ID, caseList[0].Id);
        insert caseActions;
        caseActions[0].Approval_Status__c = ConstantsUtility.CASE_ACTION_APPROVAL_STATUS_APPROVED ;
        update caseActions;
        //caseActions[0].RecordtypeId = ConstantsUtility.LEGAL_CASE_ACTION_RECORD_TYPE_ID;
        //update caseActions;  
        Spam_Phone_Emails__c spam = new Spam_Phone_Emails__c();
        spam.RecordTypeId = ConstantsUtility.EMAIL_SPAM_RECORD_TYPE_ID ;
        spam.Email__c = 'test@gmail.com';
        spam.Phone_No__c = '9760332056';
        spam.From_Date__c = system.today() ;
        spam.To_Date__c = system.today() + 2 ;
        insert spam;
        Test.stopTest();
    }
    
    /**************************** Test Methods Created By Deepak START************************************************/
    static testmethod void createTransferredChildCase_Test() {
        Test.startTest();
        List<Case> caseList = [SELECT Id FROM Case LIMIT 1];
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Transfer', ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID, caseList[0].Id);
        insert caseActions;
        caseActions[0].Approval_Status__c = ConstantsUtility.CASE_ACTION_APPROVAL_STATUS_APPROVED ;
        caseActions[0].RecordTypeId = ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID;
        update caseActions;
        Test.stopTest();
    }
    //updateApprovalNotifiers  - Covered
    static testmethod void sendChatterNotificationToApprovers_Test() {
        Test.startTest();
        List<Case> caseList = [SELECT Id FROM Case LIMIT 2];
        
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(2, 'Duplicate', ConstantsUtility.DUPLICATE_CASE_ACTION_RECORD_TYPE_ID, caseList[0].Id);
        caseActions[0].Original_Complaint_No__c = caseList[1].Id;
        caseActions[0].Approved_Rejection_Notifiers__c = 'Test';
        caseActions[0].Approval_Status__c = ConstantsUtility.In_Progress;
        caseActions[0].Approval_Chatter_Message__c = 'TEST MESSAGE';
        caseActions[0].Approval_Notifiers__c = 'L3A,L4';
        insert caseActions;
        caseActions[0].Approval_Status__c = ConstantsUtility.Rejected;
        update caseActions;
        Test.stopTest();
    }
    //updateCaseMileStone  - Covered
    //validationForDuplicateCaseActions  - Covered
    static testmethod void updateDealerTransferStakeHolders_Test() {
        
        Test.startTest();
        List<Category__c> primaryCategories = TestDataFactory.createCategories(1, 'Primary');
        insert primaryCategories;
        List<Recipient_Master__c> RecipientMasterList = TestDataFactory.createRecipientMaster(1,'Sales');
        insert RecipientMasterList;
        //List<Recipient_List__c> RecipientList = TestDataFactory.createRecipientList(1,primaryCategories[0].id,RecipientMasterList[0].id);
        //RecipientList[0].region__c ='C2';
        //insert RecipientList;
        Account dealer = [SELECT Id FROM Account WHERE RecordType.Name = :ConstantsUtility.DEALER_RECORDTYPE LIMIT 1];
        List<Case> caseList = [SELECT Id FROM Case LIMIT 1];
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(2, 'Transfer', ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID, caseList[0].Id);
        for (Case_Actions__c caseAction : caseActions) {
            caseAction.Channel__c = ConstantsUtility.ARENA_CASE_CHANNEL;
            caseAction.Case_Type__c = ConstantsUtility.COMPLAINT_CASE_TYPE;
            caseAction.Business_Area__c = ConstantsUtility.SALES_CASE_BUSINESS_AREA;
            caseAction.Region_Code__c = 'C1';
            caseAction.Approved_Rejection_Notifiers__c = 'Test';
            caseAction.Approval_Status__c = ConstantsUtility.In_Progress;
            caseAction.Approval_Chatter_Message__c = 'TEST MESSAGE';
            caseAction.Approval_Notifiers__c = 'L3A,L4';
            caseAction.Dealer_Name__c = dealer.Id;
            caseAction.Dealership_ID__c = dealer.Id;
            caseAction.Primary_Category_ID__c = primaryCategories[0].Id;
        }
        caseActions[1].Business_Area__c = ConstantsUtility.SERVICE_BODYSHOP_CASE_BUSINESS_AREA;
        /*caseActions[2].Business_Area__c = ConstantsUtility.SERVICE_WORKSHOP_CASE_BUSINESS_AREA;
caseActions[3].Business_Area__c = ConstantsUtility.SERVICE_CASE_BUSINESS_AREA;
caseActions[4].Business_Area__c = ConstantsUtility.ACCESSORIES_CASE_BUSINESS_AREA;
caseActions[5].Business_Area__c = ConstantsUtility.LOYALTY_PROGRAM_CASE_BUSINESS_AREA;
caseActions[6].Business_Area__c = ConstantsUtility.FINANCE_CASE_BUSINESS_AREA;
caseActions[7].Business_Area__c = ConstantsUtility.INTERNATIONAL_MARKETING_EXPORTS_CASE_BUSINESS_AREA;
caseActions[8].Business_Area__c = ConstantsUtility.DOMESTIC_CASE_BUSINESS_AREA;
caseActions[9].Business_Area__c = ConstantsUtility.MIBPL_CASE_BUSINESS_AREA;
caseActions[10].Business_Area__c = ConstantsUtility.SUZUKI_MOTORCYCLES_CASE_BUSINESS_AREA;
caseActions[11].Business_Area__c = ConstantsUtility.INTERNAL_CASE_BUSINESS_AREA;
caseActions[12].Business_Area__c = ConstantsUtility.DRIVING_SCHOOL_CASE_BUSINESS_AREA;
caseActions[13].Business_Area__c = ConstantsUtility.BUYER_CASE_BUSINESS_AREA;
caseActions[14].Business_Area__c = ConstantsUtility.SELLER_EXCHANGE_CASE_BUSINESS_AREA;*/
        insert caseActions;
        caseActions[0].Business_Area__c = ConstantsUtility.ACCESSORIES_CASE_BUSINESS_AREA;
        
        Test.stopTest();
        
    }
    static testmethod void updateCaseAccessForTransferCaseActions_Test() {
        Test.startTest();
        List<Case> caseList = [SELECT Id FROM Case LIMIT 1];
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(2, 'Transfer', ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID, caseList[0].Id);
        insert caseActions;
        List<User> internalUsers = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{
        });
        insert internalUsers;
        caseActions[0].Transferred_Dealer_Approver__c = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() LIMIT 1].Id;
        caseActions[0].Current_Approver__c = caseActions[0].Transferred_Dealer_Approver__c;
        caseActions[0].L4_Stakeholder__c = internalUsers[0].id;
        caseActions[0].OwnerId = UserInfo.getUserId();
        caseActions[0].Approval_Status__c = ConstantsUtility.In_Progress;
        caseActions[1].Approval_Status__c = ConstantsUtility.In_Progress;
        caseActions[1].L4_Stakeholder__c =UserInfo.getUserId();
        caseActions[1].Current_Approver__c =UserInfo.getUserId();
        caseActions[1].Transferred_Dealer_Approver__c = caseActions[0].Transferred_Dealer_Approver__c;
        
        update caseActions;
        caseActions[0].L4_Stakeholder__c = UserInfo.getUserId();
        update caseActions;
        Test.stopTest();
    }
    static testmethod void updateRevalidationRecordTypeIdServiceCases_Test() {
        Test.startTest();
        List<Case> caseList = [SELECT Id FROM Case LIMIT 1];
        list<CaseTeamRole> caseTeamRoleId= new list<CaseTeamRole>([SELECT id from CaseTeamRole limit 1]);
        CaseTeamMember caseTeamMember = new CaseTeamMember(MemberId = userInfo.getUserId(), ParentId = caseList[0].id, TeamRoleId = caseTeamRoleId[0].Id);
        insert CaseTeamMember;
        caseList[0].Status = ConstantsUtility.CASE_CLOSED;
        update caseList;
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(2, 'Revalidation', ConstantsUtility.REVALIDATION_CASE_ACTION_RECORD_TYPE_ID, caseList[0].Id);
        caseActions[0].Revalidation_Type__c = ConstantsUtility.SERVICE_REVALIDATION ;
        caseActions[0].Revalidation_Category__c = ConstantsUtility.UNJUSTIFIED_COMPLAINT_REVALIDATION;
        caseActions[0].Unjustified_Reason__c = 'External Factor/Damage';
        caseActions[0].RSM_Comments__c  = 'Rejected';
        caseActions[0].ZSH_Comments__c = 'Rejected';
        caseActions[1].Revalidation_Category__c = ConstantsUtility.PRODUCT_COMPLAINT_REVALIDATION;   
        caseActions[1].FTIR_Number__c = 123;
        insert caseActions;
        Test.stopTest();
    }
    
    // createCaseActionsShares  - Covered
    static testmethod void copyClosureFields_Test() {
        Test.startTest();
        List<Case> caseList = [SELECT Id FROM Case LIMIT 1];
        caseList[0].Status = ConstantsUtility.CASE_CLOSED;
        update caseList;
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Closure', ConstantsUtility.Service_Complaint_Closure_CASE_ACTION_RECORD_TYPE_ID, caseList[0].Id);
        insert caseActions;
        list<Case_Actions__c> caseActions2 = TestDataFactory.createCaseActions(1, 'Revalidation', ConstantsUtility.REVALIDATION_SERVICE_PRODUCT_CASE_ACTION_RECORD_TYPE_ID, caseList[0].Id);
        caseActions2[0].Revalidation_Category__c = ConstantsUtility.PRODUCT_COMPLAINT_REVALIDATION;
        caseActions2[0].Revalidation_Type__c = ConstantsUtility.SERVICE_REVALIDATION;
        caseActions2[0].FTIR_Number__c = 12;
        insert caseActions2;
        Test.stopTest();
    }
    static testmethod void serviceUnjustifiedRevalidationValidation_Test() {
        Test.startTest();
        List<Case> caseList = [SELECT Id FROM Case LIMIT 1];
        caseList[0].Status = ConstantsUtility.CASE_CLOSED;
        update caseList;
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Revalidation', ConstantsUtility.REVALIDATION_SERVICE_UNJUSTIFIED_CASE_ACTION_RECORD_TYPE_ID, caseList[0].Id);
        caseActions[0].Approval_Status__c = ConstantsUtility.Rejected;
        caseActions[0].Unjustified_Reason__c  = 'True Value issue';
        caseActions[0].Revalidation_Category__c = 'Unjustified Complaint Revalidation';
        caseActions[0].Revalidation_Type__c  = 'Service Revalidation';
        caseActions[0].RSM_Comments__c  = 'Rejected';
        caseActions[0].ZSH_Comments__c = 'Rejected';
        insert caseActions;
        Test.stopTest();
    }
    
    static testmethod void sendCustomNotifications_Test() {
        Test.startTest();
        List<Case> caseList = [SELECT Id FROM Case LIMIT 1];
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(2, 'On HOld', ConstantsUtility.ON_HOLD_CASE_ACTION_RECORD_TYPE_ID, caseList[0].Id);
        caseActions[0].Approved_Rejection_Notifiers__c = 'Test';
        caseActions[0].Approval_Status__c = ConstantsUtility.In_Progress;
        caseActions[0].Approval_Chatter_Message__c = 'TEST MESSAGE';
        caseActions[0].Initiation_Notification_Title__c = 'TEST MESSAGE';
        caseActions[0].Initiation_Notification_Message__c = 'TEST MESSAGE';
        group g1 = [
            SELECT Id, Name, DeveloperName, Email, Type
            FROM Group
            where Type = :ConstantsUtility.QUEUE
            And DeveloperName = :ConstantsUtility.ASSIGNMENT_QUEUE
        ];
        caseActions[0].Current_Approver__c = g1.id;
        caseActions[0].ownerid = userinfo.getUserId();
        insert caseActions;
        caseActions[0].Current_Approver__c = UserInfo.getUserId();
        caseActions[0].Approved_Rejection_Notifiers__c = 'Test123';
        caseActions[0].L1_Stakeholder__c = null;
        caseActions[1].OwnerId = g1.id;
        update caseActions;
        Test.stopTest();
    }
    static testmethod void sendCustomNotifications_Revalidation_Test() {
        Test.startTest();
        List<Case> caseList = [SELECT Id FROM Case LIMIT 1];
        caseList[0].Status = ConstantsUtility.CASE_CLOSED;
        update caseList;
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(2, 'Revalidation', ConstantsUtility.REVALIDATION_CASE_ACTION_RECORD_TYPE_ID, caseList[0].Id);
        caseActions[0].Approved_Rejection_Notifiers__c = 'Test';
        caseActions[0].Approval_Status__c = ConstantsUtility.Pending_Ringi_Approval;
        caseActions[0].Approval_Chatter_Message__c = 'TEST MESSAGE';
        caseActions[0].Initiation_Notification_Title__c = 'TEST MESSAGE';
        caseActions[0].Initiation_Notification_Message__c = 'TEST MESSAGE';
        group g1 = [
            SELECT Id, Name, DeveloperName, Email, Type
            FROM Group
            where Type = :ConstantsUtility.QUEUE
            And DeveloperName = :ConstantsUtility.ASSIGNMENT_QUEUE
        ];
        caseActions[0].Current_Approver__c = g1.id;
        caseActions[0].ownerid = userinfo.getUserId();
        insert caseActions;
        caseActions[0].Current_Approver__c = UserInfo.getUserId();
        caseActions[0].Approved_Rejection_Notifiers__c = 'Test123';
        
        update caseActions;
        Test.stopTest();
    }
    // sendChatterNotifications - not needed
    //sendEmailSMSApproval - Covered
    /** ************************** Test Methods Created By Deepak END ********************************************** **/
    
}