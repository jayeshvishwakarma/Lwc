/**
* @File Name          : CaseTriggerStrategyHelperTest.cls
* @Description        : Test Class of the apex class 'CaseTriggerStrategyHelper'
* @Author             : Deepak Kumar
**/
@IsTest
private class CaseTriggerStrategyHelperTest {
    
    @testSetup static void createTestData() {
        Implementation_Strategy__c imS = TestDataFactory.createImplementation('CaseMOSCaseTriggerServiceImpl','MOS_Complaints');
        insert imS;
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
        Bypass_Setting__c bypass = new Bypass_Setting__c();
        bypass.Bypass_All__c=false;
        insert bypass;
        
        List<String> campaignCodes = new List<String>();
        for (Case_Queue_Assignment_Matrix__mdt assignmentMatrix : [SELECT Id,Campaign_Code__c FROM Case_Queue_Assignment_Matrix__mdt WHERE Campaign_Code__c != null LIMIT 1]) {
            campaignCodes.add(assignmentMatrix.Campaign_Code__c);
        }
        List<Campaign> campaigns = TestDataFactory.createCampaign(1);
        campaigns[0].RecordTypeId = ConstantsUtility.CAMPAIGN_CALL_CAMPAIGN_RECORD_TYPE_ID;
        campaigns[0].Campaign_Code__c = campaignCodes.size() > 0 ? campaignCodes[0] : null;
        insert campaigns;
        
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        list<Implementation_Strategy__c> ImplementationStrategyRecord= new list<Implementation_Strategy__c>();
        Implementation_Strategy__c ImplementationStrategyRecordComplaint = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl', 'Complaint');
        ImplementationStrategyRecord.add(ImplementationStrategyRecordComplaint);
        Implementation_Strategy__c ImplementationStrategyRecordMSILQuery = TestDataFactory.createImplementation('CaseMSILQueryInternalTriggerServiceImpl','MSIL_Query_Internal');
        ImplementationStrategyRecord.add(ImplementationStrategyRecordMSILQuery);
        Implementation_Strategy__c ImplementationStrategyRecordEmail = TestDataFactory.createImplementation('CaseEmailTriggerServiceImpl','Email_Cases');
        ImplementationStrategyRecord.add(ImplementationStrategyRecordEmail);
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
        
        Spam_Phone_Emails__c SpamEmails = TestDataFactory.createSpam('Email','gitika12345@gmail.com','9877898998');
        insert SpamEmails;
        
        Spam_Phone_Emails__c SpamPhones = TestDataFactory.createSpam('Phone','gitika12345@gmail.com','9877898998');
        insert SpamPhones;
        
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
            c.Region_code__c='C2';
            // c.CCP_Outbound_Call_To__c = ConstantsUtility.CCP_OUTBOUND_CALL_TO_DEALERSHIP;
        }
        casesList[0].Business_Area__c = ConstantsUtility.SERVICE_BODYSHOP_CASE_BUSINESS_AREA;
        casesList[1].Business_Area__c = ConstantsUtility.SERVICE_WORKSHOP_CASE_BUSINESS_AREA;
        casesList[2].Business_Area__c = ConstantsUtility.SALES_CASE_BUSINESS_AREA;
        casesList[2].Outlet_Type__c = 'Arena Sales Outlets';
        
        User currentTestUser = [Select id from User where id = : UserInfo.getUserId()];
        list<Group> queueList = TestDataFactory.createPublicGroup(1);
        queueList[0].type='Queue';
        insert queueList;
        
        System.runAs(currentTestUser){
            QueuesObject testQueue = new QueueSObject(QueueID = queueList[0].id, SobjectType = 'Case');
            insert testQueue;             
        }
        
        Id EmailCasesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Email_Cases').getRecordTypeId();
        List<case> casesListEmail = TestDataFactory.createCase(3, EmailCasesRecordType);
        for (case c : casesListEmail) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.OwnerId=queueList[0].id;
            c.Case_Registration_Notifiers_Internal__c = String.valueOf(UserInfo.getUserId()); 
        }
        casesList.addall(casesListEmail);
        insert casesList;
        List<MC_Communication__c> mcComList =TestDataFactory.createMCCommData(2,null);
        for(MC_Communication__c mCcOm : mcComList){
            mCcOm.case__c=casesList[0].id;   
        }
        mcComList[0].Type__c=ConstantsUtility.DEALER_RESOLUTION_ESCALATION;
        mcComList[1].Type__c=ConstantsUtility.CCP;
        insert mcComList;
        
        list<Account> dealerList = TestDataFactory.createBusinessAccount(3, 'Dealer'); 
        dealerList[0].Name = ConstantsUtility.MOS_MASTER_MS_ALLIANZ;
        dealerList[0].MOS_Category__c = 'MOS';
        dealerList[1].Name = 'Towing User';
        dealerList[1].Stakeholder_Hierarchy__c = stakeHolderJson;
        dealerList[1].MOS_Category__c = 'MOS';
        dealerList[2].Name = 'Towing User 2';
        dealerList[2].MOS_Category__c = 'MOS';
        dealerList[2].Stakeholder_Hierarchy__c = stakeHolderJson;
        insert dealerList;
        
        
        
        /** Code For MOS Case ******/
        String caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MOS Case').getRecordTypeId();
        
        list<city__c> cityList = TestDataFactory.createCityAddressMasterData(1);
        insert cityList;
        List<Product2> product = TestDataFactory.createProducts('Variants',2);
        insert product;
        List<Color_Variant_Master__c> colorVariantMaster = TestDataFactory.createColorVarientRealetdToProduct(1,product[0].id);
        insert colorVariantMaster;
        List<Account> personAccountListForMos = TestDataFactory.createPersonAccount(1);
        insert personAccountListForMos;
        String asssetRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        List<Asset> assets = TestDataFactory.CreateAssetsRecords(product);
        assets[0].recordTypeId = asssetRecTypeId;
        assets[0].Registration_Number__c = 'UP801111';
        assets[0].AccountId = personAccountListForMos[0].Id;
        assets[0].ContactId = personAccountListForMos[0].PersonContactId;
        
        assets[1].recordTypeId = asssetRecTypeId;
        assets[1].Registration_Number__c = 'UP803111';
        assets[1].AccountId = personAccountListForMos[0].Id;
        assets[1].ContactId = personAccountListForMos[0].PersonContactId;
        insert assets;
        
        List<Account> listAccount = [SELECT Id,Name FROM Account WHERE Name =:ConstantsUtility.MOS_MASTER_MS_ALLIANZ];
        List<Account> listAccount1 = [SELECT Id,Name FROM Account WHERE Name = 'Towing User' LIMIT 1];
        List<Account> listAccount2 = [SELECT Id,Name FROM Account WHERE Name = 'Towing User 2' LIMIT 1];
        List<Contact> conList1 = TestDataFactory.createTestContact(2, dealerList[0].Id);
        insert conList1;
        
        List<Problem_Category__c> listProgramCategory = TestDataFactory.createProblemCategory(1);
        listProgramCategory[0].Problem_Code__c ='P101';
        insert listProgramCategory;
        
        List<Case> caseList = TestDataFactory.createCase(8, caseRecTypeId);
        caseList[0].Color__c = colorVariantMaster[0].id;
        caseList[0].ETA_Time__c = DateTime.now() +1;
        caseList[0].Vehicle_Model__c = 'CI';
        caseList[0].Model__c = 'CI';
        caseList[0].Channel__c = 'Nexa';
        caseList[0].Variant__c = product[0].id;
        caseList[0].MOS_Case_Source__c = ConstantsUtility.MOSCaseSourceMCall;
        caseList[0].Job_Type__c = 'Accidental';
        caseList[0].MOS_Case_Stage__c = 'Out for Service';
        caseList[0].City__c = cityList[0].Id;
        caseList[0].Towing_Destination_Dealer__c = dealerList[1].Id;
        caseList[0].Allocated_Dealer__c = dealerList[2].Id;
        caseList[0].Mobile_Number__c = '9876543219';
        caseList[0].Allocation_Time__c = DateTime.now();
        
        caseList[1].Color__c = colorVariantMaster[0].id;
        caseList[1].ETA_Time__c = DateTime.now() +1;
        caseList[1].Vehicle_Model__c = 'CI';
        caseList[1].Vehicle_Registration_Number__c = 'UP801111';
        caseList[1].Model__c = 'CI';
        caseList[1].Channel__c = 'Nexa';
        caseList[1].Variant__c = product[0].id;
        caseList[1].MOS_Case_Source__c = 'M-Call';
        caseList[1].Job_Type__c = 'Accidental';
        caseList[1].MOS_Case_Stage__c = 'Out for Service';
        caseList[1].Allocated_Dealer__c = listAccount1[0].Id;
        caseList[1].City__c = cityList[0].Id;
        
        caseList[2].Color__c = colorVariantMaster[0].id;
        caseList[2].Vehicle_Model__c = 'CI';
        caseList[2].Technician_Id__c = conList1[0].Id;
        caseList[2].Model__c = 'CI';
        caseList[2].Channel__c = 'Nexa';
        caseList[2].Variant__c = product[0].id;
        caseList[2].MOS_Case_Source__c = 'M-Call';
        caseList[2].Job_Type__c = 'Accidental';
        caseList[2].MOS_Case_Stage__c = 'Pending for Allocation';
        caseList[2].Allocated_Dealer__c = dealerList[0].Id;
        caseList[2].Customer_Location__Latitude__s = 35.00;
        caseList[2].Customer_Location__Longitude__s = 5.00;
        caseList[2].City__c = cityList[0].Id;
        
        caseList[3].Color__c = colorVariantMaster[0].id;
        caseList[3].Vehicle_Model__c = 'CI';
        caseList[3].Technician_Id__c = conList1[0].Id;
        caseList[3].Model__c = 'CI';
        caseList[3].Channel__c = 'Nexa';
        caseList[3].Variant__c = product[0].id;
        caseList[3].MOS_Case_Source__c = 'M-Call';
        caseList[3].Job_Type__c = 'Accidental';
        caseList[3].MOS_Case_Stage__c = 'Pending for Allocation';
        caseList[3].Allocated_Dealer__c = dealerList[1].Id;
        caseList[3].City__c = cityList[0].Id;
        
        caseList[4].Color__c = colorVariantMaster[0].id;
        caseList[4].ETA_Time__c = DateTime.now() +1;
        caseList[4].Vehicle_Model__c = 'CI';
        caseList[4].Vehicle_Registration_Number__c = 'UP801111';
        caseList[4].Model__c = 'CI';
        caseList[4].Channel__c = 'Nexa';
        caseList[4].Variant__c = product[0].id;
        caseList[4].MOS_Case_Source__c = 'Nexa';
        caseList[4].Job_Type__c = 'Accidental';
        caseList[4].MOS_Case_Stage__c = 'Reached';
        caseList[4].Allocated_Dealer__c = dealerList[0].Id;
        
        caseList[5].Color__c = colorVariantMaster[0].id;
        caseList[5].ETA_Time__c = DateTime.now() +1;
        caseList[5].Vehicle_Model__c = 'CI';
        caseList[3].Technician_Id__c = conList1[0].Id;
        caseList[5].Vehicle_Registration_Number__c = 'UP801111';
        caseList[5].Model__c = 'CI';
        caseList[5].Channel__c = 'Nexa';
        caseList[5].Variant__c = product[0].id;
        caseList[5].MOS_Case_Source__c = 'M-Call';
        caseList[5].Job_Type__c = ConstantsUtility.Job_Type_Breakdown;
        caseList[5].MOS_Case_Stage__c = 'Out for Service';
        caseList[5].Allocated_Dealer__c = listAccount1[0].Id;
        caseList[5].Mobile_Number__c = '9826543219';
        
        caseList[6].Color__c = colorVariantMaster[0].id;
        caseList[6].ETA_Time__c = DateTime.now() +1;
        caseList[6].Vehicle_Model__c = 'CI';
        caseList[6].Vehicle_Registration_Number__c = 'UP801111';
        caseList[6].Model__c = 'CI';
        caseList[6].Channel__c = 'Nexa';
        caseList[6].Variant__c = product[0].id;
        caseList[6].MOS_Case_Source__c = 'M-Call';
        caseList[6].Job_Type__c = 'Accidental';
        caseList[6].MOS_Case_Stage__c = 'Reached';
        caseList[6].Allocated_Dealer__c = dealerList[1].Id;
        
        caseList[7].Color__c = colorVariantMaster[0].id;
        caseList[7].ETA_Time__c = DateTime.now() +1;
        caseList[7].Vehicle_Model__c = 'CI';
        caseList[7].Vehicle_Registration_Number__c = 'UP801111';
        caseList[7].Model__c = 'CI';
        caseList[7].Channel__c = 'Nexa';
        caseList[7].Variant__c = product[0].id;
        caseList[7].MOS_Case_Source__c = 'Nexa';
        caseList[7].Job_Type__c = ConstantsUtility.Job_Type_Breakdown;
        caseList[7].MOS_Case_Stage__c = ConstantsUtility.MOS_STAGE_Pending_for_Out_for_Service;
        caseList[7].Allocated_Dealer__c = listAccount1[0].Id;
        caseList[7].Mobile_Number__c = '9826543219';
        caseList[7].Problem_Category__c = listProgramCategory[0].Id;
        INSERT caseList;
        
    }
    static testMethod void caseBulkHoldRequest_Test(){
        
        Test.startTest();
        List<Case> cases = [SELECT Id,Status,Bulk_Hold_Till_Date__c,Bulk_Hold_Status__c,Region_code__c,Previous_Owner__c FROM Case where recordtype.developername = 'Complaint'];
        for(Case cs : cases){
            cs.Bulk_Hold_Till_Date__c=system.today()+1;
            cs.Bulk_Hold_Status__c='In Progress';
        }
        update cases;
        Test.stopTest();
        
    }
    static testMethod void updatePreviousOwner_Test(){
        
        Test.startTest();
        List<Case> cases = [SELECT Id,Status,Mobile_Number__c,Previous_Owner__c FROM Case where recordtype.developername = 'Complaint'];
        list<group> grouplist =[select id from group where type='Queue'];
        cases[0].ownerId = userinfo.getUserId();
        cases[0].Previous_Owner__c= userinfo.getUserId();
        update cases;
        cases[0].Change_owner_to_Previous_owner__c=true;
        update cases[0];
        cases[0].ownerId =grouplist[0].id;
        update cases[0];
        Test.stopTest();
    }
    
    static testMethod void markMcCommunicationCancelled_Test(){
        Test.startTest();
        List<Case> cases = [SELECT Id,Status,Mobile_Number__c FROM Case where recordtype.developername = 'Complaint'];
        cases[0].Status = 'Closed';
        cases[1].CCP_Complete_Time__c =system.now();
        update cases;
        Test.stopTest();
    }
    
    static testMethod void markOrFilterQueryAsSpamTest(){
        Test.startTest();
        Id MSILQueryInternalRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MSIL_Query_Internal').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(1, MSILQueryInternalRecordType);
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        string CustomerId;
        string DealerId;
        for(Account personAcc : [Select id,Recordtype.DeveloperName from Account]){
            if(personAcc.Recordtype.DeveloperName=='Customer'){
                CustomerId=personAcc.Id; 
            }
            if(personAcc.Recordtype.DeveloperName=='Dealer'){
                DealerId=personAcc.Id; 
            }
        }
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.Channel__c = ConstantsUtility.MS_CORPORATE_CASE_CHANNEL;
            c.Case_Type__c = ConstantsUtility.INTERNAL_CASE_TYPE;
            c.Business_Area__c=ConstantsUtility.INTERNAL_CASE_BUSINESS_AREA;
            c.Primary_Category__c=ConstantsUtility.SPAM_PRIMARY_CATEGORY;
            c.Customer__c = CustomerId;
            // c.Dealer_Name__c = DealerId;
            c.Stakeholders_JSON__c = stakeHolderJson;
            c.Selected_Hierarchy_Type__c = 'msilQuery';
            c.FCR_Conducted__c = 'Yes';
            c.Outlet_Type__c = 'Arena WS';
            c.Assigned_Date__c = Date.today();
            c.Case_Registration_Notifiers_Internal__c = String.valueOf(UserInfo.getUserId()); 
        } 
        casesList[0].Mobile_Number__c='';
        //casesList[0].SuppliedEmail='gitika12345@gmail.com';
        System.debug('SPAM CASE ');
        insert casesList;
        
        Test.stopTest();
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
        Test.startTest();
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
            // c.Channel__c = ConstantsUtility.ARENA_CASE_CHANNEL;
            // c.Case_Type__c = ConstantsUtility.DEALER_QUERY_CASE_TYPE;
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
        Test.stopTest();
    }
    
    static testMethod void markMcCommunicationCancelledTest() {
        Test.startTest();
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
            // c.Channel__c = ConstantsUtility.ARENA_CASE_CHANNEL;
            // c.Case_Type__c = ConstantsUtility.DEALER_QUERY_CASE_TYPE;
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
        test.stopTest();
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
    
    
    static testMethod void updateFieldsOnMOSCaseTest1(){
        Test.startTest();
        List<User> userList = [SELECT Id FROM User LIMIT 1];
        CaseTriggerHelper.setIntegrationUserId = new Set<Id>{userList[0].Id};
            List<Case> caseList = new list<Case>([SELECT id,Customer_Consent__c,Vehicle_Registration_Number__c,Technician_Id__c,Model__c,Model_Txt__c,
                                                  Customer_feedback__c,Feedback_Reason__c,MOS_Case_Stage__c,Status,Action_Taken__c,
                                                  RO_Observation__c,Job_Type__c,FE_CaseNumber__c,Customer_Cancellation__c FROM case where recordType.Name =: 'MOS Case']);
        
        caseList[5].MOS_Case_Stage__c = 'Pending for Out for Service'; 
        update caseList;
        
        Test.stopTest();
    }
    static testMethod void updateFieldsOnMOSCaseTest6(){
        Test.startTest();
        List<User> userList = [SELECT Id FROM User LIMIT 1];
        CaseTriggerHelper.setIntegrationUserId = new Set<Id>{userList[0].Id};
            List<Case> caseList = new list<Case>([SELECT id,Customer_Consent__c,Vehicle_Registration_Number__c,Technician_Id__c,Model__c,Model_Txt__c,
                                                  Customer_feedback__c,Feedback_Reason__c,MOS_Case_Stage__c,Status,Action_Taken__c,
                                                  RO_Observation__c,Job_Type__c,FE_CaseNumber__c,Customer_Cancellation__c FROM case where recordType.Name =: 'MOS Case']);
        caseList[1].Vehicle_Registration_Number__c = 'UP803111';
        caseList[1].FE_CaseNumber__c = '10221';
        caseList[1].MOS_Case_Stage__c = 'Customer Cancelled';
        caseList[1].Status = 'Closed';
        caseList[5].FE_CaseNumber__c = '810221';
        caseList[5].MOS_Case_Stage__c = ConstantsUtility.MOS_STAGE_Reached;
        caseList[5].Status ='Open';
        update caseList;
        test.stopTest();
    }
    
    static testMethod void updateFieldsOnMOSCaseTest2(){
        Test.startTest();
        List<Contact> conList = new list<Contact>([SELECT id FROM Contact where Account.Name =: ConstantsUtility.MOS_MASTER_MS_ALLIANZ]);
        
        List<User> userList = [SELECT Id FROM User LIMIT 1];
        CaseTriggerHelper.setIntegrationUserId = new Set<Id>{userList[0].Id};
            List<Case> caseList = new list<Case>([SELECT id,Customer_Consent__c,Vehicle_Registration_Number__c,Technician_Id__c,Model__c,Model_Txt__c,
                                                  Customer_feedback__c,Feedback_Reason__c,MOS_Case_Stage__c,Status,Action_Taken__c,
                                                  RO_Observation__c,Job_Type__c,FE_CaseNumber__c,Customer_Cancellation__c FROM case where recordType.Name =: 'MOS Case']);
        caseList[2].Customer_Consent__c = ConstantsUtility.CustomerConsentTechnicianAssistance;
        caseList[1].Vehicle_Registration_Number__c = 'UP803111';
        caseList[2].Technician_Id__c = conList[1].Id;
        caseList[1].Model__c = 'BA';
        caseList[1].Model_Txt__c = null;
        caseList[1].Status = ConstantsUtility.CaseStatusClosed;
        caseList[0].MOS_Case_Stage__c = 'Pending for Out for Service';
        update caseList;
        Test.stopTest();
    }
    static testMethod void updateFieldsOnMOSCaseTest7(){
       Test.startTest();
        List<Contact> conList = new list<Contact>([SELECT id FROM Contact where Account.Name =: ConstantsUtility.MOS_MASTER_MS_ALLIANZ]);
        
        List<User> userList = [SELECT Id FROM User LIMIT 1];
        CaseTriggerHelper.setIntegrationUserId = new Set<Id>{userList[0].Id};
            List<Case> caseList = new list<Case>([SELECT id,Customer_Consent__c,Vehicle_Registration_Number__c,Technician_Id__c,Model__c,Model_Txt__c,
                                                  Customer_feedback__c,Feedback_Reason__c,MOS_Case_Stage__c,Status,Action_Taken__c,
                                                  RO_Observation__c,Job_Type__c,FE_CaseNumber__c,Customer_Cancellation__c FROM case where recordType.Name =: 'MOS Case']);
        caseList[2].Customer_Consent__c = ConstantsUtility.CustomerConsentTowingAssistance;
        caseList[1].Action_Taken__c = 'test';
        caseList[1].RO_Observation__c = 'test';
        caseList[2].Technician_Id__c = null;
        update caseList;
        Test.stopTest();
    }
    
    static testMethod void updateFieldsOnMOSCaseTest3(){
        Test.startTest();
        
        List<Contact> conList = new list<Contact>([SELECT id FROM Contact where Account.Name =: ConstantsUtility.MOS_MASTER_MS_ALLIANZ]);
        
        List<User> userList = [SELECT Id FROM User LIMIT 1];
        CaseTriggerHelper.setIntegrationUserId = new Set<Id>{userList[0].Id};
            List<Case> caseList = new list<Case>([SELECT id,Customer_Consent__c,Vehicle_Registration_Number__c,Technician_Id__c,Model__c,Model_Txt__c,
                                                  Customer_feedback__c,Feedback_Reason__c,MOS_Case_Stage__c,Status,Action_Taken__c,
                                                  RO_Observation__c,Job_Type__c,FE_CaseNumber__c,Customer_Cancellation__c FROM case where recordType.Name =: 'MOS Case']);
        caseList[2].Customer_Consent__c = ConstantsUtility.CustomerConsentTechnicianAssistance;
        caseList[1].Vehicle_Registration_Number__c = 'UP803111';
        caseList[2].Technician_Id__c = conList[1].Id;
        caseList[1].Model__c = 'BA';
        caseList[1].Model_Txt__c = null;
        caseList[1].Customer_feedback__c = 'Poor';
        caseList[1].Feedback_Reason__c = 'High Charges';
        caseList[5].MOS_Case_Stage__c = ConstantsUtility.MOS_STAGE_Pending_for_Out_for_Service;
        caseList[7].MOS_Case_Stage__c = ConstantsUtility.MOS_STAGE_Pending_for_Out_for_Service;
        caseList[1].Status = ConstantsUtility.CaseStatusClosed;
        update caseList;
        Test.stopTest();
    }
    static testMethod void updateFieldsOnMOSCaseTest5(){
        Test.startTest();
        
        List<Contact> conList = new list<Contact>([SELECT id FROM Contact where Account.Name =: ConstantsUtility.MOS_MASTER_MS_ALLIANZ]);
        
        List<User> userList = [SELECT Id FROM User LIMIT 1];
        CaseTriggerHelper.setIntegrationUserId = new Set<Id>{userList[0].Id};
            List<Case> caseList = new list<Case>([SELECT id,Customer_Consent__c,Vehicle_Registration_Number__c,Technician_Id__c,/*Model__c,*/Model_Txt__c,
                                                  Customer_feedback__c,Feedback_Reason__c,MOS_Case_Stage__c,Status,Action_Taken__c,
                                                  RO_Observation__c,Job_Type__c,FE_CaseNumber__c,Customer_Cancellation__c FROM case where recordType.Name =: 'MOS Case']);
        caseList[2].Customer_Consent__c = ConstantsUtility.CustomerConsentTowingAssistance;
        caseList[1].Action_Taken__c = 'test';
        caseList[1].RO_Observation__c = 'test';
        caseList[2].Technician_Id__c = null;
        caseList[0].Job_Type__c = ConstantsUtility.Job_Type_Breakdown;
        caseList[0].FE_CaseNumber__c = '101';
        caseList[0].MOS_Case_Stage__c = ConstantsUtility.Customer_Cancelled;
        caseList[0].Customer_Cancellation__c = 'High Charges';
        caseList[3].MOS_Case_Stage__c = ConstantsUtility.MOS_CASE_STAGE_Pending_for_Allocation;
        caseList[3].Job_Type__c = 'MCall-No Allocation';
        caseList[3].FE_CaseNumber__c = '10122';
        caseList[4].MOS_Case_Stage__c = 'Out for Service';
        caseList[6].MOS_Case_Stage__c = 'Out for Service';
        caseList[7].MOS_Case_Stage__c = ConstantsUtility.MOS_CASE_STAGE_Pending_for_Allocation;
        caseList[7].FE_CaseNumber__c = '1022';
        caseList[7].Technician_Id__c = conList[1].Id;
        update caseList;
        Test.stopTest();
    }
    
    static testMethod void updateFieldsOnMOSCaseTest4(){
        Test.startTest();
        
        List<User> userList = [SELECT Id FROM User LIMIT 1];
        CaseTriggerHelper.setIntegrationUserId = new Set<Id>{userList[0].Id};
            String asssetRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        
        List<Case> caseList = new list<Case>([SELECT id,Customer_Consent__c,Vehicle_Registration_Number__c,Technician_Id__c,Model__c,Model_Txt__c,
                                              Customer_feedback__c,Feedback_Reason__c,MOS_Case_Stage__c,Status,Action_Taken__c,Allocated_Dealer__c,
                                              RO_Observation__c,Job_Type__c,FE_CaseNumber__c,Customer_Cancellation__c FROM case where recordType.Name =: 'MOS Case']);
        caseList[1].MOS_Case_Stage__c = 'Out for Service';
        caseList[1].FE_CaseNumber__c = '1022';
        update caseList;
        Test.stopTest();
    }
    
    static testMethod void updateFieldsOnMOSCaseTest8(){
        Test.startTest();
        
        List<User> userList = [SELECT Id FROM User LIMIT 1];
        CaseTriggerHelper.setIntegrationUserId = new Set<Id>{userList[0].Id};
            String asssetRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        
        List<Case> caseList = new list<Case>([SELECT id,Customer_Consent__c,Vehicle_Registration_Number__c,Technician_Id__c,Model__c,Model_Txt__c,
                                              Customer_feedback__c,Feedback_Reason__c,MOS_Case_Stage__c,Status,Action_Taken__c,Allocated_Dealer__c,
                                              RO_Observation__c,Job_Type__c,FE_CaseNumber__c,Customer_Cancellation__c FROM case where recordType.Name =: 'MOS Case']);
        caseList[0].Job_Type__c = ConstantsUtility.Job_Type_Breakdown;
        caseList[0].FE_CaseNumber__c = '101';
        caseList[0].MOS_Case_Stage__c = ConstantsUtility.Customer_Cancelled;
        caseList[0].Customer_Cancellation__c = 'High Charges';
        caseList[2].FE_CaseNumber__c = '12022';
        caseList[3].FE_CaseNumber__c = '12002';
        caseList[1].Customer_feedback__c = 'Poor';
        caseList[1].Feedback_Reason__c = 'High Charges';
        caseList[1].Status = ConstantsUtility.CaseStatusClosed;
        update caseList;
        Test.stopTest();
    }
}