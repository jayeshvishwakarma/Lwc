/**
    Name           :   ZipcodeCheckTest
    Author         :   iBirds Services
    Date           :   30 April, 2019
    Description    :   This is a test class of AccountTriggerHelper Class.
**/
@isTest
public class ZipcodeCheckTest{
      //created on 30 april 2019 by shikha
      @isTest
      static void testUnit1(){   
        Test.startTest();
            Account newAcc = new Account(Name = 'Test Co.', ShippingPostalCode = '1314cb', Connectivity_portfolio__c = 'Business', Huisnummer__c = '33', 
                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Excellence').getRecordTypeId());
            insert newAcc;
            
            Last_Batch_Run__c lastBatch = new Last_Batch_Run__c(name = 'ZipCode Check', Last_Scheduled_Batch__c = system.now());
            insert lastBatch;
            AccountTriggerHelper.isZipCodeCheckCalled = false;
            
            Account acc = [select id, Connectivity_portfolio__c from Account where id =: newAcc.id];
            acc.Connectivity_portfolio__c = 'SMB';
            acc.Check_Beschikbaarheid__c = true;
            update acc;
            
            /*Last_Batch_Run__c setting = new Last_Batch_Run__c();
            setting.Name = 'ZipCode Check';
            setting.Last_Scheduled_Batch__c = system.now();
            insert setting;*/
                
            list<Available_Supplier__c> supplierList = [select id, Account__c from Available_Supplier__c where Account__c =: acc.id];
            
            if(supplierList.size() > 0){
                list<Available_Speed__c> speedList = [select id, Available_Supplier__c from Available_Speed__c where Available_Supplier__c =: supplierList[0].id];    
                if(speedList.size() > 0){
                    system.assertEquals(speedList[0].Available_Supplier__c, supplierList[0].id);
                }
            }
            delete acc;
            
        Test.stopTest();

    }
}