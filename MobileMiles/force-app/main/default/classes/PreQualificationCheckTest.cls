/**
Name        :        PreQualificationCheckTest
Date        :        30th July 2020
Author      :       
Description :        Test Class for PreQualificationCheck
**/
@isTest 
public class PreQualificationCheckTest{  
    @isTest
    public Static void test1(){
        List<Account> lstAccount= new List<Account>();
        Account acc = new Account();
        acc.Name ='Test Name';
        lstAccount.add(acc);   
        insert lstAccount;
        test.startTest();
        Set<Id> ids = (new Map<Id,Account>(lstAccount)).keySet();
        PreQualificationCheck pre = new PreQualificationCheck();
        //PreQualificationCheck.fetchPreQuaCheckFromBatch(ids);
        test.stopTest();  
    }
}