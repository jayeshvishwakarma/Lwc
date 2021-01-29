/**
* @File Name          : CTICustomSearchControllerTest.cls
* @Description        : Test Class of the apex class 'CTICustomSearchController'
* @Author             : Tejendra
**/
@isTest
public class CTICustomSearchControllerTest {
    @testSetup static void createTestData() {
        
        //List<Account> accountList = TestDataFactory.createPersonAccount(1);
        List<Account> accountList = TestDataFactory.createCustomerAccount(1,'Dealer');
        accountList[0].phone = '9090909090';
        insert accountList;
        System.debug('accountList[0]='+accountList[0]);
        
        CTI_Search_Logic__c ctiSearchLogic = new CTI_Search_Logic__c();
        ctiSearchLogic.Name = 'Account Search';   
        ctiSearchLogic.Fields_To_Search__c = 'Name';
        ctiSearchLogic.MOS_Non_MOS__c = 'MOS';
        ctiSearchLogic.Objects_To_Search__c = 'Account';
        ctiSearchLogic.RecprdType_To_Search__c	= 'Dealer';    
        insert ctiSearchLogic;
    }
    
    static testMethod void searchAccountsTest(){
        Test.startTest();
        CTICustomSearchController.searchAccounts('9090909090','61321400');
        Test.stopTest();
    }
}