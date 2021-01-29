/**
 * @File Name          : CopyCustomerAddressToCaseBatch.cls
 * @Description        : This class is used to copy the customer Address from Customer record to the case record
 * @Author             : Deepak
 * @Group              : Techmatrix
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    18/12/2019                    Deepak           Initial Version
**/

global class CopyCustomerAddressToCaseBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //String  productionCaseRT = String.valueOf(System.Label.Production_Case_RecordTypes).spli
        String sQuery = 'Select Id,Address__c,Customer__c FROM Case';
        return Database.getQueryLocator(sQuery);
    }
    global void execute(Database.BatchableContext BC, List<sObject> lstRecordsToBeProcessed) {
        try {
            List<Case> casesToUpdate = new List<Case>();
            List<Case> cases = (List<Case>) lstRecordsToBeProcessed; // TypeCasting to sObject to Case
            Set<Id> customerIds = new Set<Id>();
            for (Case caseObj : cases) {
                if (caseObj.Customer__c != null) {
                    customerIds.add(caseObj.Customer__c);
                }
            }
            if (!customerIds.isEmpty()) {
                Map<Id, Account> idVsCustomerMap = new Map<Id, Account>([Select Id,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry FROM Account Where Id IN:customerIds]);
                for (Case caseObj : cases) {
                    if (caseObj.Customer__c != null && idVsCustomerMap.containsKey(caseObj.Customer__c)) {
                        Account customerAccount = idVsCustomerMap.get(caseObj.Customer__c);
                        String address = '';
                        address += customerAccount.BillingStreet != null ? customerAccount.BillingStreet + ConstantsUtility.COMMA : address;
                        address += customerAccount.BillingCity != null ? customerAccount.BillingCity + ConstantsUtility.COMMA : address;
                        address += customerAccount.BillingState != null ? customerAccount.BillingState + ConstantsUtility.COMMA : address;
                        address += customerAccount.BillingPostalCode != null ? customerAccount.BillingPostalCode + ConstantsUtility.COMMA : address;
                        address += customerAccount.BillingCountry != null ? customerAccount.BillingCountry + ConstantsUtility.COMMA : address;
                        caseObj.Address__c = address.length() < 255 ? address : address.substring(0, 255);
                        if(String.isNotBlank(caseObj.Address__c)){
                            casesToUpdate.add(caseObj);
                        }
                    }
                }
            }
            if (!casesToUpdate.isEmpty()) {
                TriggerHandler.bypass('CaseTriggerHandler_Strategy');
                update casesToUpdate;
                TriggerHandler.clearBypass('CaseTriggerHandler_Strategy');
            }
        } catch (Exception ex) {
            ExceptionHandler.LogError('CopyCustomerAddressToCaseBatch', ex.getMessage(), null, null, null);
        }
    }
    global void finish(Database.BatchableContext BC) {
        System.debug('CopyCustomerAddressToCaseBatch Finished');
    }

}