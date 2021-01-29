public class RefreshMobileUsage{
    private Account acc;
    private Integer index=0;
    
    public RefreshMobileUsage(ApexPages.StandardController stdController) {
        acc = (Account)stdController.getRecord();
    }   
    public PageReference refreshData(){  
        acc = [select id, iRMA_id__c, Aantal_mobiele_profielen__c from account where id =: acc.id];
        if(acc.iRMA_id__c != null && acc.Aantal_mobiele_profielen__c > 0)
            MobileTotalUsage.refreshMobileUsage(new Set<Id>{acc.id});
        else{
            system.debug('@@@ Record does not match with criteria');
        }
        return null;
    }
    public PageReference refreshPortMobData(){
        
        Map<Integer, Set<Id>> portMobMap = new Map<Integer, Set<Id>>();
        Set<Id> portMobs = new Set<Id>();
        Integer rowIndex = 0;
        for(Porteringen_mobiel__c portMob : [SELECT Id, account__r.IRMA_MKB_Office__c, iRMA_id__c from Porteringen_mobiel__c 
                                                where iRMA_id__c != null and Actief__c = TRUE and account__c =: acc.id 
                                                ORDER BY CreatedDate]){
            portMobs.add(portMob.id);
            if(portMobs.size() == Integer.valueOf(System.Label.Mobile_Usage_Records)){
                portMobMap.put(rowIndex, portMobs);
                rowIndex++;
                portMobs = new Set<Id>();
            }  
        }
        if(portMobs.size() > 0){
            portMobMap.put(rowIndex, portMobs);              
        }
        system.debug('@@@@@ portMobMap ' + portMobMap);
        Set<Id> processPortMobs = portMobMap.get(index);
        if(processPortMobs != null && processPortMobs.size() > 0){
            MobileUsage.refreshMobileUsage(processPortMobs); 
            index = index + 1; 
            return null;                       
        }else{
            return new PageReference('/'+acc.id);
        }          
    }
}