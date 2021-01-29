/**
* @File Name          : OnholdCasesToOpenBatch.cls
* @Description        : Update the Case Status from OnHold to Open if the Hold End Date is crossed.  . 
* @Author             : Mohd Zakir 
* @Last Modified By   : Mohd Zakir 
* @Last Modified On   : 28-10-2020
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        13-10-2020                Zakir               Initial Version
**/
global class OnholdCasesToOpenBatch implements Database.Batchable<sObject> {
    global  String sQuery;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date dateBeforeToday = Date.today().addDays(-1);
        list<string> listRecordType = new list<string>();
        if(label.RecordTypesForUnHoldCaseBatch.contains(',') ){
            listRecordType.addAll(label.RecordTypesForUnHoldCaseBatch.split(','));
        }else{
            listRecordType.add(label.RecordTypesForUnHoldCaseBatch);
        }
        if(listRecordType.size()>0){
            sQuery='select Id,Status,On_Hold_End_Date__c,RecordTypeId from Case where RecordType.developerName IN : listRecordType  AND Status = \'On Hold\'  AND On_Hold_End_Date__c =: dateBeforeToday ';                 
            return Database.getQueryLocator(sQuery);
        }
        return null;
    }
    
    global void execute(Database.BatchableContext BC, List<Case> listCase){
        system.debug('listCase-->'+listCase);
        for(Case caseRecord : listCase){
            caseRecord.Status = 'Open';
        }
        if(listcase.size() > 0){
            update listcase;
        } 
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('Finish');  
    }
}