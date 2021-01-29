public class ExampleController {
    public List<Product__C> lstProducts{get;set;}
    public Product__c objProduct{get;set;}
    public String ProductId {get;set;}
    
    public ExampleController()
    {
        Product__c objProduct = new Product__c();
        lstProducts=[SELECT id,Name,price__c,product_name__c,company__c,description__c From Product__c LIMIT 10];  
    }
    
    public void addToCart()
    {
        System.debug('Button Chala');
        System.debug('ID :' +ProductId);       
        
    }
}