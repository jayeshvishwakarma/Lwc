/**
Name                :                TestCustomProductLookupController
Date                :                20 June ,2016
Author              :
Description         :                This class provides code coverage and control flow of class 'CustomProductLookupController'
**/
@isTest
public class TestCustomProductLookupController{
    
    @isTest
    private static void testFlow(){
         Product2 prod1 = new Product2(Name = 'Laptop X200', Family = 'Hardware',isActive=true);
         insert prod1;
         Product2 prod2 = new Product2(Name = 'Laptop X200', Family = 'Hardware',isActive=false);
         insert prod2;
         PricebookEntry customPrice1 = new PricebookEntry(Pricebook2Id =  Test.getStandardPricebookId(), Product2Id = prod1.Id,UnitPrice = 12000, IsActive = true);
         insert customPrice1;
         ApexPages.currentPage().getParameters().put('id',Test.getStandardPricebookId());
         CustomProductLookupController classObj = new CustomProductLookupController();
         
         system.assertEquals(classObj.productList.size(),1);
         system.assert(classObj.productList[0].Id !=prod2.Id );
         
         classObj.searchedVal = 'lap';
         classObj.searchProduct();
         
         system.assertEquals(classObj.productList.size(),1);
         
         classObj.searchedVal = 'test';
         classObj.searchProduct();
         
         system.assertEquals(classObj.productList.size(),0);
    }
}