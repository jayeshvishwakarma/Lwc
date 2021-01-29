/**
     * @File Name          : aTMTransferAndOnHoldReminderBatch.cls
     * @Description        : Update the Status when the Type is Bulk Hold Un Hold & Transfer Escalations and Escalation Date time is Today  . 
     * @Author             : Mohd Zakir 
     * @Last Modified By   : Mohd Zakir 
     * @Last Modified On   : 13-10-2020
     * @Modification Log   :
     *==============================================================================
    * Ver         Date                     Author                    Modification
    *==============================================================================
    * 1.0        13-10-2020                Zakir               Initial Version
**/
global class aTMTransferAndOnHoldReminderBatch implements Database.Batchable<sObject> {
    global  String sQuery;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        sQuery='select Id,Type__c,Name,Status__c from MC_Communication__c where (Type__c=\'Transfer Escalation\' OR Type__c=\'Bulk Hold Un-hold\') AND Escalation_Date_Time__c = Today';
        return Database.getQueryLocator(sQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> listRecord){
    List<MC_Communication__c> listMCCommunication = new List<MC_Communication__c>();
        for(MC_Communication__c mcComm : (List<MC_Communication__c>)listRecord){
            if(string.isBlank(mcComm.Status__c)){
                mcComm.Status__c = 'Picked';
                listMCCommunication.add(mcComm);
            }
        }
        if(listMCCommunication.size() > 0){
            update listMCCommunication;
            system.debug('listMCCommunication--'+listMCCommunication);
        }
    }
    global void finish(Database.BatchableContext BC){
     system.debug('mcCommunication finish');  
   }
}