/*
        Name            :    VoIPTriggerHelper
        Author          :    iBirds Services
        Date            :    13 August 2019
        Description     :    Used in VoIPTrigger
*/
public class VoIPTriggerHelper{
    
    //To call Web Http Request when Contract_duur_afloopdatum_wijzigen__c is checked (13 august 2019 by shikha)
    //Called from VoIPTrigger
    @future(callout=true)
    public static void VoIPModifyContractTerminationGREXX(Set<Id> contractIds){
        System.debug('VoIPModifyContractTerminationGREXX called...');
        List<VoIP__c> voipList = [Select name, id,  
                                        IRMA_Id__c, Contract_duur_afloopdatum_wijzigen__c  
                                        from VoIP__c Where id in :contractIds];
                                        
        Integer totalVoIP = voipList.size();
        List<VoIP__c> firstBatchVoIP = new List<VoIP__c>();
        List<VoIP__c> secondBatchVoIP = new List<VoIP__c>();
        List<VoIP__c> thirdBatchVoIP = new List<VoIP__c>();
        List<VoIP__c> fourthBatchVoIP = new List<VoIP__c>();
        
        Last_Batch_Run__c lastBatch = Last_Batch_Run__c.getValues('VoIP Contract Termination');
        DateTime lastScheduledRun = lastBatch.Last_Scheduled_Batch__c;
        Integer batchSize = Integer.valueOf(lastBatch.Batch_Size__c);
        Integer loopStart = batchSize;
        for(Integer i=0; i<batchSize && i < totalVoIP; i++){
            firstBatchVoIP.add(voipList[i]);
        }       
        for(Integer i=loopStart; i<loopStart+batchSize && i < totalVoIP; i++){
            secondBatchVoIP.add(voipList[i]);          
        }
        loopStart = loopStart + batchSize;
        for(Integer i=loopStart; i<loopStart+batchSize && i < totalVoIP; i++){
            thirdBatchVoIP.add(voipList[i]);
        }
        loopStart = loopStart + batchSize;
        for(Integer i=loopStart; i<loopStart+batchSize && i < totalVoIP; i++){
            fourthBatchVoIP.add(voipList[i]);
        }
        
        
        if(lastScheduledRun<system.now()){
            lastScheduledRun = system.now();
        }
        if(firstBatchVoIP.size() > 0){ 
            lastScheduledRun = setVoIPContractScheduler(lastScheduledRun, firstBatchVoIP);            
        }
        if(secondBatchVoIP.size() > 0){ 
            lastScheduledRun = setVoIPContractScheduler(lastScheduledRun, secondBatchVoIP);                      
        }
        if(thirdBatchVoIP.size() > 0){ 
            lastScheduledRun = setVoIPContractScheduler(lastScheduledRun, thirdBatchVoIP);                    
        }
        if(fourthBatchVoIP.size() > 0){ 
            lastScheduledRun = setVoIPContractScheduler(lastScheduledRun, fourthBatchVoIP);                        
        }     
        lastBatch.Last_Scheduled_Batch__c =  lastScheduledRun;
        update lastBatch; 
    }
    
    private static DateTime setVoIPContractScheduler(DateTime scheduleTime, List<VoIP__c> voipList){
        DateTime batchTime = scheduleTime.addHours(1);  
        Set<String> voipIds = new Set<String>(new Map<String,SObject>(voipList).keySet());
        String chronExpression = '' + batchTime.second() + ' ' + batchTime.minute() + ' ' + batchTime.hour() + ' ' + batchTime.day() + ' ' + batchTime.month() + ' ? ' + batchTime.year();
        System.schedule('VoIP Contract Termination' + batchTime + system.now().millisecond(), chronExpression, new ScheduledVoIPModifyContractTermination(voipIds)); 
        return batchTime;
    }
    
}