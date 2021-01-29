global class SchedulerTotalUsageHelper implements Schedulable{
   
   global Integer index; 
   global SchedulerTotalUsageHelper(Integer index){
       this.index= index;
   }   
   global void execute(SchedulableContext SC){        
        
        Map<Integer, Set<Id>> accountMap = new Map<Integer, Set<Id>>();
        Set<Id> accounts = new Set<Id>();
        Integer rowIndex = 0;
        for(Account acc : [select id, IRMA_MKB_Office__c, iRMA_id__c from Account where iRMA_id__c != null and Aantal_mobiele_profielen__c > 0 ORDER BY CreatedDate]){
            accounts.add(acc.id);
            if(accounts.size() == Integer.valueOf(System.Label.Mobile_Usage_Records) || Test.isRunningTest()){
                accountMap.put(rowIndex, accounts);
                rowIndex++;
                accounts = new Set<Id>();
            }  
        }
        if(accounts.size() > 0){
            accountMap.put(rowIndex, accounts);              
        }
        Set<Id> processAccounts = accountMap.get(this.index);
        if(processAccounts != null && processAccounts.size() > 0){
            MobileTotalUsage.getAccountDetails(accountMap.get(this.index)); 
            this.index = this.index + 1;
            
            DateTime sysTime = system.now();
            sysTime = sysTime.addMinutes(Integer.valueOf(System.Label.Mobile_Total_Usage_Time));
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            System.schedule( 'ScheduledBatchMobileTotalUsage_' + sysTime, chronExpression, new SchedulerTotalUsageHelper(this.index));
        }else{
            DateTime sysTime = system.now();
            sysTime = sysTime.addMinutes(Integer.valueOf(System.Label.Mobile_Total_Usage_Time));
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            System.schedule( 'ScheduledBatchMobileTotalUsage_' + sysTime, chronExpression, new SchedulerTotalUsageHelper(0));
        }
                
        System.abortJob(SC.getTriggerId());             
   }   
}