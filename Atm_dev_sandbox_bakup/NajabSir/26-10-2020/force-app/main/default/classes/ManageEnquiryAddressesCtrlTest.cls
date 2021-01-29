/**
 * @File Name          : ManageEnquiryAddressesCtrlTest.cls
 * @Description        : 
 * @Author             : Rajesh Ramachandran
 * @Group              : 
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 1/9/2020, 5:57:04 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    1/9/2020   Rajesh Ramachandran     Initial Version
**/
@isTest
public class ManageEnquiryAddressesCtrlTest {
    @testSetup
    static void CreateRecords(){
        list<Pincode__c> pinList = TestDataFactory.createPinAddressMasterData(1);
        insert pinList;
    }
    @isTest
    static void Test(){
        list<pincode__c> pinList = new list<pincode__c>([SELECT id from pincode__c]);
        ManageEnquiryAddressesCtrl.getEnquiryAddressFields('BillTo');
      //  ManageEnquiryAddressesCtrl.getCityAndStateFromPinCode(pinList[0].id);
        ManageEnquiryAddressesCtrl.validateDependencies('city', 'state', 'pincode');
    }
    
}