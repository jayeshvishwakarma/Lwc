/**
Name        :        TestIBSRelatedAccountsController 
Date        :        26th May 2020
Author      :       
Description :        Test Class for IBSRelatedAccountsController 
**/
@isTest
public class TestIBSRelatedAccountsController {
    @isTest
    static void test1(){
        Account accObj =  new Account(Name = 'Alice');
        insert accObj;
        Contact conObj = new Contact(FirstName = 'Alice', LastName = 'Community', Email = 'AliceComm@gmail.com', AccountId = accObj.Id);
        insert conObj;
        Profile  proObj = [SELECT ID  FROM profile WHERE name =  'Cloud ÉÉN Community'];
        User usr = TestIBSUtil.createTestUser(proObj.Id, conObj.Id, 'Test FirstName', 'Test LastName');        
        system.runAs(usr){
             IBSRelatedAccountsController.getChildAccounts();
        }
    }
}