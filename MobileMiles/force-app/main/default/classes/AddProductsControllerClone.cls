public without sharing class AddProductsControllerClone {

@AuraEnabled(cacheable = true)
 public static List<pricebookentry> fetchProducts(String selectedBrand){
        String queryString= 'select id,pricebook2Id, Product2.Productfoto__c, pricebook2.name,Product2.Name, Product2.Voorraad__c, Product2.Description,unitprice from pricebookentry where pricebook2.name =\'Cloud EEN portal\' and product2.isActive = true';
        if(selectedBrand !='Alle merken'){
            queryString+= ' and product2.merk__c=\''+selectedBrand +'\'';    
        } 
     
     List<pricebookentry> lstpricebookentries = Database.query(queryString); 
     if(lstpricebookentries.size() > 0)
         return lstpricebookentries;
     return null;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Response> getBrandsName() {
        List<Response> options = new List<Response>();
        options.add(new Response('Alle merken','Alle merken'));
        Set<String> brandSet = new Set<String>();
        for(pricebookentry pricebookentryrecord: [select id, product2.merk__c from pricebookentry where pricebook2.name ='Cloud EEN portal' and product2.isActive = true]){
            if(pricebookentryrecord.product2.merk__c != NUll){
                brandSet.add(pricebookentryrecord.product2.merk__c);
            }
        }
        for(String brand : brandSet){
            options.add(new Response(brand , brand ));
        }
        return options;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Response> getAccounts() {
        List<Response> options = new List<Response>();
        List<Account> accList= [Select Id, Name,Straat__c, BillingStreet, Betaalwijze_bestelling__c , Betalingscondities__c ,Huisnummer__c,
                                Huisnummer_toevoeging__c,E_mail_factuuradres__c, Saldo_MobileMiles__c, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, 
                                BillingCity, BillingState, BillingCountry, BillingPostalCode  FROM Account
                                 where Id In(SELECT AccountId FROM User WHERE Id=:UserInfo.getUserId()) limit 1];
        
        if(accList.size() == 1){
            Account acc = accList[0];
            options.add(new Response(acc.Name, acc.Id));
            //done by ranu on 16th may to show child accounts also
            for(Account accObj : [select id, name from Account where parentid =: acc.id]){
                options.add(new Response(accObj.Name, accObj.Id));
            }
        } 
        else{
            for(Account acc : [Select id, Name FROM Account limit 1000]){
                  options.add(new Response(acc.Name, acc.Id));  
            }
        }       
        return options;
    }
    
    @AuraEnabled(cacheable = true)
    public static Response changeAccount(String selectedAccount){
        System.debug('account '+selectedAccount);
        Response res = new Response();
        if(selectedAccount != NULL){
            List<Account> accounts = [SELECT Id, Name,Straat__c, BillingStreet, Betaalwijze_bestelling__c , Betalingscondities__c ,Huisnummer__c,Huisnummer_toevoeging__c,
                                  E_mail_factuuradres__c, Saldo_MobileMiles__c, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, BillingCity, 
                                  BillingState, BillingCountry, BillingPostalCode 
                                  FROM Account  WHERE Id =: selectedAccount];
            
            if(!accounts.isEmpty()){
                res.objAccount = accounts.get(0);
            }
            
            List<Contact> contacts = [SELECT Id, FirstName, LastName,Name, CP_Aanhef__c, Email,Geslacht__c FROM Contact WHERE Id In(SELECT contactid FROM User WHERE Id=:UserInfo.getUserId()) limit 1];
            if(!contacts.isEmpty()){
                res.objContact = contacts.get(0);
            }
        }
        System.debug('res '+res);
        return res;
    }
    
    @AuraEnabled
    public static List<Product2> getProducts(List<String> productIds){    
        System.debug('productIds'+productIds);
        return [select Id, Productfoto__c, Name, Voorraad__c, Description, (SELECT Id, UnitPrice, pricebook2Id FROM pricebookentries WHERE pricebook2.name ='Cloud EEN portal')
                FROM Product2 
                WHERE Id IN: productIds AND isActive = true];
    }
    
    @AuraEnabled
    public static String createRecord(Response response, String products, String inkoopnummer){
        String reference = '';
        try {   
            if(String.isNotBlank(products)){            
                List<ProductModal> productList = parse(products);  
                
                System.debug('productList==>'+ productList);
                
                
                Decimal bedrag = 0, finalAmt = 0, payableAmount = 0;            
                if(!productList.isEmpty()){
                    for(ProductModal pro :productList){
                        payableAmount += pro.UnitPrice * pro.quantity;
                    }
                }           
                bedrag = (payableAmount * 21) /100;
                finalAmt = payableAmount + bedrag ;  
                
                Account AccountObj = response.objAccount;
                
                //Fill Order Product
                Bestelling_MM__c Bestelling= new Bestelling_MM__c();
                Bestelling.Geslacht__c = response.objContact.Geslacht__c;
                Bestelling.Bedrijf__c = response.objAccount.Id;
                Bestelling.Bedrijfsnaam__c= response.objAccount.Name;        
                Bestelling.Street__c= response.objAccount.Straat__c;
                Bestelling.HouseNO__c = response.objAccount.Huisnummer__c;
                Bestelling.HouseNoSuffix__c = response.objAccount.Huisnummer_toevoeging__c;
                Bestelling.Extra_e_mailadres_1__c= response.objAccount.E_mail_factuuradres__c;
                Bestelling.Betaald_middels__c = response.objAccount.Betaalwijze_bestelling__c;
                Bestelling.Aanhef__c = response.objContact.CP_Aanhef__c;
                Bestelling.Voornaam__c = response.objContact.FirstName;
                Bestelling.Achternaam__c = response.objContact.LastName;
                Bestelling.E_mailadres__c = response.objContact.Email;
                Bestelling.city__c = response.objAccount.Shippingcity;            
                Bestelling.Postcode__c= response.objAccount.ShippingPostalCode;
                Bestelling.Betaald_middels__c = response.objAccount.Betaalwijze_bestelling__c ;
                Bestelling.Status__c = response.objAccount.Betalingscondities__c;  
                Bestelling.Referentie_mkbofficeshop_nl__c = inkoopnummer ;
                Bestelling.RecordTypeId = Schema.SObjectType.Bestelling_MM__c.getRecordTypeInfosByName().get('Weborder').getRecordTypeId();  
                
                Boolean paymentEnalble = (payableAmount > 0);
                if(response.objAccount.Betaalwijze_bestelling__c != 'iDeal'){
                    paymentEnalble = false;
                }
                
                if(paymentEnalble == false){
                    Bestelling.Payment_Status__c ='Successed';
                } else{   
                    PnlPaymentHandlerClone.TransactionModal transactionModal = PnlPaymentHandlerClone.doTransactionRequest(finalAmt*100,'Product Purchase - '+system.today(), AccountObj.Huisnummer__c + AccountObj.Shippingcity + AccountObj.ShippingCountry +'' , AccountObj.Huisnummer__c+'',AccountObj.Shippingcity+'',AccountObj.ShippingCountry+'');  
                    if(transactionModal != NULL && transactionModal.request != NULL && transactionModal.request.result == '1'){
                        Bestelling.transaction_Id__c = transactionModal.transaction_x.transactionId;
                        reference =  transactionModal.transaction_x.paymentURL; 
                    } 
                }
                
                Bestelling.status__c = (Bestelling.Betaald_middels__c == 'iDeal' || Bestelling.Betaald_middels__c == 'Automatische incasso') ? 'Betaald/verrekend - Inpakken en verzenden' : 'Lopend';
                
                insert Bestelling;
                
                List<Bestellingproduct__c> BestellingproductList = new List<Bestellingproduct__c >();        
                for(ProductModal pro :productList){
                    Bestellingproduct__c Bestellingproduct= new Bestellingproduct__c(); 
                    Bestellingproduct.Bestelling__c = Bestelling.Id;
                    Bestellingproduct.Name = pro.productName;
                    Bestellingproduct.Verkoopprijs__c = pro.UnitPrice ;
                    BestellingProduct.Price__c = pro.pricebook2Id;
                    BestellingProduct.Hoeveelheid__c = pro.quantity;
                    Bestellingproduct.product__c= pro.productId;
                    Bestellingproduct.ToestelVerzekering__c = pro.applianceInsuranc;
                    BestellingproductList.add(Bestellingproduct);
                }
                System.debug('bestingProducts :'+BestellingproductList);
                if(!BestellingproductList.isEmpty()){
                    insert BestellingproductList;   
                }     
            }
            if(reference != '')
            	return reference;
            else
                return 'success';
        }catch (Exception e) {
            system.debug('createRecord#######'+e.getStackTraceString());
            throw new AuraHandledException(e.getStackTraceString());    
        }
    }
    
    public class ProductModal {
        
        @AuraEnabled public String productId;
        @AuraEnabled public String productName;
        @AuraEnabled public String pricebook2Id;
        @AuraEnabled public String applianceInsuranc;
        @AuraEnabled public Decimal unitPrice;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Decimal totalPerMonth;
    }
    
    public static List<ProductModal> parse(String json){
		return (List<ProductModal>) System.JSON.deserialize(json, List<ProductModal>.class);
	}
    
    // wrapper class to send dynamic selectOptions to addProducts and addProductsNextPage component
    public class Response{
		@AuraEnabled  public String label {get; set;}
		@AuraEnabled  public String value {get; set;}
        @AuraEnabled  public Account objAccount {get; set;}
        @AuraEnabled  public Contact objContact {get; set;}
      
	public Response() {
        this.objAccount = new Account();
        this.objContact = new Contact();
        this.label = '';
        this.value = '';
	}
	
	public Response(String lab, String val) {
		this.label = lab;
		this.value = val;
	}  
        
    public Response(Account objAccount, Contact objContact){
       this.objAccount = objAccount;
       this.objContact = objContact;
    }	        
 } 
}