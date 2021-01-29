@RestResource(urlMapping='/invoiceposts/*')
global without sharing class DemoInvoicePostEndpoint{ 
    
    @HttpPost
    global static string doPost() {
        String parseCode = RestContext.request.requestBody.toString();
        //String parseCode = '{"klant":{"kvk_nummer":"3008.67.99.69","verzendpostcode":"1055 PO","voornaam_cp":"Bradley","telefoonnummer":"020-6717171","verzendadres":"Helicopterstraat 583","achternaam_cp":"Wister","verzendplaats":"Sneek","klantnummer_afas":"7132638","bedrijfsnaam":"Schlots","factuurplaats":"Sneek","verzendhuisnummer":"583","e_mailadres":"b.wister@schlots.nl","factuurpostcode":"3456 BV","verzendhuisnummertoevoeging":"","verzendstraat":"Helicopterstraat","aanhef_cp":"","factuuradres":"Hoofdstraat 66"},"factuur":{"betalingscondities":"Mastercard","factuurnummer":"00000001"},"product":[{"btw_21_bedrag":268.63200,"btw_0_bedrag":0,"prijs_excl_btw":1279.20000,"btw_9_bedrag":0,"productid":"01t2o000009t9jBAAQ"},{"btw_21_bedrag":0,"btw_0_bedrag":0,"prijs_excl_btw":56,"btw_9_bedrag":0,"productid":"01t2o000009t9jBAAQ"},{"btw_21_bedrag":10.08000,"btw_0_bedrag":0,"prijs_excl_btw":48,"btw_9_bedrag":0,"productid":"01t2o000009t9jBAAQ"},{"btw_21_bedrag":0,"btw_0_bedrag":0,"prijs_excl_btw":0,"btw_9_bedrag":0,"productid":"01t2o000009t9jBAAQ"}]	}';
        system.debug('--data--' + parseCode);
        MKBInvoiceDataModel invoiceData = (MKBInvoiceDataModel)JSON.deserialize(
            parseCode, MKBInvoiceDataModel.class);
        //System.assertEquals(invoiceData, parseCode);
        system.debug('invoiceData ' + invoiceData);
        String klantNum = invoiceData.klant.klantnummer_afas;
        List<Account> lstAccount = new List<Account>();
        Id accountRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Excellence').getRecordTypeId();
        lstAccount = [Select id, mkbofficeshop_klantnummer__c from Account where mkbofficeshop_klantnummer__c =: klantNum and recordtypeid= :accountRecordId];
        
        
        Savepoint sp = Database.setSavepoint();
        try{
            Account accObj = new Account();
            if(lstAccount.size() == 0){
                accObj.RecordTypeId = accountRecordId;
                accObj.Name = invoiceData.klant.bedrijfsnaam;
                accObj.mkbofficeshop_klantnummer__c = invoiceData.klant.klantnummer_afas;
                accObj.KvK_nummer__c = invoiceData.klant.kvk_nummer;
                accObj.ShippingStreet = invoiceData.klant.verzendadres;
                accObj.Straat__c = invoiceData.klant.verzendstraat;
                accObj.Huisnummer__c = invoiceData.klant.verzendhuisnummer;
                accObj.Huisnummer_toevoeging__c = invoiceData.klant.verzendpostcode;
                accObj.ShippingPostalcode = invoiceData.klant.verzendpostcode;
                accObj.ShippingCity = invoiceData.klant.verzendplaats;
                accObj.Billingstreet = invoiceData.klant.factuuradres;
                accObj.BillingPostalcode = invoiceData.klant.factuurpostcode;
                accObj.BillingCity = invoiceData.klant.factuurplaats;
                accObj.Aanhef_CP__c = invoiceData.klant.aanhef_cp;
                accObj.Voornaam_CP__c = invoiceData.klant.voornaam_cp;
                accObj.Achternaam_CP__c = invoiceData.klant.achternaam_cp;
                accObj.E_mailadres_bedrijf__c = invoiceData.klant.e_mailadres;
                accObj.Phone = invoiceData.klant.telefoonnummer;
                insert accObj;
            }else{
                accObj = lstAccount[0];
            }
            
            Id bestllingRecordId = Schema.SObjectType.Bestelling_MM__c.getRecordTypeInfosByName().get('Verkooporder').getRecordTypeId();
            
            Bestelling_MM__c bestelObj = new Bestelling_MM__c();
            bestelObj.RecordTypeId = bestllingRecordId;
            bestelObj.Status__c = 'Lopend';
            bestelObj.Betaald_middels__c = invoiceData.factuur.betalingscondities;
            bestelObj.Kenmerk__c = invoiceData.factuur.factuurnummer;
            bestelObj.Bedrijf__c = accObj.Id;
            insert bestelObj;
            
            List<Bestellingproduct__c> lstBestelProd = new List<Bestellingproduct__c>();
            MKBInvoiceDataModel.MKBProductModel mkbInvoiceData = new MKBInvoiceDataModel.MKBProductModel();
            List<Product2> lstProduct = [Select id, Name from Product2 where Name =: label.MKB_Shop_Product];
            if(lstProduct.size() > 0){
                List<Bestellingproduct__c> lstBestllingProd = new List<Bestellingproduct__c>();
                for(MKBInvoiceDataModel.MKBProductModel mkbObj : invoiceData.product){
                    System.debug('mkbObj'+mkbObj);
                    Bestellingproduct__c bestelProdObj = new Bestellingproduct__c();
                    bestelProdObj.Name = label.MKB_Shop_Product;
                    bestelProdObj.Hoeveelheid__c = 1;
                    bestelProdObj.Verkoopprijs__c = mkbObj.prijs_excl_btw;
                    bestelProdObj.Product__c = lstProduct[0].Id;
                    bestelProdObj.BTW_21_bedrag__c = mkbObj.btw_21_bedrag;
                    bestelProdObj.BTW_9_bedrag__c = mkbObj.btw_9_bedrag;
                    bestelProdObj.BTW_21_bedrag__c = mkbObj.btw_0_bedrag;
                    bestelProdObj.Bestelling__c = bestelObj.id;
                    lstBestllingProd.add(bestelProdObj);
                }
                if(lstBestllingProd.size() > 0){
                    insert lstBestllingProd;
                    
                    MKBInvoiceResponse response = new MKBInvoiceResponse();
                    response.result = true;
                    response.customer_id = accObj.Id;
                    response.bestelling_id = bestelObj.Id;
                    return  JSON.serialize(response);
                    
                }else{
                    MKBInvoiceResponse response = new MKBInvoiceResponse();
                    response.result = false;
                    response.error_message = 'No product found in request';
                    return JSON.serialize(response);
                }
            }else{
                MKBInvoiceResponse response = new MKBInvoiceResponse();
                response.result = false;
                response.error_message = 'MKB product not found in system';
                return JSON.serialize(response);
            }
        }catch(Exception ex){
            Database.rollback(sp);
            MKBInvoiceResponse response = new MKBInvoiceResponse();
            response.result = false;
            response.error_message = ex.getMessage();
            return  JSON.serialize(response);
            
        }
    }    
 }