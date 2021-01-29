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
	
	  static testmethod void test5(){
    
         DSE_Report_RUn__c cs = new DSE_Report_RUn__c();
                cs.Name='DSE Report Run';
                cs.Daily_End_Time__c=system.now().addDays(-1);
                cs.Month_End_Time__c=(system.now()).addMonths(-1);
               insert cs;
         //For Code Creation
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;
        
         //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
            accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;
        
        //Contacts Creation 
        List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert conList;
        
        list<User> spocUser = TestDataFactory.createUserData('Portal', 'Dealer Sales Executive', conList);
        insert spocUser;
        
        test.startTest();
        system.runAs(spocUser[0])
        {
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;
        system.debug('spocUser[0].Id' + spocUser[0].Id);
        userAccountList[0].User__c = spocUser[0].Id;
        update userAccountList[0];
        system.debug('212 56353 '  + [Select Id,No_of_Times_SVOC_Accessed__c,SVOC_Accessed_Today__c,SVOC_accessed_this_month__c from Account where User__c =: spocUser[0].Id limit 1]);
        DSE_Adoption__c dse = new DSE_Adoption__c (DSEAccount__c = userAccountList[0].Id,IsMonthly__c  = false);
        insert dse;
        DSE_Adoption__c dse1 = new DSE_Adoption__c (DSEAccount__c = userAccountList[0].Id,IsMonthly__c  = true);
        insert dse1;
        CustomerProfileTriggerHandler.profileUpdatesbyDSE();
        }
        test.stopTest();
    }
}