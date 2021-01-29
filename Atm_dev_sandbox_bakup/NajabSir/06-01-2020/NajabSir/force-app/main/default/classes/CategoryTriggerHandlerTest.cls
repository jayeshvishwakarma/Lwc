/**
 * @File Name          : CategoryTriggerHandlerTest.cls
 * @Description        : Test Class of the apex class 'CategoryTriggerHandler' and 'CategoryTrigger'
 * @Author             : Deepak Kumar
**/

@IsTest
private class CategoryTriggerHandlerTest {

    @testSetup static void createTestData() {
        List<Category__c> primaryCategories = TestDataFactory.createCategories(1, 'Primary');
        primaryCategories[0].Channel__c = 'Arena';
        primaryCategories[0].Case_Type__c = 'Complaint';
        primaryCategories[0].Business_Area__c = 'Sales';
        primaryCategories[0].Case_Stage__c = 'Pre Sales';
        insert primaryCategories;
        List<Category__c> secondaryCategories = TestDataFactory.createCategories(1, 'Secondary');
        secondaryCategories[0].Primary_Category__c = primaryCategories[0].Id;
        secondaryCategories[0].Channel__c = 'Arena';
        secondaryCategories[0].Case_Type__c = 'Complaint';
        secondaryCategories[0].Business_Area__c = 'Sales';
        secondaryCategories[0].Case_Stage__c = 'Pre Sales';
        insert secondaryCategories;
    }
    static testMethod void updateExternalIdTest() {
        Test.startTest();
        List<Category__c> categories = new List<Category__c>([SELECT Id FROM Category__c]);
        update categories;
        Test.stopTest();
    }
}