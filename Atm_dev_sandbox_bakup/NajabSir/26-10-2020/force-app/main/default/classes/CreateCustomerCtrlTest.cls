/**
* @File Name          : CreateCustomerCtrlTest.cls
* @Description        :
* @Author             : Najab Maghribi
* @Group              :
* @Last Modified By   : Najab Maghribi
* @Last Modified On   : 23/10/2020 10:30 AM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    23/10/2020 10:30 AM         Najab Maghribi            Initial Version
**/
@isTest
public class CreateCustomerCtrlTest {
	@testsetup
    static void createTestRecord(){
        //Create Account record for testing 
        List<Account> accountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        INSERT accountList;
        //Create For_code__c record for testing 
        List<For_Code__c> forCodeList = TestDataFactory.createForCodeRecord();
        INSERT forCodeList;
    }
    @isTest
    private static void unitTest(){
        List<Account> accountList = [SELECT ID, Name, Status__c, OwnerId, SFMC_Sync__c, For_code__c, recordTypeId FROM ACCOUNT LIMIT 1];
        CreateCustomerCtrl createCustomerCltrRec = new CreateCustomerCtrl();
        CreateCustomerCtrl.getCutomerDetail(accountList[0].ID);
        //CreateCustomerCtrl.createCutomer('{"First_Name__c" : "'+accountList[0].Name+'"}');
        CreateCustomerCtrl.createCutomer('{"First_Name__c" : "TestAccount"}');
        CreateCustomerCtrl.getForCodeDetail('DELHI');
        List<Account> accountDetailList = CreateCustomerCtrl.getAccountDetail(accountList[0].Name, accountList[0].For_code__c);
    	//system.assertEquals(accountList[0].RecordTypeId, accountDetailList[0].RecordTypeId);
    }
}