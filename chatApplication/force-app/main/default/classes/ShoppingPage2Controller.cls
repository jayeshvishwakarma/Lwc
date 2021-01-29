public class ShoppingPage2Controller {
    public List<Product__C> lstProducts{get;set;}
    public List<ContentVersion> lstContentVersions{get;set;}
    public Product__c objProduct{get;set;}
    
    public String ProductId {get;set;}
    public String detailOfProduct{get;set;}
    public String EmailIdFromShoppingPage{get;set;}
    public String imageId{get;set;}
    public String nameOfContact{get;set;}
    public String searchProduct{get;set;}
    public String ViewAllInteger{get;set;}
    
    public boolean ispgBlock1{get;set;}
    public boolean pgBlockPay{get;set;}
    public boolean ispgBlock2{get;set;}
    public boolean isPgBlockBuyNow{get;set;}
    public boolean isPageBlockList{get;set;}
    public boolean ispgBlockFilter{get;set;}
   
    public INTEGER searchByOption{get;set;}
    public INTEGER cardNumber{get;set;}
    public INTEGER cvv{get;set;}
    
    public Map<Integer,String> mapOfOptions{get;set;}
    
    private static String strQuery='SELECT id,Name,price__c,product_name__c,company__c,Stock_quantity__c,description__c,Category__c,(SELECT id,ContentDocument.LatestPublishedVersionId From ContentDocumentLinks) From Product__c';
    
    public ShoppingPage2Controller()
    {
        isPageBlockList=ispgBlockFilter=true;
        
        ViewAllInteger=ApexPages.currentPage().getParameters().get('ViewAllInteger');
        
        searchProduct=ApexPages.currentPage().getParameters().get('searchProduct');
        
        EmailIdFromShoppingPage=ApexPages.currentPage().getParameters().get('EmailIdFromShoppingPage');
        
        nameOfContact=ApexPages.currentPage().getParameters().get('nameOfContact');
        
        Product__c objProduct=new Product__c();
        
        ispgBlock1=true;
        
        findProduct();
        
        if(ViewAllInteger== '1')
        {
            String var= 'Grocery';
            lstProducts=DataBase.query(strQuery+' WHERE Category__c = :var');
        }
        if(ViewAllInteger== '2')
        {
            String var= 'Grooming';
            lstProducts=DataBase.query(strQuery+' WHERE Category__c = :var');
        }
        if(ViewAllInteger== '3')
        {
            String var= 'Electronics';
            lstProducts=DataBase.query(strQuery+' WHERE Category__c = :var');
        }
        if(lstProducts.size()==0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'No Records For the Particular Category'));
        }
        
        createMapOfCategories();
        
        if(EmailIdFromShoppingPage!=null)
        {
            isPgBlock2=true;
            isPgBlock1=false;
        }
        if(EmailIdFromShoppingPage=='')
        {
            isPgBlock2=false;
            isPgBlock1=true;   
            EmailIdFromShoppingPage=null;
            nameOfContact=null;
        }
    }
    
    public void createMapOfCategories()
    {
        mapOfOptions = new Map<Integer,String>();
        mapOfOptions.put(0, 'All Products');
        mapOfOptions.put(1, 'Electronics');
        mapOfOptions.put(2, 'Grocery');
        mapOfOptions.put(3, 'Cloths');
        mapOfOptions.put(4, 'Sports & Fitness');
        
    }
    public PageReference login()
    {
        return page.loginAccount;
    }
    
    public void SearchProducts()
    {
        if(searchByOption==0)
        {
            lstProducts=Database.query(strQuery);
            return;
        }
        System.debug('+++++'+searchByOption);
        System.debug('+++++'+mapOfOptions.get(searchByOption));
        String Str=mapOfOptions.get(searchByOption);
        lstProducts=Database.query(strQuery+' Where Category__c =:Str');
        if(lstProducts.size()==0) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'----No Records Of Particular Category-----'));
    }
    
    public PageReference logout()
    {
        EmailIdFromShoppingPage=nameOfContact=null;
        isPgBlock1=true;
        isPgBlock2=false;
        return page.shopping;
        
    }
    
    public void addToCart()
    {
        System.debug('Email:::'+EmailIdFromShoppingPage);
        if(EmailIdFromShoppingPage!=null)
        {
            Shopping_cart__c objSc= new Shopping_cart__c();
            System.debug('Button Chala');
            System.debug('ID :' +ProductId);
            for(Contact objContact2 : [SELECT Id FROM Contact WHERE Email=:EmailIdFromShoppingPage])
            {
                objSc.ProductId__c=ProductId;
                objsc.ContactId__c=objContact2.id;
            }
            insert objSc;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'----Your Product is Added In Your Cart-----'));
            System.debug('Product id Or Contact Id::::'+objSc);
        }
        else
        {
            System.debug('Login NI Hai');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'---You Have To Login First------'));
        }
    }
    
    public PageReference detail()
    {
        System.debug('===================='+EmailIdFromShoppingPage);
        PageReference pref = page.detail_of_product;
        pref.getParameters().put('detailofProductId',detailOfProduct);
        pref.getParameters().put('EmailIdFromShoppingPage2',EmailIdFromShoppingPage);
        pref.getParameters().put('nameOfContact',nameOfContact);
        pref.getParameters().put('imageId',imageId);
        System.debug('Detail of Product '+detailOfProduct);
        return pref;
    }
    
    public PageReference openCart()
    {
        PageReference pref = page.cart;
        pref.getParameters().put('EmailIdFromShoppingPage',EmailIdFromShoppingPage);
        System.debug('**************'+EmailIdFromShoppingPage);
        return pref;
        
    }
    
    public void buyNow()
    {
        ispgBlockFilter=isPageBlockList=false;
        isPgBlockBuyNow=true;
        lstProducts=Database.query(strQuery+' WHERE id=:productId');
        System.debug(lstProducts);
    }
    
    public void proceedToPay()
    {
        System.debug(EmailIdFromShoppingPage);
        if(EmailIdFromShoppingPage==null || EmailIdFromShoppingPage=='')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'You Have To Login To Buy a Product'));
        }
        else
        {
            pgBlockPay=true;
            isPgBlockBuyNow=false;
        }
    }
    public PageReference pay()
    {
        System.debug(cardNumber);
        System.debug(cvv);
        if(cardNumber!=0 && cvv!=0)
        {   
            List<Contact> lstContacts=[SELECT id,Firstname,LastName,email 
                                       FROM Contact 
                                       WHERE Email=:EmailIdFromShoppingPage];
            PageReference pref= page.orderDetails;
            Transaction__c objTransaction=new Transaction__c();
            for(Contact objCOntact : lstContacts)
            {
                objTransaction.ContactId__c=objContact.id;
            }
            insert objTransaction;
            
            Order_Detail__c objOrderDetail=new Order_Detail__C();
            lstProducts=Database.query(strQuery+' WHERE id=:productId');
            for(Product__c objProduct : lstProducts)
            {
                objOrderDetail.ProductId__c=objProduct.id;
                objOrderDetail.Total_Amount__c=objProduct.Price__c;
            }
            objOrderDetail.Quantity__c= 1;
            objOrderDetail.TransactionId__c=objTransaction.id;
            insert objOrderDetail;
            System.debug(objtransaction);
            System.debug(objOrderDetail);
            pref.getParameters().put('EmailIdFromShoppingPage',emailIdFromShoppingPage);
            pref.getParameters().put('TransactionId',objtransaction.id);
            return pref;
            
        }else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Invalid CardNumber'));
        }
        return null;
    }
    
    public void findProduct()
    {
        System.debug(searchProduct);
        String searchCriteria='%' + searchProduct + '%';
        lstProducts=Database.query(strQuery+' WHERE Category__c Like :searchCriteria');
        if(lstProducts.size()>0) return;
        lstProducts=Database.query(strQuery+' WHERE Product_name__c Like :searchCriteria');
        System.debug(lstProducts);
    }
    
    public PageReference backToHome()
    {
        PageReference pref=page.shopping;
        if(emailIdFromShoppingPage!=null)
        {
            Contact objContact=[SELECT id,FirstName 
                                FROM Contact 
                                WHERE email=:emailIdFromShoppingPage];
            String nameFromLoginPage=objCOntact.firstName;
            pref.getParameters().put('EmailIdFromLoginPage',emailIdFromShoppingPage);
            pref.getParameters().put('nameFromLoginPage',nameFromLoginPage);
            return pref ;
        }
        else
        {
            return pref;
        }
    }
    
}