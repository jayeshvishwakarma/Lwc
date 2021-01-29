/**
* @File Name          : CategoryRecipientMasterScriptTest.cls
* @Description        : Test Class of the apex class 'CategoryRecipientMasterScript'
* @Author             : Tejendra
**/
@isTest
public class CategoryRecipientMasterScriptTest {
    
    @testSetup static void createTestData() {
        
        List<Account> accountList = TestDataFactory.createDealerAccount(1);
        
        insert accountList;
        
        accountList[0].Id = Label.MSIL_Stakeholder_Account;
        update accountList;
        
        List<Contact> contactList = TestDataFactory.createTestContact(1,accountList[0].Id); 
        contactList[0].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('MSIL_Stakeholder').getRecordTypeId();
        contactList[0].email = 'nitinghai115@gmail.com';
        
        insert contactList; 
        
        List<Category__c> categoryList= TestDataFactory.createCategories(3,'Primary');
        for(Category__c category : categoryList){
            category.Channel__c = 'Nexa';
            category.Case_Type__c = 'Complaint';
            category.Business_Area__c = 'Sales';       
            category.Case_Stage__c = 'Pre Sales';
            category.Region_Mandatory__c = true;
        }
        categoryList[1].Type__c = 'Tertiary';
        categoryList[2].Type__c = 'Secondary';
        
        insert categoryList;
        
        List<Recipient_Master__c> recipientMasterList = TestDataFactory.createRecipientMaster(1,'Sales');
        for(Recipient_Master__c recipientMaster : recipientMasterList){
            recipientMaster.External_ID__c = 'Nexa_Complaint_Sales_N1';
        }
        
        insert RecipientMasterList;
    }
    
    static testMethod void method1(){
        Test.startTest();
        CategoryRecipientMasterScript.manageCategoryMasters();
        Test.stopTest();
        System.assertEquals(108,[SELECT Id FROM Category__c].size());
    }
    
    static testMethod void method2(){
        Test.startTest();
        CategoryRecipientMasterScript.manageRecipientMaster();
        Test.stopTest();
        System.assertEquals(3289,[SELECT Id FROM Recipient_Master__c].size());
    }
    
    static testMethod void method3(){
        Test.startTest();
        CategoryRecipientMasterScript.createComplaintCORecords();
        Test.stopTest();
        System.assertEquals(619,[SELECT Id FROM Complaint_Coordinator__c].size());
    }
    
    static testMethod void method4(){
        Test.startTest();
        CategoryRecipientMasterScript.manageRecipientList();
        Test.stopTest();
    }
}