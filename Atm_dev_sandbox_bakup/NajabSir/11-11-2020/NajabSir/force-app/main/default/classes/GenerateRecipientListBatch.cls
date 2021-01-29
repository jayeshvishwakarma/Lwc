public class GenerateRecipientListBatch implements Database.Batchable<sObject>{
    List<Recipient_List__c> resListToInsert = new list<Recipient_List__c>();
    
    public GenerateRecipientListBatch(List<Recipient_List__c> rlList){
        this.resListToInsert = rlList;
    }
    
    public Iterable<sObject> start(Database.BatchableContext BC){
      return resListToInsert;
   }
    
    public void execute(Database.BatchableContext BC, list<Recipient_List__c> scope){
        Database.SaveResult[] srList = Database.insert(scope, false);
        // Iterate through each returned result
        Integer count = 1;
        for (Database.SaveResult sr : srList) {
            
            if (!sr.isSuccess()) {
                
                // Operation failed, so get all errors
                for (Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Fields that affected this error: ' + err.getFields());
                }
                
            }
            count++;
        }
    }
    
    public void finish(Database.BatchableContext BC){}
 

}