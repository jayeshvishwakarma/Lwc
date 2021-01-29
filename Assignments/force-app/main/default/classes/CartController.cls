public class CartController {
    public List<Shopping_cart__c> lstCarts{get;set;}
    public List<Transaction__c> lstTransactions{get;set;}
    Public List<Id> lstIds{get;set;}
    public List<Product__c> lstProducts{get;set;}
    public String emailIdFromShoppingPage{get;set;}
    public Boolean isPgBlock{get;set;}
    public Boolean isPgBlock2{get;set;}
    public String RemoveObj{get;set;}
    public DECIMAL TotalAmount{get;set;}
    public INTEGER countOfProducts{get;set;}
    public INTEGER Quantity{get;set;}
    public String productIdForQuantity{get;set;}
    public CartController()
    {
        Quantity=1;
        TotalAmount=0;
        ispgBlock=true;
        
        emailIdFromShoppingPage=ApexPages.currentPage().getParameters().get('EmailIdFromShoppingPage');
        System.debug('Cart Me ::'+emailIdFromShoppingPage);
        
        lstCarts=[SELECT id,quantity__c,ProductId__r.id,ProductId__r.price__c,ProductId__r.stock_quantity__c
                  From Shopping_cart__c
                  Where contactId__r.email=:emailIdFromShoppingPage];
        System.debug('Size Of Cart ::'+lstCarts.size());
        
        List<Id> lstIds=new List<id>();
        for(Shopping_cart__c sc:lstCarts)
        {
            lstIds.add(sc.ProductId__r.id);
        }
        System.debug('lstIds::'+lstIds);
        
        lstProducts=[SELECT id,Product_name__c,Price__c,company__c,
                     (SELECT id,ContentDocument.LatestPublishedVersionId From ContentDocumentLinks)
                     FROM Product__c 
                     WHERE id IN :lstIds];
        System.debug('Size Of Cart In:::'+lstProducts);
        
        
        countOfProducts=lstCarts.size();
        if(lstCarts.size()==0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, '---------OOPS--------Your Cart Is Empty!!!!!------Shop Now'));
            ispgBlock=false;
        }
        for(Shopping_cart__c objSc : lstCarts)
        {
            TotalAmount+=(objSc.ProductId__r.Price__c * objSc.Quantity__c)+((objSc.ProductId__r.Price__c * objsc.Quantity__c)*4)/100;
        }
    }
    
    public void increaseQuantity()
    {
        quantity++;   
        System.debug(productIdForQuantity);
        TotalAmount=0;
        for(Shopping_cart__c objsc : lstCarts )
        {
            if(productIdForQuantity==objsc.productId__r.id)
            {
                if(objsc.Quantity__c < objSc.ProductId__r.stock_quantity__c)
                {
                objsc.Quantity__c++;
                update objSc;
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'You can order only Limited Quantity'));
                }
               
            }
            TotalAmount+=(objSc.ProductId__r.Price__c * objSc.Quantity__c)+((objSc.ProductId__r.Price__c * objsc.Quantity__c)*4)/100;
        }
    }
    
    public void decreaseQuantity()
    {
        quantity--;
         TotalAmount=0;
        for(Shopping_cart__c objsc : lstCarts )
        {
            if(productIdForQuantity==objsc.productId__r.id)
            {
                if(objSc.Quantity__c<2)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Min Value Should be 1'));
                }
                else
                {
                objsc.Quantity__c--;
                update objSc;
                }
            }
            TotalAmount+=(objSc.ProductId__r.Price__c * objSc.Quantity__c)+((objSc.ProductId__r.Price__c * objsc.Quantity__c)*4)/100;
        }
    }
    
    public PageReference placeOrder()
    {
        PageReference pref=page.placeOrder;
        pref.getParameters().put('EmailIdFromShoppingPage',emailIdFromShoppingPage);
        return pref;
    }
    
    
    public void Remove()
    {
        lstcarts=[SELECT id,ProductId__r.id,quantity__c,ProductId__r.Price__c
                  From Shopping_cart__c
                  Where ProductId__r.id =:RemoveObj];
        
        Database.delete(lstCarts);
    }
    
    public PageReference backToHome()
    {
        Contact objContact=[SELECT id,FirstName 
                            FROM Contact 
                            WHERE email=:emailIdFromShoppingPage];
        PageReference pref=page.shopping;
        String nameFromLoginPage=objCOntact.firstName;
        pref.getParameters().put('EmailIdFromLoginPage',emailIdFromShoppingPage);
        pref.getParameters().put('nameFromLoginPage',nameFromLoginPage);
        
        return pref;
    }
    
}