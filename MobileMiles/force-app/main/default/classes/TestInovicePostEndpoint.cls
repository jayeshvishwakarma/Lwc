@isTest
public class TestInovicePostEndpoint {
    
    @isTest
    static void teste(){
        MKBInvoiceDataModel mkbInObj = new MKBInvoiceDataModel();
       
        MKBInvoiceDataModel.MKBAccountModel mkbAccObj = new MKBInvoiceDataModel.MKBAccountModel();
        mkbAccObj.kvk_nummer = '3008.67';
        mkbAccObj.verzendpostcode = '1055 PO';
        mkbAccObj.voornaam_cp = 'Bradley';
        mkbAccObj.telefoonnummer = '020-6717171';
        mkbAccObj.verzendadres = 'Helicopterstraat 583';
        mkbAccObj.achternaam_cp = 'Wiste';
        mkbAccObj.verzendplaats = 'Sneek';
        mkbAccObj.klantnummer_afas = '7132638';
        mkbAccObj.bedrijfsnaam = 'Schlots';
        mkbAccObj.factuurplaats = 'Sneek';
        mkbAccObj.verzendhuisnummer = '583';
        mkbAccObj.e_mailadres = 'b.wister@schlots.nl';
        mkbAccObj.factuurpostcode = '3456 BV';
        mkbAccObj.verzendhuisnummertoevoeging = '';
        mkbAccObj.verzendstraat = 'Helicopterstraat';
        mkbAccObj.aanhef_cp = '';
        mkbAccObj.factuuradres = 'Hoofdstraat 66';
        mkbInObj.klant = mkbAccObj;
        
        
        MKBInvoiceDataModel.MKBBestellingModel mkbBestellingObj = new MKBInvoiceDataModel.MKBBestellingModel();
        mkbBestellingObj.betalingscondities = 'Mastercard';
        mkbBestellingObj.factuurnummer = '00000001';
        mkbInObj.factuur = mkbBestellingObj;
        
        product2 proObj = new product2();
        proObj.Name = 'mkbofficeshop.nl';
        insert proObj;
        
        MKBInvoiceDataModel.MKBProductModel mkbprodObj = new MKBInvoiceDataModel.MKBProductModel();
        List<MKBInvoiceDataModel.MKBProductModel> lstProd = new  List<MKBInvoiceDataModel.MKBProductModel>();
        mkbprodObj.btw_21_bedrag = 268.63200;
        mkbprodObj.btw_0_bedrag = 0;
        mkbprodObj.prijs_excl_btw = 1279.20000;
        mkbprodObj.btw_9_bedrag = 0;
        mkbprodObj.productid = proObj.Id;
        lstProd.add(mkbprodObj);
        mkbInObj.product = lstProd;
        
        String invoiceJSON = JSON.serialize(mkbInObj);
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://mobilemiles--sandbox.my.salesforce.com/services/apexrest/invoicepost';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(invoiceJSON);
        
        RestContext.request = request;
        InvoicePostEndpoint.doPost();
     }
}