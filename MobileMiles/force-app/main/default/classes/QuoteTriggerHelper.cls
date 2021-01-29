/*
        Name            :    QuoteTriggerHelper
        Author          :    Ranu Bari
        Date            :    01/23/2018
        Description     :    Used in QuoteTrigger
*/
public class QuoteTriggerHelper{

    //To prevent ‘porteringen_mobiel__c’ records to be deleted when ‘IRMA_Id__c’ field is populated.
    //Called from QuoteTrigger
    public static void deletePorteringMobiels(List<Quote> quotes){
        Set<Id> quoteSet = new Set<Id>();    
        
        Set<Id> quoteAll = (new Map<Id,SObject>(quotes)).keySet(); 
        for(Porteringen_mobiel__c pm : [select id,Offerte__c from Porteringen_mobiel__c where Offerte__c in : quoteAll 
                                        and IRMA_Id__c != null]){
            quoteSet.add(pm.Offerte__c);
        }
        
        if(quoteSet.size() > 0){
            for(Quote qut : quotes){
                if(quoteSet.contains(qut.id) && !Test.isRunningTest())
                    qut.addError('You cannot delete this record, Please contact to System Administrator.');
            }
        }
        
        
    }
    //To update Recordtype of Quote based on master Opportunity done by shikha (24/5/2019)
    public static void updatePorteringRecordType(List<Quote> quoteRecordTypes){
        List<Porteringen_mobiel__c> portMobToUpdate = new List<Porteringen_mobiel__c>();
        
        ID Tele2GoedQuotID = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Tele2 Goedgekeurd').getRecordTypeId();
        ID Tele2GoedPortMobID = Schema.SObjectType.Porteringen_mobiel__c.getRecordTypeInfosByName().get('Goedgekeurd Tele2').getRecordTypeId();
        
        ID Tele2QuotID = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Tele2').getRecordTypeId();
        ID Tele2PortMobID = Schema.SObjectType.Porteringen_mobiel__c.getRecordTypeInfosByName().get('Tele2').getRecordTypeId();
        
        ID TmobileGoedQuotID = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('T-Mobile Goedgekeurd').getRecordTypeId();
        ID TmobileGoedPortMobID = Schema.SObjectType.Porteringen_mobiel__c.getRecordTypeInfosByName().get('T-Mobile Goedgekeurd').getRecordTypeId();
        
        ID TmobileQuotID = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('T-Mobile').getRecordTypeId();
        ID TmobilePortMobID = Schema.SObjectType.Porteringen_mobiel__c.getRecordTypeInfosByName().get('T-Mobile').getRecordTypeId();        
        
        
        
        ID kpnGoedQuoteID = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('KPN KleinZakelijk Goedgekeurd').getRecordTypeId();
        ID kpnGoedPortMobID = Schema.SObjectType.Porteringen_mobiel__c.getRecordTypeInfosByName().get('KPN KleinZakelijk Goedgekeurd').getRecordTypeId();
        
        ID kpnQuoteID = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('KPN KleinZakelijk').getRecordTypeId();
        ID kpnPortMobID = Schema.SObjectType.Porteringen_mobiel__c.getRecordTypeInfosByName().get('KPN KleinZakelijk').getRecordTypeId();
        
        ID kpnExcGoedQuoteID = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('KPN ÉÉN Excellence Goedgekeurd').getRecordTypeId();
        ID goedKpnPortMobID = Schema.SObjectType.Porteringen_mobiel__c.getRecordTypeInfosByName().get('Goedgekeurd KPN ÉÉN').getRecordTypeId();
        
        ID kpnEenQuoteID = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('KPN ÉÉN').getRecordTypeId();
        ID kpnEenPortMobID = Schema.SObjectType.Porteringen_mobiel__c.getRecordTypeInfosByName().get('KPN ÉÉN').getRecordTypeId();
        
        Set<Id> quotRecTypes = new Set<Id>();
        quotRecTypes.add(Tele2GoedQuotID);
        quotRecTypes.add(Tele2QuotID);
        
        quotRecTypes.add(TmobileGoedQuotID);
        quotRecTypes.add(TmobileQuotID);        
        
        quotRecTypes.add(kpnGoedQuoteID);
        quotRecTypes.add(kpnQuoteID);
        quotRecTypes.add(kpnExcGoedQuoteID);
        quotRecTypes.add(kpnEenQuoteID);
        
        for(Porteringen_mobiel__c portMob : [select id, recordtypeID, Offerte__r.recordtypeID 
                                             from Porteringen_mobiel__c  where Offerte__c IN : quoteRecordTypes and 
                                             Offerte__r.recordtypeID IN : quotRecTypes]){
            if(portMob.Offerte__r.recordtypeID == Tele2GoedQuotID){
                portMob.recordtypeID = Tele2GoedPortMobID;
            }
            if(portMob.Offerte__r.recordtypeID == Tele2QuotID){
                portMob.recordtypeID = Tele2PortMobID;
            }
            
            if(portMob.Offerte__r.recordtypeID == TmobileGoedQuotID){
                portMob.recordtypeID = TmobileGoedPortMobID;
            }
            if(portMob.Offerte__r.recordtypeID == TmobileQuotID){
                portMob.recordtypeID = TmobilePortMobID;
            }
            
            
            
            if(portMob.Offerte__r.recordtypeID == kpnGoedQuoteID){
                portMob.recordtypeID = kpnGoedPortMobID;
            }
            if(portMob.Offerte__r.recordtypeID == kpnQuoteID){
                portMob.recordtypeID = kpnPortMobID;
            }
            if(portMob.Offerte__r.recordtypeID == kpnExcGoedQuoteID){
                portMob.recordtypeID = goedKpnPortMobID;
            }
            if(portMob.Offerte__r.recordtypeID == kpnEenQuoteID){
                portMob.recordtypeID = kpnEenPortMobID;
            }
            portMobToUpdate.add(portMob);
        }   
        if(portMobToUpdate.size() > 0)
            update portMobToUpdate;
    }
    /*//To Porteergegevens ophalen by ranu 27th may 2019
    public static void updatePorteringPorteergegevens(List<Quote> porteergegevensQuotes){
        List<Porteringen_mobiel__c> portMobToUpdate = new List<Porteringen_mobiel__c>();
        
        for(Porteringen_mobiel__c portMob : [select id, Porteergegevens_ophalen__c 
                                             from Porteringen_mobiel__c  where Voorgaande_order__c != null and 
                                             Offerte__c IN : porteergegevensQuotes]){
            portMob.Porteergegevens_ophalen__c = true;
            portMobToUpdate.add(portMob);                                     
        }    
        if(portMobToUpdate.size() > 0)
            update portMobToUpdate; 
        
        List<Quote> quoteToUpdate = new List<Quote>();    
        for(Quote quot : [select id, Porteergegevens_ophalen__c from Quote where id IN : porteergegevensQuotes]){
            quot.Porteergegevens_ophalen__c  = false;
            quoteToUpdate.add(quot);
        }      
        if(quoteToUpdate.size() > 0)
            update quoteToUpdate;                        
    }*/
}