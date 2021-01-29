/**
    * @Autho:- Rahul Sharma
    * @Company-: MSIL
    * @Description-: Batch class to inactive TV evaluator users to
    **/
public without sharing class updateEvaluatorContact implements Database.Batchable<sObject>, Database.Stateful{
   
   Integer k=0;
   set<string> uIds = new set<string>();
   set<string> conIds = new set<string>();
   Boolean isInsert; 
   public updateEvaluatorContact(set<string> ids, Boolean Bool){
             uIds = ids;
             isInsert = Bool;
  }
   //Start Method
   public Database.QueryLocator start(Database.BatchableContext BC){
       //return User list
       return Database.getQueryLocator([Select id,IsActive,DMS_Active__c,ContactId,Contact.IsEvaluator__c from user 
                                        where id in: uIds]);
  
   }
   
   //Execute method 
   public void execute(Database.BatchableContext BC, List<User> scope){
         
        List<Contact> conLst = new List<Contact>();
        if(scope.size() > 0)
        {
            for(User u : scope)
            {
               if((u.ContactId != null)
                    &&(u.profile.name.equalsIgnoreCase('Dealer TV Evaluator'))){  //Run Logic only if the its a TV evaluator user.
               {
                    Contact c = new Contact(id=u.ContactId);
                    c.Related_TV_Eval_User__c = u.Id;
                    c.IsEvaluator__c = u.DMS_Active__c;
                    c.Is_eval_contact__c = true;
                    conLst.add(c);
                    conIds.add(u.ContactId);
               }
            }   
        }
        if(conLst.size() > 0)
        {
       
          Database.SaveResult[] srList = database.update( conLst, false);
            for (Database.SaveResult sr : srList) 
            {
                 if (sr.isSuccess()) {
                     k++;
                }
            }
        }
     }
   }
   //Finish Method
   public void finish(Database.BatchableContext BC){
        system.debug('50 conIds '+conIds.size());
        CreateVisitorEvaluatorUnderParentGroup b = new  CreateVisitorEvaluatorUnderParentGroup(conIds,isInsert); 
        Integer size = integer.valueof(Label.MSIL_NoOfContactProcessInBatch);
        string jobId= database.executebatch(b,size);
   }
   
}