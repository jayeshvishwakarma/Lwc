/**
 * @File Name          : ProductTriggerHandlerTest.cls
 * @Description        : 
 * @Author             : Rajesh Ramachandran
 * @Group              : 
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 12/28/2019, 10:06:54 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    12/28/2019   Rajesh Ramachandran     Initial Version
**/
@isTest
public class ProductTriggerHandlerTest {

    @isTest
    public static void testAccessoryPrice(){
        system.debug('@@## Test ');
        List<Product2> listOfAccessoriesProduct = TestDataFactory.createProducts('Accessories',200);
        system.debug('@@## listOfAccessoriesProduct '+listOfAccessoriesProduct.size());
        if(listOfAccessoriesProduct != null && listOfAccessoriesProduct.size() > 0){
            Insert listOfAccessoriesProduct;
        }
        system.debug('@@## listOfAccessoriesProduct '+listOfAccessoriesProduct.size());
        List<Product2> listOfPartsProduct = TestDataFactory.createProducts('Parts',2);
        if(listOfPartsProduct != null && listOfPartsProduct.size() > 0){
            Insert listOfPartsProduct;
        }
        system.debug('@@## listOfPartsProduct '+listOfPartsProduct.size());
        List<Product2> listOfOfferProduct = TestDataFactory.createProducts('Offer',2);
        if(listOfOfferProduct != null && listOfOfferProduct.size() > 0){
            Insert listOfOfferProduct;
            listOfOfferProduct[0].Discount_Price__c = 100;
            Update listOfOfferProduct[0];
        }
    }

}