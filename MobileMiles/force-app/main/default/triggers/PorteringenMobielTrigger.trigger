/*
Name            :    PorteringenMobielTrigger 
Author          :    Ranu Bari
Date            :    01/23/2018
Description     :    Used to perform action on Porteringen_mobiel__c  records
*/
trigger PorteringenMobielTrigger on Porteringen_mobiel__c (before delete, after update, before insert, before update, after insert) {
    
    if(!KWTTriggerHelper.isUpdatingKWT){
        
        
        //To prevent ‘porteringen_mobiel__c’ records to be deleted when ‘IRMA_Id__c’ field is populated.
        if(Trigger.isDelete && Trigger.isBefore){
            PorteringenMobielTriggerHelper.deletePorteringMobiels(Trigger.old);
        }
        
        //To call Web Http Request when Simwissel_uitvoeren__c is checked (14/3/2019)
        if(Trigger.isUpdate && Trigger.isAfter){
            Set<ID> recordIds = new Set<ID>();
            Set<Id> portMobs = new Set<Id>();
            for(Porteringen_mobiel__c porteringen : Trigger.new){
                if(System.IsBatch() == false && System.isFuture() == false){ 
                    if(trigger.oldMap.get(porteringen.id).Simwissel_uitvoeren__c != porteringen.Simwissel_uitvoeren__c && porteringen.Simwissel_uitvoeren__c == true){
                        recordIds.add(porteringen.id);
                        system.debug('--in simswap--');
                    }
                }
                //ranu 21st may 2019
                if(porteringen.Verzend_wijziging_mobiele_instelling__c == TRUE && 
                   porteringen.Verzend_wijziging_mobiele_instelling__c != Trigger.oldMap.get(porteringen.id).Verzend_wijziging_mobiele_instelling__c 
                   /* && (porteringen.BlockCallerId__c != Trigger.oldMap.get(porteringen.id).BlockCallerId__c || 
porteringen.BlockCallsToInternationalNumbers__c != Trigger.oldMap.get(porteringen.id).BlockCallsToInternationalNumbers__c || 
porteringen.BlockCallWaiting__c != Trigger.oldMap.get(porteringen.id).BlockCallWaiting__c || 
porteringen.BlockDataRoaming__c != Trigger.oldMap.get(porteringen.id).BlockDataRoaming__c  || 
porteringen.BlockIncomingCallsWhenRoaming__c != Trigger.oldMap.get(porteringen.id).BlockIncomingCallsWhenRoaming__c || 
porteringen.BlockOutgoingCalls__c != Trigger.oldMap.get(porteringen.id).BlockOutgoingCalls__c || 
porteringen.BlockOutgoingCallsExceptDomestic__c != Trigger.oldMap.get(porteringen.id).BlockOutgoingCallsExceptDomestic__c || 
porteringen.BlockPremiumSms__c != Trigger.oldMap.get(porteringen.id).BlockPremiumSms__c || 
porteringen.BlockRoaming__c != Trigger.oldMap.get(porteringen.id).BlockRoaming__c || 
porteringen.BlockServiceNumbers__c != Trigger.oldMap.get(porteringen.id).BlockServiceNumbers__c  || 
porteringen.BlockSim__c != Trigger.oldMap.get(porteringen.id).BlockSim__c || 
porteringen.DataRoamingLimitEnabled__c != Trigger.oldMap.get(porteringen.id).DataRoamingLimitEnabled__c || 
porteringen.BlockVoLte__c != Trigger.oldMap.get(porteringen.id).BlockVoLte__c)*/){
    portMobs.add(porteringen.id);
}
            }
            if(recordIds.size() > 0){
                PorteringenMobielTriggerHelper.doSimSwap(recordIds);
            }
            if(portMobs.size() > 0){
                //ModifyMobileSettings.getPorteringMobile(portMobs);
                //updated for batch process on 27 june 2019 (shikha)
                PorteringenMobielTriggerHelper.ModifyMobileSettingsGREXX(portMobs);
            }
        }
        
        
        //To call Web Http Request when Mobiele_settings_ophalen__c is checked (25/6/2019) by shikha
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            Set<ID> mobielIds = new Set<ID>();
            Set<ID> contractIds = new Set<ID>();
            
            for(Porteringen_mobiel__c porteringen : Trigger.new){
                if(System.IsBatch() == false && System.isFuture() == false){ 
                    if((Trigger.isInsert && porteringen.Mobiele_settings_ophalen__c == true) || (Trigger.isUpdate && trigger.oldMap.get(porteringen.id).Mobiele_settings_ophalen__c != porteringen.Mobiele_settings_ophalen__c && porteringen.Mobiele_settings_ophalen__c == true)){
                        mobielIds.add(porteringen.id);
                    }
                    if((Trigger.isInsert && porteringen.Contract_duur_afloopdatum_wijzigen__c == true) || (Trigger.isUpdate && trigger.oldMap.get(porteringen.id).Contract_duur_afloopdatum_wijzigen__c != porteringen.Contract_duur_afloopdatum_wijzigen__c && porteringen.Contract_duur_afloopdatum_wijzigen__c == true)){
                        contractIds.add(porteringen.id);
                    }
                }
            }
            //call web service
            if(mobielIds.size() > 0){
                PorteringenMobielTriggerHelper.MobileSettingsGREXX(mobielIds);
            }
            if(contractIds.size() > 0){
                PorteringenMobielTriggerHelper.ModifyContractTerminationGREXX(contractIds);
            }
            
        }  
        
        //To update Active/Inactive lookup of account in PorteringenMobiel by shikha(24/5/2019)
        /*if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
PorteringenMobielTriggerHelper.SetPMLookup(Trigger.new, trigger.oldMap);
}*/
        
        
        if(Trigger.isUpdate && Trigger.isAfter){
            Set<Id> productIds = new Set<Id>();
            Set<Id> accIds = new Set<Id>();
            List<Porteringen_mobiel__c> lstPorteringens = new List<Porteringen_mobiel__c>();
            
            
            for(Porteringen_mobiel__c objPorteringen : Trigger.new){
                
                if((objPorteringen.Product__c !=null && objPorteringen.Product__c != Trigger.oldmap.get(objPorteringen.Id).Product__c) || 
                   (objPorteringen.Account__c != null && objPorteringen.Account__c != Trigger.oldmap.get(objPorteringen.Id).Account__c
                   )){
                       accIds.add(objPorteringen.Account__c);
                       productIds.add(objPorteringen.Product__c);
                       lstPorteringens.add(objPorteringen);
                   }
            }
            if(lstPorteringens.size() > 0){
                PorteringenMobielTriggerHelper.updatePorteringen(accIds, productIds, lstPorteringens);  
            }
        }  
    }
}