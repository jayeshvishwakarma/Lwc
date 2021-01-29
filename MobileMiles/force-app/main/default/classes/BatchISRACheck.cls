global class BatchISRACheck implements Database.Batchable<sobject>,Database.AllowsCallouts {   
   global Set<String> accIds;
   global BatchISRACheck(Set<String> accIds){
       this.accIds = accIds;
   }
   // Start Method
   global Database.Querylocator start (Database.BatchableContext BC) {
      String query = 'select id from Account where id IN : accIds';
      system.debug('@@@@ query ' + query);
      return Database.getQueryLocator(query);     
   }
   
   // Execute method
   global void execute (Database.BatchableContext BC, List<Account> scope) {
       Set<String> accountIds = new Set<String>(new Map<String,SObject>(scope).keySet());
       if(accountIds.size()>0){
            ISRACheck.getAccountDetails(accountIds);            
        }
   }
   
   // Finish Method
   global void finish(Database.BatchableContext BC) {
      
   }
}