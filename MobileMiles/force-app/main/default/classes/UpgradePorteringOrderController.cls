public class UpgradePorteringOrderController {
    public Quote quoteObj{get;set;}
    public UpgradePorteringOrderController(ApexPages.StandardController controller) {
        this.quoteObj= (Quote)controller.getRecord();
    }
    public void UpgradePorteringOrder(){
        try{
        List<Porteringen_mobiel__c> porterList = new List<Porteringen_mobiel__c>();
        Map<String, Porteringen_mobiel__c> upgradedPorterNameMap = new Map<String, Porteringen_mobiel__c>();
        Map<String, Porteringen_mobiel__c> previousPorterNameMap = new Map<String, Porteringen_mobiel__c>();
        
        for(Porteringen_mobiel__c porterObj : [SELECT id,Upgrade_order__c,Voorgaande_order__c,Name 
                                                FROM Porteringen_mobiel__c 
                                                WHERE Offerte__c = :quoteObj.id
                                                AND Stagename__c = 'Lopend']){
            upgradedPorterNameMap.put(porterObj.Name, porterObj);
        }
        
        for(Porteringen_mobiel__c porterObj : [select id,Upgrade_order__c,Voorgaande_order__c,Name 
                                                   from Porteringen_mobiel__c 
                                                   where Name IN :upgradedPorterNameMap.keySet() 
                                                   AND Stagename__c = 'Actief'
                                                   ORDER BY LastModifiedDate ASC]){
            previousPorterNameMap.put(porterObj.Name, porterObj);
        }
        
        for(String key : upgradedPorterNameMap.keySet()){
            Porteringen_mobiel__c upgradedPorter = new Porteringen_mobiel__c();
            Porteringen_mobiel__c previousPorter = new Porteringen_mobiel__c();
            if(upgradedPorterNameMap.containsKey(key)){
                upgradedPorter = upgradedPorterNameMap.get(key);    
            }
            if(previousPorterNameMap.containsKey(key)){
                previousPorter = previousPorterNameMap.get(key);    
            }
            
            if(upgradedPorter.Voorgaande_order__c == null){
                upgradedPorter.Voorgaande_order__c = previousPorter.id;
                if(upgradedPorter.id != null){
                    PorterList.add(upgradedPorter);
                }
            }
            
            
            previousPorter.Upgrade_order__c = upgradedPorter.id;
            
            
            if(previousPorter.id != null){
                PorterList.add(previousPorter);
            }
            
        }
        System.debug('porterList'+porterList);
        if(!porterList.isEmpty()){
            update PorterList;
        }
        }catch(Exception e){
            
        }
        
    }
}