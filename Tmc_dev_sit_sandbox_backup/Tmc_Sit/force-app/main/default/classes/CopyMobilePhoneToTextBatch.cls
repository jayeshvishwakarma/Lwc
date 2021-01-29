/**
* @File Name          : CopyMobilePhoneToTextBatch.cls
* @Description        : Trigger handler class for Account
* @Author             : 
* @Group              : 
* @Last Modified By   : Deepak Kumar
* @Last Modified On   : 
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    7/05/2019, 9:14:54 PM                                Initial Version 
**/


global with sharing class CopyMobilePhoneToTextBatch implements Database.Batchable<sObject> {
    global string query = '';
    public CopyMobilePhoneToTextBatch(string q) {
        query = q;

    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> lstRecordsToBeProcessed) {
        for (Account oAccVar : (List<Account>) lstRecordsToBeProcessed) {
            oAccVar.Phone_txt__c = oAccVar.PersonMobilePhone;
            oAccVar.Processed__c = 'Yes';
        }
        update lstRecordsToBeProcessed;
    }
    global void finish(Database.BatchableContext BC) {
        list<account> acclist = [
                Select id,Phone_txt__c, PersonMobilePhone
                from Account
                where RecordType.DeveloperName = 'Customer'
                and Phone_txt__c = null
                and PersonMobilePhone != null
                and SVOC_ID__c != null
                LIMIT 11000
        ];
        if (acclist.size() > 5000) {
            CopyMobilePhoneToTextBatch abc = new CopyMobilePhoneToTextBatch(query);
            database.executebatch(abc, 5000);
        }
    }
}