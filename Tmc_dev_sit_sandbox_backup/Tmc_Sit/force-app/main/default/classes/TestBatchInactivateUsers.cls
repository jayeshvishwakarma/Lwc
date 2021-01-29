/**
 * @description       : 
 * @author            : Rajesh Ramachandran
 * @group             : 
 * @last modified on  : 08-18-2020
 * @last modified by  : Rajesh Ramachandran
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   08-18-2020   Rajesh Ramachandran   Initial Version
**/
@isTest
public with sharing class TestBatchInactivateUsers {
    

    @isTest
    static void testDriverInactivation(){

         //Accounts Creation
         List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
         insert accList;
         
         List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
         insert conList;
         
         List<User> usr = TestDataFactory.createUserData('Portal', 'Driver', conList);
         insert usr;

         test.startTest();
         BatchInactivateUsers biu = new BatchInactivateUsers();
         Database.executeBatch(biu);
         test.stopTest();
         List<User> lsUsr = [select id from user where profile.name = 'Driver' and isActive = true and createddate = today];
         system.assertEquals(lsUsr.size(),0,'User not inactivated' );        

    }

    @isTest static void executeTest(){
        
         //Accounts Creation
         List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
         insert accList;
         
         List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
         insert conList;
         
         List<User> usr = TestDataFactory.createUserData('Portal', 'Driver', conList);
         insert usr;

        test.startTest();
        SchedulableContext sc = null;
        BatchInactivateUsers tsc = new BatchInactivateUsers();
        tsc.execute(sc);
        test.stopTest();
         
    }      

}