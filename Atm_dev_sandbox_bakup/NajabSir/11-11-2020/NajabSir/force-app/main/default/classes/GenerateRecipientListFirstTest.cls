/**
* @File Name          : GenerateRecipientListFirstTest.cls
* @Description        : Test Class of the apex class 'GenerateRecipientListFirst'
* @Author             : Tejendra
**/

@isTest
public class GenerateRecipientListFirstTest {
    
    @testSetup static void createTestData() {
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
        System.enqueueJob(new GenerateRecipientListFirst());
        Test.stopTest();
    }    
}