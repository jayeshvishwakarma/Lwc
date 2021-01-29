/**
* @File Name          : GetLatestJobCardDetailsTest.cls
* @Description        : This class is used for code coverage of  GetLatestJobCardDetails
* @Author             : Rajesh Ramachandran
* @Group              :
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 07-13-2020
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0    13/02/2020, 11:37:23 AM   Sunit Kumar Chand         Initial Version
* 1.1    15/04/2020  01:53:00 PM   Nitin Ghai               Updated the Test class
* 1.2    08/06/2020  09:10:00 AM   Mahith Madwesh           Updated the Test class
**/
@isTest
public class GetLatestJobCardDetailsTest{
    
    @TestSetup
    static void makeData(){
        list<account> accountList = UtilityClass.createPersonAccount(1);
        insert accountList;
        
        asset assetRecord = new asset();
        assetRecord.Name = 'Test Asset';
        assetRecord.Registration_Number__c = 'DL2CAV8580';
        assetRecord.AccountId = accountList.get(0).Id;
        assetRecord.recordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        insert assetRecord;
    }
    
    @isTest
    public static void fetchDataTest(){
        test.startTest();
        List<Account> accountList = [SELECT Id FROM Account];
        GetLatestJobCardDetails.WrapperClass test1 = GetLatestJobCardDetails.fetchData(accountList.get(0).Id);
        system.assertEquals(1, test1.assetRec.size());
        test.stopTest();
    }
    
    @isTest
    public static void getAssetNameTest(){
        list<asset> assetRecId = [SELECT Name,Registration_Number__c FROM Asset];
        
        asset assetRec = GetLatestJobCardDetails.getAssetName(assetRecId.get(0).Id);
        System.assertEquals(assetRecId.get(0), assetRec);
    }
}