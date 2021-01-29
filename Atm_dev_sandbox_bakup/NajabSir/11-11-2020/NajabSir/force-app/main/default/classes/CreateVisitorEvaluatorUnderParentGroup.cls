/**
* @File Name          : CreateVisitorEvaluatorUnderParentGroup.cls
* @Description        : Class to create visitor evaluators under each dealership of a parent group
* @Author             : Rahul Sharma
**/
public without sharing class CreateVisitorEvaluatorUnderParentGroup implements Database.Batchable<sObject>, Database.Stateful{
   
   //Start Method
   public Database.QueryLocator start(Database.BatchableContext BC){
   Integer abc= Integer.valueOf(label.updateEvaluatorContact_mins);
   DateTime dt = DateTime.Now().addMinutes(-abc);
   return Database.getQueryLocator([Select IsEvaluator__c,Account.Parent_Group__c,Account.Region_Code__c,Id,AccountId,FirstName,MiddleName,LastName,Title,Related_TV_Eval_User__c,OwnerId,MobilePhone from Contact where IsPersonAccount = false and LastModifiedDate >=: dt]);
  
   }
   
   //Execute method 
   public void execute(Database.BatchableContext BC, List<Contact> scope){
    
    set<String> parentGroups = new set<String>();
    List<Account> accLst = new List<Account>();
    List<Contact> conLstInsert = new List<Contact>();
    
    if(scope.size() > 0)
    {
        for(Contact con : scope)
        {
            if(parentGroups.contains(con.Account.Parent_Group__c) == false)
                parentGroups.add(con.Account.Parent_Group__c);  
        }
    }
    
    if(parentGroups.size() > 0)
        accLst = [Select Id, Parent_Group__c,Region_Code__c from Account where IsPartner = true and IsPersonAccount = false and Parent_Group__c != null and Parent_Group__c in: parentGroups];
    
    if(accLst.size() > 0)
    {
        for(Account acc : accLst)
        {
            for(Contact con : scope)
            {
                if(acc.Parent_Group__c == con.Account.Parent_Group__c && acc.Region_Code__c == con.Account.Region_Code__c && con.AccountId != acc.Id)
                {
                    Contact conCreate = new Contact();
                    conCreate.AccountId = acc.Id;
                    conCreate.FirstName = con.FirstName;
                    conCreate.LastName = con.LastName;
                    conCreate.MiddleName = con.MiddleName;
                    conCreate.Title = con.Title;
                    conCreate.IsEvaluator__c = con.IsEvaluator__c;
                    conCreate.Related_TV_Eval_User__c = con.Related_TV_Eval_User__c;
                    conCreate.OwnerId = con.OwnerId;
                    conCreate.MobilePhone = con.MobilePhone;
                    conLstInsert.add(conCreate);    
                }
            }
        }
    }
    
    if(conLstInsert.size() > 0)
        insert conLstInsert;
}

     //Finish Method
   public void finish(Database.BatchableContext BC){
      }
   
}