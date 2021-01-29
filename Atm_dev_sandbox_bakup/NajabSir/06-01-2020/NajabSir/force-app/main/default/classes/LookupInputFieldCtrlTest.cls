@isTest
public class LookupInputFieldCtrlTest {
    @testSetup
    static void CreateRecords(){
        list<City__c> CityList = TestDataFactory.createAddressMasterData(1,'city__c');
        insert CityList;
    }
    
    @isTest
    static void Test(){
        List<City__c> CityList = new list<City__c>([SELECT id,name from City__c]);
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = CityList[0].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        LookupInputFieldCtrl.search('City__c','Noida','');
    }
}