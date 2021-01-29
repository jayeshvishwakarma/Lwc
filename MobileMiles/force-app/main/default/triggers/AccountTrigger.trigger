/*
        Name            :    AccountTrigger
        Author          :    Ranu Bari
        Date            :    01/23/2018
        Description     :    Used to perform action on Account records
*/
trigger AccountTrigger on Account(before delete, after update, after insert) {
   List<Trigger_Settings__c> lstTriggerSettings = [SELECT Account_Trigger__c From Trigger_Settings__c];
   if(lstTriggerSettings.size()>0 && lstTriggerSettings[0].Account_Trigger__c){
   
    //To prevent ‘porteringen_mobiel__c’ records to be deleted when ‘IRMA_Id__c’ field is populated.
    if(Trigger.isDelete && Trigger.isBefore){
        AccountTriggerHelper.deletePorteringMobiels(Trigger.old);
    }
    //for isra check work by ranu
    if(Trigger.isUpdate && Trigger.isAfter){
        List<Account> accounts  = new List<Account>();
        List<Account> accountsZipCode  = new List<Account>();
        for(Account acc : Trigger.new){
            if(acc.ISRA_Check__c == true && acc.ISRA_Check__c != Trigger.oldMap.get(acc.id).ISRA_Check__c){
                accounts.add(acc);
            }
            //done by ranu on 27th May 2019
            if(acc.Check_Beschikbaarheid__c == true && acc.Check_Beschikbaarheid__c != Trigger.oldMap.get(acc.id).Check_Beschikbaarheid__c){
                accountsZipCode.add(acc);
            }
        }
        if(accounts.size() > 0 && AccountTriggerHelper.isISRACheckCalled == false){
            system.debug('Account Trigger Called.....');
            AccountTriggerHelper.sendIsraCheckRequestToGrexx(accounts);
            AccountTriggerHelper.isISRACheckCalled = true;
            
        }
        if(accountsZipCode.size() > 0 && AccountTriggerHelper.isZipCodeCheckCalled == false){
            system.debug('Account Trigger Zip Code Called.....');
            AccountTriggerHelper.sendZipCodeCheckRequestToGrexx(accountsZipCode);
            AccountTriggerHelper.isZipCodeCheckCalled = true;
            
        }
    }   
    }     
}