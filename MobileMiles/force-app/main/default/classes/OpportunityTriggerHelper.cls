/*
        Name            :    OpportunityTriggerHelper
        Author          :    Ranu Bari
        Date            :    01/23/2018
        Description     :    Used in OpportunityTrigger
*/
public class OpportunityTriggerHelper{

    //To prevent ‘porteringen_mobiel__c’ records to be deleted when ‘IRMA_Id__c’ field is populated.
    //Called from OpportunityTrigger
    public static void deletePorteringMobiels(List<Opportunity> opportunities){
        Set<Id> oppSet = new Set<Id>(); 
        Map<Id, Quote> quoteMap = new Map<Id, Quote>();    
        
        Set<Id> oppAll = (new Map<Id,SObject>(opportunities)).keySet();
        quoteMap = new Map<Id, Quote>([select id, opportunityid from Quote where Opportunityid in : oppAll]); 
        if(quoteMap.size() > 0){
            for(Porteringen_mobiel__c pm : [select id,Account__c,Offerte__c  from Porteringen_mobiel__c where Offerte__c in : quoteMap.keySet() 
                                            and IRMA_Id__c != null]){
                oppSet.add(quoteMap.get(pm.Offerte__c).opportunityid);
            }
        }
        if(oppSet.size() > 0){
            for(Opportunity opp : opportunities){
                if(oppSet.contains(opp.id) && !Test.isRunningTest())
                    opp.addError('You cannot delete this record, Please contact to System Administrator.');
            }
        }
        
        
    }
    
    
    //To create Quote & Quote Line Item Records from Opportunity & OLI records
    //Called from OpportunityTrigger Edited on 20 May 2019 By shikha
    public static void createQuoteQLIs(List<Opportunity> opportunities, Set<Id> syncedQuotes){
        
        Map<Id, Quote> syncedQuoteMap = new Map<Id, Quote>();
        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();  
        Map<Id, Quote> oppQuoteMap = new Map<Id, Quote>();
        if(syncedQuotes.size() > 0){
            syncedQuoteMap = new Map<Id, Quote>([select id, (select id, Product2id, PriceBookEntryId, Quantity, Unitprice,Price_Connect__c,Price_Installation__c,Maatwerk_korting__c,KPN_N_Mobiel_product__c from quotelineitems) from Quote where id IN : syncedQuotes]);
        }     
        Id pvoRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('PVO').getRecordTypeId();
        for(Opportunity opp : opportunities){
            Quote quote = new Quote();
            quote.Name = opp.Account.Name;
            quote.Opportunityid = opp.id;
            quote.Aansluitadres__c = opp.Aansluitadres__c;
            quote.Aansluitadres_huisnummer__c = opp.Huisnummer_aansluit__c;
            quote.Aansluitadres_plaats__c = opp.Plaats_aansluit__c;
            quote.Aansluitadres_postcode__c = opp.Postcode_aansluit__c;
            quote.Cloud_EEN_as_a_Service__c = opp.syncedQuote.Cloud_EEN_as_a_Service__c;
            quote.Betreft_verlenging_Excellence_klant__c = opp.syncedQuote.Betreft_verlenging_Excellence_klant__c;
            quote.Betreft_contractovername__c = opp.syncedQuote.Betreft_contractovername__c;
            quote.Account__c = opp.AccountId;
            quote.ExpirationDate = System.Today()+5;
            quote.Looptijd__c = opp.Looptijd_overeenkomst__c;
            quote.pricebook2id = System.Label.OpportunityTrigger_PriceBook;
            quote.Recordtypeid = pvoRecordTypeId;
            quote.Status = 'Concept';
            quote.Pricebook2id = opp.Pricebook2ID;
            
            oppQuoteMap.put(opp.id, quote);            
        }
   
       if(oppQuoteMap.size() > 0){
           insert oppQuoteMap.values();
           for(Opportunity opp : opportunities){
               if(syncedQuoteMap.containsKey(opp.SyncedQuoteid)){
                    for(QuoteLineItem quLineItem : syncedQuoteMap.get(opp.SyncedQuoteid).quotelineitems){
                        QuoteLineItem qli = new QuoteLineItem();
                        qli.quoteId = oppQuoteMap.get(opp.id).id;
                        qli.Product2id = quLineItem.Product2id;
                        qli.PriceBookEntryId = quLineItem.PriceBookEntryId;
                        qli.Quantity = quLineItem.Quantity;
                        qli.Unitprice = quLineItem.Unitprice;
                        qli.Price_Connect__c = quLineItem.Price_Connect__c;
                        qli.Price_Installation__c = quLineItem.Price_Installation__c;
                        qli.Maatwerk_korting__c = quLineItem.Maatwerk_korting__c;
                        qli.KPN_N_Mobiel_product__c = quLineItem.KPN_N_Mobiel_product__c;
                        quoteLineItems.add(qli);
                    }
                }
            }
       
            if(quoteLineItems.size() > 0){
                insert quoteLineItems;                
            }
       }        
       //set PVO_aanmaken__c false again
       List<Opportunity> oppUpdate = new List<Opportunity>();
       for(Opportunity opp : opportunities){
           oppUpdate.add(new Opportunity(id = opp.id, PVO_aanmaken__c = false));
       }
       if(oppUpdate.size() > 0){
           update oppUpdate;
       }
       
       
    }
    
    
      //To update Recordtype of Quote based on master Opportunity done by shikha (24/5/2019)
    public static void updateRecordType(List<Opportunity> oppRecordTypes){
        List<Quote> quoteToUpdate = new List<Quote>();
        ID GoedgeOppID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KPN ÉÉN Excellence Goedgekeurd').getRecordTypeId();
        ID Tele2GoedOppID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Tele2 Goedgekeurd').getRecordTypeId();
        ID TmobileGoedOppID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('T-Mobile Goedgekeurd').getRecordTypeId();

    ID KZGoedOppID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KPN KleinZakelijk Goedgekeurd').getRecordTypeId();
        ID GoedgeQuoteID = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('KPN ÉÉN Excellence Goedgekeurd').getRecordTypeId();
        ID Tele2GoedQuoteID = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Tele2 Goedgekeurd').getRecordTypeId();
ID TmobileGoedQuoteID = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('T-Mobile Goedgekeurd').getRecordTypeId();
        ID KZGoedQuoteID = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('KPN KleinZakelijk Goedgekeurd').getRecordTypeId();
        ID kpnExcOppID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KPN ÉÉN Excellence').getRecordTypeId();
        ID Tele2OppID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Tele2').getRecordTypeId();
ID TmobileOppID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('T-Mobile').getRecordTypeId();
        ID KZOppID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KPN KleinZakelijk').getRecordTypeId();
        ID kpnExcQuoteID = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('KPN ÉÉN').getRecordTypeId();
        ID Tele2QuoteID = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Tele2').getRecordTypeId();
  ID TmobileQuoteID = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('T-Mobile').getRecordTypeId();
    ID KZQuoteID = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('KPN KleinZakelijk').getRecordTypeId();     
   
        Set<Id> oppRecTypes = new Set<Id>();
        oppRecTypes.add(GoedgeOppID);
        oppRecTypes.add(Tele2GoedOppID);
oppRecTypes.add(TmobileGoedOppID);
    oppRecTypes.add(KZGoedOppID);
        oppRecTypes.add(kpnExcOppID);
        oppRecTypes.add(Tele2OppID);
oppRecTypes.add(TmobileOppID);
                oppRecTypes.add(KZOppID);

        for(Quote quot : [select id, recordtypeID, opportunity.recordtypeID from Quote where opportunityid IN : oppRecordTypes and opportunity.recordtypeID IN : oppRecTypes]){
            if(quot.opportunity.recordtypeID == GoedgeOppID){
                quot.recordtypeID = GoedgeQuoteID;
            }
            if(quot.opportunity.recordtypeID == Tele2GoedOppID){
                quot.recordtypeID = Tele2GoedQuoteID;
        }
            if(quot.opportunity.recordtypeID == TmobileGoedOppID){
                quot.recordtypeID = TmobileGoedQuoteID;
        }
        if(quot.opportunity.recordtypeID == KZGoedOppID){
                quot.recordtypeID = KZGoedQuoteID;
            }
            if(quot.opportunity.recordtypeID == kpnExcOppID){
                quot.recordtypeID = kpnExcQuoteID;
            }
            if(quot.opportunity.recordtypeID == Tele2OppID){
                quot.recordtypeID = Tele2QuoteID;
        }
if(quot.opportunity.recordtypeID == TmobileOppID){
                quot.recordtypeID = TmobileQuoteID;
        }
            if(quot.opportunity.recordtypeID == KZOppID){
                quot.recordtypeID = KZQuoteID;

            }
            quoteToUpdate.add(quot);
        }   
        if(quoteToUpdate.size() > 0)
            update quoteToUpdate;
    }
}