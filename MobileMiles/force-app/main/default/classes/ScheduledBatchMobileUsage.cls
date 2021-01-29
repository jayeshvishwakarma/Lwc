global class ScheduledBatchMobileUsage  implements Schedulable{
      
   global Integer index; 
   global ScheduledBatchMobileUsage(Integer index){
       this.index= index;
   }   
   global void execute(SchedulableContext SC){        
        
        Map<Integer, Set<Id>> portMobMap = new Map<Integer, Set<Id>>();
        Set<Id> portMobs = new Set<Id>();
        Integer rowIndex = 0;
        for(Porteringen_mobiel__c portMob : [SELECT Id, account__r.IRMA_MKB_Office__c, iRMA_id__c from Porteringen_mobiel__c where iRMA_id__c != null and Actief__c = TRUE ORDER BY CreatedDate]){
            portMobs.add(portMob.id);
            if(portMobs.size() == Integer.valueOf(System.Label.Mobile_Usage_Records) || Test.isRunningTest()){
                portMobMap.put(rowIndex, portMobs);
                rowIndex++;
                portMobs = new Set<Id>();
            }  
        }
        if(portMobs.size() > 0){
            portMobMap.put(rowIndex, portMobs);              
        }
        Set<Id> processPortMobs = portMobMap.get(this.index);
        if(processPortMobs != null && processPortMobs.size() > 0){
            MobileUsage.getPorteringDetails(processPortMobs); 
            this.index = this.index + 1;                        
        }else{
            this.index = 0;
        }
        DateTime sysTime = system.now();
        sysTime = sysTime.addMinutes(Integer.valueOf(System.Label.Mobile_Usage_Time));
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        System.schedule( 'ScheduledBatchMobileUsage_' + sysTime, chronExpression, new ScheduledBatchMobileUsage(this.index));
                            
        System.abortJob(SC.getTriggerId());             
   } 
}