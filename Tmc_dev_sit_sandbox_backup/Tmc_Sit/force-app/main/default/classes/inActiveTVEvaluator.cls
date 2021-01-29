/**
    * @Autho:- Rahul Sharma
    * @Company-: MSIL
    * @Description-: Batch class to inactive TV evaluator users to
    **/
public without sharing class inActiveTVEvaluator implements Database.Batchable<sObject>, Database.Stateful{
   
   Integer k=0;
   set<string> uIds1 = new set<string>();
   Boolean isInsert;
   public inActiveTVEvaluator(set<string> ids, Boolean Bool){
             uIds1= ids;
             isInsert = Bool;
   }
   //Start Method
   public Database.QueryLocator start(Database.BatchableContext BC){
       //return User list
       return Database.getQueryLocator([Select id,IsActive,ContactId from user where id in: uIds1]);
  
   }
   
   //Execute method 
   public void execute(Database.BatchableContext BC, List<User> scope){
         
        List<User> usrLst1 = new List<User>();
        if(scope.size() > 0)
        {
            for(User u : scope)
            {
                u.IsActive = false;
                usrLst1.add(u);
            }  
        }
         if(usrLst1.size() > 0)
        {
           TriggerHandler.bypass('UserTriggerHandler');
           update usrLst1;
           TriggerHandler.clearBypass('UserTriggerHandler');                
        }
        
   }

   //Finish Method
   public void finish(Database.BatchableContext BC){
        system.debug('50 uIds '+uIds1.size());
        boolean isInactiveBatch=UtilityHelper.updateAndRetreiveEvalFlag(false,'update','inactiveBatch');
        updateEvaluatorContact b = new  updateEvaluatorContact(uIds1,isInsert); 
        Integer size = integer.valueof(Label.DSE_Report_Batch_Size);
        string jobId= database.executebatch(b,size);
   }
   
 }