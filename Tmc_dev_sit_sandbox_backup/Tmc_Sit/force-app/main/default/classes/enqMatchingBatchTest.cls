/**
* @File Name          : enqMatchingBatchTest.cls
* @Description        : Test class for enqMatchingBatch.
* @Author             : Rahul Sharma
* @Group              : MSIL
**/
@isTest
public class enqMatchingBatchTest{
    @testSetup
    static void createRecord(){
        
        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
        
        list<product2> productList = TestDataFactory.createProducts('Variants', 5);
        productList[0].Model__c = 'BA';
        productList[0].Enquiry__c = 'Yes';
        Insert productList;
        
        list<Account> acclist = TestDataFactory.createBusinessAccount(1,'Dealer');
        insert acclist;
        acclist[0].Parent_Group__c = 'PREM';
        acclist[0].Dealer_Map_Code__c = '45342';
        acclist[0].Dealer_Location__c =  'DEL';
        update acclist[0];
        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        
        list<Opportunity> opplist = TestDataFactory.createTestOpportunity(1,'Vehicle Sales');
        for(Opportunity opp : opplist){
            opp.stageName = 'New';
            opp.Customer__c = personAccountList[0].Id;
            opp.Dealership__c = acclist[0].Id;
            oppList[0].Line_Of_Business__c = 'Nexa';
            oppList[0].Model_Code__c = 'BA';
            opp.Variant__c = productList[0].Id;
            opp.DMS_Enquiry_Name__c= 'ENQ51634';
         }
        insert opplist;
        
        Enq_Matching__c match = new Enq_Matching__c();
        match.Parent_Group__c ='PREM';
        match.Dealer_Map_Code__c ='45342';
        match.Dealer_Location__c ='DEL';
        match.Enquiry_Number__c ='ENQ51634';
        match.DMS_SF_Id__c =opplist[0].Id;
        
        insert match;
    }

    @istest
    static  void batchTest1(){
        Test.startTest();
        String query = 'Select Id,DMS_External_id__c From Enq_Matching__c Where Picked_By_Batch__c = false and DMS_External_id__c != null and SF_Enquiry_Id__c = null';
        enqMatchingBatch b = new  enqMatchingBatch(query); 
        Integer size = integer.valueof(Label.DSE_Report_Batch_Size);
        string jobId= database.executebatch(b,size);
        Test.stopTest();        
    }
     @istest
    static  void batchTest2(){
        Test.startTest();
        Enq_Matching__c match = [select id,DMS_SF_Id__c  from Enq_Matching__c limit 1];
        match.DMS_SF_Id__c   = '';
        update match;
        String query = 'Select Id,Name,External_id__c,DMS_Enquiry_Name__c From Opportunity Where variant__c !=null';
        enqMatchingBatch1 b = new  enqMatchingBatch1(query); 
        Integer size = integer.valueof(Label.DSE_Report_Batch_Size);
        string jobId= database.executebatch(b,size);
        Test.stopTest();        
    }
    
}