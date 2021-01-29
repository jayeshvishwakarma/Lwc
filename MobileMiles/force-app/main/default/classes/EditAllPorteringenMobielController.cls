/*
    Name         : EditAllPorteringenMobielController
    Description  : used for EditAllPorteringenMobiel
    Created Date : 14 April 2017
*/

public class EditAllPorteringenMobielController{
    public List<Porteringen_mobiel__c> mobielList {get; set;}
    String quoteId;
    
    public EditAllPorteringenMobielController(ApexPages.StandardController st){
        quoteId = st.getRecord().id;
        if(!String.isEmpty(quoteId))
            mobielList = [SELECT Name, Profiel__c, Klant_of_SIM_kaart_nummer__c, Naam_huidige_provider__c, Type__c,  Blokkeren__c, PUK_code__c, Buitenland_modules__c, Huidige_provider__c, Profieltype__c, Internet_World_bundel__c, Mobiel_bellen_naar_buiten_EU__c,
                      Datum_eind_contract__c, Type_huidig_abonnement__c, Klant_nummer__c,Aanvraag_Vrijgeven_voor_Migratie__c,
                      Huidig_SIM_kaart_nummer_bij_consument__c,Datum_actief__c,IRMA_Id__c,Selecteer__c,Naam_huidig_abonnement__c,GREXX_status_update__c,Nieuw_SIM_kaart_nummer__c FROM Porteringen_mobiel__c 
                      WHERE Offerte__c = :quoteId ORDER BY Profiel__c];    
    }
    // below method is used to save all Porteringen_mobiel__c records related to quote
    public pagereference save(){
        try{
            if(mobielList != NULL && mobielList.size() > 0){
                update mobielList;
                return new Pagereference('/'+quoteId);
            }
        }catch(Exception exc){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,exc.getMessage()));
        }
        return NULL;    
    }
    //redirect to quote detail
    public pagereference cancel(){
        return new Pagereference('/'+quoteId);
    }
}