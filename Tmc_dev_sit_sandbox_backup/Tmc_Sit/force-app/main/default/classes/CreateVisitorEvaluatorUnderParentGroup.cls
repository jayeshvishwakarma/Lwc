/**
* @File Name          : CreateVisitorEvaluatorUnderParentGroup.cls
* @Description        : Class to create visitor evaluators under each dealership of a parent group
* @Author             : Rahul Sharma
**/
public without sharing class CreateVisitorEvaluatorUnderParentGroup implements Database.Batchable<sObject>, Database.Stateful{
   
   public static  Profile p= [Select Id From Profile where Name =: 'Dealer TV Evaluator'];
   set<string> conIds = new set<string>();
   Boolean isInsert; 
   public CreateVisitorEvaluatorUnderParentGroup(set<string> ids, Boolean Bool){
             conIds = ids;
             isInsert = Bool;
  }
   //Start Method
   public Database.QueryLocator start(Database.BatchableContext BC){
   return Database.getQueryLocator([Select IsEvaluator__c,Account.Parent_Group__c,Account.Region_Code__c,Id,AccountId,FirstName,Name,
                                    MiddleName,LastName,Title,Related_TV_Eval_User__c,OwnerId,MobilePhone,Eval_Emp_Code__c from Contact where id in: conIds
                                    and  IsPersonAccount = false]);
  
   }
   
    //Execute method 
    public void execute(Database.BatchableContext BC, List<Contact> scope){
    set<String> parentGroups = new set<String>();
    set<String> conName = new set<String>();
    set<Id> accIds = new set<Id>();
    List<Account> accLst = new List<Account>();
    List<Contact> conLstInsert = new List<Contact>();
    List<Contact> conLstUpdate = new List<Contact>();
    List<Contact> newContactList = new List<Contact>();
    //boolean isInsert=UtilityHelper.updateAndRetreiveEvalFlag(null,'Fetch','isInsert');
    //system.debug('isinsert check - ' + UtilityHelper.updateAndRetreiveEvalFlag(null,'Fetch','isInsert'));
    if(scope.size() > 0)
    {
        for(Contact con : scope)
        {
            if(parentGroups.contains(con.Account.Parent_Group__c) == false)
                parentGroups.add(con.Account.Parent_Group__c);  
           
           conName.add(con.Name);    
        }
    }
    
    if(parentGroups.size() > 0)
        accLst = [Select Id, Parent_Group__c,Region_Code__c from Account where IsPartner = true and IsPersonAccount = false and Parent_Group__c != null and Parent_Group__c in: parentGroups];
   
  if(isInsert==true){
    if(accLst.size() > 0)
    {
        for(Account acc : accLst)
        {
            for(Contact con : scope)
            {
                if(acc.Parent_Group__c == con.Account.Parent_Group__c && acc.Region_Code__c == con.Account.Region_Code__c && con.AccountId != acc.Id)
                {
                    Contact conCreate = new Contact( AccountId = acc.Id,FirstName = con.FirstName,LastName = con.LastName,MiddleName = con.MiddleName,
                    Title = con.Title,IsEvaluator__c = con.IsEvaluator__c,Related_TV_Eval_User__c = con.Related_TV_Eval_User__c,OwnerId = con.OwnerId,MobilePhone = con.MobilePhone,Is_eval_contact__c = true);
                    conLstInsert.add(conCreate);    
                }
            }
        }
    }
    
    if(conLstInsert.size() > 0)
        insert conLstInsert;
   }
        if(isInsert==false){  
        if(accLst.size() > 0 )           
        {        
            for(Account acc : accLst)
            {
            accIds.add(acc.id);
            }
        }
        if(accIds.size()>0){
            List<Contact> conlist = [Select id,IsEvaluator__c,Account.Parent_Group__c,Account.Region_Code__c,Name,Eval_Emp_Code__c from contact
                                    where AccountId in: accIds and  IsPersonAccount = false and Is_eval_contact__c = true and Related_TV_Eval_User__c != null
                                     limit 50000];
            if(conList.Size()>0)
            {
                for(Contact con1 : conList)
                {
                    if(conName.contains(con1.Name))
                    {
                        for(Contact con2 : scope)
                        {
                            if(con1.Account.Parent_Group__c == con2.Account.Parent_Group__c && con1.Account.Region_Code__c == con2.Account.Region_Code__c && con1.Name == con2.Name && con1.Eval_Emp_Code__c == con2.Eval_Emp_Code__c)
                            {
                            con1.IsEvaluator__c = con2.IsEvaluator__c;
                            conLstUpdate.add(con1);
                            }
                        }
                    }
                }
            }
        }
        if(conLstUpdate.size() > 0)
            update conLstUpdate;
        }
    }
    //Finish Method
    public void finish(Database.BatchableContext BC){
        //boolean  isInsert2=UtilityHelper.updateAndRetreiveEvalFlag(true,'update','isInsert');
    }
   
}