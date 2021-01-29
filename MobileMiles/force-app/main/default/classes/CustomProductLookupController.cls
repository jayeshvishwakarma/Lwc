/**
Name                :                CustomProductLookupController
Date                :                20 June ,2016
Author              :
Description         :                This class is used to provide list of products related to a particular price that will show in lookup popup                           
**/
public class CustomProductLookupController{
    public List<Product2> productList{get;set;}
    public String searchedVal{get;set;}
    private Set<Id> productIdSet;
    public Map<String,Decimal> productPriceMap{get;set;}

    public CustomProductLookupController(){
        //get id of price and provide list of related products
        String priceBookId = ApexPages.currentPage().getParameters().get('id');
        productList = new List<Product2>(); 
        productIdSet = new Set<Id>(); 
        productPriceMap = new Map<String,Decimal>();
        
        for(PricebookEntry price : [SELECT Id,UnitPrice,PriceBook2Id,PriceBook2.Name,Product2Id FROM PricebookEntry where isActive=true AND PriceBook2Id=:priceBookId ]){     
            productIdSet.add(price.Product2Id);
            productPriceMap.put(price.Product2Id,price.UnitPrice);  
        }               
        if(productIdSet.size() >0){  
            for(Product2 product : [select Id,Name,Description,ProductCode,Family from Product2 where Id IN:productIdSet and isActive=true Order By Name asc Limit 1000])
                productList.add(product);       
        }  
    } 
    //This method provides search result for particular product
    public void searchProduct(){
        String str = '%'+searchedVal+'%';
        productList = [select Name,Description,ProductCode,Family from Product2 where Id IN:productIdSet and Name like:str and isActive=true Order By Name asc Limit 1000];     
    } 
}