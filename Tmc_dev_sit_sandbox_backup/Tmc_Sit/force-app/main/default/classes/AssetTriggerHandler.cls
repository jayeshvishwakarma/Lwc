/**
* @File Name          : AssetTriggerHandler.cls
* @Description        : Trigger handler class for Asset
* @Author             : Rahul Sharma
* @Group              : MSIL
* @Last Modified By   : Rahul Sharma
* @Last Modified On   : 20/07/2020, 3:16:16 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    20/07/2020, 3:16:16 PM                                Initial Version 
**/

public class AssetTriggerHandler extends TriggerHandler {
  
    private Map<Id, Asset> newAssetMap;
    private List<Asset> newAssetList;
    private Map<Id,Asset> oldAssetMap;
    public static Id vehicleAssetId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
    public static Id insuranceAssetId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Insurance').getRecordTypeId();
    public static Id loyaltyAssetId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Loyalty').getRecordTypeId();
    //constructor
    public AssetTriggerHandler() {
        this.newAssetMap = (Map<Id, Asset>) Trigger.newMap;
        this.newAssetList = (list<Asset>) Trigger.New;
        this.oldAssetMap = (Map<Id,Asset>) Trigger.oldMap;
    }

    public override void beforeInsert() {
        uniqueVehicleAssetCheck();
    }

    public override void beforeUpdate() {
        uniqueVehicleAssetCheck();    
    }
    
    /*
    Author: Rahul Sharma
    Company: MSIL
    Description: Check for uniqueness of Asset and send error with 18 digit id in case of duplicate to DMS
    Returns: void
    */
    public void uniqueVehicleAssetCheck(){
        
        map<String,Asset> newAssetWithVIN = new map<String,Asset>();
        map<String,String> assetIdWithVIN = new map<String,String>();
         map<String,String> svocIdWithVIN = new map<String,String>();
         map<String,String> loyaltySfIdWithVIN = new map<String,String>();
         map<String,String> miSfIdWithVIN = new map<String,String>();
        set<String> sfIds = new set<string>();
        set<String> sfId2s = new set<string>();
        for (Asset ast : this.newAssetList){
            if(ast.VIN__c != null && ast.RecordTypeId == vehicleAssetId )
            {
                newAssetWithVIN.put(ast.VIN__c,ast);
                if(trigger.isUpdate)
                    sfIds.add(ast.Id);
                
            }
        }
        
        if(newAssetWithVIN.size() > 0)
        {
            List<Asset> lstAst = new List<Asset>();
            List<Asset> lstAst1 = new List<Asset>();
            if(trigger.isUpdate)
               lstAst = [Select id,VIN__c,Account.SVOC_ID__c from Asset where VIN__c  != null and RecordTypeId =: vehicleAssetId and VIN__c in: newAssetWithVIN.keyset() and id not in: sfIds];  
            else
               lstAst = [Select id,VIN__c,Account.SVOC_ID__c from Asset where VIN__c  != null and RecordTypeId =: vehicleAssetId and VIN__c in: newAssetWithVIN.keyset()];  
            for(Asset ast : lstAst)
            {
                sfId2s.add(ast.Id);
            }
            lstAst1 = [Select id,VIN__c,Account.SVOC_ID__c,RecordTypeId,ParentId,Parent.VIN__c from Asset where ParentId in: sfId2s and (RecordTypeId =: insuranceAssetId or RecordTypeId =: loyaltyAssetId)];  
            if(lstAst1 != null && lstAst1.size() > 0)
            {
                for(Asset ast : lstAst1)
                {
                if(ast.RecordTypeId == insuranceAssetId )
                miSfIdWithVIN.put(ast.Parent.VIN__c,ast.Id);
                
                if(ast.RecordTypeId == loyaltyAssetId)
                loyaltySfIdWithVIN.put(ast.Parent.VIN__c,ast.Id);
                }
            }          
            if(!lstAst .IsEmpty())
            {
                for(Asset ast : lstAst )
                {
                    assetIdWithVIN.put(ast.VIN__c,ast.Id);
                    if(ast.Account.SVOC_ID__c != null)
                        svocIdWithVIN.put(ast.VIN__c,ast.Account.SVOC_ID__c);
                    else
                        svocIdWithVIN.put(ast.VIN__c,'');
                        
                    if(!miSfIdWithVIN.containsKey(ast.VIN__c))
                        miSfIdWithVIN.put(ast.VIN__c,'');
                    if(!loyaltySfIdWithVIN.containsKey(ast.VIN__c))
                        loyaltySfIdWithVIN.put(ast.VIN__c,'');    
                }
                
                for(String str : newAssetWithVIN.keySet())
                {
                    if(assetIdWithVIN.containsKey(str))
                    {
                        String error = 'Duplicate Record Found, Existing record id is : '+svocIdWithVIN.get(str)+','+ loyaltySfIdWithVIN.get(str)+','+ miSfIdWithVIN.get(str)+','+ assetIdWithVIN.get(str);
                        (newAssetWithVIN.get(str)).addError(error);
                    }
                }
                
            }
        }
    }     
    
}