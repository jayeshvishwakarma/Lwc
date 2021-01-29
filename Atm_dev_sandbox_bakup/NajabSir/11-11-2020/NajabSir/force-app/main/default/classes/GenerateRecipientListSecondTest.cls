/**
* @File Name          : GenerateRecipientListSecondTest.cls
* @Description        : Test Class of the apex class 'GenerateRecipientListFirst'
* @Author             : Tejendra
**/

@isTest
public class GenerateRecipientListSecondTest {
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
        
        List<Recipient_Master__c> recipientMasterList = TestDataFactory.createRecipientMaster(12,'Sales');
        /*for(Recipient_Master__c recipientMaster : recipientMasterList){
            recipientMaster.External_ID__c = 'Test123';
        }*/
        recipientMasterList[0].External_ID__c  = 'Nexa_Complaint_Sales_N1';
        recipientMasterList[1].External_ID__c  = 'Nexa_Complaint_Sales';
        recipientMasterList[2].External_ID__c  = 'Nexa_Complaint_Sales_Pre Sales';
        recipientMasterList[3].External_ID__c  = 'Nexa_Complaint_Sales_Pre Sales_N2';
        recipientMasterList[4].External_ID__c  = 'Nexa_Complaint_Sales_Pre Sales_Test_N2';
        recipientMasterList[5].External_ID__c  = 'Nexa_Complaint_Sales_Pre Sales_Test'; 
        recipientMasterList[6].External_ID__c  = 'Nexa_Complaint_Sales_Pre Sales_Test_N3';
        recipientMasterList[7].External_ID__c  = 'Nexa_Complaint_Sales_Pre Sales_null';
        recipientMasterList[8].External_ID__c  = 'Nexa_Complaint_Sales_Pre Sales_null_N4';
        recipientMasterList[9].External_ID__c  = 'Nexa_Complaint_Sales_Pre Sales_null_Test';
        recipientMasterList[10].External_ID__c = 'Nexa_Complaint_Sales_Pre Sales_null_Test_N4';
        recipientMasterList[11].External_ID__c = 'Nexa_Complaint_Sales_Pre Sales_null_Test_N5';
        insert RecipientMasterList;
    }
    static testMethod void method1() {
        Map<String, Category__c> categoryMasterMap = new Map<String, Category__c>();
        List<Category__c> categories = [SELECT Id,Name,Type__c,Channel__c,Case_Type__c,Business_Area__c,Case_Stage__c,Primary_Category__c,
                                        Primary_Category__r.Name,Secondary_Category__c,Region_Mandatory__c FROM Category__c ];
        for(Category__c category : categories){
          categoryMasterMap.put(category.Id, category);  
        }
        
        Map<String, String> categoryMasterFinalMap = new Map<String, String>();
        List<Recipient_Master__c> recipientMasterList = [SELECT Id, External_ID__c FROM Recipient_Master__c];
        for(Recipient_Master__c recipientMaster : recipientMasterList){
          categoryMasterFinalMap.put(recipientMaster.External_ID__c,recipientMaster.Id);   
        }
        
        Test.startTest();
        System.enqueueJob(new GenerateRecipientListSecond(categoryMasterMap,categoryMasterFinalMap));
        Test.stopTest();
        System.assertEquals(3,[SELECT Id FROM Recipient_List__c].size());
    }    
}