public class PlaceOrderController {
    public List<Shopping_cart__C> lstCarts{get;set;}
    public List<Contact> lstContacts {get;set;}
    public String emailIdFromShoppingPage{get;set;}
    public Decimal totalAmount{get;set;}
    public boolean pgBlock2{get;set;}
    public boolean pgBlock3{get;set;}
    public INTEGER cardNumber{get;set;}
    public INTEGER cvv{get;set;}
    public PlaceOrderController()	
    {
        pgBlock2=true;
        TotalAmount=0;
        emailIdFromShoppingPage=ApexPages.currentPage().getParameters().get('EmailIdFromShoppingPage');
        System.debug('+++++++++++++++++++++'+emailIdFromShoppingPage);
         lstCarts=[SELECT id,ProductId__r.id,ProductId__r.price__c,quantity__c
                  From Shopping_cart__c
                  Where contactId__r.email=:emailIdFromShoppingPage];
        System.debug('+++++++++++++++++++'+lstCarts.size());
         for(Shopping_cart__c objSc : lstCarts)
        {
            TotalAmount+=(objSc.ProductId__r.Price__c * objSc.Quantity__c)+((objSc.ProductId__r.Price__c * objsc.Quantity__c)*4)/100;
        }
        
        lstContacts = [SELECT id,name,FirstName,LastName,Email,Phone,Country__c,Address__c FROM Contact WHERE Email=:emailIdFromShoppingPage];
        System.debug(lstContacts);
    }
    
    public void proceedToPay()
    {
        pgBlock2=false;
        pgBlock3=true;
    }
    public PageReference pay()
    {
        System.debug(cardNumber);
        System.debug(cvv);
        if(cardNumber!=0 && cvv!=0)
        {   
            PageReference pref= page.orderDetails;
            Transaction__c objTransaction=new Transaction__c();
            for(Contact objCOntact : lstContacts)
            {
                objTransaction.ContactId__c=objContact.id;
            }
            insert objTransaction;
            
            Order_Detail__c objOrderDetail=new Order_Detail__C();
            for(Shopping_cart__c objSc : lstCarts)
            {
                objOrderDetail.ProductId__c=objSc.ProductId__r.id;
                objOrderDetail.Quantity__c=objSc.Quantity__c;
            }
            objOrderDetail.TransactionId__c=objTransaction.id;
            objOrderDetail.Total_Amount__c=TotalAmount;
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

}