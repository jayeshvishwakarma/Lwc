@IsTest
public class CaseActionsTrigger_Test {
    @testSetup static void createTestData() {
        Group g1 = new Group(Name = 'ASSIGNMENT QUEUE', type = 'Queue');
        insert g1;
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case_Actions__c');
        insert q1;

        GroupMember gm = new GroupMember(
                GroupId = g1.id,
                UserOrGroupId = userinfo.getUserId()
        );

        insert gm;
    }
    /*list<account> dealerList = TestDataFactory.createDealerAccount(1);
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
c.Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":[{"stakeHolder":"L3A","refName":"TSM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"shashank@maruti.com.invaild"},{"stakeHolder":"L1","refName":"","recordId":"","phone":"","email":""},{"stakeHolder":"L2A","refName":"Arena QCM","recordId":"'+Userinfo.getUserId()+'","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msilQuery":null,"msgp":null,"msds":null,"loyaltyProgram":null,"finance":[{"stakeHolder":"L3A","refName":"TSM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"shashank@maruti.com.invaild"}],"accessories":[{"stakeHolder":"L3A","refName":"TSM MSGA","recordId":"'+Userinfo.getUserId()+'","phone":"1234567890","email":"akhil.jain@maruti.co.in.invalid"},{"stakeHolder":"L4","refName":"MGA Accessories Zonal","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"MGA DVM_All","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"Accessories EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"deepak.thukral@maruti.co.in.invalid"}]}';
c.Selected_Hierarchy_Type__c='sales';
c.Assigned_Date__c=system.now();
c.Region_Code__c ='C2';
c.FCR_Conducted__c = 'Yes';
}
insert casesList;
*/

    static testmethod void closureFormChanged_test() {
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl', 'Complaint');
        insert ImplementationStrategyRecord;
        List<User> internalUsers = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{
        });
        insert internalUsers;

        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        list<Account> businessAccountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        businessAccountList[0].Stakeholder_Hierarchy__c = stakeHolderJson;
        insert businessAccountList;
        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        Approval_Notification_Setting__c approvalNotification = TestDataFactory.createApprovalNotificationSetting('Legal', True);
        insert approvalNotification;

        List<case> casesList = TestDataFactory.createCase(2, ComplaintRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.Customer__c = personAccountList[0].Id;
            c.Dealer_Name__c = businessAccountList[0].Id;
            c.Stakeholders_JSON__c = stakeHolderJson;
            c.Selected_Hierarchy_Type__c = 'sales';
            c.FCR_Conducted__c = 'No';
        }
        insert casesList;
        Case_Actions__c case_actionsObj = new Case_Actions__c(
                Name = 'NCH Legal',
                Approval_Status__c = 'Approved',
                Channel__c = 'Arena',
                Case_Type__c = 'Complaint',
                Business_Area__c = 'Sales',
                Case_Stage__c = 'Pre Sales',
                Primary_Category__c = 'Sales Initiation',
                Secondary_Category__c = 'Dirty Washroom',
                Hold_Till_Date__c = System.today(),
                Region_Code__c = 'C1', Case_Source__c = 'NCH',
                FCR_Conducted__c = 'No',
                Dealer_Code__c = '0813',
                Zone__c = 'Central',
                Issue_Description__c = 'test',
                Gaps_Identified__c = 'Test1',
                Action_Taken__c = 'Test2',
                Counter_Measure_at_Dealer_Level__c = 'test4',
                Timeline_For_Implementation__c = 'test5',
                Counter_Measure_at_RO_Level__c = 'test5',
                Closure_Form_Not_Changed__c = true,
                recordtypeid = ConstantsUtility.ON_HOLD_SERVICE_CASE_ACTION_RECORD_TYPE_ID,
                Case_Number__c = casesList[0].id);
        insert case_actionsObj ;
        Case_Actions__c case_actionsObj1 = new Case_Actions__c(
                Name = 'NCH Legal',
                Approval_Status__c = 'Approved',
                Channel__c = 'Arena',
                Case_Type__c = 'Complaint',
                Business_Area__c = 'Sales',
                Case_Stage__c = 'Pre Sales',
                Primary_Category__c = 'Sales Initiation',
                Secondary_Category__c = 'Dirty Washroom',
                Region_Code__c = 'C1', Case_Source__c = 'NCH',
                FCR_Conducted__c = 'No',
                Dealer_Code__c = '0813',
                Zone__c = 'Central',
                Issue_Description__c = 'test',
                Gaps_Identified__c = 'Test1',
                Action_Taken__c = 'Test2',
                Counter_Measure_at_Dealer_Level__c = 'test4',
                Timeline_For_Implementation__c = 'test5',
                Counter_Measure_at_RO_Level__c = 'test5',
                Closure_Form_Not_Changed__c = true,
                L5_Stakeholder__c = userinfo.getUserId(),
                Hold_Start_Date__c = system.today(),
                Hold_Till_Date__c = system.today() + 12,
                recordtypeid = ConstantsUtility.ON_HOLD_SERVICE_CASE_ACTION_RECORD_TYPE_ID,
                Case_Number__c = casesList[0].id);
        insert case_actionsObj1 ;

    }

    static testmethod void sendChatterNotificationCCPnotResponded_Test() {
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl', 'Complaint');
        insert ImplementationStrategyRecord;
        List<User> internalUsers = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{
        });
        insert internalUsers;

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
            c.FCR_Conducted__c = 'No';
        }
        insert casesList;


        Case_Actions__c case_actionsObj = new Case_Actions__c(
                Name = 'NCH Legal',
                Approval_Status__c = 'Approved',
                Channel__c = 'Arena',
                Case_Type__c = 'Complaint',
                Business_Area__c = 'Sales',
                Case_Stage__c = 'Pre Sales',
                Primary_Category__c = 'Sales Initiation',
                Secondary_Category__c = 'Dirty Washroom',
                Hold_Till_Date__c = System.today(),
                Region_Code__c = 'C1', Case_Source__c = 'NCH',
                FCR_Conducted__c = 'No',
                Dealer_Code__c = '0813',
                Zone__c = 'Central',
                Issue_Description__c = 'test',
                Gaps_Identified__c = 'Test1',
                Action_Taken__c = 'Test2',
                Counter_Measure_at_Dealer_Level__c = 'test4',
                Timeline_For_Implementation__c = 'test5',
                Counter_Measure_at_RO_Level__c = 'test5',
                Closure_Form_Not_Changed__c = true,
                recordtypeid = ConstantsUtility.CCP_NOT_RESPONDED_CASE_ACTION_RECORD_TYPE_ID,
                L3A_Stakeholder__c = userinfo.getUserId(),
                Case_Number__c = casesList[0].id
        );
        insert case_actionsObj ;
    }

    static testmethod void methodToUpdateCaseOnHoldWhenloggedInL3L5_Test() {
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl', 'Complaint');
        insert ImplementationStrategyRecord;
        List<User> internalUsers = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{
        });
        insert internalUsers;

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
            c.FCR_Conducted__c = 'No';
        }
        insert casesList;


        Case_Actions__c case_actionsObj = new Case_Actions__c(
                Name = 'NCH Legal',
                Approval_Status__c = 'In Progress',
                Channel__c = 'Arena',
                Case_Type__c = 'Complaint',
                Business_Area__c = 'Sales',
                Case_Stage__c = 'Pre Sales',
                Primary_Category__c = 'Sales Initiation',
                Secondary_Category__c = 'Dirty Washroom',
                Hold_Start_Date__c = System.today(),
                //Hold_Till_Date__c = System.today()+16,
                Region_Code__c = 'C1', Case_Source__c = 'NCH',
                FCR_Conducted__c = 'No',
                Dealer_Code__c = '0813',
                Zone__c = 'Central',
                Issue_Description__c = 'test',
                Gaps_Identified__c = 'Test1',
                Action_Taken__c = 'Test2',
                Counter_Measure_at_Dealer_Level__c = 'test4',
                Timeline_For_Implementation__c = 'test5',
                Counter_Measure_at_RO_Level__c = 'test5',
                Closure_Form_Not_Changed__c = true,
                recordtypeid = ConstantsUtility.ON_HOLD_CASE_ACTION_RECORD_TYPE_ID,
                L3A_Stakeholder__c = userinfo.getUserId(),
                Case_Number__c = casesList[0].id
        );
        insert case_actionsObj ;
        case_actionsObj.Approval_Status__c = ConstantsUtility.CASE_ACTION_APPROVAL_STATUS_APPROVED ;
        case_actionsObj.RecordTypeId = ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID ;
        case_actionsObj.Transferred_Dealer_Approver__c = userinfo.getUserId();
        update case_actionsObj ;

    }


    static testmethod void methodToUpdateCaseOnHoldWhenloggedInL3L5_Test1() {
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl', 'Complaint');
        insert ImplementationStrategyRecord;
        List<User> internalUsers = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{
        });
        insert internalUsers;

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
            c.FCR_Conducted__c = 'No';

        }
        insert casesList;

        Case_Actions__c case_actionsObj = new Case_Actions__c(
                Name = 'NCH Legal',
                Approval_Status__c = 'Approved',
                Channel__c = 'Arena',
                Case_Type__c = 'Complaint',
                Business_Area__c = 'Sales',
                Case_Stage__c = 'Pre Sales',
                Primary_Category__c = 'Sales Initiation',
                Secondary_Category__c = 'Dirty Washroom',
                Hold_Start_Date__c = System.today(),
                Hold_Till_Date__c = System.today() + 20,
                Region_Code__c = 'C1', Case_Source__c = 'NCH',
                FCR_Conducted__c = 'No',
                Dealer_Code__c = '0813',
                Zone__c = 'Central',
                Issue_Description__c = 'test',
                Gaps_Identified__c = 'Test1',
                Action_Taken__c = 'Test2',
                Counter_Measure_at_Dealer_Level__c = 'test4',
                Timeline_For_Implementation__c = 'test5',
                Counter_Measure_at_RO_Level__c = 'test5',
                Closure_Form_Not_Changed__c = true,
                Reason_For_Hold__c = ConstantsUtility.Delay_in_RC_due_to_RTO_Issue,
                L3A_Stakeholder__c = userinfo.getUserId(),
                Case_Number__c = casesList[0].id

        );
        insert case_actionsObj ;


        Case_Actions__c case_actionsObj1 = new Case_Actions__c(
                Name = 'NCH Legal',
                Approval_Status__c = 'Approved',
                Channel__c = 'Arena',
                Case_Type__c = 'Complaint',
                Business_Area__c = 'Sales',
                Case_Stage__c = 'Pre Sales',
                Primary_Category__c = 'Sales Initiation',
                Secondary_Category__c = 'Dirty Washroom',
                Hold_Start_Date__c = System.today(),
                Hold_Till_Date__c = System.today() + 20,
                Region_Code__c = 'C1', Case_Source__c = 'NCH',
                FCR_Conducted__c = 'No',
                Dealer_Code__c = '0813',
                Zone__c = 'Central',
                Issue_Description__c = 'test',
                Gaps_Identified__c = 'Test1',
                Action_Taken__c = 'Test2',
                Counter_Measure_at_Dealer_Level__c = 'test4',
                Timeline_For_Implementation__c = 'test5',
                Counter_Measure_at_RO_Level__c = 'test5',
                Closure_Form_Not_Changed__c = true,
                Reason_For_Hold__c = ConstantsUtility.Delay_in_RC_due_to_RTO_Issue,
                L3A_Stakeholder__c = userinfo.getUserId(),
                Case_Number__c = casesList[1].Id,
                RecordTypeId = ConstantsUtility.MSIL_QUERY_CLOSURE_CASE_ACTION_RECORD_TYPE_ID
        );
        insert case_actionsObj1;
    }

    static testMethod void method3() {
        Test.startTest();
        /* List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
insert forCodeList;
//Accounts Creation
List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
userAccountList[0].For_Code__c = forCodeList[0].Id;
insert userAccountList;

List<Contact> conList = TestDataFactory.createTestContact(1, userAccountList[0].Id);
insert conList;
System.assertEquals(1, conList.size());

List<User> usr = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
insert usr; */

        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl', 'Complaint');
        insert ImplementationStrategyRecord;
        List<User> internalUsers = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{
        });
        insert internalUsers;

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
            c.FCR_Conducted__c = 'No';
        }
        insert casesList;

        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Closure123', ConstantsUtility.DNE_CASE_ACTION_RECORD_TYPE_ID, casesList[0].Id);
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
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl', 'Complaint');
        insert ImplementationStrategyRecord;
        List<User> internalUsers = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{
        });
        insert internalUsers;

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
            c.FCR_Conducted__c = 'No';
            c.Origin = ConstantsUtility.EMAIL;
        }
        insert casesList;
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Closure123', ConstantsUtility.SPAM_CASE_ACTION_RECORD_TYPE_ID, casesList[0].Id);
        insert caseActions;
        caseActions[0].Approval_Status__c = ConstantsUtility.CASE_ACTION_APPROVAL_STATUS_APPROVED ;
        update caseActions;


        Spam_Phone_Emails__c spam = new Spam_Phone_Emails__c();
        spam.RecordTypeId = ConstantsUtility.EMAIL_SPAM_RECORD_TYPE_ID ;
        spam.Email__c = 'test@gmail.com';
        spam.Phone_No__c = '9760332056';
        spam.From_Date__c = system.today() ;
        spam.To_Date__c = system.today() + 2 ;
        insert spam;
    }

    static testmethod void createTransferredChildCase_Test() {

        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl', 'Complaint');
        insert ImplementationStrategyRecord;
        List<User> internalUsers = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{
        });
        insert internalUsers;

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
            c.FCR_Conducted__c = 'No';
            c.Origin = ConstantsUtility.EMAIL;
        }
        insert casesList;
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Closure123', ConstantsUtility.SPAM_CASE_ACTION_RECORD_TYPE_ID, casesList[0].Id);
        insert caseActions;
        caseActions[0].Approval_Status__c = ConstantsUtility.CASE_ACTION_APPROVAL_STATUS_APPROVED ;
        caseActions[0].RecordTypeId = ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID;
        update caseActions;


    }

    static testmethod void updateCaseAccessForTransferCaseActions_Test() {

        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl', 'Complaint');
        insert ImplementationStrategyRecord;
        List<User> internalUsers = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{
        });
        insert internalUsers;

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
            c.FCR_Conducted__c = 'No';
            c.Origin = ConstantsUtility.EMAIL;
        }
        insert casesList;
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Closure123', ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID, casesList[0].Id);
        insert caseActions;
        List<User> internalUsers1 = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{
        });
        insert internalUsers1;
        caseActions[0].Transferred_Dealer_Approver__c = userinfo.getUserId();
        caseActions[0].L4_Stakeholder__c = internalUsers1[0].id;
        caseActions[0].OwnerId = userinfo.getUserId();
        caseActions[0].Approval_Status__c = ConstantsUtility.In_Progress;
        update caseActions;
        caseActions[0].Approval_Status__c = ConstantsUtility.In_Progress ;
        caseActions[0].OwnerId = userinfo.getUserId();
        caseActions[0].L4_Stakeholder__c = userinfo.getUserId();
        caseActions[0].Transferred_Dealer_Approver__c = userinfo.getUserId();
        update caseActions;
    }

    static testmethod void updateRevalidationRecordTypeIdServiceCases_Test() {

        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl', 'Complaint');
        insert ImplementationStrategyRecord;

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
            c.FCR_Conducted__c = 'No';
            c.Origin = ConstantsUtility.EMAIL;
        }
        insert casesList;

        CaseTeamMember caseTeamMember = new CaseTeamMember(MemberId = userInfo.getUserId(), ParentId = casesList[0].id, TeamRoleId = '0B71s0000004CA6CAM');
        insert CaseTeamMember;
        casesList[0].status = 'Closed';
        update casesList;
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(2, 'Closure123', ConstantsUtility.REVALIDATION_CASE_ACTION_RECORD_TYPE_ID, casesList[0].Id);
        caseActions[0].Revalidation_Type__c = ConstantsUtility.SERVICE_REVALIDATION ;
        caseActions[0].Revalidation_Category__c = ConstantsUtility.UNJUSTIFIED_COMPLAINT_REVALIDATION;
        caseActions[0].Unjustified_Reason__c = 'External Factor/Damage';
        insert caseActions;

    }

    static testmethod void copyClosureFields_Test() {

        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl', 'Complaint');
        insert ImplementationStrategyRecord;

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
            c.FCR_Conducted__c = 'No';
            c.Origin = ConstantsUtility.EMAIL;
        }
        insert casesList;
        casesList[0].status = 'Closed';
        update casesList;
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(2, 'Closure123', ConstantsUtility.REVALIDATION_SERVICE_PRODUCT_CASE_ACTION_RECORD_TYPE_ID, casesList[0].Id);

        insert caseActions;

        caseActions[0].recordtypeid = ConstantsUtility.Service_Complaint_Closure_CASE_ACTION_RECORD_TYPE_ID;
        update caseActions;

    }


    static testmethod void sendCustomNotifications_Test() {

        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl', 'Complaint');
        insert ImplementationStrategyRecord;

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
            c.FCR_Conducted__c = 'No';
            c.Origin = ConstantsUtility.EMAIL;
        }
        insert casesList;
        casesList[0].status = 'Closed';
        update casesList;
        list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(2, 'Closure123', ConstantsUtility.REVALIDATION_SERVICE_PRODUCT_CASE_ACTION_RECORD_TYPE_ID, casesList[0].Id);
        caseActions[0].Approved_Rejection_Notifiers__c = 'Test';
        caseActions[0].Approval_Status__c = ConstantsUtility.In_Progress;
        group g1 = [
                SELECT Id, Name, DeveloperName, Email, Type
                FROM Group
                where Type = :ConstantsUtility.QUEUE
                And DeveloperName = :ConstantsUtility.ASSIGNMENT_QUEUE
        ];
        caseActions[0].Current_Approver__c = g1.id;
        caseActions[0].ownerid = userinfo.getUserId();
        insert caseActions;
        caseActions[0].Approved_Rejection_Notifiers__c = 'Test123';
        update caseActions;

    }


}