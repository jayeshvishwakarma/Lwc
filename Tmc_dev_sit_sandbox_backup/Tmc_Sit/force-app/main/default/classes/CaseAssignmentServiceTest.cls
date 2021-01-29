@IsTest
private class CaseAssignmentServiceTest {
    private static String createStakeHolderJSON(String actionType) {
        StakeholderHierarchy hierarchy = new StakeholderHierarchy();
        List<StakeholderHierarchy.Sales> sales = new List<StakeholderHierarchy.Sales>();
        if (actionType == 'create') {
            StakeholderHierarchy.Sales holder = new StakeholderHierarchy.Sales();
            holder.stakeHolder = 'L1';
            holder.refName = 'TESST REF';
            holder.recordId = UserInfo.getUserId();
            holder.phone = '9876543212';
            holder.email = 'test@email.com';
            sales.add(holder);
        } else {
            
        }
        hierarchy.sales = sales;
        return JSON.serialize(hierarchy);
    }
    
    @testSetup static void createTestData() {
        List<Category__c> primaryCategories = TestDataFactory.createCategories(1, 'Primary');
        insert primaryCategories;
        
        List<Category__c> secondaryCategories = TestDataFactory.createCategories(1, 'Secondary');
        secondaryCategories[0].Primary_Category__c = primaryCategories[0].Id;
        insert secondaryCategories;
        
        
        Recipient_Master__c recipientMaster = TestDataFactory.createRecipientMaster('User', 'L1', 'Sales', null);
        insert recipientMaster;
        
       // List<Recipient_List__c> recipientLists = TestDataFactory.createRecipientList(1,  secondaryCategories[0].Id,recipientMaster.Id);
       // insert recipientLists;
        
        list<Account> businessAccountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        businessAccountList[0].Stakeholder_Hierarchy__c = createStakeHolderJSON('create');
        insert businessAccountList;
        List<Implementation_Strategy__c> ImplementationStrategyRecordList = new List<Implementation_Strategy__c>();
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        
        ImplementationStrategyRecordList.add(ImplementationStrategyRecord);
        insert ImplementationStrategyRecordList;
        Id ComplaintRecordType = ConstantsUtility.COMPLAINT_CASE_RECORD_TYPE_ID;
        List<case> casesList = TestDataFactory.createCase(2, ComplaintRecordType);
        List<Product2> productsList = TestDataFactory.createProducts( 'Variants',1);
     	productsList[0].Model__c = 'AK';
        insert productsList;
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'Yes';
            c.Channel__c = 'Arena';
            c.Case_Type__c = 'Complaint';
            c.Business_Area__c = 'Sales'; 
            c.Model__c = 'AK'; // Added for custom validation - Model and Variant Required for Selected Case Type
            c.Variant__c = productsList[0].id; // Added for custom validation - Model and Variant Required for Selected Case Type
            c.Case_Stage__c = 'Pre Sales';
            c.Primary_Category_ID__c = primaryCategories[0].Id;
            c.Secondary_Category_ID__c = secondaryCategories[0].Id;
            c.Dealer_Name__c = businessAccountList[0].Id;
        }
        insert casesList;
    }
    
    static testMethod void getOnloadInfoForCaseActionWithCaseActionTest() {
        Test.startTest();
        
        Test.stopTest();
    }
}