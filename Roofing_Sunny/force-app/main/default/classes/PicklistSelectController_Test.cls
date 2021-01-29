@isTest
public class PicklistSelectController_Test {
	 @isTest static void testgetFieldLabel(){ 
         PicklistSelectController.getFieldLabel('Account', 'ShippingCountry');
     }
     @isTest static void testgetPicklistOptions(){ 
         PicklistSelectController.getPicklistOptions('Account', 'Customer_Group__c', '', false);
     }
   	 @isTest static void testgetPicklistOptionsCountry(){ 
         PicklistSelectController.getPicklistOptions('Account', 'Country__c', 'UNITED STATES', true);
     }
     @isTest static void testgetPicklistOptionsCountryLowercase(){ 
         PicklistSelectController.getPicklistOptions('Account', 'Country__c', 'UNITED STATES', false);
     }
}