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
        List<City__c> lstCity = TestDataFactory.createCityAddressMasterData(1);
        List<Tehsil__c> lstTehsil = TestDataFactory.createTehsilMasterData(1);
        insert lstCity;
        pinList[0].City__c = lstCity[0].id;
        insert pinList;
        insert lstTehsil;
    }
    @isTest
    static void Test(){
        list<pincode__c> pinList = new list<pincode__c>([SELECT id from pincode__c]);
        List<City__c> lstCity = new List<City__c>([SELECT id,name,state__c from city__c]);
        List<Tehsil__c> lstTehsil = new List<Tehsil__c>([SELECT id,name,state__c,District__c from Tehsil__c]);
       // ManageEnquiryAddressesCtrl.getEnquiryAddressFields('BillTo','Opportunity');
        //For negative testing
       // ManageEnquiryAddressesCtrl.getEnquiryAddressFields('BillTo','Survey_Taker_CTI__c');
       // ManageEnquiryAddressesCtrl.validateDependencies(lstCity[0].id, 'UP', pinList[0].id);
        //for negative testing
       // ManageEnquiryAddressesCtrl.validateDependencies(lstCity[0].id, 'state', pinList[0].id);
        
       // ManageEnquiryAddressesCtrl.getPincodeSearchResults('Pincode__c', pinList[0].id );
        
//        ManageEnquiryAddressesCtrl.getTehsilSearchResults('Tehsil__c', 'Ujjain');
        
        ManageEnquiryAddressesCtrl.getCitySearchResults('City__c', lstCity[0].State__c);
        
      //  ManageEnquiryAddressesCtrl.getVillageSearchResults('Village__c', 'Ajmer');
    }
    
}