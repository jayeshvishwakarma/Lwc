/*
    Name        :    KlantkaartController 
    Date        :    13 April 2017
    Auther      :    
    Description :    This is an extension Controller Used By klantkaart VF Page   

*/
public class KlantkaartController {

    private Quote quotesRecord;
    public List<Porteringen_mobiel__c> quotesRelatedPorteringenMobiels{get;set;}
    public KlantkaartController(ApexPages.StandardController stdController) {
        this.quotesRecord= (Quote)stdController.getRecord();
        if(quotesRecord != Null){
            quotesRelatedPorteringenMobiels = [SELECT Name, Profieltype__c, Internet_World_bundel__c, Mobiel_bellen_naar_buiten_EU__c, Blokkeren__c, Gids_vermelding__c, Huidig_contract_afkopen_of_uitzitten__c,   Buitenland_modules__c, 
                                              Huidige_provider__c, Datum_eind_contract__c, Type_huidig_abonnement__c, Klant_nummer__c,
                                              Huidig_SIM_kaart_nummer_bij_consument__c, Nieuw_SIM_kaart_nummer__c FROM Porteringen_mobiel__c
                                              WHERE  Offerte__c =: quotesRecord.id ORDER BY Profieltype__c]; 
        }
    }
}