/**
 * @File Name          : ServiceCalculatorTest.cls
 * @Description        : It is utilized for ServiceCalculator Apex code coverage
 * @Author             : Nitin Ghai
 * @Group              : 
 * Apex Class		   : ServiceCalculator
 * @Last Modified By   : 
 * @Last Modified On   : 08/06/2020
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0        03/01/2020               Nitin Ghai   		    	  Initial Version
 * 1.0        08/06/2020               Nitin Ghai   		    	  Added system.assert
**/

@isTest
public class ServiceCalculatorTest {
@isTest
    public static void run(){
        Test.startTest();
        // To create For Code Record
        List<For_Code__c> forCodeRec = TestDataFactory.createTestForCode(1);
        insert forCodeRec;
        
        //To Create City Records
        List<City__c> cityRec = TestDataFactory.createCityAddressMasterData(1);
        cityRec[0].For_Code__c=forCodeRec[0].Id;
        insert cityRec;
        
        // To Create Dealer records
        List<Account> dealerAccount =TestDataFactory.createBusinessAccount(1,'Dealer');
        dealerAccount[0].For_Code__c=forCodeRec[0].Id;
        insert dealerAccount;
        
        // To create Contact records
        List<Contact> contactRec = TestDataFactory.createTestContact(1,dealerAccount[0].Id);
        insert contactRec;
        
        //To Create Customer records
        List<Account> customerRec = TestDataFactory.createPersonAccount(1);
        customerRec[0].LastName='Test User';
        insert customerRec[0];
        Profile profileRec = [SELECT Id,Name FROM Profile WHERE Name =: System.Label.Service_CCE_Profile LIMIT 1];
        
        //To create Custom Setting record
        List<UserEvaluatorFlag__c> userEvalFlag =  TestDataFactory.createUserEvaluatorFlagRec(1,'TestRecord');
        insert userEvalFlag;
        
        //To Create Partner User records
        List<User> partnerUser = TestDataFactory.createUserData('Portal',profileRec.Name,contactRec);
        partnerUser[0].isActive=True;
        partnerUser[0].PortalRole = 'Manager';
        insert partnerUser;
        
        Id assetVehicleRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        
        // To Create Asset record and Link with Customer record
        List<Asset> assetRec = TestDataFactory.CreateAssetsRecords(1);
        assetRec[0].AccountId=customerRec[0].Id;
        assetRec[0].recordTypeId=assetVehicleRecTypeId;
        assetRec[0].Registration_Number__c='DL2337276';
        insert assetRec[0];
        
        ServiceCalculator.ServiceCalculatorWrapper wrap=ServiceCalculator.fetchCityandAssestInfo(customerRec[0].Id);
        system.assertEquals(1, wrap.registrationNumberList.size());
        Test.stopTest();
    }
    @isTest
    public static void errorHanlder(){
        test.startTest();
        ServiceCalculator.ServiceCalculatorWrapper wrap=ServiceCalculator.fetchCityandAssestInfo('');
        test.stopTest();
    }
}