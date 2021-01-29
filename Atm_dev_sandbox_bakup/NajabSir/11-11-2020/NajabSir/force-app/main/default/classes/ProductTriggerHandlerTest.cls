/**
 * @File Name          : ProductTriggerHandlerTest.cls
 * @Description        : 
 * @Author             : Rajesh Ramachandran
 * @Group              : 
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 12/28/2019, 10:06:54 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    12/28/2019   Rajesh Ramachandran     Initial Version
**/
@isTest
public class ProductTriggerHandlerTest {

    @isTest
    public static void testAccessoryPrice(){
        TestDataFactory.createProducts('Accessories',200);
    }

}