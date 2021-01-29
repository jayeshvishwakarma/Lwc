/*
    Name         :    ConvertQuoteLineItemCtrl
    Autohr       :
    Date         :    03/26/2016
    Description  :    Here we convert quteLineItem to bestellingMM, bestellingProduct and MobieleAansluiting(insert , existing update)
                      This class call from qoute detail page button 'Convert QuoteLineItem To Custom Object'.
*/
public class ConvertQuoteLineItemCtrl{
    private list<QuoteLineItem> quoteLineItemList;
    private string quoteId;
    private string recordTypeId;
    private map<string, list<string>> mobInsNameAndIdsMap;
    // Constructer
    public ConvertQuoteLineItemCtrl() {
        quoteId = apexPages.currentPage().getParameters().get('id');
        init();
    }
    
    // init
    private void init(){
        quoteLineItemList = new list<QuoteLineItem>();
        mobInsNameAndIdsMap = new map<string, list<string>>();
        fetchQuoteLineItems();
        fetchRecordTypeVerkooporder();
        
        
    }
  
    // Fetch quoteLineItems
    private void fetchQuoteLineItems() {
        quoteLineItemList = [SELECT id, quote.ID,Quantity,  
                               Toestel__c,Toestel_ID__c, Extra_HW_korting__c, 
                              Verkoopprijs_tbv_import__c, Product2.name,Product2Id,ToestelVerzekering__c, 
                              quote.AccountId, quote.Toegekend_VoorschotMM__c, quote.Voorschot_MM_tbv_convert__c,quote.Voornaam__c, 
                             quote.Achternaam__c, quote.Email , quote.Aanhef__c, quote.Offerte_URL__c,quote.Cloud_EEN_as_a_Service__c,quote.Pricebook2Id // added field quote.PriceBookId in SOQL Query
                             FROM QuoteLineItem WHERE QuoteId =: quoteId];
    }
    
    // Fetch Verkooporder record type for Bestellling_MM object
    private void fetchRecordTypeVerkooporder() {
        list<recordType> rtList = [SELECT id FROM recordType WHERE name = 'Verkooporder'];
        if(rtList.size() > 0) {
            recordTypeId = rtList[0].id;
        }
    }
    
   
    
    // Call from page action
    public pagereference createCustomObjectRecord() {
        try {
            createBestellingRecords();
            
        }catch(Exception e) {
            system.debug('-----###'+e.getMessage());
        }
        pagereference pg = new pagereference('/'+quoteId);
        return pg;
    }
    
    // CASE 1 : Here creating bestelling_MM and bestellingProduct , 
    // We are creating here single bestellingMM and multipal bestellingProduct
    private void createBestellingRecords() {
        Bestelling_MM__c bestMmObj = new Bestelling_MM__c();
        list<Bestellingproduct__c> bestProdList = new list<Bestellingproduct__c>();
        integer i=0;
        for(QuoteLineItem qliObj : quoteLineItemList) {
            if(qliObj.Toestel__c != null && qliObj.Toestel__c.trim().length()>0) {
                // Fill Bestellling_MM object
                if(i==0) {
                    bestMmObj.MobileMiles__c = qliObj.quote.Voorschot_MM_tbv_convert__c;
                     bestMmObj.Cloud_N_as_a_Service__c = qliObj.quote.Cloud_EEN_as_a_Service__c;
                    bestMmObj.Status__c = 'Lopend';bestMmObj.Gerelateerde_Offerte__c=qliObj.quote.ID;
                    bestMmObj.Aanhef__c = qliObj.quote.Aanhef__c;
                    bestMmObj.Voornaam__c = qliObj.quote.Voornaam__c;
                    bestMmObj.Achternaam__c = qliObj.quote.Achternaam__c;
                    bestMmObj.E_mailadres__c = qliObj.quote.Email;


                    if(recordTypeId != null)
                        bestMmObj.recordTypeId = recordTypeId;
                       
                        
                    if(qliObj.quote.AccountId != null)
                        bestMmObj.Bedrijf__c = qliObj.quote.AccountId;
                    i = 1;
                }
                // Fill BestelllingProduct object
                Bestellingproduct__c bestProdObj = new Bestellingproduct__c();
                bestProdObj.Extra_HW_korting__c = qliObj.Extra_HW_korting__c;
                bestProdObj.Hoeveelheid__c = qliObj.Quantity;
                bestProdObj.ToestelVerzekering__c = qliObj.ToestelVerzekering__c;
                bestProdObj.Product__c = qliObj.Toestel_ID__c;
                bestProdObj.Bestelling__r = bestMmObj;
                if(qliObj.Product2Id != null) {
                    bestProdObj.Name   = qliObj.Product2.name;
                }
                bestProdObj.Verkoopprijs__c = qliObj.Verkoopprijs_tbv_import__c;
                bestProdObj.Price__c = qliObj.quote.Pricebook2Id; // added field Price set with the value of the source; “pricebook” from the quote
                bestProdList.add(bestProdObj);
            }
        }
        
        // insert work
        if(bestMmObj != null) {
            // insert besttelingMM
            if(bestMmObj.Bedrijf__c != null) {
                insert bestMmObj;
            }
            // insert besttelingProduct
            if(bestMmObj.id != null) {
                if(bestProdList.size() > 0) {
                    for(Bestellingproduct__c obj : bestProdList) {
                        obj.Bestelling__c = obj.Bestelling__r.id;
                    }
                    insert bestProdList;
                }
            }  
        }
        system.debug('-----'+bestMmObj);
        system.debug('-----'+bestProdList);
    }
    }