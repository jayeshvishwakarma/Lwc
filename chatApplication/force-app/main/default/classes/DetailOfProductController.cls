public class DetailOfProductController {
    
    public String detailOfProductId{get;set;}
    
    public String imageId{get;set;}
    
    public String EmailIdFromShoppingPage2{get;set;}
    
    public String nameOfContact{get;set;}
    
    public String ProductId {get;set;}
    
    public List<Product__c> lstProduct{get;set;}
    
    public boolean ispgBlock1{get;set;}
    
    public boolean ispgBlock2{get;set;}
    
    public DetailOfProductController()
    {
        ispgBlock1=true;
        ispgBlock2=false;
        imageId=ApexPages.currentPage().getParameters().get('imageId');
        detailOfProductId=ApexPages.currentPage().getParameters().get('detailOfProductId');
        EmailIdFromShoppingPage2=ApexPages.currentPage().getParameters().get('EmailIdFromShoppingPage2');
        nameOfContact=ApexPages.currentPage().getParameters().get('nameOfContact');
        if(nameOfContact=='' || EmailIdFromShoppingPage2=='')
        {
            nameOfContact=null;
            EmailIdFromShoppingPage2=null;
        }
        if(nameOfContact!=null)
        {
            ispgBlock1=false;
            isPgblock2=true;
        }
        
        lstProduct=[SELECT Id,Description__c, Company__c, Category__c, Price__c, Product_Name__c, Stock_Quantity__c,
                    (SELECT id,ContentDocument.LatestPublishedVersionId From ContentDocumentLinks WHERE ContentDocument.LatestPublishedVersionId=:imageId) 
                    FROM Product__c 
                    WHERE id=:detailOfProductId];
        System.debug(lstProduct.size());
        System.Debug(imageId);
    }
    
    public PageReference login()
    {
        return page.loginAccount;
    }
    
    public void addToCart()
    {
        System.debug('ID::::::'+ProductId);
        if(EmailIdFromShoppingPage2!=null)
        {
            Shopping_cart__c objSc= new Shopping_cart__c();
            System.debug('Button Chala');
            System.debug('ID :' +ProductId);
            System.debug('EmailID: ' +EmailIdFromShoppingPage2);
            for(Contact objContact2 : [SELECT Id FROM Contact WHERE Email = :EmailIdFromShoppingPage2])
            {
                System.debug(objContact2);
                objSc.ProductId__c=ProductId;
                objsc.ContactId__c=objContact2.id;
            }
            insert objSc;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'----Your Product is In Cart Now-----'));
            System.debug('Product id Or Contact Id::::'+objSc);
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'---You Have To Login First------'));
        }
    }
    
   public PageReference openCart()
    {
        PageReference pref = page.cart;
        pref.getParameters().put('EmailIdFromShoppingPage',EmailIdFromShoppingPage2);
        System.debug('**************'+EmailIdFromShoppingPage2);
        return pref;
        
    }
    
    public PageReference logout()
    {
        emailIdFromShoppingPage2=nameOfContact=null;
        isPgBlock1=true;
        isPgBlock2=false;
        return page.shopping;
    }
    
}