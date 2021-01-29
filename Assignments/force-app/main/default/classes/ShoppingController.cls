public without sharing class ShoppingController {
    public boolean isPgBlock1{get;set;}
    
    public boolean isPgBlock2{get;set;}
    
    public boolean isPgBlockEdit{get;set;}
    
    public boolean isMainpgBlock{get;set;}
    
    public boolean ispgBlockAccount{get;set;}
    
    public Boolean ispgBlockTransaction{get;set;}
    
    public String EmailIdFromLoginPage{get;set;}
    
    public String EmailIdFromShoppingPage{get;set;}
    
    public String nameFromLoginPage{get;set;}
    
    public String searchProduct{get;set;}
    
    public String ViewAllInteger{get;set;}
    
    public Contact objContact{get;set;}
    
    public List<Order_detail__C> lstorderDetails{get;set;}
    
    public ShoppingController()
    {
        nameFromLoginPage=ApexPages.currentPage().getParameters().get('nameFromLoginPage');
        System.debug('Name:'+nameFromLoginPage);
        EmailIdFromLoginPage=ApexPages.currentPage().getParameters().get('EmailIdFromLoginPage');
        System.debug('Email  ' +EmailIdFromLoginPage);
        isMainpgBlock=true;
        isPgBlock1=true;
        isPgBlock2=false;
        if(EmailIdFromLoginPage!=null)
        {
            abc(); 
        }
    }
    public PageReference login()
    {
        return page.loginAccount;
    }
    public void abc()
    {
        isPgBlock1=false;
        isPgBlock2=true;
        
    }
    
    public PageReference ViewAll()
    {
        System.debug(ViewAllInteger);
        PageReference pref = page.shopping_page2;
        pref.getParameters().put('EmailIdFromShoppingPage',EmailIdFromShoppingPage);
        pref.getParameters().put('nameOfContact',nameFromLoginPage);
        pref.getParameters().put('ViewAllInteger',ViewAllINteger);
        System.debug('**************'+EmailIdFromShoppingPage);
        return pref;
    }
    
    public PageReference logout()
    {
        EmailIdFromLoginPage=EmailIdFromShoppingPage=nameFromLoginPage=null;
        isPgBlock1=true;
        isPgBlock2=false;
        return null;
        
    }
    
    public PageReference openCart()
    {
        PageReference pref = page.cart;
        pref.getParameters().put('EmailIdFromShoppingPage',EmailIdFromShoppingPage);
        System.debug('**************'+EmailIdFromShoppingPage);
        return pref;
        
    }
    
    public void editProfile()
    {
        ispgBlockAccount=true;
        ispgBlockTransaction=isMainpgBlock=false;
        isPgBlockEdit=true;
        objContact=new Contact();
        List<Contact> lstContact=[SELECT id,FirstName,LastNAme,Phone,Email,Password__C,Address__c,Country__c
                                  FROM Contact 
                                  WHERE Email=:EmailIdFromLoginPage];
        for(Contact objContact2 : lstContact)
        {
            System.debug(objCOntact2);
            objContact.id=objContact2.id;
            objContact.FirstName=objContact2.firstName;
            objContact.lastNAme=objContact2.LastName;
            objCOntact.Phone=objContact2.Phone;
            objContact.Email=objContact2.Email;
            objContact.Password__c=objContact2.Password__c;
            objContact.Address__c=objContact2.Address__c;
            objContact.Country__c=objContact2.Country__c;
            System.debug(objCOntact);
        }
    }
    
    public void updateContact()
    {
        PageReference pref = Page.shopping ;
        update objContact;
        System.debug(objContact);
        nameFromLoginPage=objCOntact.firstName;
        isMainpgBlock=true;
        isPgBlockEdit=false;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM,'    Your Profile Is Updated'));
    }
    public void back()
    {
        isMainpgBlock=true;
        isPgBlockEdit=false;
        
    }
    
    public PageReference findProduct()
    {
        System.debug(searchProduct);
        PageReference pref=Page.shopping_Page2;
        pref.getParameters().put('searchProduct',searchProduct);
        pref.getParameters().put('EmailIdFromShoppingPage',EmailIdFromShoppingPage);
        pref.getParameters().put('nameOfContact',nameFromLoginPage);
        return pref;
    }
    
    public void myTransaction()
    {
        lstorderDetails=[SELECT Id, TransactionId__r.id,TransactionId__r.ContactId__r.email,TransactionId__r.CreatedDate, Total_Amount__c,Quantity__c, ProductId__r.Product_name__C 
                         FROM Order_Detail__c
                         WHERE TransactionId__r.ContactId__r.email=:EmailIdFromLoginPage];
        System.debug(LstOrderDetails);
        ispgBlockAccount=false;
        ispgBlockTransaction=true;
    }
}