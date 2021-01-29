/*
    Community Page to Add Products
*/

public class AddProductsController{
    public List<pricebookEntryWrapper> pricebookEntryList {get; set;}
    public Boolean selectAll{get; set;}
    public Double Total_Price {get; set;} 
    public Account AccountObj{get; set;}   
    public String selectedAccount{get; set;} 
    public Double payableAmount {get; set;} 
    public List<pricebookEntryWrapper> SelectedPricebookentryList{get; set;} 
    public Boolean paymentEnalble {get; set;}   
    public Contact contactObj {get; set;}
    public Bestelling_MM__c Bestelling {get; set;}
    //public Double accountBalance {get;set;}
    public String selectedBrand{get; set;}
    public PageReference reference {get;set;}
    public Integer rowIndex{get;set;}
    public String inkoopnummer {get;set;}
    
    public AddProductsController(){
        selectedBrand = 'Alle merken';
        fetchProducts();
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String MyProflieName = PROFILE[0].Name;
        List<Account> accountsList = new List<Account>();
        
        if(MyProflieName == 'Cloud ÉÉN Community'){
        
            accountsList = [SELECT Id, Name,Straat__c,BillingStreet ,Betaalwijze_bestelling__c , Betalingscondities__c ,
                                    Saldo_MobileMiles__c,Huisnummer__c,Huisnummer_toevoeging__c,E_mail_factuuradres__c, ShippingCity, ShippingState, 
                                    ShippingCountry, ShippingPostalCode, BillingCity, BillingState, BillingCountry, BillingPostalCode FROM Account 
                                    where Id In(SELECT AccountId FROM User WHERE Id=:UserInfo.getUserId()) limit 1];
                                    
        }else{
        
            accountsList = [SELECT Id, Name,Straat__c,BillingStreet ,Betaalwijze_bestelling__c , Betalingscondities__c ,
                                    Saldo_MobileMiles__c,Huisnummer__c,Huisnummer_toevoeging__c,E_mail_factuuradres__c, ShippingCity, ShippingState, 
                                    ShippingCountry, ShippingPostalCode, BillingCity, BillingState, BillingCountry, BillingPostalCode FROM Account limit 1];
        }
        
        if(AccountsList.size() > 0){
            AccountObj = AccountsList[0];
            List<Contact> ContactList = [SELECT Id, FirstName, LastName,Name, CP_Aanhef__c, Email,Geslacht__c FROM Contact WHERE 
                                        ID In(SELECT contactid FROM User WHERE Id=:UserInfo.getUserId()) limit 1];
            //accountBalance = AccountObj.Saldo_MobileMiles__c /100;
            if(ContactList.size() > 0){
                contactObj = ContactList[0];
            }
        }
        
        
        if(Total_Price != NULL){
            payableAmount = Total_Price;//Total_Price - accountBalance; 
            if(payableAmount <0){
                payableAmount =0;    
            }
        }
        if(payableAmount == NULL || payableAmount == 0){
            paymentEnalble = false;    
        }
        else{
            paymentEnalble = true;
        } 
        
        SelectedPricebookentryList = new List<pricebookEntryWrapper>();
    }
    /*
        Filter By brand Name Functionality added on 07 March 2019
    */
    public List<SelectOption> getBrandsName() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Alle merken','Alle merken'));
        Set<String> brandSet = new Set<String>();
        for(pricebookentry pricebookentryrecord: [select id, product2.merk__c from pricebookentry where pricebook2.name ='Cloud EEN portal' and product2.isActive = true]){
            if(pricebookentryrecord.product2.merk__c != NUll){
                brandSet.add(pricebookentryrecord.product2.merk__c);
            }
        }
        for(String brand : brandSet){
            options.add(new SelectOption(brand , brand ));
        }
        return options;
    }
    public void fetchProducts(){
        pricebookEntryList = new List<pricebookEntryWrapper>();
        String queryString= 'select id,pricebook2Id, product2.Productfoto__c, pricebook2.name,product2.Name, product2.Voorraad__c, product2.description,unitprice from pricebookentry where pricebook2.name =\'Cloud EEN portal\' and product2.isActive = true';
        if(selectedBrand !='Alle merken'){
            queryString+= ' and product2.merk__c=\''+selectedBrand +'\'';    
        }
        
        for(pricebookentry pricebookentryrecord: Database.query(queryString)){
            pricebookEntryWrapper pwarp = new pricebookEntryWrapper(pricebookentryrecord);
            pwarp.Bestellingproduct.recalculateFormulas();
            
            pricebookEntryList.add(pwarp);     
        } 
    }
    public void changeAccount(){
        
        if(selectedAccount != NULL){
            AccountObj = [SELECT Id, Name,Straat__c, BillingStreet, Betaalwijze_bestelling__c , Betalingscondities__c ,Huisnummer__c,Huisnummer_toevoeging__c,
                          E_mail_factuuradres__c, Saldo_MobileMiles__c, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, BillingCity, 
                          BillingState, BillingCountry, BillingPostalCode FROM Account WHERE Id =: selectedAccount];
            contactObj = [SELECT Id, FirstName, LastName,Name, CP_Aanhef__c, Email,Geslacht__c FROM Contact WHERE Id In(SELECT contactid FROM User WHERE Id=:UserInfo.getUserId()) limit 1][0];
            //accountBalance = AccountObj.Saldo_MobileMiles__c / 100;
        }
       
        if(Total_Price != NULL){
            payableAmount = Total_Price ;//Total_Price - accountBalance ; 
            if(payableAmount <0){
                payableAmount =0;    
            }
        }
        if(payableAmount == NULL || payableAmount == 0){
            paymentEnalble = false;    
        }
        else{
            paymentEnalble = true;
        } 
    }
    
    
    public PageReference nextPage(){
        Total_Price =0;   
        for(pricebookEntryWrapper pricebookEntry : pricebookEntryList){
            if(pricebookEntry.isChecked){
                Total_Price = Total_Price + pricebookEntry.pricebookentryrecordObject.unitPrice * pricebookEntry.Bestellingproduct.Hoeveelheid__c;  
                SelectedPricebookentryList.add(pricebookEntry);   
            }
        } 
        if(Total_Price != NULL){
            payableAmount = Total_Price ;//Total_Price - accountBalance; 
            if(payableAmount <0){
                payableAmount =0;    
            }
        }
        if(payableAmount == NULL || payableAmount == 0){
            paymentEnalble = false;    
        }
        else{
            paymentEnalble = true;
        } 
        PageReference reference=new PageReference('/apex/AddProductsNextPage');
        reference.setRedirect(false);
        return reference;   
       
    }
    public List<SelectOption> getAccounts() {
        List<SelectOption> options = new List<SelectOption>();
        List<Account> accList= [Select Id, Name,Straat__c, BillingStreet, Betaalwijze_bestelling__c , Betalingscondities__c ,Huisnummer__c,
                                Huisnummer_toevoeging__c,E_mail_factuuradres__c, Saldo_MobileMiles__c, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, 
                                BillingCity, BillingState, BillingCountry, BillingPostalCode  FROM Account
                                 where Id In(SELECT AccountId FROM User WHERE Id=:UserInfo.getUserId()) limit 1];
        if(accList.size() == 1){
            AccountObj = accList[0];    
            //accountBalance = AccountObj.Saldo_MobileMiles__c /100;
            contactObj = [SELECT Id, FirstName, LastName,Name, CP_Aanhef__c, Email,Geslacht__c FROM Contact WHERE Id In(SELECT ContactId FROM User WHERE Id=:UserInfo.getUserId()) limit 1][0];
        }
        if(accList.size() == 1){
            Account acc = accList[0];
            options.add(new SelectOption(acc.Id,acc.Name));
            //done by ranu on 16th may to show child accounts also
            for(Account accObj : [select id, name from Account where parentid =: acc.id]){
                options.add(new SelectOption(accObj.Id,accObj.Name));
            }
        } 
        else{
            for(Account acc : [Select id, Name FROM Account limit 1000]){
                  options.add(new SelectOption(acc.Id,acc.Name));  
            }
        }       
        return options;
    }
    public void quantityChangeFunction(){
        Total_Price =0;   
        for(pricebookEntryWrapper pricebookEntry : SelectedPricebookentryList){
            Total_Price = Total_Price + pricebookEntry.pricebookentryrecordObject.unitPrice * pricebookEntry.Bestellingproduct.Hoeveelheid__c;      
        } 
        if(Total_Price != NULL){
            payableAmount = Total_Price ;//Total_Price - accountBalance; 
            if(payableAmount <0){
                payableAmount =0;    
            }
        }  
        if(payableAmount == NULL || payableAmount == 0){
            paymentEnalble = false;    
        }
        else{
            paymentEnalble = true;
        } 
    }
    public PageReference submitOrder(){       
        if(paymentEnalble == false){          
            reference=new PageReference('/apex/PaynlResponse');
            reference.setRedirect(false);            
            return reference;
        }
        else{           
            
            reference.setRedirect(true);                
            return reference;    
             
        }        
        
        return null;    
        
    }
    public void createRecords(){  
        Bestelling= new Bestelling_MM__c();
        Bestelling.Geslacht__c = contactobj.Geslacht__c;
        Bestelling.Achternaam__c = contactobj.lastname;
        //Bestelling.FirstName_PostNL__c = contactobj.firstname;
        Bestelling.Bedrijf__c = AccountObj.Id;
        Bestelling.Bedrijfsnaam__c= AccountObj.Name;        
        Bestelling.Street__c= AccountObj.Straat__c;
        Bestelling.HouseNO__c = AccountObj.Huisnummer__c;
        Bestelling.HouseNoSuffix__c = AccountObj.Huisnummer_toevoeging__c;
        Bestelling.Extra_e_mailadres_1__c= AccountObj.E_mail_factuuradres__c;
        Bestelling.Betaald_middels__c = AccountObj.Betaalwijze_bestelling__c;
        Bestelling.Aanhef__c = contactObj.CP_Aanhef__c;
        Bestelling.Voornaam__c = contactObj.FirstName;
        Bestelling.Achternaam__c = contactObj.LastName;
        Bestelling.E_mailadres__c = contactObj.Email;
        Bestelling.city__c = AccountObj.Shippingcity;            
        Bestelling.Postcode__c= AccountObj.ShippingPostalCode;
        Bestelling.Betaald_middels__c = AccountObj.Betaalwijze_bestelling__c ;
        Bestelling.Status__c = AccountObj.Betalingscondities__c ;  
        Bestelling.Referentie_mkbofficeshop_nl__c = inkoopnummer ;
        Bestelling.RecordTypeId = Schema.SObjectType.Bestelling_MM__c.getRecordTypeInfosByName().get('Weborder').getRecordTypeId();  
        if(AccountObj.Betaalwijze_bestelling__c != 'iDeal'){
            paymentEnalble = false;
        }
        if(paymentEnalble == false){
            Bestelling.Payment_Status__c ='Successed';
        }
        else{
            
            Double bedrag = (payableAmount*21)/100;
            Double finalAmt = payableAmount + bedrag ;
            PnlPaymentHandler.TransactionModal transactionModal = PnlPaymentHandler.doTransactionRequest(finalAmt*100,'Product Purchase - '+system.today(), AccountObj.Huisnummer__c + AccountObj.Shippingcity + AccountObj.ShippingCountry +'' , AccountObj.Huisnummer__c+'',AccountObj.Shippingcity+'',AccountObj.ShippingCountry+'');  
            if(transactionModal != NULL && transactionModal.request != NULL && transactionModal.request.result == '1'){
                Bestelling.transaction_Id__c =transactionModal.transaction_x.transactionId;
                reference=new PageReference(transactionModal.transaction_x.paymentURL);                   
            } 
        }
        if(Bestelling.Betaald_middels__c == 'iDeal' || Bestelling.Betaald_middels__c == 'Automatische incasso'){
            Bestelling.status__c = 'Betaald/verrekend - Inpakken en verzenden';
        }
        else{
            Bestelling.status__c = 'Lopend';
        }
        insert Bestelling;
        
        List<Bestellingproduct__c> BestellingproductList = new List<Bestellingproduct__c >();
        
        for(pricebookEntryWrapper pricebookEntry : SelectedPricebookentryList){
            Bestellingproduct__c Bestellingproduct= new Bestellingproduct__c(); 
            Bestellingproduct.Bestelling__c = Bestelling.Id;
            Bestellingproduct.Name = pricebookEntry.pricebookentryrecordObject.product2.Name;
            Bestellingproduct.Verkoopprijs__c = pricebookEntry.pricebookentryrecordObject.unitPrice ;
            BestellingProduct.Price__c = pricebookEntry.pricebookentryrecordObject.pricebook2Id;
            BestellingProduct.Hoeveelheid__c = pricebookEntry.Bestellingproduct.Hoeveelheid__c;
            Bestellingproduct.product__c= pricebookEntry.pricebookentryrecordObject.product2id;
            Bestellingproduct.ToestelVerzekering__c = pricebookEntry.Bestellingproduct.ToestelVerzekering__c;
            BestellingproductList.add(Bestellingproduct);
        }
        if(Test.isRunningTest()){
            
            Total_Price = 1000;
        }
        /*if(Total_Price > 0){ //accountBalance >0
            List<Product2> ProductList= [SELECT Id,Standaardprijs__c FROM Product2 WHERE Name ='Verzilveren MobileMiles' limit 1];
            if(ProductList.size() > 0){
                Bestellingproduct__c Bestellingproduct= new Bestellingproduct__c(); 
                Bestellingproduct.Bestelling__c = Bestelling.Id;
                Bestellingproduct.Name = 'Verzilveren MobileMiles';
                
                Product2 product= ProductList[0];
                Bestellingproduct.Verkoopprijs__c = product.Standaardprijs__c;
                Bestellingproduct.product__c= product.Id;
                if(Total_Price - accountBalance  > 0 )
                    Bestellingproduct.Hoeveelheid__c = accountBalance  * -100;    
                else
                    Bestellingproduct.Hoeveelheid__c = Total_Price * -100; 
                BestellingproductList.add(Bestellingproduct);
            }
        }*/
        insert BestellingproductList;
        
    } 
    public void removeRow(){                
        if(rowIndex != null){            
            SelectedPricebookentryList.remove(rowIndex);
        }
    }
    public void calculateTotalMaand(){
        for(pricebookEntryWrapper pricebookEntry : SelectedPricebookentryList){  
            Bestellingproduct__c Bestellingproduct = new Bestellingproduct__c();
            Decimal total = 0.00;
            pricebookEntry.Bestellingproduct.Verkoopprijs__c = pricebookEntry.pricebookentryrecordObject.unitprice;
            IF(pricebookEntry.Bestellingproduct.Verkoopprijs__c  < 501 && pricebookEntry.Bestellingproduct.ToestelVerzekering__c == 'Schade')
                total = 8.99;
            else IF(pricebookEntry.Bestellingproduct.Verkoopprijs__c  < 501 && pricebookEntry.Bestellingproduct.ToestelVerzekering__c == 'Totaal')
                total = 10.99;
            else IF(pricebookEntry.Bestellingproduct.Verkoopprijs__c  < 651 && pricebookEntry.Bestellingproduct.ToestelVerzekering__c == 'Schade')
                total = 9.99;
            else IF(pricebookEntry.Bestellingproduct.Verkoopprijs__c  < 651 && pricebookEntry.Bestellingproduct.ToestelVerzekering__c == 'Totaal')
                total = 12.99;
            else IF(pricebookEntry.Bestellingproduct.Verkoopprijs__c  < 901 && pricebookEntry.Bestellingproduct.ToestelVerzekering__c == 'Schade')
                total = 11.99;
            else IF(pricebookEntry.Bestellingproduct.Verkoopprijs__c  < 901 && pricebookEntry.Bestellingproduct.ToestelVerzekering__c == 'Totaal')
                total = 13.99;
            else IF(pricebookEntry.Bestellingproduct.Verkoopprijs__c  > 901 && pricebookEntry.Bestellingproduct.ToestelVerzekering__c == 'Schade')
                total = 13.99;
            else IF(pricebookEntry.Bestellingproduct.Verkoopprijs__c  > 901 && pricebookEntry.Bestellingproduct.ToestelVerzekering__c == 'Totaal')
                total = 16.99; 
    
            pricebookEntry.TOTAALPERMAAND = total * pricebookEntry.Bestellingproduct.Hoeveelheid__c;
            pricebookEntry.tempBestellingproduct.Verkoopprijs__c = pricebookEntry.TOTAALPERMAAND;
        }
    }   
    public class pricebookEntryWrapper{
        public Boolean isChecked{get; set;}
        public pricebookentry pricebookentryrecordObject{get; set;}
        public Bestellingproduct__c Bestellingproduct{get;set;}
        public Bestellingproduct__c tempBestellingproduct{get;set;}
        public Decimal TOTAALPERMAAND{get;set;}
        public pricebookEntryWrapper(pricebookentry pricebookentryrecord){           
            pricebookentryrecordObject = pricebookentryrecord;
            //quantity = 1;
            isChecked = false;
            Bestellingproduct = new Bestellingproduct__c();
            tempBestellingproduct = new Bestellingproduct__c();
            Bestellingproduct.Hoeveelheid__c = 1;
            //Bestellingproduct.Verkoopprijs__c = pricebookentryrecordObject.unitprice;
            //Bestellingproduct.ToestelVerzekering__c = 'Totaal';           
            
        }
    }
    
}