/**
 * @author            : Nitin
 * @group             : 
 * @last modified on  : 10-16-2020
**/
@isTest
public class BatchUpdateServiceCCMTest {
@isTest static void executeTest(){
        
         //Accounts Creation
         List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
         insert accList;
         
         List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
         insert conList;
         
         List<User> usr = TestDataFactory.createUserData('Portal', 'Call Center/Workshop Manager', conList);
         insert usr;

        test.startTest();
        SchedulableContext sc = null;
        BatchUpdateServiceCCM tsc = new BatchUpdateServiceCCM();
        tsc.execute(sc);
        test.stopTest();
         
    }     
}