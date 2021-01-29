/*
        Name            :    AccountTriggerHelper
        Author          :    Ranu Bari
        Date            :    01/23/2018
        Description     :    Used in AccountTrigger
*/
public class AccountTriggerHelper{
    public static Boolean isISRACheckCalled = false;
    public static Boolean isZipCodeCheckCalled = false;
    private Static Map<String,String> mapOfFields = new Map<String,String>();
    private Static Boolean bool;    

    //To prevent ‘porteringen_mobiel__c’ records to be deleted when ‘IRMA_Id__c’ field is populated.
    //Called from AccountTrigger
    public static void deletePorteringMobiels(List<Account> accounts){
        Set<Id> accSet = new Set<Id>(); 
        Set<Id> quoteSet = new Set<Id>();    
        
        Set<Id> accountAll = (new Map<Id,SObject>(accounts)).keySet();

        for(Quote quote : [select id, opportunity.accountid from Quote where Opportunity.accountid in : accountAll]){
            quoteSet.add(quote.id);
        }
        for(Porteringen_mobiel__c pm : [select id,Account__c  from Porteringen_mobiel__c where (Account__c in : accountAll OR Offerte__c in : quoteSet) 
                                        and IRMA_Id__c != null]){
            accSet.add(pm.Account__c);
        }
        
        if(accSet.size() > 0){
            for(Account acc : accounts){
                if(accSet.contains(acc.id) && !Test.isRunningTest())
                    acc.addError('You cannot delete this record, Please contact to System Administrator.');
            }
        }
        
        
    }
    //for ISRA Check Work on grexx
    public static void sendIsraCheckRequestToGrexx(List<Account> accounts){
        System.debug('sendIsraCheckRequestToGrexx called...');
        Integer totalAccounts = accounts.size();
        /*List<Account> firstBatchAccounts = new List<Account>();
        List<Account> secondBatchAccounts = new List<Account>();
        List<Account> thirdBatchAccounts = new List<Account>();
        List<Account> fourthBatchAccounts = new List<Account>();*/
        
        Last_Batch_Run__c lastBatch = Last_Batch_Run__c.getValues('ISRA Check');
        DateTime lastScheduledRun = lastBatch.Last_Scheduled_Batch__c;
        Integer interval = lastBatch.Interval_Minutes__c != null ? Integer.valueOf(lastBatch.Interval_Minutes__c) : 60;
        
        Integer batchSize = Integer.valueOf(lastBatch.Batch_Size__c);
        
        if(lastScheduledRun<system.now()){
            lastScheduledRun = system.now();
        }
        
        Integer dataIndexPerBatch = 0;
        List<Account> batchAccounts = new List<Account>();
        for(Integer i = 0; i < totalAccounts; i++){
            batchAccounts.add(accounts[i]);
            dataIndexPerBatch++;
            if(dataIndexPerBatch >= batchSize){
                lastScheduledRun = setScheduler(lastScheduledRun, interval, batchAccounts);
				batchAccounts = new List<Account>();
				dataIndexPerBatch = 0;            
            }
            
        }
        
        if(batchAccounts.size() > 0){
            lastScheduledRun = setScheduler(lastScheduledRun, interval, batchAccounts);
        }
        
        
        /*Integer loopStart = batchSize; 
        for(Integer i=0; i<batchSize && i < totalAccounts; i++){
            firstBatchAccounts.add(accounts[i]);
        }
        for(Integer i=loopStart; i<loopStart+batchSize && i < totalAccounts; i++){
            secondBatchAccounts.add(accounts[i]);          
        }
        loopStart = loopStart + batchSize;
        for(Integer i=loopStart; i<loopStart+batchSize && i < totalAccounts; i++){
            thirdBatchAccounts.add(accounts[i]);
        }
        loopStart = loopStart + batchSize;
        for(Integer i=loopStart; i<loopStart+batchSize && i < totalAccounts; i++){
            fourthBatchAccounts.add(accounts[i]);
        }
        
        
        if(lastScheduledRun<system.now()){
            lastScheduledRun = system.now();
        }
        if(firstBatchAccounts.size() > 0){ 
            lastScheduledRun = setScheduler(lastScheduledRun, interval, firstBatchAccounts);            
        }
        if(secondBatchAccounts.size() > 0){ 
            lastScheduledRun = setScheduler(lastScheduledRun, interval, secondBatchAccounts);                      
        }
        if(thirdBatchAccounts.size() > 0){ 
            lastScheduledRun = setScheduler(lastScheduledRun, interval, thirdBatchAccounts);                    
        }
        if(fourthBatchAccounts.size() > 0){ 
            lastScheduledRun = setScheduler(lastScheduledRun, interval, fourthBatchAccounts);                        
        }    
*/
        lastBatch.Last_Scheduled_Batch__c =  lastScheduledRun;
        update lastBatch;  
    }
    
    private static DateTime setScheduler(DateTime scheduleTime, Integer interval, List<Account> accountList){
        DateTime batchTime = scheduleTime.addMinutes(interval);  
        Set<String> accIds = new Set<String>(new Map<String,SObject>(accountList).keySet());
        String chronExpression = '' + batchTime.second() + ' ' + batchTime.minute() + ' ' + batchTime.hour() + ' ' + batchTime.day() + ' ' + batchTime.month() + ' ? ' + batchTime.year();
        System.schedule('ISRA Check' + batchTime + system.now().millisecond(), chronExpression, new ScheduledBatchISRACheck(accIds)); 
        return batchTime;
    }
    //for Zip Code Check Work on grexx
    public static void sendZipCodeCheckRequestToGrexx(List<Account> accounts){
        System.debug('sendZipCodeCheckRequestToGrexx called...');
        Integer totalAccounts = accounts.size();
        List<Account> firstBatchAccounts = new List<Account>();
        List<Account> secondBatchAccounts = new List<Account>();
        List<Account> thirdBatchAccounts = new List<Account>();
        List<Account> fourthBatchAccounts = new List<Account>();
        
        Last_Batch_Run__c lastBatch = Last_Batch_Run__c.getValues('ZipCode Check');
        DateTime lastScheduledRun = lastBatch.Last_Scheduled_Batch__c;
        Integer batchSize = Integer.valueOf(lastBatch.Batch_Size__c);
        Integer loopStart = batchSize;
        for(Integer i=0; i<batchSize && i < totalAccounts; i++){
            firstBatchAccounts.add(accounts[i]);
        }
        for(Integer i=loopStart; i<loopStart+batchSize && i < totalAccounts; i++){
            secondBatchAccounts.add(accounts[i]);          
        }
        loopStart = loopStart + batchSize;
        for(Integer i=loopStart; i<loopStart+batchSize && i < totalAccounts; i++){
            thirdBatchAccounts.add(accounts[i]);
        }
        loopStart = loopStart + batchSize;
        for(Integer i=loopStart; i<loopStart+batchSize && i < totalAccounts; i++){
            fourthBatchAccounts.add(accounts[i]);
        }
        
        
        if(lastScheduledRun<system.now()){
            lastScheduledRun = system.now();
        }
        if(firstBatchAccounts.size() > 0){ 
            lastScheduledRun = setSchedulerZipCode(lastScheduledRun, firstBatchAccounts);            
        }
        if(secondBatchAccounts.size() > 0){ 
            lastScheduledRun = setSchedulerZipCode(lastScheduledRun, secondBatchAccounts);                      
        }
        if(thirdBatchAccounts.size() > 0){ 
            lastScheduledRun = setSchedulerZipCode(lastScheduledRun, thirdBatchAccounts);                    
        }
        if(fourthBatchAccounts.size() > 0){ 
            lastScheduledRun = setSchedulerZipCode(lastScheduledRun, fourthBatchAccounts);                        
        }     
        lastBatch.Last_Scheduled_Batch__c =  lastScheduledRun;
        update lastBatch;  
    }
    private static DateTime setSchedulerZipCode(DateTime scheduleTime, List<Account> accountList){
        DateTime batchTime = scheduleTime.addHours(1);  
        Set<String> accIds = new Set<String>(new Map<String,SObject>(accountList).keySet());
        String chronExpression = '' + batchTime.second() + ' ' + batchTime.minute() + ' ' + batchTime.hour() + ' ' + batchTime.day() + ' ' + batchTime.month() + ' ? ' + batchTime.year();
        System.schedule('ZipCode Check' + batchTime + system.now().millisecond(), chronExpression, new ScheduledBatchZipCodeCheck(accIds)); 
        return batchTime;
    }
}