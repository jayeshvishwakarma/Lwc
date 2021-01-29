/**
* @File Name          : deleteEvalContactCreatedWrongly.cls
* @Description        : Class to delete visitor evaluators under each dealership of a parent group created during error in code
* @Author             : Rahul Sharma
**/
public without sharing class deleteEvalContactCreatedWrongly implements Database.Batchable<sObject>{
   
   //Start Method
   Integer k=0;
   string query;
   set<string> conIds = new set<string>();
   //Public static set<string> conIds;
   public deleteEvalContactCreatedWrongly(String Q)
   {
       query = Q;
       system.debug('query '+query +Q);
       List<User> lstUser = [Select Id,ContactId,Contact.Name from user where ContactId != null and Profile.Name = 'Dealer TV Evaluator'];
      for(User u : lstUser )
      {
          conIds.add(u.ContactId);
      }     
   }
   public Database.QueryLocator start(Database.BatchableContext BC){
  system.debug('query '+query);
  return Database.getQueryLocator(query);
  
   }
   
    //Execute method 
    public void execute(Database.BatchableContext BC, List<Contact> scope){
      List<Contact> lstcon = new List<Contact>();
      List<Custom_Error__c> errors = new List<Custom_Error__c>();
        if(scope.size() > 0)
        {
            for(Contact con: scope)
            {
              if(!conIds.contains(con.Id))
              {
                    lstcon.add(con);
              }
            }
        }
      
      if(lstcon.size() > 0)
      {
        Database.DeleteResult[] srList = database.delete(lstcon, false);
        for (Database.DeleteResult sr : srList) 
        {
          if (sr.isSuccess()) {
            k++;
          }
          else
          {  
            for (Database.Error e : sr.getErrors())
            {  
            system.debug('error in contact deletion'+ e.getMessage());
            Custom_Error__c customObj = new Custom_Error__c(Error_source__c='deleteEvalContactCreatedWrongly',
                                                        Error_Message__c=e.getMessage(),
                                                        Object_Type__c='contact'
                                                        );
            errors.add(customObj);
            }
          }
          
          
        }
        if(!errors.IsEmpty())
            insert errors;
      }
    }
    //Finish Method
    public void finish(Database.BatchableContext BC){
       system.debug('no of deleted contacts'+k);
    }
   
}