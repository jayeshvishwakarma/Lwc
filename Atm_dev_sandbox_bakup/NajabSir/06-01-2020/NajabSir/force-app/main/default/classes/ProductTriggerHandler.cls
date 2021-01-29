/**
 * @File Name          : ProductTriggerHandler.cls
 * @Description        : 
 * @Author             : Rajesh Ramachandran
 * @Group              : 
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 12/28/2019, 9:59:33 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    12/28/2019   Rajesh Ramachandran     Initial Version
**/
public without sharing class ProductTriggerHandler extends TriggerHandler {
    private list<Product2> newProdList; // Used to store the list of new User
    private Map<Id, Product2> oldProdMap; // Used to store Map of old User

    public ProductTriggerHandler() {
        this.newProdList= (list<Product2>) Trigger.new;
        this.oldProdMap= (Map<Id, Product2>) Trigger.oldMap;        
    }

    public override void afterInsert() {
        addAccessoryPriceEntry();
    }

    public override void afterUpdate() {
        addAccessoryPriceEntry();
    }
    //method to add prices for accessory product list
    public void addAccessoryPriceEntry(){

        try {
                Id accessoryRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Accessories').getRecordTypeId();
                List<Product2> prListToUpdate = new List<Product2>();
                //find accessory products whose price is updated
                for(Product2 pr : this.newProdList){
                    if(pr.recordtypeid == accessoryRecordTypeId && (trigger.isInsert ||(trigger.isUpdate && pr.Discount_Price__c != this.oldProdMap.get(pr.id).Discount_Price__c))){
                        prListToUpdate.add(pr);
                    }
                }
                if(prListToUpdate != null && prListToUpdate.size() > 0){
                    String pricebook2Id = '';
                    StandardPriceBookId__c lsPB = StandardPriceBookId__c.getInstance(); 
                    if (lsPB != null){
                        pricebook2Id = lsPB.PriceBookId__c;
                    }
                    if(pricebook2Id == '') return;
                    list<PricebookEntry> pricebookEntryList = new list<PricebookEntry>();
                    List<PricebookEntry> updPriceboookEntryList = [select id,unitprice,product2id,isActive from pricebookEntry where pricebook2Id = :pricebook2Id and product2id = :prListToUpdate];
                    for(Product2 prUpd : prListToUpdate){
                        boolean pbeExists = false;
                        for (PricebookEntry pbe : updPriceboookEntryList){
                            if (pbe.Product2id == prUpd.id){
                                pbe.UnitPrice = prUpd.Discount_Price__c;
                                pbe.IsActive =true;
                                pricebookEntryList.add(pbe);
                                pbeExists = true;
                                break;
                            }
                        }
                        if (pbeExists == false){
                            PricebookEntry priceBookEntryVar = new PricebookEntry();                           
                            priceBookEntryVar.Pricebook2Id = pricebook2Id;
                            priceBookEntryVar.Product2Id = prUpd.id;
                            priceBookEntryVar.UnitPrice = prUpd.Discount_Price__c;
                            priceBookEntryVar.IsActive =true;
                            pricebookEntryList.add(priceBookEntryVar);
                        }
                    }
                    if (pricebookEntryList != null && pricebookEntryList.size() > 0)
                        upsert pricebookEntryList; 
                }    
            } catch (Exception e) {
                ExceptionHandler.LogError('Producttriggerhandler addAccessoryPrice', e.getMessage(), 'ProductTriggerHandler', '', null);            
            }
    }

}