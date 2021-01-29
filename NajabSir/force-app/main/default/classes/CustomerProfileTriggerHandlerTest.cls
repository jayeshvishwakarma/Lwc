@isTest
public class CustomerProfileTriggerHandlerTest {
    @testsetup
    static void testRecordCreate(){
        list<Account> customerAccountList = TestDataFactory.createPersonAccount(1);
        Insert customerAccountList;
        list<Customer_Profile__c> customerProfileList = TestdataFactory.createCustomerProfile(200);
        for(Customer_Profile__c cp : customerProfileList){
            cp.Customer__c = customerAccountList[0].Id;
        }
        insert customerProfileList;
    }
     
    @istest 
    static void updateTest(){
        map<id,Customer_Profile__c> cpMap = new map<id,Customer_Profile__c>();
        list<Account> acclistforMap = new list<Account>([Select id, name,Preferred_Video_Content__c from Account where isPersonAccount =true]);
        list<Customer_Profile__c> cplist = new list<Customer_Profile__c>([Select id ,Preferred_Video_Content__c,Customer__c from Customer_Profile__c]);
        for(Customer_Profile__c cp : cplist){
            cp.Preferred_Video_Content__c = 'Instagram';
            cpmap.put(cp.Customer__c,cp);
        }
        update cpmap.values();
        list<Account> acclist = new list<Account>([Select id, name,Preferred_Video_Content__c from Account where isPersonAccount =true]);
        System.assertEquals(acclist[0].Preferred_Video_Content__c, cpmap.get(acclist[0].Id).Preferred_Video_Content__c);
        System.assertNotEquals(acclistforMap[0].Preferred_Video_Content__c, cpmap.get(acclistforMap[0].Id).Preferred_Video_Content__c);
    }
}