global class ScheduledBatchPreQualificationCheck implements Schedulable{    
    global void execute(SchedulableContext SC){   }
   /*   
   global Integer index; 
   global ScheduledBatchPreQualificationCheck(Integer index){
       this.index= index;
   }   
   global void execute(SchedulableContext SC){        
        
        Map<Integer, Set<Id>> accountMap = new Map<Integer, Set<Id>>();
        Set<Id> accounts = new Set<Id>();
        Integer rowIndex = 0;
        for(Account acc : [select id, IRMA_MKB_Office__c, iRMA_id__c from Account where                            
                           Check_infra_informatie__c = true ORDER BY CreatedDate]){
            accounts.add(acc.id);
            if(accounts.size() == Integer.valueOf(System.Label.Pre_qualification_check_records) || Test.isRunningTest()){
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
            PreQualificationCheck.fetchPreQuaCheckFromBatch(processAccounts); 
            this.index = this.index + 1;                        
        }else{
            this.index = 0;
        }
        DateTime sysTime = system.now();
        sysTime = sysTime.addMinutes(Integer.valueOf(System.Label.Pre_qualification_check_time));
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        System.schedule( 'ScheduledBatchPreQualificationCheck_' + sysTime, chronExpression, new ScheduledBatchPreQualificationCheck(this.index));
                            
        System.abortJob(SC.getTriggerId());             
   } */
}