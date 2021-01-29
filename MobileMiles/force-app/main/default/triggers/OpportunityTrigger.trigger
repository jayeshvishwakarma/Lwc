/*
        Name            :    OpportunityTrigger
        Author          :    Ranu Bari
        Date            :    01/23/2018
        Description     :    Used to perform action on Opportunity records
*/
trigger OpportunityTrigger on Opportunity(before delete, after insert, after update) {
   
    //To prevent ‘porteringen_mobiel__c’ records to be deleted when ‘IRMA_Id__c’ field is populated.
    if(Trigger.isDelete && Trigger.isBefore){
        OpportunityTriggerHelper.deletePorteringMobiels(Trigger.old);
    }
    //done by ranu on 21st may 2019
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        List<Opportunity> opportunities = new List<Opportunity>();
        Set<Id> syncedQuotes = new Set<Id>();
        
        for(Opportunity opp : Trigger.new){
            if((Trigger.isInsert && opp.PVO_aanmaken__c == TRUE) || (Trigger.isUpdate && opp.PVO_aanmaken__c == TRUE && opp.PVO_aanmaken__c != Trigger.oldMap.get(opp.id).PVO_aanmaken__c)){
                opportunities.add(opp);
                if(opp.SyncedQuoteid != null){
                    syncedQuotes.add(opp.SyncedQuoteid);
                }
            }
        }
        if(opportunities.size() > 0){           
            opportunities = [select id, account.name, Aansluitadres__c, Huisnummer_aansluit__c, Plaats_aansluit__c, Postcode_aansluit__c,
                             AccountId, Looptijd_overeenkomst__c, Pricebook2ID, SyncedQuoteid, 
                             syncedQuote.Cloud_EEN_as_a_Service__c, syncedQuote.Betreft_verlenging_Excellence_klant__c, syncedQuote.Betreft_contractovername__c 
                             from Opportunity 
                             where id IN : opportunities]; 
            OpportunityTriggerHelper.createQuoteQLIs(opportunities, syncedQuotes);
        }
        
        if(Trigger.isAfter){
            //To update Recordtype of Quote based on master Opportunity done by shikha (24/5/2019)
            List<Opportunity> oppRecordTypes = new List<Opportunity>();
            for(Opportunity opp : Trigger.new){
                if(opp.recordtypeID != null && Trigger.isUpdate && opp.recordtypeID != Trigger.oldMap.get(opp.id).recordtypeID){
                    oppRecordTypes.add(opp);
                }
            }
            if(oppRecordTypes.size() > 0)
                OpportunityTriggerHelper.updateRecordType(oppRecordTypes);
        }
    }
}