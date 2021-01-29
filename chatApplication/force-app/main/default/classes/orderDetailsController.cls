public class orderDetailsController {
    public List<order_detail__c> lstOrderDetails{get;set;}
    public List<Contact> lstContacts{get;set;}
    public List<Shopping_Cart__C> lstCarts{get;set;}
    public String nameOfContact{get;set;}
    public String EmailIdFromShoppingPage{get;set;}
    public String TransactionId{get;set;}
    
    public orderDetailsController()
    {
        EmailIdFromShoppingPage=ApexPages.currentPage().getParameters().get('EmailIdFromShoppingPage');
        TransactionId=ApexPages.currentPage().getParameters().get('TransactionId');
        lstCarts=[SELECT id,ProductId__r.id,ProductId__r.Product_name__c,Quantity__c
                  From Shopping_cart__c
                  Where contactId__r.email=:emailIdFromShoppingPage];
        
        lstOrderDetails=[SELECT id,TransactionId__r.id,Total_Amount__c,Quantity__c,ProductId__r.Product_name__c
                         FROM Order_Detail__c WHERE TransactionId__r.id=:TransactionId];
        
        lstContacts=[SELECT id,name,phone,Email,Address__c,Country__c 
                     FROM Contact 
                     WHERE Email=:EmailIdFromShoppingPage];
        System.debug('+=++++++========');        
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Your Order Has Been Placed'));
    }
    public PageReference home()
    {
         lstContacts=[SELECT id,name,firstName,phone,Email 
                     FROM Contact 
                     WHERE Email=:EmailIdFromShoppingPage];
        Database.delete(lstCarts);
        for(Contact objContact : lstContacts)
        {
            nameOfContact=objContact.firstName;
        }
        PageReference pref=page.shopping;
        pref.getParameters().put('EmailIdFromLoginPage',emailIdFromShoppingPage);
        pref.getParameters().put('nameFromLoginPage',nameOfContact);
        return pref;
    }
}