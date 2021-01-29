/**
    * @Autho:- Rahul Sharma
    * @Company-: MSIL
    * @Description-: Batch class to inactive TV evaluator users to
    **/
public without sharing class updateEvaluatorContact implements Database.Batchable<sObject>, Database.Stateful{
   
   Integer k=0;
   //Start Method
   public Database.QueryLocator start(Database.BatchableContext BC){
       //return User list
       Profile p = [Select Id From Profile where Name =: 'Dealer TV Evaluator'];
       Integer abc= Integer.valueOf(label.updateEvaluatorContact_mins);
       DateTime dt = DateTime.Now().addMinutes(-abc);
       return Database.getQueryLocator([Select id,IsActive,DMS_Active__c,ContactId,Contact.IsEvaluator__c from user where ProfileId =: p.Id and (CreatedDate >=: dt or LastModifiedDate >=: dt)]);
  
   }
   
   //Execute method 
   public void execute(Database.BatchableContext BC, List<User> scope){
         
        List<Contact> conLst = new List<Contact>();
        if(scope.size() > 0)
        {
            for(User u : scope)
            {
               system.debug('scope'+scope.size() + u);
               if(u.ContactId != null)
               {
                   system.debug(u.ContactId);
                    Contact c = new Contact(id=u.ContactId);
                    c.Related_TV_Eval_User__c = u.Id;
                    c.IsEvaluator__c = u.DMS_Active__c;
                    conLst.add(c);
               }
            }   
        }
        system.debug('conLst'+conLst.size() + conLst);
        if(conLst.size() > 0)
        {
       
          Database.SaveResult[] srList = database.update( conLst, false);
            system.debug('conLst 58'+srList.size());
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
       system.debug('success records'+k);
       CreateVisitorEvaluatorUnderParentGroup b = new  CreateVisitorEvaluatorUnderParentGroup(); 
        Integer size = integer.valueof(Label.DSE_Report_Batch_Size);
        string jobId= database.executebatch(b,size);
        system.debug('job id'+ jobId);
   }
   
}