public class SimSwapComponentController {
    
    //by ranu on 16th may to show child and parent accounts on component
    
    @AuraEnabled (cacheable=true)
    public static List<Account> fetchAllAccounts(){
        List<Account> accounts = new List<Account>();
        User usr = [select id, contact.accountid, contact.account.name from user where id =: Userinfo.getUSerID()];
        accounts.add(new Account(Id = usr.contact.accountId, name = usr.contact.account.name));        
        for(Account acc : [select id, name from account where parentId =: usr.contact.accountid]){
            accounts.add(acc);
        }
        return accounts;
    }
    @AuraEnabled
    public static List<Porteringen_mobiel__c> fetchActivePMRecords(String accId){
        /*User currentUser = [SELECT Username, ContactId, Contact.Name, Contact.AccountId, Contact.Account.Name, Contact.Email 
                                FROM User WHERE Id =: UserInfo.getUserId() ];*/
        Set<Id> recordTypes = new Set<Id>();
        recordTypes.add(Schema.SObjectType.Porteringen_mobiel__c.getRecordTypeInfosByName().get('Goedgekeurd KPN ÉÉN').getRecordTypeId());
        recordTypes.add(Schema.SObjectType.Porteringen_mobiel__c.getRecordTypeInfosByName().get('Direct order KPN ÉÉN Mobiel').getRecordTypeId());
        List<Porteringen_mobiel__c> porteringens = [select id, Name, Netto_prijs_per_maand__c, Product_KPN_EEN_VAMO__c, 
                                                    X06_097_nummer__c, Product_KPN_EEN__c, Product_KPN_EEN__r.Name  from Porteringen_mobiel__c 
                                Where Account__c = : accId //'0011l00000TQca8'
                                AND (Stagename__c = 'Actief' OR Stagename__c = 'Opheffen') 
                                AND recordtypeId  IN : recordTypes Order By X06_097_nummer__c];
        
        return porteringens;
    }
     
    @AuraEnabled
    public static String saveRecords(String configData){ 
        //System.debug('configData--------------' + configData);
        Map<String, Object> config = (Map<String, Object>) JSON.deserializeUntyped(configData);
        User currentUser = [SELECT Username, ContactId, Contact.Name, Contact.AccountId, Contact.Account.Name, Contact.Email 
                                FROM User WHERE Id =: UserInfo.getUserId() ];
        //system.debug('--' + config);
        //system.debug('currentUser' + currentUser); 
        
        String selectionType = config.get('selectionType') != null ? String.valueOf(config.get('selectionType')) : '';
        String pmId = config.get('pmId') != null ? String.valueOf(config.get('pmId')) : '';
        String simKaartNumber = config.get('simKaartNumber') != null ? String.valueOf(config.get('simKaartNumber')) : '';
        String product = config.get('product') != null ? String.valueOf(config.get('product')) : '';
        String name = config.get('name') != null ? String.valueOf(config.get('name')) : '';
        String vamo = config.get('vamo') != null ? String.valueOf(config.get('vamo')) : '';
        String label = config.get('label') != null ? String.valueOf(config.get('label')) : '';
        String klantnumber = config.get('klantnumber') != null ? String.valueOf(config.get('klantnumber')) : '';
        String huidigeProvider = config.get('huidigeProvider') != null ? String.valueOf(config.get('huidigeProvider')) : '';
        String selectedAccount = config.get('selectedAccount') != null ? String.valueOf(config.get('selectedAccount')) : null;
        System.debug('label' + label);
        System.debug('klantnumber' + klantnumber);
        System.debug('huidigeProvider' + huidigeProvider);
        System.debug('selectionType' + selectionType);
        //String accountId = '0011l00000TQca8';
        if(selectionType == 'ActivateSim'){
            Porteringen_mobiel__c newPM = new Porteringen_mobiel__c(Id = pmId);
            newPM.Nieuw_SIM_kaart_nummer__c = simKaartNumber;
            newPM.E_mailadres_SIM_activatie__c = currentUser.Contact.Email;
            newPM.Naam_simwissel__c = currentUser.Contact.Name;
            //SYstem.debug('currentUser.Contact.Email' + currentUser.Contact.Email);
            //SYstem.debug('currentUser.Contact.Name' + currentUser.Contact.Name);
            try{
                //newPM.Simwissel_uitvoeren__c = false;
                //update newPM;
                newPM.Simwissel_uitvoeren__c = true;
                update newPM;
                System.debug('newPM' + newPM);
                String returnVal = '{"message" : "Success" , "isWebCall" : "false" , "pmId" : "'+newPM.Id+'"}';
                return returnVal;
            }catch(Exception ex){
                System.debug('ex.getMessage()' + ex.getMessage());
                return 'Error: ' + ex.getMessage();
            }
        }else if(selectionType == 'NewNumber'){
            Porteringen_mobiel__c newPM = new Porteringen_mobiel__c();
            newPM.RecordTypeId = Schema.SObjectType.Porteringen_mobiel__c.getRecordTypeInfosByName().get('Direct order KPN ÉÉN Mobiel').getRecordTypeId();
            newPm.Name = 'Nieuw';
            newPM.Product_KPN_EEN__c = product;
            newPM.Nieuw_SIM_kaart_nummer__c = simKaartNumber;
            newPM.Type_aanvraag__c = 'Nieuw nummer';
            newPM.VAMO__c = vamo.equalsIgnoreCase('true') ? true : false;
            newPM.Wensdatum__c = system.today();
            newPM.Selecteer__c = TRUE;
            newPM.Account__c = selectedAccount;
            newPM.E_mailadres_SIM_activatie__c = currentUser.Contact.Email;
            newPM.Naam_simwissel__c = currentUser.Contact.Name;
            newPM.Label__c = label;
            try{
                insert newPM;
                String returnVal = '{"message" : "Success" , "isWebCall" : "true" , "pmId" : "'+newPM.Id +'"}';
                return returnVal;
            }catch(Exception ex){
                System.debug('ex.getMessage()' + ex.getMessage());
                return 'Error: ' + ex.getMessage();
            }
        }else if(selectionType == 'PorteringName'){
            Porteringen_mobiel__c newPM = new Porteringen_mobiel__c();
            newPM.RecordTypeId = Schema.SObjectType.Porteringen_mobiel__c.getRecordTypeInfosByName().get('Direct order KPN ÉÉN Mobiel').getRecordTypeId();
            newPm.Name = name;
            newPM.Product_KPN_EEN__c = product;
            newPM.Type_aanvraag__c = 'Portering';
            newPM.VAMO__c = vamo.equalsIgnoreCase('true') ? true : false;
            newPM.Wensdatum__c = system.today();
            newPM.Selecteer__c = TRUE;
            newPM.Account__c = selectedAccount;
            newPM.E_mailadres_SIM_activatie__c = currentUser.Contact.Email;
            newPM.Naam_simwissel__c = currentUser.Contact.Name;
            newPM.Label__c = label;
            newPM.Klant_nummer__c = klantnumber;
            newPM.Huidige_provider__c = huidigeProvider;
            try{ 
                insert newPM;
                String returnVal = '{"message" : "Success" , "isWebCall" : "true" , "pmId" : "'+newPM.Id+'"}';
                return returnVal;
            }catch(Exception ex){
                System.debug('ex.getMessage()' + ex.getMessage());
                return 'Error: ' + ex.getMessage();
            }
        }else if(selectionType == 'PorteringNumber'){
            Porteringen_mobiel__c newPM = new Porteringen_mobiel__c();
            newPM.RecordTypeId = Schema.SObjectType.Porteringen_mobiel__c.getRecordTypeInfosByName().get('Direct order KPN ÉÉN Mobiel').getRecordTypeId();
            newPm.Name = name;
            newPM.Product_KPN_EEN__c = product;
            newPM.Nieuw_SIM_kaart_nummer__c = simKaartNumber;
            newPM.Type_aanvraag__c = 'Portering';
            newPM.VAMO__c = vamo.equalsIgnoreCase('true') ? true : false;
            newPM.Wensdatum__c = system.today();
            newPM.Selecteer__c = TRUE;
            newPM.Account__c = selectedAccount;
            newPM.E_mailadres_SIM_activatie__c = currentUser.Contact.Email;
            newPM.Naam_simwissel__c = currentUser.Contact.Name;
            newPM.Label__c = label;
            newPM.Klant_nummer__c = klantnumber;
            newPM.Huidige_provider__c = huidigeProvider;
            try{
                insert newPM;
                System.debug('newPM' + newPM);
                String returnVal = '{"message" : "Success" , "isWebCall" : "true" , "pmId" : "'+ newPM.Id +'"}';
                return returnVal;
            }catch(Exception ex){
                System.debug('ex.getMessage()' + ex.getMessage());
                return 'Error: ' + ex.getMessage();
            }
        }   
        return 'blank value retun';
    }
    
    @AuraEnabled (cacheable=true)
    public static List<String> fetchHuidigeProviders(){
        List<String> providers = new List<String>();
        Schema.DescribeFieldResult fieldResult = Porteringen_mobiel__c.Huidige_provider__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            providers.add(pickListVal.getLabel());
        }     
        
        return providers;
    }
    
    @AuraEnabled
    public static String callGrexxService(String pmId) {
        if( String.isBlank(pmId) ) {
            return 'pmId is null';
        }
        List<Porteringen_mobiel__c> portMob = [Select name, orderwishdate__c, account__r.iRMA_id__c, account__r.name, account__r.Straat__c, account__r.Huisnummer__c, 
                                               account__r.Huisnummer_toevoeging__c, account__r.Postcode__c, account__r.shippingcity, 
                                               account__r.Telefoonnummer_nummeriek__c, account__r.E_mailadres_bedrijf__c, account__r.Rechtsvormtext__c, 
                                               account__r.Naam_volledig_cp__c, account__r.Voornaam_CP__c, account__r.Achternaam_CP__c, Grexxref__c, account__r.IRMA_MKB_Office__c, Nieuw_SIM_kaart_nummer__c 
                                               from Porteringen_mobiel__c where Id = :pmId LIMIT 1];
        
        
        list<Porteringen_mobiel__c> mobPorteringen = [Select productcode__c, Nieuw_SIM_kaart_nummer__c, phonenumber_nummeriek__c, donortelco_ID__c,
                                                      phonenumbertype__c, subscriptiontype__c, Gids_vermelding__c, Wensdatum__c, Blokkeren_betaalde_servicenummers__c,
                                                      Blokkeren_bellen_in_het_buitenland__c, Blokkeren_bellen_naar_buitenland__c, Blokkeren_data_in_het_buitenland__c,
                                                      Blokkeren_nummer_herkenning__c, Klant_nummer__c, Huidig_SIM_kaart_nummer_bij_consument__c, IRMA_Id__c,
                                                      OrderStatusCode__c, Contract_einddatum__c, Label__c,
                                                      (Select Id, productcode__c From Mobiele_modules__r)
                                                      From Porteringen_mobiel__c where id = :pmId  
                                                      ];//and GREXX_status_update__c = null and Selecteer__c = TRUE
        System.debug('portMob' + portMob);
        System.debug('mobPorteringen' + mobPorteringen);
        if(portMob.isEmpty() || mobPorteringen.isEmpty()) return 'data not found';
        //return 'shoiab is here';
        return PorteringToWSGrexxOrder.callGrexxService(portMob[0], mobPorteringen);
    }
    
}