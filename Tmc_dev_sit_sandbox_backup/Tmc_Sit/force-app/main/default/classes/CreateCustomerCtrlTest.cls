/**
* @File Name          : CreateCustomerCtrlTest.cls
* @Description        :
* @Author             : Najab Maghribi
* @Group              :
* @Last Modified By   : Najab Maghribi
* @Last Modified On   : 23/12/2020 11:55 AM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    23/12/2020 11:55 AM         Najab Maghribi            Initial Version
**/
@isTest
public class CreateCustomerCtrlTest {
	@testsetup
    static void createTestRecord(){
        //Create For_code__c record for testing 
        List<For_Code__c> forCodeList = TestDataFactory.createForCodeRecord();
        INSERT forCodeList;
        //Create Account record for testing 
        List<Account> accountList = TestDataFactory.createCustomerAccount(3, 'Dealer');
        accountList[0].For_code__c = forCodeList[0].id;
        accountList[0].Channel__c = 'MDS';
        accountList[0].BillingPostalCode = '232342';
        accountList[1].For_code__c = forCodeList[0].id;
        accountList[1].Channel__c = 'COM';
        accountList[1].BillingPostalCode = '232342';
		accountList[2].For_code__c = forCodeList[0].id;
        accountList[2].Channel__c = 'NRM';
        accountList[2].BillingPostalCode = '232342';
        INSERT accountList;
    }
    @isTest
    private static void unitTest(){
        List<Account> accountList = [SELECT ID, Name, Status__c, OwnerId, SFMC_Sync__c, For_code__c, recordTypeId FROM ACCOUNT LIMIT 3];
        CreateCustomerCtrl createCustomerCltrRec = new CreateCustomerCtrl();
        CreateCustomerCtrl.getCutomerDetail(accountList[0].ID);
        CreateCustomerCtrl.createCutomer('{"First_Name__c" : "'+accountList[0].Name+'","Last_Name__c" : "'+accountList[0].Name+'"}');
        CreateCustomerCtrl.getForCodeDetail('DELHI');
        CreateCustomerCtrl.getAccountDetail(accountList[0].For_code__c, accountList[0].Name, 'Account.EnquiryMSDSSales');
        CreateCustomerCtrl.getAccountDetail(accountList[1].For_code__c, accountList[1].Name, 'Account.VehicleSales');
        CreateCustomerCtrl.getAccountDetail(accountList[2].For_code__c, accountList[2].Name, 'Account.CommercialVehicleSales');
        CreateCustomerCtrl.getAccountDetail(accountList[2].For_code__c, accountList[2].Name, 'Account.AccessoriesSales');
        CreateCustomerCtrl.getAccountDetail(accountList[2].For_code__c, accountList[2].Name, 'Account.Parts');
        CreateCustomerCtrl.DealershipInfo dealershipInfoWrapRec = new CreateCustomerCtrl.DealershipInfo();
        CreateCustomerCtrl.Pincode pincodeRec = new CreateCustomerCtrl.Pincode();
        pincodeRec.label = 'test';
        pincodeRec.value = 'testing record';
        CreateCustomerCtrl.DealershipWrapper  dealershipWrapperRec = new CreateCustomerCtrl.DealershipWrapper();
     }
}