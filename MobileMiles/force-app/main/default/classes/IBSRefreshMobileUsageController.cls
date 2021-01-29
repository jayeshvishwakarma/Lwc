public class IBSRefreshMobileUsageController {
    
    @AuraEnabled
    public static void refreshData(String accId){  
        List<Account> accObj = [SELECT id, iRMA_id__c, Aantal_mobiele_profielen__c FROM account WHERE id =: accid];

        if(accObj.size() > 0 && accObj[0].iRMA_id__c != null && accObj[0].Aantal_mobiele_profielen__c > 0)
            MobileTotalUsage.refreshMobileUsage(new Set<Id>{accObj[0].id});
        else{
            system.debug('@@@ Record does not match with criteria');
        }        
    }
    @AuraEnabled
    public static String refreshPortMobData(String accId, Integer index){
        //Integer index = 0;
        Map<Integer, Set<Id>> portMobMap = new Map<Integer, Set<Id>>();
        Set<Id> portMobs = new Set<Id>();
        Integer rowIndex = 0;
        for(Porteringen_mobiel__c portMob : [SELECT Id, account__r.IRMA_MKB_Office__c, iRMA_id__c from Porteringen_mobiel__c 
                                                where iRMA_id__c != null and Actief__c = TRUE and account__c =: accId 
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
            //index = index + 1; 
            return null;                       
        }
        return 'completed';         
    }
}