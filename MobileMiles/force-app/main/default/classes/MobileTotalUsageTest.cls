/**
Name        :        MobileTotalUsageTest
Date        :        19th May 2020
Author      :       
Description :        Test Class for MobileTotalUsage
**/
@isTest 
public class MobileTotalUsageTest {  
    @isTest
    public Static void test1(){
        List<Account> lstAccount= new List<Account>();
        Account acc = new Account();
        acc.Name ='Test Name';
        lstAccount.add(acc);   
        insert lstAccount;
        test.startTest();
        Set<Id> ids = (new Map<Id,Account>(lstAccount)).keySet();
        MobileTotalUsage.fetchMobileUsageFromBatch(ids);
        test.stopTest();  
    }
}