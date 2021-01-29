/**
    * @Autho:- Rahul Sharma
    * @Company-: MSIL
    * @Description-: Batch class to inactive TV evaluator users to
    **/
public without sharing class inActiveTVEvaluator implements Database.Batchable<sObject>, Database.Stateful{
   
   Integer k=0;
   //Start Method
   public Database.QueryLocator start(Database.BatchableContext BC){
       //return User list
       Profile p = [Select Id From Profile where Name =: 'Dealer TV Evaluator'];
       return Database.getQueryLocator([Select id,IsActive,ContactId from user where ProfileId =: p.Id AND (IsActive = true OR DMS_Active__c = false)]);
  
   }
   
   //Execute method 
   public void execute(Database.BatchableContext BC, List<User> scope){
         
        List<User> usrLst1 = new List<User>();
        if(scope.size() > 0)
        {
            for(User u : scope)
            {
               if(u.IsActive == true)
               {
                u.IsActive = false;
                usrLst1.add(u);
                }
            }  
        }
        if(usrLst1.size() > 0)
        {
            Database.SaveResult[] srList = database.update( usrLst1, false);
            for (Database.SaveResult sr : srList) 
            {
                 if (sr.isSuccess()) {
                     k++;
                }
            }
        }
        
   }
   //Finish Method
   public void finish(Database.BatchableContext BC){
        system.debug('success record is : ' + k);
        updateEvaluatorContact b = new  updateEvaluatorContact(); 
        Integer size = integer.valueof(Label.DSE_Report_Batch_Size);
        string jobId= database.executebatch(b,size);
        system.debug('job id'+ jobId);
   }
   
 }