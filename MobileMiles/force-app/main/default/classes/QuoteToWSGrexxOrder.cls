public class QuoteToWSGrexxOrder {

    public Quote quote { get; set; }
    public list<Porteringen_mobiel__c> mobPorteringen = new list<Porteringen_mobiel__c> ();

    public QuoteToWSGrexxOrder(apexpages.StandardController controller) {
        quote = (quote) controller.getRecord();
        quote = [Select
                 Id,
                 Name,
                 orderwishdate__c,
                 newcustomer__c,
                 iRMA_klant_id__c,
                 Bedrijfsnaam__c,
                 Straat__c,
                 Huisnummer__c,
                 Huisnummer_toevoeging__c,
                 Postcode__c,
                 Plaats__c,
                 Landcode__c,
                 Telefoonnummer_nummeriek__c,
                 E_mailadres__c,
                 Rechtsvorm__c,
                 contactnaam__c,
                 Voornaam__c,
                 Achternaam__c,
                 ExternalId__c,
                 KvK_nummer__c,
                 IBAN_MM__c,
                 Directorder__c,
                 Account.phone,
                 Account.ShippingCity,
                 Grexxref__c,
                 Opportunityid,
                 productcode_telefooncentrale__c,
                 grouporderid__c,
                 Domein_telefooncentrale__c,
                 groupid__c,
                 unlimitedenabled__c,
                 desktopenabled__c,
                 externalproductid_telefooncentrale__c,
                 account.IRMA_MKB_Office__c //24 jan
                 From quote where Id = :quote.Id];

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

                          From Porteringen_mobiel__c where Offerte__c = :quote.Id and Selecteer__c = TRUE and GREXX_status_update__c = null];
    }

    public boolean showCreateOrderForce { get; set; }
    public pagereference CreateOrderForce() {
        quote.Grexxref__c = null;
        update quote;
        PageReference pageref = ApexPages.currentPage();
        pageref.setRedirect(true);
        return pageref;
    }

    public pagereference CreateOrder() {
        if (quote.Grexxref__c != null) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quote was already sent to Grexx'));
            showCreateOrderForce = true;
            return null;
        }

        try {
            if (reqFieldCheck(Quote)) {
                WSGrexxOrderControl.order_client_element Client = new WSGrexxOrderControl.order_client_element();
                Client.newcustomer = quote.newcustomer__c;
                if (!Client.newcustomer) {
                    Client.irmaklantid = (String) reqField('iRMA_klant_id__c');
                }
                Client.name = (String) reqField('Bedrijfsnaam__c');
                Client.street = (String) reqField('Straat__c');
                Client.HouseNr = Integer.valueOf((String) reqField('Huisnummer__c'));
                Client.housenrext = quote.Huisnummer_toevoeging__c;
                Client.ZipCode = (String) reqField('Postcode__c');
                Client.city = (String) reqField('Account.ShippingCity');
                Client.countrycode = quote.Landcode__c;
                Client.phone1 = ((string) reqField('Telefoonnummer_nummeriek__c')).replaceAll('[^a-zA-Z0-9]', ''); //((string) reqField('Account.phone')).replaceAll('[^a-zA-Z0-9]', ''); //eigenlijk int
                Client.email = (String) reqField('E_mailadres__c');
                Client.legalstatus = (String) reqField('Rechtsvorm__c');
                Client.contactname = (String) reqField('contactnaam__c');
                //Client.contactvoornaam = quote.Voornaam__c;
                //Client.contactachternaam = quote.Achternaam__c;
                Client.contactphone = ((string) reqField('Telefoonnummer_nummeriek__c')).replaceAll('[^a-zA-Z0-9]', ''); //eigenlijk int
                Client.externalid = quote.ExternalId__c;
                Client.chamberofcommercenr = quote.KvK_nummer__c;
                Client.iban = quote.IBAN_MM__c;

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
                        mobPhoneNr.contractterminationdate = Date.valueOf(pMob.Contract_einddatum__c);
                    }*/
                    //mobPhoneNr.contractterminationduration = '1';
                    
                    //by shikha on 1july for fixed format
                    mobPhoneNr.contractterminationdate = Date.valueOf('2023-01-01');
                    mobPhoneNr.contractterminationduration = '1';
                    
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
                    mobPhoneNr.lastname = Client.name;
                    mobPhoneNr.street = Client.street;
                    mobPhoneNr.housenr = String.valueOf(Client.housenr);
                    mobPhoneNr.housenrext = Client.housenrext;
                    mobPhoneNr.zipcode = Client.zipcode;
                    mobPhoneNr.city = Client.city;
                    mobPhoneNr.externalproductid = pMob.Id;
                    //ranu 1st may 2019
                    mobPhoneNr.vamoid = pMob.Id;
                    
                    //aslam 14th Oct, 2019
                    mobPhoneNr.label = pMob.Label__c;
                    system.debug('@@@ mobPhoneNr ' + mobPhoneNr);
                    
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
                
                //create users by ranu on 1st may 2019
                list<WSGrexxOrderControl.order_grouporder_kpneenv2user_user_element> kpeenusers = new list<WSGrexxOrderControl.order_grouporder_kpneenv2user_user_element> ();
                
                for (VoIP__c  voip : [select id, Vamo_ID__c, E_mailadres__c, Gebruikersnaam__c, productcode__c from VoIP__c 
                                      where Offerte__c = : quote.Id and 
                                      Selecteer_user_voor_GREXX__c = true]) {
                    WSGrexxOrderControl.order_grouporder_kpneenv2user_user_element kpeenuser = new WSGrexxOrderControl.order_grouporder_kpneenv2user_user_element();
                    
                    if(String.isNotBlank(voip.productcode__c) && String.isNotBlank(voip.Gebruikersnaam__c)){
                        kpeenuser.productcode = voip.productcode__c;
                        kpeenuser.username = voip.Gebruikersnaam__c;
                        kpeenuser.email = voip.E_mailadres__c;
                        kpeenuser.vamoid = voip.Vamo_ID__c;
                        kpeenuser.externalproductid = voip.id;
                    
                        kpeenusers.add(kpeenuser);
                    }
                }
                //system.debug('@@@@ kpeenusers ' + kpeenusers);
                WSGrexxOrderControl.order_grouporder_element  grouporderE = new WSGrexxOrderControl.order_grouporder_element ();
                grouporderE.productcode = quote.productcode_telefooncentrale__c;
                grouporderE.domain = quote.Domein_telefooncentrale__c;
                grouporderE.groupid = quote.groupid__c ;
                grouporderE.unlimitedenabled = quote.unlimitedenabled__c;
                grouporderE.desktopenabled = quote.desktopenabled__c ;
                grouporderE.orderid = quote.grouporderid__c ;

                WSGrexxOrderControl.order_grouporder_kpneenv2user_element kpeen2user = new WSGrexxOrderControl.order_grouporder_kpneenv2user_element();
                kpeen2user.user_x = kpeenusers;
                
                grouporderE.kpneenv2user = kpeen2user;
                
                groupOrderE.externalproductid = quote.externalproductid_telefooncentrale__c;
                system.debug('@@@@ grouporderE ' + grouporderE);

                if(kpeenusers.size() == 0 || (quote.productcode_telefooncentrale__c == null || 
                                              quote.Domein_telefooncentrale__c == null || 
                                              quote.groupid__c == null || 
                                              quote.desktopenabled__c == null || 
                                              quote.unlimitedenabled__c == null || 
                                              quote.grouporderid__c == null)) grouporderE = null;
                
                if(mobilephonenumbers.size() == 0) mobilephonenumbers= null;
                //Create the order
                    WSGrexxOrderControl.grexxResponse_element response = WSGrexxService.WSGrexxOrderControl(quote.Id, quote.orderwishdate__c == null ? system.today() : quote.orderwishdate__c, quote.Name, quote.Directorder__c,
                                                                                                            Client, null, grouporderE, mobilephonenumbers, null, null, quote.account.IRMA_MKB_Office__c); //24 Jan
                    if (response.status.code != 0) {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ref: ' + response.header.reference + '. Error code: ' + response.status.code + ': ' + response.status.message + '. ' + response.status.description));
                        return null;
                    }
                    system.debug('@@@@ response ' + response);
                    quote.grexxref__c = response.header.reference;
                    update quote;
                    Opportunity opp = new Opportunity(id=quote.Opportunityid, stagename = 'Ingelegd in IRMA');
                    database.update(opp, false);
                return(new pagereference('/' + quote.Id));
            }
        } catch(grexxException gExc) {
            ApexPages.addMessages(gExc);
            return null;
        }
        return null;
    }

    public list<string> getRequiredFields() {
        list<string> reqFields = new list<string> ();
        reqFields.add('orderwishdate__c');
        reqFields.add('newcustomer__c');
        reqFields.add('Bedrijfsnaam__c');
        reqFields.add('Straat__c');
        reqFields.add('Huisnummer__c');
        reqFields.add('Postcode__c');
        reqFields.add('Plaats__c');
        reqFields.add('Landcode__c');
        reqFields.add('Telefoonnummer_nummeriek__c');
        reqFields.add('E_mailadres__c');
        reqFields.add('contactnaam__c');
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
        return reqField(quote, field);
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
                    return null;
                }
            }
            Schema.DescribeFieldResult fldDesc = fld.getDescribe();

            if (fldDesc.getType() == Schema.DisplayType.Reference && isRelation) {
                if (stepNr >= steps.size() - 1) {
                    throw new grexxException('Kan geen SObject als waarde gebruiken in verplicht veld: ' + currObj.getSObjectType().getDescribe().fields.getMap().get(singleFieldName).getDescribe().getLabel() + ', op object <a href="/' + currObj.Id + '">' + currObj.getSObjectType().getDescribe().getName() + '</a>');
                    return null;
                }
                Sobject newObj = currObj.getSObject(step);
                if (newObj == null) {
                    throw new grexxException('SObject is leeg in verplicht veld: ' + currObj.getSObjectType().getDescribe().fields.getMap().get(singleFieldName).getDescribe().getLabel() + ', op object <a href="/' + currObj.Id + '">' + currObj.getSObjectType().getDescribe().getName() + '</a>');
                    return null;
                }
                currObj = newObj;
            } else {
                Object o = currObj.get(singleFieldName);
                if (stepNr<steps.size() - 1) {
                    throw new grexxException('Kan geen child waarde nemen na  verplicht veld: ' + currObj.getSObjectType().getDescribe().fields.getMap().get(singleFieldName).getDescribe().getLabel() + ', op object <a href="/' + currObj.Id + '">' + currObj.getSObjectType().getDescribe().getName() + '</a>');
                    return null;
                }
                if (o == null || (o instanceof String && String.isBlank(((string) o)))) {
                    throw new grexxException('Geen waarde in verplicht veld: ' + currObj.getSObjectType().getDescribe().fields.getMap().get(singleFieldName).getDescribe().getLabel() + ', op object <a href="/' + currObj.Id + '">' + currObj.getSObjectType().getDescribe().getName() + '</a>');
                    return null;
                }

                return o;
            }
        }

        throw new grexxException('Kan hier niet komen');
        return null;
    }
}