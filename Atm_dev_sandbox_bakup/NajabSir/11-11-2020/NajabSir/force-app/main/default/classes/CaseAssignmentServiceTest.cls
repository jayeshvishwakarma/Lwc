@IsTest
private class CaseAssignmentServiceTest {
    @testSetup static void createTestData() {
        Implementation_Strategy__c ImplementationStrategyRecordOpp = TestDataFactory.createImplementation('OpportunityVehicleTriggerServiceImpl','Vehicle_Sales');
        ImplementationStrategyRecordOpp.Use_Case__c = 'OpportunityTriggers';
        insert ImplementationStrategyRecordOpp;
        
        
        Approval_Notification_Setting__c notificationSetting = TestDataFactory.createApprovalNotificationSetting('Complaint',true);
        insert notificationSetting;

        List<Category__c> primaryCategories = TestDataFactory.createCategories(1, 'Primary');
        insert primaryCategories;
        
        List<Category__c> secondaryCategories = TestDataFactory.createCategories(1, 'Secondary');
        secondaryCategories[0].Primary_Category__c = primaryCategories[0].Id;
        insert secondaryCategories;
        Recipient_Master__c recipientMaster = TestDataFactory.createRecipientMaster('User', 'L1', 'Sales', null);
        insert recipientMaster;
        
        List<Recipient_List__c> recipientLists = TestDataFactory.createRecipientList(1,  secondaryCategories[0].Id,recipientMaster.Id);
        insert recipientLists;
        
        list<Account> businessAccountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        businessAccountList[0].Stakeholder_Hierarchy__c = TestDataFactory.createStakeHolderJSON( ConstantsUtility.ACCOUNT_OBJ);
        businessAccountList[0].Primary_QCM__c = UserInfo.getUserId();
        insert businessAccountList;
        List<Implementation_Strategy__c> ImplementationStrategyRecordList = new List<Implementation_Strategy__c>();
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        
        ImplementationStrategyRecordList.add(ImplementationStrategyRecord);
        insert ImplementationStrategyRecordList;
        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        //Product List
        list<Product2> productList = TestDataFactory.createProducts('Variants', 1);
        productList[0].Model__c = 'BA';
        productList[0].Enquiry__c = 'Yes';
        Insert productList;

        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].accountId = personAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Current_Open_Follow_up__c = null;
        oppList[0].Customer__c = personAccountList[0].PersonContactId;
        Opportunity opp = oppList[0];
        opp.First_Name__c = 'Test Dealer';
        opp.Dealership__c = businessAccountList[0].Id;
        insert oppList;

        Id ComplaintRecordType = ConstantsUtility.COMPLAINT_CASE_RECORD_TYPE_ID;
        List<case> casesList = TestDataFactory.createCase(2, ComplaintRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'No';
            c.Channel__c = 'Arena';
            c.Case_Type__c = 'Complaint';
            c.Business_Area__c = 'Sales'; 
            c.Case_Stage__c = 'Pre Sales';
            c.Primary_Category_ID__c = primaryCategories[0].Id;
            c.Secondary_Category_ID__c = secondaryCategories[0].Id;
            c.Dealer_Name__c = businessAccountList[0].Id;
            c.FCR_Conducted__c = ConstantsUtility.YES;
            c.Enquiry__c = oppList[0].Id;
        }
        insert casesList;

    }
    
    static testMethod void updateToServiceBodyShopTest() {
        Test.startTest();
        Case caseObj = [SELECT Business_Area__c FROM Case LIMIT 1];
        caseObj.Business_Area__c = ConstantsUtility.SERVICE_BODYSHOP_CASE_BUSINESS_AREA;
        update caseObj;
        Test.stopTest();
    }
    static testMethod void updateToServiceBodyWorkShopTest() {
        Test.startTest();
        Case caseObj = [SELECT Business_Area__c,Channel__c FROM Case LIMIT 1];
        caseObj.Business_Area__c = ConstantsUtility.SERVICE_WORKSHOP_CASE_BUSINESS_AREA;
        caseObj.Channel__c = ConstantsUtility.NEXA_CASE_CHANNEL;
        update caseObj;
        Test.stopTest();
    }
    static testMethod void updateToAccessoriesTest() {
        Test.startTest();
        Case caseObj = [SELECT Business_Area__c FROM Case LIMIT 1];
        caseObj.Business_Area__c = ConstantsUtility.ACCESSORIES_CASE_BUSINESS_AREA;
        update caseObj;
        Test.stopTest();
    }
    static testMethod void updateToFinanceTest() {
        Test.startTest();
        Case caseObj = [SELECT Business_Area__c FROM Case LIMIT 1];
        caseObj.Business_Area__c = ConstantsUtility.FINANCE_CASE_BUSINESS_AREA;
        update caseObj;
        Test.stopTest();
    }
    static testMethod void updateToTrueValueTest() {
        Test.startTest();
        Case caseObj = [SELECT Channel__c FROM Case LIMIT 1];
        caseObj.Channel__c = ConstantsUtility.TRUEVALUE_CASE_CHANNEL;
        update caseObj;
        Test.stopTest();
    }
    static testMethod void updateToMSDSTest() {
        Test.startTest();
        Case caseObj = [SELECT Business_Area__c,Channel__c FROM Case LIMIT 1];
        caseObj.Channel__c = ConstantsUtility.MSDS_CASE_CHANNEL;
        update caseObj;
        Test.stopTest();
    }
    static testMethod void updateToMSGPTest() {
        Test.startTest();
        Case caseObj = [SELECT Business_Area__c,Channel__c FROM Case LIMIT 1];
        caseObj.Channel__c = ConstantsUtility.MSGP_CASE_CHANNEL;
        update caseObj;
        Test.stopTest();
    }
    static testMethod void updateToMLoyaltyProgramTest() {
        Test.startTest();
        Case caseObj = [SELECT Business_Area__c,Channel__c FROM Case LIMIT 1];
        caseObj.Business_Area__c = ConstantsUtility.LOYALTY_PROGRAM_CASE_BUSINESS_AREA;
        update caseObj;
        Test.stopTest();
    }

    static testMethod void updateToMsilQueryTest() {
        Test.startTest();
        Account dealerAccount = [SELECT Stakeholder_Hierarchy__c FROM Account WHERE RecordType.Name = :ConstantsUtility.DEALER_RECORDTYPE LIMIT 1];
        Recipient_Master__c recipientMaster = [SELECT MSIL_Stakeholder_JSON__c FROM Recipient_Master__c  LIMIT 1];
        recipientMaster.MSIL_Stakeholder_JSON__c = dealerAccount.Stakeholder_Hierarchy__c;
        update recipientMaster;
        Case caseObj = [SELECT Case_Type__c,Channel__c,Dealer_Name__c FROM Case LIMIT 1];
        caseObj.Case_Type__c = ConstantsUtility.MSIL_QUERY_CASE_TYPE;
        caseObj.Dealer_Name__c = null;
        update caseObj;
        Test.stopTest();
    }
    static testMethod void updateToMsilQueryQueueOwnerTest() {
        Test.startTest();
        Account dealerAccount = [SELECT Stakeholder_Hierarchy__c FROM Account WHERE RecordType.Name = :ConstantsUtility.DEALER_RECORDTYPE LIMIT 1];
        Recipient_Master__c recipientMaster = [SELECT MSIL_Stakeholder_JSON__c,Owner_Type__c,Queue_Name__c FROM Recipient_Master__c  LIMIT 1];
        recipientMaster.MSIL_Stakeholder_JSON__c = dealerAccount.Stakeholder_Hierarchy__c;
        recipientMaster.Owner_Type__c = ConstantsUtility.QUEUE;
        recipientMaster.Queue_Name__c = ConstantsUtility.UNASSIGNED_QUEUE;
        update recipientMaster;
        Case caseObj = [SELECT Case_Type__c,Channel__c,Dealer_Name__c,Business_Area__c FROM Case LIMIT 1];
        caseObj.Case_Type__c = ConstantsUtility.MSIL_QUERY_CASE_TYPE;
        caseObj.Business_Area__c = ConstantsUtility.ACCESSORIES_CASE_BUSINESS_AREA;
        caseObj.Dealer_Name__c = null;
        update caseObj;
        Test.stopTest();
    }
    static testMethod void updateToMsilQueryNoOwnerTest() {
        Test.startTest();
        Case caseObj = [SELECT Case_Type__c,Channel__c,Dealer_Name__c,Business_Area__c FROM Case LIMIT 1];
        caseObj.Channel__c = ConstantsUtility.MS_CORPORATE_CASE_CHANNEL;
        caseObj.Case_Type__c = ConstantsUtility.MSIL_QUERY_CASE_TYPE;
        caseObj.Business_Area__c = ConstantsUtility.SALES_CASE_BUSINESS_AREA;
        caseObj.Dealer_Name__c = null;
        update caseObj;
        Test.stopTest();
    }
}