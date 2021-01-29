@isTest
public class AssetTriggerHandlerTest {
    
    @testsetup
    static void CreateRecord(){
        String vehicleAssetId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        String insuranceAssetId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Insurance').getRecordTypeId();
        String loyaltyAssetId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Loyalty').getRecordTypeId();
    
        list<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        
         //Create Product
        list<product2> productList = TestDataFactory.createProducts('Variants', 5);
        productList[0].Model__c = 'BA';
        productList[0].Enquiry__c = 'Yes';
        
        Insert productList;
        
        List<Asset> assetList =TestDataFactory.CreateAssetsRecords(productList);
        for(Asset ast : assetList)
        {
            ast.AccountId = personAccountList[0].Id;
        }
        assetList[0].RecordTypeId = vehicleAssetId;
        assetList[0].VIN__c = '5635ste';
        assetList[4].RecordTypeId = vehicleAssetId;
        assetList[4].VIN__c = '5635ste45';
        assetList[3].RecordTypeId = vehicleAssetId;
        assetList[3].VIN__c = '5635ste5646';
        assetList[1].RecordTypeId = loyaltyAssetId;
        assetList[2].RecordTypeId = insuranceAssetId;
        
        Insert assetList;
        assetList[1].ParentId = assetList[0].Id;
        assetList[2].ParentId = assetList[0].Id;
        update assetList;
    }

    @isTest 
    static void createNewVehicleAsset(){
        Test.startTest();
         String error;
        String vehicleAssetId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        //Create Product
        list<product2> productList = TestDataFactory.createProducts('Variants', 1);
        productList[0].Model__c = 'BA';
        productList[0].Enquiry__c = 'Yes';
        
        Insert productList;
        Try{
        List<Asset> assetList =TestDataFactory.CreateAssetsRecords(productList);
        assetList[0].RecordTypeId = vehicleAssetId;
        assetList[0].VIN__c = '5635ste';
        insert assetList;
        }
        catch(Exception e){ 
       system.debug('67 error'+e.getMessage());
       error =e.getMessage();
        }
       system.assertNotEquals(null,error); 
        Test.stopTest();
    }
    
    @isTest
    static void updateExsitingVehicleAsset(){
        Test.startTest();
        String error;
        try
        {
       List<Asset> lstAsset = [Select Id,VIN__c From Asset where VIN__c = '5635ste5646' limit 1];     
       lstAsset[0].VIN__c = '5635ste';
       update lstAsset[0];
       }
       catch(Exception e){ 
       system.debug('67 error'+e.getMessage());
       error =e.getMessage();
        }
       system.assertNotEquals(null,error);
       Test.stopTest();
    }
    
}