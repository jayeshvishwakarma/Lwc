/**
* @File Name          : LeadConversionService.cls
* @Description        : Lead Conversion Service Class Test
* @Author             : Mahith Madwesh
* @Group              : 
* @Last Modified By   : 
* @Last Modified On   : 
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0         19/01/2020               Mahith Madwesh         Initial Version
*/
@isTest
private class LeadConversionServiceTest {

    @IsTest
    private static void convertLeadTest(){
        //create a campaign
        Campaign camp = TestDataFactory.createCampaign(1).get(0);
        insert camp;
        
        //Create Product
        Product2 prod = TestDataFactory.createProducts('Variants', 1).get(0);
        prod.Model__c = 'BA';
        prod.Enquiry__c = 'Yes';
        Insert prod;

        //Create Color Variant Master
        Color_Variant_Master__c color = TestdataFactory.createColorVarientRealetdToProduct(1, prod.Id).get(0);
        insert color;

        Lead newLead = new Lead(
          Salutation = 'Mr.',
          FirstName = 'Test',
          LastName = 'leadTest',
          MobilePhone = '9123456789',
          OwnerId = Userinfo.getUserId(), 
          AdEventName__c = camp.Id, 
          Status = 'New'
        );
        insert newLead;

        newLead.Email = 'test@email.com';
        newLead.Line_Of_Business__c = 'Nexa';
        newLead.Dealership_Channel__c = 'Nexa';
        newLead.Buyer_Type__c = '03';
        newLead.Enq_Model__c = 'BA';
        newLead.Variant__c = prod.Id;
        newLead.Color__c = color.Id;
        newLead.Gender__c = 'M';
        newLead.Customer_Type__c = 'I';
        newLead.LeadSource = 'EVE';
        newLead.Test_Drive_Given__c = 'N';
        newLead.Status = 'Converted_won';
        update newLead;

        Decimal enquiryRecordsCount = [SELECT Count() FROM Opportunity];
        System.assertEquals(1, enquiryRecordsCount);
    }
}