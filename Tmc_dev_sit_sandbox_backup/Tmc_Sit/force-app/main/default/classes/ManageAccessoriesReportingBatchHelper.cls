/**
* @Author:- Anuj Kumar
* @Company-: Techmatrix Consulting
* @Description-: Helper class of ManageAccessoriesReportingBatch
* =============================================================
* Version   Date            Author      Modification
* =============================================================
* 1.0       15 APR 2020    Anuj Kumar     Intial Version
**/
public class ManageAccessoriesReportingBatchHelper{
    
    public final string PRODUCT_NAME = 'Accessories Reporting';
    public string priceBookEntryId;
    
    public List<OpportunityLineItem> oppLineItemList;
    
    public void prepare(){
        oppLineItemList = new List<OpportunityLineItem>();
        priceBookEntryId = getPriceBookEntryDetails();
    }
    
    public void processOpportunity(Map<String, Opportunity> oppIdWithObjMap){
        Map<String, List<OpportunityLineItem>> oppIdWithListLineItemeMap = new Map<String, List<OpportunityLineItem>>();
        
        for(OpportunityLineItem oli : [Select id, TotalPrice, ServiceDate, type__c, UnitPrice, opportunityId from OpportunityLineItem 
                where opportunityId IN: oppIdWithObjMap.keySet() And Type__c =: PRODUCT_NAME]){
            
            if(!oppIdWithListLineItemeMap.containsKey(oli.opportunityId))
                oppIdWithListLineItemeMap.put(oli.opportunityId, new List<OpportunityLineItem> ());
            oppIdWithListLineItemeMap.get(oli.opportunityId).add(oli);
        }
        
        for(String oppId : oppIdWithObjMap.keySet()){
            Opportunity opp = oppIdWithObjMap.get(oppId);
            
            Integer oppCurrentMonth = opp.Acc_Current_Month__c != Null ? opp.Acc_Current_Month__c.month() : 0;
            
            Decimal previousMonthAmount = 0.0;
            Boolean isCurrentMonLineExist = false;
            OpportunityLineItem currentOli = new OpportunityLineItem();
            
            for(OpportunityLineItem oli : oppIdWithListLineItemeMap.containsKey(oppId) ? oppIdWithListLineItemeMap.get(oppId) : new List<OpportunityLineItem>()){
                
                Integer oppLineItemMonth = oli.ServiceDate != Null ? oli.ServiceDate.month() : 0;
                if(oppCurrentMonth != 0 && oppLineItemMonth != 0 && oppCurrentMonth != oppLineItemMonth){
                    previousMonthAmount += oli.TotalPrice;
                }else if(oppCurrentMonth == oppLineItemMonth){
                    isCurrentMonLineExist = true;
                    currentOli = oli;
                }
            }
            
            if(!isCurrentMonLineExist){
                currentOli = createNewLineItem(opp);
            }
            currentOli.ServiceDate = opp.Acc_Current_Month__c;
            decimal price = opp.Acc_Value_Current_Month__c - previousMonthAmount;
            currentOli.UnitPrice = price;            
            oppLineItemList.add(currentOli);
        }
        
    }
    
    public void modifyLineItemDetails(){
        List<Opportunity> oppList = new List<Opportunity>();
        if(!oppLineItemList.isEmpty()){
            for(OpportunityLineItem oli : oppLineItemList){
                if(oli.opportunityId != Null){
                    oppList.add(new Opportunity(Id = oli.opportunityId, Is_Acc_Updated__c = false));
                }
            }
            try{
                TriggerHandler.bypass('OpportunityLineItemTriggerHandler');
                    Upsert oppLineItemList;
                TriggerHandler.clearBypass('OpportunityLineItemTriggerHandler');
                
                if(!oppList.isEmpty()){
                    TriggerHandler.bypass('OpportunityTriggerHandler');
                        update oppList;
                    TriggerHandler.clearBypass('OpportunityTriggerHandler');
                }
            }catch(Exception ex){ ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace(); ehst.componentName='ManageAccessoriesReportingBatchHelper'; ehst.userId=UserInfo.getUserId(); ExceptionHandler.LogError('ManageAccessoriesReportingBatchHelper', ex.getMessage(), 'ManageAccessoriesReportingBatchHelper', '', ehst); }
        }
    }
    
    public OpportunityLineItem createNewLineItem(Opportunity opp){
        
        OpportunityLineItem oli = new OpportunityLineItem();
        
        oli.Quantity = 1;
        oli.ServiceDate = opp.Acc_Current_Month__c;
        if(!string.isEmpty(priceBookEntryId))
        oli.priceBookEntryId = priceBookEntryId;
        oli.UnitPrice = opp.Acc_Value_Current_Month__c;
        oli.opportunityId = opp.Id;
        oli.type__c = PRODUCT_NAME;
        
        return oli;
    }
    
    public String getPriceBookEntryDetails(){
        
        String priceBookEntryId = '';
        
        List<Product2> proList = [Select id, name, (Select id from PriceBookEntries) from Product2 where Name =: PRODUCT_NAME];
        if(!proList.isEmpty()){
            priceBookEntryId = (proList[0].PriceBookEntries != Null && proList[0].PriceBookEntries.size() > 0) ? 
                                proList[0].PriceBookEntries[0].Id : Null;
        } else{
            priceBookEntryId = createNewProduct(PRODUCT_NAME);
        }
        
        return priceBookEntryId;
    }
    
    public String createNewProduct(String Name){
        String priceBookEntryId = '';
        
        List<Pricebook2> priceBookDetail = new List<Pricebook2>([select id, name from Pricebook2 where isStandard = true limit 1]);
            
        Product2 pro = new Product2();
        pro.Name = Name;
        pro.IsActive = true;
        
        try{
            TriggerHandler.bypass('ProductTriggerHandler');
                Insert pro;
            TriggerHandler.clearBypass('ProductTriggerHandler');
            
            if(!priceBookDetail.isEmpty()){
                PricebookEntry pbe = new PricebookEntry (Pricebook2Id = priceBookDetail[0].Id,
                    Product2Id = pro.Id,
                    IsActive = true,
                    UnitPrice = 0,
                    UseStandardPrice = false);
                
                Insert pbe;
                
                priceBookEntryId = pbe.Id;
            }
        }catch(Exception ex){ ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace(); ehst.componentName='ManageAccessoriesReportingBatchHelper'; ehst.userId=UserInfo.getUserId(); ExceptionHandler.LogError('ManageAccessoriesReportingBatchHelper', ex.getMessage(), 'ManageAccessoriesReportingBatchHelper', '', ehst); }
        
        return priceBookEntryId;
    }
    
}