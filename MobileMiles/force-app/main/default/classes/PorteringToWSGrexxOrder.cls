public class PorteringToWSGrexxOrder {

    public Porteringen_mobiel__c portMob{ get; set; }
    public list<Porteringen_mobiel__c> mobPorteringen = new list<Porteringen_mobiel__c> ();

    public PorteringToWSGrexxOrder(apexpages.StandardController controller) {
        portMob = (Porteringen_mobiel__c) controller.getRecord();
        portMob = [Select
                 Id, name, orderwishdate__c, account__r.iRMA_id__c, account__r.name, account__r.Straat__c, account__r.Huisnummer__c, 
                 account__r.Huisnummer_toevoeging__c, account__r.Postcode__c, account__r.shippingcity, 
                 account__r.Telefoonnummer_nummeriek__c, account__r.E_mailadres_bedrijf__c, account__r.Rechtsvormtext__c, 
                 account__r.Naam_volledig_cp__c, account__r.Voornaam_CP__c, account__r.Achternaam_CP__c, account__r.IRMA_MKB_Office__c, Grexxref__c //24 Jan
                 from Porteringen_mobiel__c where Id = :portMob.Id]; 

        mobPorteringen = [Select
                          Id,
                          productcode__c,
                          Nieuw_SIM_kaart_nummer__c,
                          phonenumber_nummeriek__c,
                          donortelco_ID__c,
                          phonenumbertype__c,
                          subscriptiontype__c,
                          Gids_vermelding__c,
                          Wensdatum__c,
                          Blokkeren_betaalde_servicenummers__c,
                          Blokkeren_bellen_in_het_buitenland__c,
                          Blokkeren_bellen_naar_buitenland__c,
                          Blokkeren_data_in_het_buitenland__c,
                          Blokkeren_nummer_herkenning__c,
                          Klant_nummer__c,
                          Huidig_SIM_kaart_nummer_bij_consument__c,
                          IRMA_Id__c,
                          OrderStatusCode__c,
                          Contract_einddatum__c,
                          Label__c,

        (Select
         Id,
         productcode__c
         From Mobiele_modules__r)

                          From Porteringen_mobiel__c where id = :portMob.Id and Selecteer__c = TRUE and GREXX_status_update__c = null];
    }

    public boolean showCreateOrderForce { get; set; }
    public pagereference CreateOrderForce() {
        portMob.Grexxref__c = null;
        update portMob;
        PageReference pageref = ApexPages.currentPage();
        pageref.setRedirect(true);
        return pageref;
    }

    public pagereference CreateOrder() {
        if (portMob.Grexxref__c != null) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Portering Mobile was already sent to Grexx'));
            showCreateOrderForce = true;
            return null;
        }

        try {
            if (reqFieldCheck(portMob)) {
                WSGrexxOrderControl.order_client_element Client = new WSGrexxOrderControl.order_client_element();
                Client.newcustomer = false;
                if (!Client.newcustomer) {
                    Client.irmaklantid = portMob.account__r.iRMA_id__c;
                }
                Client.name = portMob.account__r.name;
                Client.street = portMob.account__r.Straat__c;
                Client.HouseNr = String.isNotBlank(portMob.account__r.Huisnummer__c) ? Integer.valueOf(portMob.account__r.Huisnummer__c) : 0;
                Client.housenrext = portMob.account__r.Huisnummer_toevoeging__c;
                Client.ZipCode = portMob.account__r.Postcode__c;
                Client.city = portMob.account__r.shippingcity;
                Client.countrycode = 'NLD';
                Client.phone1 = portMob.account__r.Telefoonnummer_nummeriek__c;
                Client.email = portMob.account__r.E_mailadres_bedrijf__c;
                Client.legalstatus = portMob.account__r.Rechtsvormtext__c;
                Client.contactname = portMob.account__r.Naam_volledig_cp__c;
                //Client.contactvoornaam = portMob.account__r.Voornaam_CP__c;
               // Client.contactachternaam = portMob.account__r.Achternaam_CP__c;
                Client.contactphone = portMob.account__r.Telefoonnummer_nummeriek__c;                

                //create mobile phonenumbers
                list<WSGrexxOrderControl.order_mobilephonenumbers_mobilephonenumber_element> mobilephonenumbers = new list<WSGrexxOrderControl.order_mobilephonenumbers_mobilephonenumber_element> ();

                for (Porteringen_mobiel__c pMob : mobPorteringen) {
                    WSGrexxOrderControl.order_mobilephonenumbers_mobilephonenumber_element mobPhoneNr = new WSGrexxOrderControl.order_mobilephonenumbers_mobilephonenumber_element();

                    //System.assert(false, pMob);
                    if(!test.isRunningTest()){
                    mobPhoneNr.productcode = (String) reqField(pMob, 'productcode__c');}
                    if (String.isNotBlank(pMob.Nieuw_SIM_kaart_nummer__c)) {
                        mobPhoneNr.iccshort = pMob.Nieuw_SIM_kaart_nummer__c;
                    }
                    if (String.isNotBlank(pMob.phonenumber_nummeriek__c)) {
                        mobPhoneNr.phonenumber = pMob.phonenumber_nummeriek__c;
                    }
                    if (String.isNotBlank(pMob.donortelco_ID__c)) {
                        mobPhoneNr.donortelco = pMob.donortelco_ID__c;
                    }
                    //by ranu on 27th august
                    /*if(pMob.Contract_einddatum__c != null){
                       //mobPhoneNr.contractterminationdate = Date.valueOf(pMob.Contract_einddatum__c);    
                    }*/
                    //mobPhoneNr.contractterminationduration = '1';
                    
                    //by shikha on 1july for fixed format
                    mobPhoneNr.contractterminationdate = Date.valueOf('2099-01-01');
                    mobPhoneNr.contractterminationduration = '0';
                    //system.debug('@@@ mobPhoneNr ' + mobPhoneNr);
                    //end of 27th august
                    mobPhoneNr.phonenumbertype = Integer.valueOf((Decimal) reqField(pMob, 'phonenumbertype__c'));
                    mobPhoneNr.subscriptiontype = pMob.subscriptiontype__c == null ? '1' : String.valueOf(pMob.subscriptiontype__c);
                    mobPhoneNr.listedinphonebook = (Boolean) reqField(pMob, 'Gids_vermelding__c');
                    mobPhoneNr.wishdate = String.valueOf((date) reqField(pMob, 'Wensdatum__c'));
                    mobPhoneNr.blockservicenumber = (Boolean) reqField(pMob, 'Blokkeren_betaalde_servicenummers__c');
                    mobPhoneNr.blockroaming = (Boolean) reqField(pMob, 'Blokkeren_bellen_in_het_buitenland__c');
                    mobPhoneNr.blockcalltointernational = (Boolean) reqField(pMob, 'Blokkeren_bellen_naar_buitenland__c');
                    mobPhoneNr.blockdataroaming = (Boolean) reqField(pMob, 'Blokkeren_data_in_het_buitenland__c');
                    mobPhoneNr.isprivatenumber = (Boolean) reqField(pMob, 'Blokkeren_nummer_herkenning__c');
                    if (String.isNotBlank(pMob.Klant_nummer__c)) {
                        mobPhoneNr.customernumber = pMob.Klant_nummer__c;
                    }
                    if (String.isNotBlank(pMob.Huidig_SIM_kaart_nummer_bij_consument__c)) {
                        mobPhoneNr.customersimcardnumber = pMob.Huidig_SIM_kaart_nummer_bij_consument__c;
                    }
                    mobPhoneNr.firstname = portMob.account__r.Voornaam_CP__c;
                    mobPhoneNr.lastname = Client.name;
                    mobPhoneNr.street = Client.street;
                    mobPhoneNr.housenr = String.valueOf(Client.housenr);
                    mobPhoneNr.housenrext = Client.housenrext;
                    mobPhoneNr.zipcode = Client.zipcode;
                    mobPhoneNr.city = Client.city;
                    mobPhoneNr.externalproductid = pMob.Id;
                    //ranu 1st may 2019
                    //mobPhoneNr.vamoid = pMob.Id;
                    
                    //aslam 14th Oct, 2019
                    mobPhoneNr.label = pMob.Label__c;
                    system.debug('@@mobPhoneNr--'+mobPhoneNr);
                    
                    //add modules to mobile phone number
                    list<WSGrexxOrderControl.order_mobilephonenumbers_mobilephonenumber_modules_module_element> modules = new list<WSGrexxOrderControl.order_mobilephonenumbers_mobilephonenumber_modules_module_element> ();
                    for (Mobiel_module__c mobMod : pMob.Mobiele_modules__r) {
                        WSGrexxOrderControl.order_mobilephonenumbers_mobilephonenumber_modules_module_element mod = new WSGrexxOrderControl.order_mobilephonenumbers_mobilephonenumber_modules_module_element();
                        mod.productcode = (String) reqField(mobMod, 'productcode__c');
                        //Added by Ranu on 13th March, 2018
                        mod.externalproductid = mobMod.Id;
                        modules.add(mod);
                    }

                    if (modules.size() > 0) {
                        mobPhoneNr.modules = new WSGrexxOrderControl.order_mobilephonenumbers_mobilephonenumber_modules_element();
                        mobPhoneNr.modules.module = modules;
                    }
                    mobilephonenumbers.add(mobPhoneNr);
                }
                
               
                if(mobilephonenumbers.size() == 0) mobilephonenumbers= null;
                //Create the order
                    WSGrexxOrderControl.grexxResponse_element response = WSGrexxService.WSGrexxOrderControl(portMob.Id, portMob.orderwishdate__c == null ? system.today() : portMob.orderwishdate__c, portMob.Name, true,
                                                                                                            Client, null, null, mobilephonenumbers, null, null, portMob.account__r.IRMA_MKB_Office__c);
                    if (response.status.code != 0) {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ref: ' + response.header.reference + '. Error code: ' + response.status.code + ': ' + response.status.message + '. ' + response.status.description));
                        return null;
                    }
                    system.debug('@@@@ response ' + response);
                    portMob.grexxref__c = response.header.reference;
                    update portMob;
                    
                return(new pagereference('/' + portMob.Id));
            }
        } catch(grexxException gExc) {
            ApexPages.addMessages(gExc);
            return null;
        }
        return null;
    }

    public list<string> getRequiredFields() {
        list<string> reqFields = new list<string> ();
        /*reqFields.add('orderwishdate__c');        
        reqFields.add('Bedrijfsnaam__c');
        reqFields.add('Straat__c');
        reqFields.add('Huisnummer__c');
        reqFields.add('Postcode__c');
        reqFields.add('Plaats__c');
        reqFields.add('Landcode__c');
        reqFields.add('Telefoonnummer_nummeriek__c');
        reqFields.add('E_mailadres__c');
        reqFields.add('contactnaam__c');*/
        return reqFields;
    }

    public Boolean reqFieldCheck(SObject sobj) {
        list<string> errors = new list<string> ();
        for (String field : getRequiredFields()) {
            try {
                object x = reqField(sobj, field);
            } catch(grexxException gExc) {
                ApexPages.addMessages(gExc);
            }
        }
        if (ApexPages.getMessages().size() == 0) {
            return true;
        }
        return false;
    }

    public object reqField(String field) {
        return reqField(portMob, field);
    }

    public object reqField(Sobject sobj, String field) {
        object returnvalue = null;
        string[] steps = field.split('\\.');
        SObject currObj = sobj;

        for (Integer stepNr = 0; stepNr<steps.size(); stepNr++) {
            String step = steps[stepNr];
            String singleFieldName = step.replaceall('__r', '__c');
            Schema.sObjectField fld = currObj.getSObjectType().getDescribe().fields.getMap().get(singleFieldName);
            Boolean isRelation = step.endsWith('__r');
            if (fld == null) {
                if (singleFieldName == 'Account') { //if (!step.endsWith('__r')) {
                    singleFieldName = step + 'ID';
                    isRelation = true;
                    fld = currObj.getSObjectType().getDescribe().fields.getMap().get(singleFieldName);
                }
                if (fld == null) {
                    throw new grexxException(stepNr + 'Veld bestaat niet: ' + step + ' en ' + singleFieldName + ', op object <a href="/' + currObj.Id + '">' + currObj.getSObjectType().getDescribe().getName() + '</a>');
                    //return null;
                }
            }
            Schema.DescribeFieldResult fldDesc = fld.getDescribe();

            if (fldDesc.getType() == Schema.DisplayType.Reference && isRelation) {
                if (stepNr >= steps.size() - 1) {
                    throw new grexxException('Kan geen SObject als waarde gebruiken in verplicht veld: ' + currObj.getSObjectType().getDescribe().fields.getMap().get(singleFieldName).getDescribe().getLabel() + ', op object <a href="/' + currObj.Id + '">' + currObj.getSObjectType().getDescribe().getName() + '</a>');
                    //return null;
                }
                Sobject newObj = currObj.getSObject(step);
                if (newObj == null) {
                    throw new grexxException('SObject is leeg in verplicht veld: ' + currObj.getSObjectType().getDescribe().fields.getMap().get(singleFieldName).getDescribe().getLabel() + ', op object <a href="/' + currObj.Id + '">' + currObj.getSObjectType().getDescribe().getName() + '</a>');
                    //return null;
                }
                currObj = newObj;
            } else {
                Object o = currObj.get(singleFieldName);
                if (stepNr<steps.size() - 1) {
                    throw new grexxException('Kan geen child waarde nemen na  verplicht veld: ' + currObj.getSObjectType().getDescribe().fields.getMap().get(singleFieldName).getDescribe().getLabel() + ', op object <a href="/' + currObj.Id + '">' + currObj.getSObjectType().getDescribe().getName() + '</a>');
                    //return null;
                }
                if (o == null || (o instanceof String && String.isBlank(((string) o)))) {
                    throw new grexxException('Geen waarde in verplicht veld: ' + currObj.getSObjectType().getDescribe().fields.getMap().get(singleFieldName).getDescribe().getLabel() + ', op object <a href="/' + currObj.Id + '">' + currObj.getSObjectType().getDescribe().getName() + '</a>');
                    //return null;
                }

                return o;
            }
        }

        throw new grexxException('Kan hier niet komen');
        //return null;        
    }
    
    
    //This method is called from LWC (SimSwap) component
    public static string callGrexxService(Porteringen_mobiel__c  portMob, List<Porteringen_mobiel__c> mobPorteringen){
        try {
            //if (reqFieldCheck(portMob)) {
                WSGrexxOrderControl.order_client_element Client = new WSGrexxOrderControl.order_client_element();
                Client.newcustomer = false;
                if (!Client.newcustomer) {
                    Client.irmaklantid = portMob.account__r.iRMA_id__c;
                }
                Client.name = portMob.account__r.name;
                Client.street = portMob.account__r.Straat__c;
                Client.HouseNr = String.isNotBlank(portMob.account__r.Huisnummer__c) ? Integer.valueOf(portMob.account__r.Huisnummer__c) : 0;
                Client.housenrext = portMob.account__r.Huisnummer_toevoeging__c;
                Client.ZipCode = portMob.account__r.Postcode__c;
                Client.city = portMob.account__r.shippingcity;
                Client.countrycode = 'NLD';
                Client.phone1 = portMob.account__r.Telefoonnummer_nummeriek__c;
                Client.email = portMob.account__r.E_mailadres_bedrijf__c;
                Client.legalstatus = portMob.account__r.Rechtsvormtext__c;
                Client.contactname = portMob.account__r.Naam_volledig_cp__c;
                //Client.contactvoornaam = portMob.account__r.Voornaam_CP__c;
               // Client.contactachternaam = portMob.account__r.Achternaam_CP__c;
                Client.contactphone = portMob.account__r.Telefoonnummer_nummeriek__c;                

                //create mobile phonenumbers
                list<WSGrexxOrderControl.order_mobilephonenumbers_mobilephonenumber_element> mobilephonenumbers = new list<WSGrexxOrderControl.order_mobilephonenumbers_mobilephonenumber_element> ();

                for (Porteringen_mobiel__c pMob : mobPorteringen) {
                    WSGrexxOrderControl.order_mobilephonenumbers_mobilephonenumber_element mobPhoneNr = new WSGrexxOrderControl.order_mobilephonenumbers_mobilephonenumber_element();

                    //System.assert(false, pMob);
                    if(!test.isRunningTest()){
                    mobPhoneNr.productcode = (String) reqFieldLWC(pMob, 'productcode__c');}
                    if (String.isNotBlank(pMob.Nieuw_SIM_kaart_nummer__c)) {
                        mobPhoneNr.iccshort = pMob.Nieuw_SIM_kaart_nummer__c;
                    }
                    if (String.isNotBlank(pMob.phonenumber_nummeriek__c)) {
                        mobPhoneNr.phonenumber = pMob.phonenumber_nummeriek__c;
                    }
                    if (String.isNotBlank(pMob.donortelco_ID__c)) {
                        mobPhoneNr.donortelco = pMob.donortelco_ID__c;
                    }
                    //by ranu on 27th august
                    /*if(pMob.Contract_einddatum__c != null){
                       //mobPhoneNr.contractterminationdate = Date.valueOf(pMob.Contract_einddatum__c);    
                    }*/
                    //mobPhoneNr.contractterminationduration = '1';
                    
                    //by shikha on 1july for fixed format
                    mobPhoneNr.contractterminationdate = Date.valueOf('2023-01-01');
                    mobPhoneNr.contractterminationduration = '1';
                    //system.debug('@@@ mobPhoneNr ' + mobPhoneNr);
                    //end of 27th august
                    mobPhoneNr.phonenumbertype = Integer.valueOf((Decimal) reqFieldLWC(pMob, 'phonenumbertype__c'));
                    mobPhoneNr.subscriptiontype = pMob.subscriptiontype__c == null ? '1' : String.valueOf(pMob.subscriptiontype__c);
                    mobPhoneNr.listedinphonebook = (Boolean) reqFieldLWC(pMob, 'Gids_vermelding__c');
                    mobPhoneNr.wishdate = String.valueOf((date) reqFieldLWC(pMob, 'Wensdatum__c'));
                    mobPhoneNr.blockservicenumber = (Boolean) reqFieldLWC(pMob, 'Blokkeren_betaalde_servicenummers__c');
                    mobPhoneNr.blockroaming = (Boolean) reqFieldLWC(pMob, 'Blokkeren_bellen_in_het_buitenland__c');
                    mobPhoneNr.blockcalltointernational = (Boolean) reqFieldLWC(pMob, 'Blokkeren_bellen_naar_buitenland__c');
                    mobPhoneNr.blockdataroaming = (Boolean) reqFieldLWC(pMob, 'Blokkeren_data_in_het_buitenland__c');
                    mobPhoneNr.isprivatenumber = (Boolean) reqFieldLWC(pMob, 'Blokkeren_nummer_herkenning__c');
                    if (String.isNotBlank(pMob.Klant_nummer__c)) {
                        mobPhoneNr.customernumber = pMob.Klant_nummer__c;
                    }
                    if (String.isNotBlank(pMob.Huidig_SIM_kaart_nummer_bij_consument__c)) {
                        mobPhoneNr.customersimcardnumber = pMob.Huidig_SIM_kaart_nummer_bij_consument__c;
                    }
                    mobPhoneNr.firstname = portMob.account__r.Voornaam_CP__c;
                    mobPhoneNr.lastname = Client.name;
                    mobPhoneNr.street = Client.street;
                    mobPhoneNr.housenr = String.valueOf(Client.housenr);
                    mobPhoneNr.housenrext = Client.housenrext;
                    mobPhoneNr.zipcode = Client.zipcode;
                    mobPhoneNr.city = Client.city;
                    mobPhoneNr.externalproductid = pMob.Id;
                    //ranu 1st may 2019
                    //mobPhoneNr.vamoid = pMob.Id;
                    
                    //aslam 14th Oct, 2019
                    mobPhoneNr.label = pMob.Label__c;
                    system.debug('@@mobPhoneNr--'+mobPhoneNr);
                    
                    //add modules to mobile phone number
                    list<WSGrexxOrderControl.order_mobilephonenumbers_mobilephonenumber_modules_module_element> modules = new list<WSGrexxOrderControl.order_mobilephonenumbers_mobilephonenumber_modules_module_element> ();
                    for (Mobiel_module__c mobMod : pMob.Mobiele_modules__r) {
                        WSGrexxOrderControl.order_mobilephonenumbers_mobilephonenumber_modules_module_element mod = new WSGrexxOrderControl.order_mobilephonenumbers_mobilephonenumber_modules_module_element();
                        mod.productcode = (String) reqFieldLWC(mobMod, 'productcode__c');
                        //Added by Ranu on 13th March, 2018
                        mod.externalproductid = mobMod.Id;
                        modules.add(mod);
                    }

                    if (modules.size() > 0) {
                        mobPhoneNr.modules = new WSGrexxOrderControl.order_mobilephonenumbers_mobilephonenumber_modules_element();
                        mobPhoneNr.modules.module = modules;
                    }
                    mobilephonenumbers.add(mobPhoneNr);
                }
                
               
                if(mobilephonenumbers.size() == 0) mobilephonenumbers= null;
                //Create the order
                    WSGrexxOrderControl.grexxResponse_element response = WSGrexxService.WSGrexxOrderControl(portMob.Id, portMob.orderwishdate__c == null ? system.today() : portMob.orderwishdate__c, portMob.Name, true,
                                                                                                            Client, null, null, mobilephonenumbers, null, null, portMob.account__r.IRMA_MKB_Office__c);
                    if (response.status.code != 0) {
                        //Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ref: ' + response.header.reference + '. Error code: ' + response.status.code + ': ' + response.status.message + '. ' + response.status.description));
                        return 'Error: ' + response.header.reference + '. Error code: ' + response.status.code + ': ' + response.status.message + '. ' + response.status.description;
                    }
                    system.debug('@@@@ response ' + response);
                    portMob.grexxref__c = response.header.reference;
                    update portMob;
                    
                return 'Success: ' + response.header.reference;
            //}
        } catch(grexxException gExc) {
            
            return 'Error: ' + gExc.getMessage();
        }
    }
    
    
    private static object reqFieldLWC(Sobject sobj, String field) {
        object returnvalue = null;
        string[] steps = field.split('\\.');
        SObject currObj = sobj;

        for (Integer stepNr = 0; stepNr<steps.size(); stepNr++) {
            String step = steps[stepNr];
            String singleFieldName = step.replaceall('__r', '__c');
            Schema.sObjectField fld = currObj.getSObjectType().getDescribe().fields.getMap().get(singleFieldName);
            Boolean isRelation = step.endsWith('__r');
            if (fld == null) {
                if (singleFieldName == 'Account') { //if (!step.endsWith('__r')) {
                    singleFieldName = step + 'ID';
                    isRelation = true;
                    fld = currObj.getSObjectType().getDescribe().fields.getMap().get(singleFieldName);
                }
                if (fld == null) {
                    throw new grexxException(stepNr + 'Veld bestaat niet: ' + step + ' en ' + singleFieldName + ', op object <a href="/' + currObj.Id + '">' + currObj.getSObjectType().getDescribe().getName() + '</a>');
                    //return null;
                }
            }
            Schema.DescribeFieldResult fldDesc = fld.getDescribe();

            if (fldDesc.getType() == Schema.DisplayType.Reference && isRelation) {
                if (stepNr >= steps.size() - 1) {
                    throw new grexxException('Kan geen SObject als waarde gebruiken in verplicht veld: ' + currObj.getSObjectType().getDescribe().fields.getMap().get(singleFieldName).getDescribe().getLabel() + ', op object <a href="/' + currObj.Id + '">' + currObj.getSObjectType().getDescribe().getName() + '</a>');
                    //return null;
                }
                Sobject newObj = currObj.getSObject(step);
                if (newObj == null) {
                    throw new grexxException('SObject is leeg in verplicht veld: ' + currObj.getSObjectType().getDescribe().fields.getMap().get(singleFieldName).getDescribe().getLabel() + ', op object <a href="/' + currObj.Id + '">' + currObj.getSObjectType().getDescribe().getName() + '</a>');
                    //return null;
                }
                currObj = newObj;
            } else {
                Object o = currObj.get(singleFieldName);
                if (stepNr<steps.size() - 1) {
                    throw new grexxException('Kan geen child waarde nemen na  verplicht veld: ' + currObj.getSObjectType().getDescribe().fields.getMap().get(singleFieldName).getDescribe().getLabel() + ', op object <a href="/' + currObj.Id + '">' + currObj.getSObjectType().getDescribe().getName() + '</a>');
                    //return null;
                }
                if (o == null || (o instanceof String && String.isBlank(((string) o)))) {
                    throw new grexxException('Geen waarde in verplicht veld: ' + currObj.getSObjectType().getDescribe().fields.getMap().get(singleFieldName).getDescribe().getLabel() + ', op object <a href="/' + currObj.Id + '">' + currObj.getSObjectType().getDescribe().getName() + '</a>');
                    //return null;
                }

                return o;
            }
        }

        throw new grexxException('Kan hier niet komen');
        //return null;        
    }
}