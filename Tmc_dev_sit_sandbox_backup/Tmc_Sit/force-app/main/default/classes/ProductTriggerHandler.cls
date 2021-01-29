/**
 * @File Name          : ProductTriggerHandler.cls
 * @Description        : 
 * @Author             : Rajesh Ramachandran
 * @Group              : 
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 12/28/2019, 9:59:33 AM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    12/28/2019   Rajesh Ramachandran     Initial Version
**/
public without sharing class ProductTriggerHandler extends TriggerHandler {
    private list<Product2> newProdList; // Used to store the list of new User
    private Map<Id, Product2> oldProdMap; // Used to store Map of old User

    public ProductTriggerHandler() {
        this.newProdList= (list<Product2>) Trigger.new;
        this.oldProdMap= (Map<Id, Product2>) Trigger.oldMap;        
    }

    public override void beforeInsert() {
        updateActiveFlag();
        updateModelMaster();
    }
    
    public override void beforeUpdate() {
        updateActiveFlag();
        updateModelMaster();
    }

    public override void afterInsert() {
        addAccessoryPriceEntry();    
        createPricebookEntry();
    }

    public override void afterUpdate() {
        addAccessoryPriceEntry();
        createPricebookEntry();
    }
    //method to add prices for accessory product list
    public void addAccessoryPriceEntry(){

        try {
                Id accessoryRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Accessories').getRecordTypeId();
                Id partsRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Parts').getRecordTypeId();
                List<Product2> prListToUpdate = new List<Product2>();
                //find accessory products whose price is updated
                for(Product2 pr : this.newProdList){
                    if((pr.recordtypeid == accessoryRecordTypeId || pr.recordtypeid == partsRecordTypeId) && (trigger.isInsert ||(trigger.isUpdate && pr.Discount_Price__c != this.oldProdMap.get(pr.id).Discount_Price__c))){
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
    // Created as parts of R1.2 Phase 2 PARTS development to update the Active flag on Product is Tag Code != 5
    public void updateActiveFlag(){
        String partsProductRecordTypeId = Schema.SObjectType.product2.getRecordTypeInfosByName().get(ConstantsUtility.PARTS).getRecordTypeId();
        for(Product2 pro : this.newProdList){
            if(pro.recordTypeId == partsProductRecordTypeId && (trigger.isInsert && pro.Tag_Code__c != 5 || (trigger.isUpdate && (this.oldProdMap.get(pro.id).Tag_Code__c  != pro.Tag_Code__c && pro.Tag_Code__c != 5)))){
                pro.isActive = true;
            }else if(pro.recordTypeId == partsProductRecordTypeId &&  pro.Tag_Code__c == 5){
                pro.isActive = false;
            }
        }    
    }
    
    /* @Author             : Navin Soni
     * @Description        : This method is use to create and update PricebookEntry records for Consumer Offer records. */
    public void createPricebookEntry(){
        try{
            System.debug('@@## Start createPricebookEntry ');
            Id OfferRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Offer').getRecordTypeId();
            List<Product2> listOfConsumerProduct = new List<Product2>();
            for(Product2 objPro : this.newProdList){
                if(objPro.recordtypeid == OfferRecordTypeId && (trigger.isInsert || (trigger.isUpdate && objPro.Discount_Price__c != this.oldProdMap.get(objPro.id).Discount_Price__c))){
                    listOfConsumerProduct.add(objPro);
                }
            }
            if(listOfConsumerProduct != null && listOfConsumerProduct.size() > 0){
                String pricebook2Id = '';
                StandardPriceBookId__c lsPB = StandardPriceBookId__c.getInstance(); 
                if (lsPB != null){
                    pricebook2Id = lsPB.PriceBookId__c;
                }
                if(pricebook2Id == '') return;
                List<PricebookEntry> listOfPricebookEntry = new List<PricebookEntry>();
                For(Product2 objProduct2 : [Select Id, start_date__c, end_date__c, Name, Discount_Price__c, for_code__c, Model__c, Scheme_Regiom__c, state__c, variant__c, Fuel_Type__c,(SELECT Id from PricebookEntries) from Product2 Where ID IN : listOfConsumerProduct]){
                    if(objProduct2.PricebookEntries.size() == 0){
                        PricebookEntry priceBookEntryVar = new PricebookEntry();                           
                        priceBookEntryVar.Pricebook2Id = pricebook2Id;
                        priceBookEntryVar.Product2Id = objProduct2.id;
                        priceBookEntryVar.UnitPrice = objProduct2.Discount_Price__c;
                        priceBookEntryVar.IsActive = true;
                        listOfPricebookEntry.add(priceBookEntryVar);
                    }else{
                        PricebookEntry priceBookEntryVar = new PricebookEntry();  
                        priceBookEntryVar = objProduct2.PricebookEntries[0];             
                        priceBookEntryVar.UnitPrice = objProduct2.Discount_Price__c;
                        priceBookEntryVar.IsActive = true;
                        listOfPricebookEntry.add(priceBookEntryVar);
                    }
                }
                System.debug('@@## listOfPricebookEntry '+listOfPricebookEntry.size());
                If(listOfPricebookEntry != null && listOfPricebookEntry.size() > 0){
                    Upsert listOfPricebookEntry;
                }
            }
        }catch (Exception e) {
            ExceptionHandler.LogError('Producttriggerhandler createPricebookEntry', e.getMessage(), 'ProductTriggerHandler', '', null);            
        }
    }

    /*----------------------------------------------------------------------------------------------------------
        Description : Created as Part of R1.2 Phase 3 Ture Value Leads to update the Model Master for Products.
    ------------------------------------------------------------------------------------------------------------*/
    public void updateModelMaster(){
        String compVariant = 'Competitor Variant';
        String variantRecTypeId = Schema.SObjectType.product2.getRecordTypeInfosByName().get(ConstantsUtility.VARIANT_CONST).getRecordTypeId();
        String compVariantRecTypeId = Schema.SObjectType.product2.getRecordTypeInfosByName().get(compVariant).getRecordTypeId();
        
        Map<String, String> uniqueCodeWithModeMasterIdMap = new Map<String, String>();
        
        for(Product2 pro : this.newProdList){
            String model = String.isNotEmpty(pro.Model__c) ? pro.Model__c : '';
            if(pro.recordTypeId != null && pro.recordTypeId == variantRecTypeId){
                uniqueCodeWithModeMasterIdMap.put('M_' + model, null);
            }else if(pro.recordTypeId != null && pro.recordTypeId == compVariantRecTypeId){
                uniqueCodeWithModeMasterIdMap.put('N_' + model, null);
            }
        }
        
        if(!uniqueCodeWithModeMasterIdMap.isEmpty()){
            
            for(Model_Master__c master : [Select id, External_Id__c from Model_Master__c where External_Id__c != null AND 
                                    External_Id__c IN : uniqueCodeWithModeMasterIdMap.keySet()]){
                
                if(uniqueCodeWithModeMasterIdMap.containsKey(master.External_Id__c)){
                    uniqueCodeWithModeMasterIdMap.put(master.External_Id__c, master.Id);
                }
            }
            
            for(Product2 pro : this.newProdList){
                String model = String.isNotEmpty(pro.Model__c) ? pro.Model__c : '';
                if(pro.recordTypeId != null && pro.recordTypeId == variantRecTypeId && uniqueCodeWithModeMasterIdMap.containsKey('M_' + model)){
                    pro.Model_Master_LKP__c = uniqueCodeWithModeMasterIdMap.get('M_' + model);
                }else if(pro.recordTypeId != null && pro.recordTypeId == compVariantRecTypeId && uniqueCodeWithModeMasterIdMap.containsKey('N_' + model)){
                    pro.Model_Master_LKP__c = uniqueCodeWithModeMasterIdMap.get('N_' + model);
                }
            }
            
        }
        
    }    
}