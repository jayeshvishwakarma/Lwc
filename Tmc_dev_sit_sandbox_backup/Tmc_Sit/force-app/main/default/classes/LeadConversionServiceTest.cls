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

        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;


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
        
    }
    
    @IsTest
    private static void convertLeadTest1(){
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

        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;

        List<Lead> lstLead = new List<Lead>();
        List<Lead> lstLead1 = new List<Lead>();
        
        for(Integer i=0;i<2;i++)
        {
            Lead newLead = new Lead(
              Salutation = 'Mr.',
              FirstName = 'Test'+i,
              LastName = 'leadTest',
              MobilePhone = '9123456789',
              OwnerId = Userinfo.getUserId(), 
              AdEventName__c = camp.Id, 
              Status = 'New'
            );
            lstLead.add(newLead);
        }
        insert lstLead;
        for(Lead newLead : lstLead)
        {
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
        lstLead1.add(newLead);
        
        }
        update lstLead1;
        
        Decimal enquiryRecordsCount = [SELECT Count() FROM Opportunity];
        
    }
}