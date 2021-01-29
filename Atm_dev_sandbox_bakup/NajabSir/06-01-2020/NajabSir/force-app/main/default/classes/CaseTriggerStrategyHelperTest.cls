/**
* @File Name          : CaseTriggerStrategyHelperTest.cls
* @Description        : Test Class of the apex class 'CaseTriggerStrategyHelper'
* @Author             : Deepak Kumar
**/
@IsTest
private class CaseTriggerStrategyHelperTest {
    @testSetup static void createTestData() {

        List<Approval_Notification_Setting__c> approval_notification_settings = new List<Approval_Notification_Setting__c>();
        Approval_Notification_Setting__c notificationSetting = TestDataFactory.createApprovalNotificationSetting(ConstantsUtility.QC_CHECK_CASE_DISCARDED, true);
        notificationSetting.Name = 'T1';
        approval_notification_settings.add(notificationSetting);
        Approval_Notification_Setting__c notificationSetting2 = TestDataFactory.createApprovalNotificationSetting(ConstantsUtility.QC_CHECK_DONE, true);
        notificationSetting2.Name = 'T2';
        approval_notification_settings.add(notificationSetting2);
        Approval_Notification_Setting__c notificationSetting3 = TestDataFactory.createApprovalNotificationSetting(ConstantsUtility.QC_CHECK_DEALER_CHANGED, true);
        notificationSetting3.Name = 'T3';
        approval_notification_settings.add(notificationSetting3);
        Approval_Notification_Setting__c notificationSetting4 = TestDataFactory.createApprovalNotificationSetting(ConstantsUtility.COMPLAINT_CASE_TYPE, true);
        notificationSetting.Name = 'T4';
        approval_notification_settings.add(notificationSetting4);
        insert approval_notification_settings;


        List<String> campaignCodes = new List<String>();
        for (Case_Queue_Assignment_Matrix__mdt assignmentMatrix : [SELECT Id,Campaign_Code__c FROM Case_Queue_Assignment_Matrix__mdt WHERE Campaign_Code__c != null LIMIT 1]) {
            campaignCodes.add(assignmentMatrix.Campaign_Code__c);
        }
        List<Campaign> campaigns = TestDataFactory.createCampaign(1);
        campaigns[0].RecordTypeId = ConstantsUtility.CAMPAIGN_CALL_CAMPAIGN_RECORD_TYPE_ID;
        campaigns[0].Campaign_Code__c = campaignCodes.size() > 0 ? campaignCodes[0] : null;
        insert campaigns;

        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl', 'Complaint');
        insert ImplementationStrategyRecord;
        List<User> internalUsers = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{
        });
        insert internalUsers;

        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        personAccountList[0].SVOC_ID__c = '12345';
        insert personAccountList;
        list<Account> businessAccountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        businessAccountList[0].Stakeholder_Hierarchy__c = stakeHolderJson;
        insert businessAccountList;

        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(3, ComplaintRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.Channel__c = ConstantsUtility.ARENA_CASE_CHANNEL;
            c.Case_Type__c = ConstantsUtility.COMPLAINT_CASE_TYPE;
            c.Customer__c = personAccountList[0].Id;
            c.Dealer_Name__c = businessAccountList[0].Id;
            c.Stakeholders_JSON__c = stakeHolderJson;
            c.Selected_Hierarchy_Type__c = 'sales';
            c.FCR_Conducted__c = 'Yes';
            c.Outlet_Type__c = 'Arena WS';
            c.Assigned_Date__c = Date.today();
            c.Case_Registration_Notifiers_Internal__c = String.valueOf(UserInfo.getUserId());
           // c.CCP_Outbound_Call_To__c = ConstantsUtility.CCP_OUTBOUND_CALL_TO_DEALERSHIP;
        }
        casesList[0].Business_Area__c = ConstantsUtility.SERVICE_BODYSHOP_CASE_BUSINESS_AREA;
        casesList[1].Business_Area__c = ConstantsUtility.SERVICE_WORKSHOP_CASE_BUSINESS_AREA;
        casesList[2].Business_Area__c = ConstantsUtility.SALES_CASE_BUSINESS_AREA;
        casesList[2].Outlet_Type__c = 'Arena Sales Outlets';
        insert casesList;

    }


    static testMethod void updateCaseResolutionTimeTest() {
        Test.startTest();
        List<Case> cases = [SELECT Id,Status,Mobile_Number__c FROM Case LIMIT 1];
        cases[0].Status = ConstantsUtility.CASE_STATUS_RESOLVED;
        cases[0].Mobile_Number__c = '9876543123';
        cases[0].Description = 'test';
        update cases;
        Test.stopTest();
    }
    static testMethod void ccpCampaignDetectionTest() {
        Test.startTest();
        List<Case> cases = [
                SELECT Id,Channel__c,Case_Type__c,Business_Area__c,Status,CCP_Outbound_Call_To__c,SVOC_ID__c,
                        Selected_Hierarchy_Type__c,Stakeholders_JSON__c,Primary_Category__c,CampaignId__c,
                        Mobile_Number__c,Mobile_Number_1__c,Mobile_Number_2__c,Mobile_Number_3__c,Mobile_Number_4__c
                FROM Case
                WHERE Business_Area__c = :ConstantsUtility.SALES_CASE_BUSINESS_AREA
                LIMIT 1
        ];
        cases[0].CCP_Outbound_Call_To__c = ConstantsUtility.CCP_OUTBOUND_CALL_TO_DEALERSHIP;
        CaseTriggerStrategyHelper.ccpCampaignDetectionHelper(cases, null);
        Test.stopTest();
    }
    static testMethod void populateCustomerBasedOnSVOCIdTes() {
        Test.startTest();
        List<Case> cases = [SELECT Id,Status,SVOC_ID__c FROM Case LIMIT 1];
        cases[0].SVOC_ID__c = '12345';
        update cases;
        Test.stopTest();
    }
    static testMethod void caseTeamCreationTest() {

        Id serviceRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        system.debug('test-- serviceRecordType--' + serviceRecordType);
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseVehicleServiceTriggerServiceImpl', 'Service');
        insert ImplementationStrategyRecord;
        List<User> internalUsers = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{
        });
        insert internalUsers;

        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        list<Account> businessAccountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        businessAccountList[0].Stakeholder_Hierarchy__c = stakeHolderJson;
        insert businessAccountList;
        List<case> casesList = TestDataFactory.createCase(1, serviceRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.Channel__c = ConstantsUtility.ARENA_CASE_CHANNEL;
            c.Case_Type__c = ConstantsUtility.DEALER_QUERY_CASE_TYPE;
            c.Customer__c = personAccountList[0].Id;
            c.Dealer_Name__c = businessAccountList[0].Id;
            c.Stakeholders_JSON__c = stakeHolderJson;
            c.Selected_Hierarchy_Type__c = 'sales';
            c.FCR_Conducted__c = 'Yes';
            c.Outlet_Type__c = 'Arena WS';
            c.Assigned_Date__c = Date.today();
            c.OwnerId = userInfo.getUserId();
            // c.recordtypeid = ConstantsUtility.QUERY_FEEDBACK_CASE_RECORD_TYPE_ID ;
            c.Mobile_Number__c = '9760332976';
        }
        insert casesList;
        system.debug('ownerid -->' + casesList[0].OwnerId);

        Account acc = New Account();
        acc.Name = 'test123';
        acc.User__c = casesList[0].OwnerId ;
        acc.RecordTypeId = ConstantsUtility.USER_ACCOUNT_RECORDTYPE_ID ;
        insert acc ;
        system.debug('test -->' + acc.RecordTypeId);
        AccountTeamMember accTeamMember = New AccountTeamMember();
        accTeamMember.Accountid = acc.Id;
        accteamMember.UserId = casesList[0].OwnerId ;
        insert accTeamMember;

        //  CaseTriggerStrategyHelper Casetrigger = new CaseTriggerStrategyHelper();
        // Casetrigger.markQueryAsSpam(); 

        Spam_Phone_Emails__c spanPhoneEmail = new Spam_Phone_Emails__c();
        spanPhoneEmail.RecordTypeId = ConstantsUtility.EMAIL_SPAM_RECORD_TYPE_ID ;
        spanPhoneEmail.Email__c = 'test@gmail.com';
        spanPhoneEmail.Phone_No__c = '789654123';
        spanPhoneEmail.From_Date__c = system.today() - 10;
        spanPhoneEmail.To_Date__c = system.today() + 5;
        insert spanPhoneEmail ;
    }

    static testMethod void markMcCommunicationCancelledTest() {
        Id serviceRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        system.debug('test-- serviceRecordType--' + serviceRecordType);
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseVehicleServiceTriggerServiceImpl', 'Service');
        insert ImplementationStrategyRecord;
        List<User> internalUsers = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{
        });
        insert internalUsers;

        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        list<Account> businessAccountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        businessAccountList[0].Stakeholder_Hierarchy__c = stakeHolderJson;
        insert businessAccountList;
        List<case> casesList = TestDataFactory.createCase(1, serviceRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.Channel__c = ConstantsUtility.ARENA_CASE_CHANNEL;
            c.Case_Type__c = ConstantsUtility.DEALER_QUERY_CASE_TYPE;
            c.Customer__c = personAccountList[0].Id;
            c.Dealer_Name__c = businessAccountList[0].Id;
            c.Stakeholders_JSON__c = stakeHolderJson;
            c.Selected_Hierarchy_Type__c = 'sales';
            c.FCR_Conducted__c = 'Yes';
            c.Outlet_Type__c = 'Arena WS';
            c.Assigned_Date__c = Date.today();
            c.OwnerId = userInfo.getUserId();
            // c.recordtypeid = ConstantsUtility.QUERY_FEEDBACK_CASE_RECORD_TYPE_ID ;
            c.Mobile_Number__c = '9760332976';
            c.CCP_Complete_Time__c = Datetime.newInstance(2020, 2, 17) ;

        }
        insert casesList;
        MC_Communication__c mcComm = new MC_Communication__c();
        mcComm.Type__c = ConstantsUtility.DEALER_RESOLUTION_ESCALATION ;
        mcComm.Status__c = ConstantsUtility.CANCELLED ;
        mcComm.Case__c = casesList[0].id ;
        insert mcComm;
    }
    static testMethod void sendChatterNotificationOnQCTest1() {
        Test.startTest();
        List<Case> cases = [SELECT Id,Status,Mobile_Number__c,QC_Done_By__c,QC_Status__c,QC_Remarks__c FROM Case LIMIT 1];
        cases[0].QC_Status__c = ConstantsUtility.QC_STATUS_NOT_OK;
        cases[0].QC_Remarks__c = 'DONE';
        update cases;
        Test.stopTest();
    }
    static testMethod void sendChatterNotificationOnQCTest2() {
        Test.startTest();
        List<Case> cases = [SELECT Id,Status,Mobile_Number__c,QC_Done_By__c,QC_Status__c,QC_Remarks__c FROM Case LIMIT 1];
        cases[0].QC_Status__c = 'OK';
        cases[0].QC_Remarks__c = 'DONE';
        update cases;
        Test.stopTest();
    }
    static testMethod void sendChatterNotificationOnQCTest3() {
        // ASSIGN TO NEW DEALERSHIP
        Test.startTest();
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        list<Account> businessAccountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        businessAccountList[0].Stakeholder_Hierarchy__c = stakeHolderJson;
        insert businessAccountList;
        List<Case> cases = [SELECT Id,Status,Mobile_Number__c,QC_Done_By__c,QC_Status__c,QC_Remarks__c,Channel__c,Business_Area__c FROM Case WHERE Business_Area__c = :ConstantsUtility.SERVICE_BODYSHOP_CASE_BUSINESS_AREA LIMIT 1];
        cases[0].Dealer_Name__c = businessAccountList[0].Id;
        //cases[0].Business_Area__c = ConstantsUtility.SERVICE_WORKSHOP_CASE_BUSINESS_AREA;
        // cases[0].QC_Remarks__c = 'DONE';
        update cases;
        Test.stopTest();
    }


}