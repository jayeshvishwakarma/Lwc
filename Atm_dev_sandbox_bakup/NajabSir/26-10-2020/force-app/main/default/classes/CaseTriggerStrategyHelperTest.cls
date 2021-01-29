/**
* @File Name          : CaseTriggerStrategyHelperTest.cls
* @Description        : Test Class of the apex class 'CaseTriggerStrategyHelper'
* @Author             : Deepak Kumar
**/
@IsTest
private class CaseTriggerStrategyHelperTest {
    @testSetup static void createTestData() {
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        insert ImplementationStrategyRecord;
        List<User> internalUsers = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{});
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
            c.Channel__c = ConstantsUtility.ARENA_CASE_CHANNEL;
            c.Case_Type__c = ConstantsUtility.DEALER_QUERY_CASE_TYPE;
            c.Customer__c = personAccountList[0].Id;
            c.Dealer_Name__c = businessAccountList[0].Id;
            c.Stakeholders_JSON__c = stakeHolderJson;
            c.Selected_Hierarchy_Type__c = 'sales';
            c.FCR_Conducted__c = 'Yes';
            c.Outlet_Type__c = 'Arena WS';
            c.Assigned_Date__c = Date.today();
        }
        casesList[0].Business_Area__c = ConstantsUtility.SERVICE_BODYSHOP_CASE_BUSINESS_AREA;
        casesList[1].Business_Area__c = ConstantsUtility.SERVICE_WORKSHOP_CASE_BUSINESS_AREA;
        insert casesList;
        // casesList[1].FCR_Conducted__c = 'Yes' ;
        // insert casesList[1];
        
        List<Campaign> campaigns = TestDataFactory.createCampaign(3);
        for(Integer i = 0; i > campaigns.size() ; i++){
            campaigns[i].Campaign_Code__c = '67500'+i;
            campaigns[i].RecordTypeId = ConstantsUtility.CAMPAIGN_CALL_CAMPAIGN_RECORD_TYPE_ID;
        }
        insert campaigns;
        
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
        List<Case> cases = [SELECT Id,Status,Mobile_Number__c FROM Case LIMIT 1];
        
        update cases;
        Test.stopTest();
    }
    
    static testMethod void caseTeamCreationTest(){
        
        Id serviceRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        system.debug('test-- serviceRecordType--'+serviceRecordType);
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseVehicleServiceTriggerServiceImpl','Service');
        insert ImplementationStrategyRecord;
        List<User> internalUsers = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{});
        insert internalUsers;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        list<Account> businessAccountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        businessAccountList[0].Stakeholder_Hierarchy__c = stakeHolderJson;
        insert businessAccountList;
        List<case> casesList = TestDataFactory.createCase(1, serviceRecordType );
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
            c.OwnerId =userInfo.getUserId();
           // c.recordtypeid = ConstantsUtility.QUERY_FEEDBACK_CASE_RECORD_TYPE_ID ;
            c.Mobile_Number__c = '9760332976';
        }
        insert casesList; 
        system.debug('ownerid -->'+casesList[0].OwnerId);
        
        Account acc = New Account();
        acc.Name = 'test123';
        acc.User__c =  casesList[0].OwnerId ; 
        acc.RecordTypeId = ConstantsUtility.USER_ACCOUNT_RECORDTYPE_ID ;
        insert acc ; 
        system.debug('test -->'+acc.RecordTypeId);
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
        spanPhoneEmail.To_Date__c =system.today() +5;
        insert spanPhoneEmail ; 
      }
    
    static testMethod void markMcCommunicationCancelledTest(){
        Id serviceRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        system.debug('test-- serviceRecordType--'+serviceRecordType);
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseVehicleServiceTriggerServiceImpl','Service');
        insert ImplementationStrategyRecord;
        List<User> internalUsers = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{});
        insert internalUsers;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        list<Account> businessAccountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        businessAccountList[0].Stakeholder_Hierarchy__c = stakeHolderJson;
        insert businessAccountList;
        List<case> casesList = TestDataFactory.createCase(1, serviceRecordType );
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
            c.OwnerId =userInfo.getUserId();
           // c.recordtypeid = ConstantsUtility.QUERY_FEEDBACK_CASE_RECORD_TYPE_ID ;
            c.Mobile_Number__c = '9760332976';
            c.CCP_Complete_Time__c = Datetime.newInstance(2020, 2, 17) ;
            
        }
        insert casesList; 
         MC_Communication__c mcComm =  new MC_Communication__c();
        mcComm.Type__c = ConstantsUtility.DEALER_RESOLUTION_ESCALATION ;
        mcComm.Status__c = ConstantsUtility.CANCELLED ;
        mcComm.Case__c = casesList[0].id ;
        insert mcComm;  
      }
     
    
}