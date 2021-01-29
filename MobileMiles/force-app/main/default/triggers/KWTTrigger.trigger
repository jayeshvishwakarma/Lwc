/*
Name            :    KWTTrigger 
Author          :    Rajrishi Kaushik
Date            :    01/09/2020
Description     :    Used to perform action on KTW__c records
*/
trigger KWTTrigger on KWT__c (after insert, after update) {
    Set<Id> productIds = new Set<Id>();
    Set<Id> accIds = new Set<Id>();
    List<KWT__c> lstKWTs = new List<KWT__c>();
    
    if(Trigger.isInsert || Trigger.isUpdate){        
        for(KWT__c objKWT : Trigger.new){
            
            if((Trigger.isInsert && objKWT.Product__c != null) ||
                (Trigger.isUpdate && objKWT.Product__c !=null && (objKWT.Product__c != Trigger.oldmap.get(objKWT.Id).Product__c) || 
                                     								objKWT.Korting_per_aansluiting_p_mnd__c != Trigger.oldmap.get(objKWT.Id).Korting_per_aansluiting_p_mnd__c)){
                accIds.add(objKWT.Bedrijf__c);
                productIds.add(objKWT.Product__c);
                lstKWTs.add(objKWT);
            }
        }
        if(lstKWTs.size() > 0){
            KWTTriggerHelper.updatePorteringen(accIds, productIds, lstKWTs);  
        }
    }               
}