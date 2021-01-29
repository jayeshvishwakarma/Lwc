@isTest
public  class GetAccountRecordCustomerProfile_test {
  @testSetup
    static void CreateMethod(){
       Integer iCount=20;
       
       
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