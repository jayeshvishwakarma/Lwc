/**
 * @File Name          : ManageEnquiryAddressesCtrlTest.cls
 * @Description        :
 * @Author             : Rajesh Ramachandran
 * @Group              :
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 1/9/2020, 5:57:04 AM
 * @Modification Log   :
 * Ver       Date            Author              Modification
 * 1.0    1/9/2020   Rajesh Ramachandran     Initial Version
**/
@isTest
public class ManageEnquiryAddressesCtrlTest {
    @testSetup
    static void CreateRecords(){

        list<City__c> cityList = TestDataFactory.createCityAddressMasterData(1);
        insert cityList;

        list<Pincode__c> pinList = TestDataFactory.createPinAddressMasterData(1);
        pinList[0].City__c= cityList[0].id;
        pinList[0].State__c = 'UP';
        insert pinList;

        list<Tehsil__c> tehsilList= TestDataFactory.createTehsilAddressMasterData(1);
        tehsilList[0].State__c = 'UP';
        insert tehsilList;

        list<Village__c> villageList = TestDataFactory.createVillageAddressMasterData(1);
        villageList[0].Tehsil__c= tehsilList[0].id;
        insert villageList;
    }
    @isTest
    static void Test(){
        list<pincode__c> pinList = new list<pincode__c>([SELECT id,State__c,City__c,Name,City__r.Name, City__r.State__c from pincode__c]);
        list<City__c> cityList = new list<City__c>([SELECT id,State__c,Name from City__c]);
        list<Village__c> viaalgeList = new list<Village__c>([SELECT id,Name from Village__c]);
        list<Tehsil__c> tehsilList = new list<Tehsil__c>([SELECT id,Name,State__c from Tehsil__c]);


        ManageEnquiryAddressesCtrl.getEnquiryAddressFields('BillTo','Opportunity');
        ManageEnquiryAddressesCtrl.validateDependencies(cityList[0].id, pinList[0].State__c,pinList[0].id);
        Id [] fixedSearchResults= new Id[4];
         fixedSearchResults[0] = cityList[0].id;
        fixedSearchResults[1] = pinList[0].id;
        fixedSearchResults[2] = tehsilList[0].id;
        fixedSearchResults[3] = viaalgeList[0].id;
         Test.setFixedSearchResults(fixedSearchResults);

        ManageEnquiryAddressesCtrl.getPincodeSearchResults('Pincode__c', 'Noida');
        ManageEnquiryAddressesCtrl.getCitySearchResults('City__c', 'Noida');
        ManageEnquiryAddressesCtrl.getVillageSearchResults('Village__c', 'Noida');
        ManageEnquiryAddressesCtrl.getTehsilSearchResults('Tehsil__c', 'Nanded');
    }

}