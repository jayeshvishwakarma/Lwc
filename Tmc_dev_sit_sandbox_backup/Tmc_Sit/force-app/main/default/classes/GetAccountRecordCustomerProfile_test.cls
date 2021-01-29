@isTest
public  class GetAccountRecordCustomerProfile_test {
  @testSetup
    static void CreateMethod(){
       Integer iCount=20;
        GlobalSwitchOn__c gs = new GlobalSwitchOn__c();
        gs.Name = 'Email';
        gs.Create_Dummy_Account__c = true;
        
        Insert gs;
       
       // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
       
        List<Account> lstCustomer=TestDataFactory.createPersonAccount(iCount);
        insert lstCustomer;
       List<Opportunity> lstOPP=TestDataFactory.createTestOpportunity(iCount,'Vehicle Sales');
        for(Opportunity oppVar:lstOPP){
         oppVar.First_Name__c='test';
         oppVar.Last_Name__c='test';
         oppVar.StageName='New';
        }
       insert lstOpp;
   }
   @isTest
   static void runFlow(){
       Map<Id,Opportunity> mapOpp=new Map<Id,Opportunity>([select Id from Opportunity]);
       List<String> lstIdrec=new List<String>();
       for(Opportunity oppVar:mapOpp.values())
          lstIdrec.add(oppVar.Id);
       GetAccountRecordCustomerProfile_flow.getAccount(lstIdrec);
      
   }
   
}