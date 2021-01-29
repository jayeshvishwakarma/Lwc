/**
* @File Name          : WorkshopInformationSMSTest.cls
* @Description        : It is utilized for WorkshopInformationSMS Apex code coverage
* @Author             : Nitin Ghai
* @Group              : 
* Apex Class           : WorkshopInformationSMS
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 10-17-2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0        18/03/2020               Nitin Ghai                  Initial Version
**/
@isTest
public class WorkshopInformationSMSTest {
    
    @isTest
    public static void run1(){
        test.startTest();
        // To Create Dealer records
        List<Account> dealerAccount =TestDataFactory.createBusinessAccount(1,'Dealer');
        dealerAccount[0].Dealer_CC_Phone__c='9811349999';
        insert dealerAccount;
        
        //To Create Customer records
        List<Account> customerRec = TestDataFactory.createPersonAccount(1);
        customerRec[0].PersonMobilePhone='9811349999';
        insert customerRec;
        
        Id delerRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('PSF_Follow_Up').getRecordTypeId();
        
        List<Task> taskList = TestDataFactory.createTask(1,customerRec[0],delerRecordTypeId);
        insert taskList;
        
        WorkshopInformationSMS.wrapperClass wrap =WorkshopInformationSMS.fetchWorkShopDetails(customerRec[0].Id);
        System.assertEquals(1, wrap.customerRec.size());
        BasicReturn result= WorkshopInformationSMS.createMcCommunicationrecord(dealerAccount[0].Id,customerRec[0].Name,customerRec[0].PersonMobilePhone,customerRec[0].Id,customerRec[0].PersonContactId,'test');
        System.assertEquals('Success', result.status) ;
        test.stopTest();
    }
    @isTest
    public static void run2(){
        test.startTest();
        // To Create Dealer records
        List<Account> dealerAccount =TestDataFactory.createBusinessAccount(1,'Dealer');
        dealerAccount[0].Dealer_CC_Phone__c='919811349999';
        insert dealerAccount;
        
        //To Create Customer records
        List<Account> customerRec = TestDataFactory.createPersonAccount(1);
        customerRec[0].PersonMobilePhone='9811349999';
        insert customerRec;
        
        Id delerRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('PSF_Follow_Up').getRecordTypeId();
        
        List<Task> taskList = TestDataFactory.createTask(1,customerRec[0],delerRecordTypeId);
        insert taskList;
        
        WorkshopInformationSMS.wrapperClass wrap =WorkshopInformationSMS.fetchWorkShopDetails(customerRec[0].Id);
        System.assertEquals(1, wrap.customerRec.size());
        BasicReturn result= WorkshopInformationSMS.createMcCommunicationrecord(dealerAccount[0].Id,customerRec[0].Name,customerRec[0].PersonMobilePhone,customerRec[0].Id,customerRec[0].PersonContactId,'test');
        System.assertEquals('Success', result.status) ;
        test.stopTest();
    } 
    @isTest
    public static void run3(){
        test.startTest();
        // To Create Dealer records
        List<Account> dealerAccount =TestDataFactory.createBusinessAccount(1,'Dealer');
        dealerAccount[0].Dealer_CC_Phone__c='919811349999';
        insert dealerAccount;
        
        //To Create Customer records
        List<Account> customerRec = TestDataFactory.createPersonAccount(1);
        customerRec[0].PersonMobilePhone='9811349999';
        insert customerRec;
        
        Id delerRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('PSF_Follow_Up').getRecordTypeId();
        
        List<Task> taskList = TestDataFactory.createTask(1,customerRec[0],delerRecordTypeId);
        insert taskList;
        
        WorkshopInformationSMS.wrapperClass wrap =WorkshopInformationSMS.fetchWorkShopDetails(customerRec[0].Id);
        System.assertEquals(1, wrap.customerRec.size());
        BasicReturn result= WorkshopInformationSMS.createMcCommunicationrecord(dealerAccount[0].Id,customerRec[0].Name,'nb**a8',customerRec[0].Id,customerRec[0].PersonContactId,'test');
        System.assertEquals('Success', result.status) ;
        test.stopTest();
    }     
    
}