/**
Name        :        TestIBSUserInfoController 
Date        :        26th May 2020
Author      :       
Description :        Test Class for IBSUserInfoController 
**/
@isTest
public class TestIBSUserInfoController {
    @isTest
    static void test1(){
        Account accObj =  new Account(Name = 'Alice');
        insert accObj;
        IBSUserInfoController.getUserInfo(accObj.Id);
    }
}