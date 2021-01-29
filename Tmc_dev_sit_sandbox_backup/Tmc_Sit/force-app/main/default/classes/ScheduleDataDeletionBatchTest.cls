/**
* @File Name          : ScheduleDataDeletionBatchTest.cls
* @Description        : This class will cover ManageIndentifyJobs, ManageDeleteJobs, DataIndentifyBatch, DataDeleteBatch
* @Author             : 
* @Group              : 
* @Last Modified By   : Brijesh Singh
* @Last Modified On   : 28th Jul 2020
* @Modification Log   : 

**/


@IsTest()  
       
public class ScheduleDataDeletionBatchTest{
    
    @TestSetup
    private static void testDataCreation(){
        Account acc = new Account();
        acc.FirstName = 'AccountOne';
        acc.LastName = 'To Delete Account';
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        INSERT acc; 
        
        Account assetacc = new Account();
        assetacc.FirstName = 'AccountTwo';
        assetacc.LastName= 'Asset Account';
        INSERT assetacc;
        
        Asset assObj = new Asset();
        assObj.Name = 'Identify Asset';
        assObj.AccountId = assetacc.Id;
        assObj.recordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId(); 
        INSERT assObj;
        
       
        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        Insert IS;
        
        
        
        
        Opportunity oppObj = new Opportunity();
        oppobj.First_Name__c = 'Car';
        oppObj.Name = 'Link Customer';
        oppObj.CloseDate = System.Today().addDays(60);
        oppObj.Buyer_Type__c = '03';
        oppObj.Line_Of_Business__c = 'Nexa';
        oppObj.StageName = 'New';
        oppObj.Customer__c = acc.Id;
        oppObj.LeadSource = 'Email';
        oppObj.Profession_Type__c = 'C';
        oppObj.recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vehicle Sales').getRecordTypeId();  
        INSERT oppObj;
        
    }
    
    @isTest
    private static void testUnit(){
        List<Account> accList = [Select Id,Name From Account Where LastName = 'To Delete Account' LIMIT 1];
        
                                                           
        list<Delete_Job_Sequence__mdt> currentSequence  = [select id, Batch_Size__c, Query__c 
                                                            FROM Delete_Job_Sequence__mdt WHERE
                                                            type__c = 'Delete'
                                                            AND DeveloperName = 'Test_Class_Delete_Data'  LIMIT 1]; 
        Test.StartTest();
        ScheduleDataDeletionBatch sh1 = new ScheduleDataDeletionBatch();     
        String sch = '0  00 1 3 * ?';
        system.schedule('Test', sch, sh1);
        Test.stopTest();  
    }  
    
    @isTest
    private static void uniteTest2(){
        List<Account> accList = [Select Id,Name,(Select Id,Name FROM Enquiries__r) From Account LIMIT 1];
        System.debug('11111111 Test Class ==>    '+accList );
        
                                                           
        list<Delete_Job_Sequence__mdt> currentSequence  = [select id, Batch_Size__c, Query__c 
                                                            FROM Delete_Job_Sequence__mdt WHERE
                                                            type__c = 'Delete'
                                                            AND DeveloperName = 'Test_Class_Delete_Data'  LIMIT 1]; 
        Test.StartTest();
        ScheduleDataDeletionBatch sh1 = new ScheduleDataDeletionBatch();     
        String sch = '0  00 1 3 * ?';
        system.schedule('Test', sch, sh1);
        Test.stopTest();  
    }
    
    @isTest
    private static void uniteTest3(){
        list<Delete_Job_Sequence__mdt> currentSequence1  = [select id, Batch_Size__c, Query__c ,
                                                           Field_To_Be_Updated__c
                                                           FROM Delete_Job_Sequence__mdt WHERE 
                                                           type__c = 'Identify'
                                                           AND DeveloperName = 'Test_Class_Identity_Data' LIMIT 1];
                                                           
        new ManageIndentifyJobs(0);
    }
    
    @isTest
    private static void uniteTest4(){
        list<Delete_Job_Sequence__mdt> currentSequence  = [select id, Batch_Size__c, Query__c 
                                                            FROM Delete_Job_Sequence__mdt WHERE
                                                            type__c = 'Delete'
                                                            AND DeveloperName = 'Test_Class_Delete_Data'  LIMIT 1]; 
                                                           
        new manageDeleteJobs(0);
    }
    
    @isTest
    private static void uniteTest5(){
        Account accountUn5 = new Account();
        accountUn5.FirstName = 'AccountTwo';
        accountUn5.LastName= 'Asset Account';
        INSERT accountUn5;
        
        Asset assObjun5 = new Asset();
        assObjun5.Name = 'Identify Asset';
        assObjun5.AccountId = accountUn5.Id;
        assObjun5.recordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId(); 
        INSERT assObjun5;
        
        Test.startTest();
        DataIndentifyBatch dib = new DataIndentifyBatch('Select Id,Name,To_Delete__c, (Select Id, Name FROM Loyalty_Enrollments__r) FROM Asset LIMIT 1',50,'To_Delete__c','Loyalty_Enrollments__r');
        Database.executeBatch(dib );
        Test.stopTest();
    }
    
    @isTest
    private static void uniteTest6(){
        Account accountUn6 = new Account();
        accountUn6.FirstName = 'AccountTwo';
        accountUn6.LastName= 'Asset Account';
        INSERT accountUn6;
        
        Asset assObjun6 = new Asset();
        assObjun6.Name = 'Identify Asset';
        assObjun6.AccountId = accountUn6.Id;
        assObjun6.recordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId(); 
        INSERT assObjun6;
        
        Test.startTest();
        DataIndentifyBatch dib = new DataIndentifyBatch('Select Id,Name,To_Delete__c FROM Asset LIMIT 1',50,'To_Delete__c','');
        Database.executeBatch(dib );
        Test.stopTest();
    }
    /*
    @isTest
    private static void uniteTest7(){
        Test.startTest();
        DataIndentifyBatch dib = new DataIndentifyBatch('',50,'To_Delete__c','');
        Database.executeBatch(dib );
        Test.stopTest();
    }
    
    @isTest
    private static void uniteTest8(){
        Account accountUn8 = new Account();
        accountUn8.FirstName = 'AccountTwo';
        accountUn8.LastName= 'Asset Account';
        INSERT accountUn8;
        
        Asset assObjun8 = new Asset();
        assObjun8.Name = 'Identify Asset';
        assObjun8.AccountId = accountUn8.Id;
        assObjun8.recordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId(); 
        INSERT assObjun8;
        
        assObjun8.Email__c = 'test@gmail.com';
        UPDATE assObjun8;
        
        Test.startTest();
        DataIndentifyBatch dib = new DataIndentifyBatch('Select Id,Name,To_Delete__c FROM Asset LIMIT 1',50,'To_Delete__c','');
        Database.executeBatch(dib );
        Test.stopTest();
    }
    */
}