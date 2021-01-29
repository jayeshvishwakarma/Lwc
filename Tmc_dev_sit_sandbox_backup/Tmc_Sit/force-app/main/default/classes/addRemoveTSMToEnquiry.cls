/**
* @File Name          : addRemoveTSMToEnquiry.cls
* @Description        : Class to add TSM to already created enquiry and remove previous TSM from enq as he is no more TSM now for data visibility and security purpose
* @Author             : Rahul Sharma
**/
public without sharing class addRemoveTSMToEnquiry implements Database.Batchable<sObject>, Database.Stateful{
   
    //Start Method
    Integer k=0;
    string query;
    set<string> accIds = new set<string>();
    //Public static set<string> conIds;
    public addRemoveTSMToEnquiry(String Q)
    {
        query = Q;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        DateTime Dt = system.now();
        DateTime Dt1 = Dt.addHours(-24);
        system.debug('query '+query);
        return Database.getQueryLocator(query);

    }

    //Execute method 
    public void execute(Database.BatchableContext BC, List<Account> scope){
        
        map<String,String> primaryTSM = new map<String,String>();
        set<String> previousPrimaryTSM = new set<String>();
        
        for(Account acc : scope)
        {
            if(acc.Territory_Sales_Manager__c != null && !primaryTSM.containsKey(acc.Territory_Sales_Manager__c))
                primaryTSM.put(acc.Id,acc.Territory_Sales_Manager__c);
            if(acc.Previous_Primary_TSM__c != null && !previousPrimaryTSM.contains(acc.Previous_Primary_TSM__c))
                previousPrimaryTSM.add(acc.Previous_Primary_TSM__c);
            if(acc.Is_Previous_TSM_Removed_From_Opp_Team__c == true && !accIds.contains(acc.Id))
                accIds.add(acc.Id);
            system.debug('line no 39 '+primaryTSM.size());
            system.debug('line no 40 '+previousPrimaryTSM.size());
            system.debug('line no 41 '+accIds.size());
            if(!previousPrimaryTSM.isEmpty())
            {
                List<OpportunityTeamMember> optyTeamMembr = [Select Id,OpportunityId,UserId from OpportunityTeamMember where UserId in: previousPrimaryTSM Limit 10000];
                system.debug('line no 45 '+optyTeamMembr.size());
                if(!optyTeamMembr.isEmpty())
                {   try
                    {
                    delete optyTeamMembr;
                    }
                    catch(Exception ex) {
                    ExceptionHandler.stackTrace trace = new ExceptionHandler.stackTrace();
                    trace.componentName = 'Delete TSM in Opp team';
                    trace.userId = UserInfo.getUserId();
                    ExceptionHandler.LogError('addRemoveTSMToEnquiry', ex.getMessage(), 'OpportunityTeamMember', '', trace);
                    }       
                }
                
            }
            if(primaryTSM.size() > 0)
            {
                List<OpportunityTeamMember> optyTeamMembr2 = [Select Id,OpportunityId from OpportunityTeamMember where Opportunity.Dealership__c in : primaryTSM.keyset() and user.User_Role_Text__c = 'TSM' and user.profile.name =: 'Maruti Sales User' Limit 50000];
                system.debug('line no 52 '+optyTeamMembr2.size());
                List<Opportunity> lstOpp = new List<Opportunity>();
                if(optyTeamMembr2.size() > 0)
                {
                    set<String> oppId = new set<String>();
                    for(OpportunityTeamMember otm : optyTeamMembr2)
                    {
                        if(!oppId.contains(otm.OpportunityId))
                            oppId.add(otm.OpportunityId);
                    }
                    system.debug('line no 61 '+oppId.size());    
                   lstOpp = [Select id,Dealership__c from Opportunity where Dealership__c in: primaryTSM.keyset() and id not in: oppId Limit 10000];
                }
                else
                {
                    lstOpp = [Select id,Dealership__c from Opportunity where Dealership__c in: primaryTSM.keyset() Limit 10000];
                }
                system.debug('line no 63 '+lstOpp.size());    
                List<OpportunityTeamMember> optyTeamMembr1 = new List<OpportunityTeamMember>();
                if(lstOpp.size() > 0)
                {
                    for(Opportunity opp : lstOpp)
                    {
                        OpportunityTeamMember oppteamMember = new OpportunityTeamMember();
                        oppteamMember.OpportunityId = opp.Id;
                        oppteamMember.UserId = primaryTSM.get(opp.Dealership__c);
                        optyTeamMembr1.add(oppteamMember);
                    }
                    system.debug('line no 74 '+lstOpp.size());        
                    if(!optyTeamMembr1.isEmpty())
                    {    
                        try
                        {
                        insert optyTeamMembr1;
                        }
                        catch(Exception ex) {
                        ExceptionHandler.stackTrace trace = new ExceptionHandler.stackTrace();
                        trace.componentName = 'Insert TSM in Opp team';
                        trace.userId = UserInfo.getUserId();
                        ExceptionHandler.LogError('addRemoveTSMToEnquiry', ex.getMessage(), 'OpportunityTeamMember', '', trace);
                        }                    
                    }
                }
            }
        }

    }
    //Finish Method
    public void finish(Database.BatchableContext BC){
        system.debug('line no 85 '+accIds.size());        
        if(!accIds.isEmpty())
        {   
            List<Account> accLst = new List<Account>();
            for(String str : accIds)
            {
                Account acc = new Account(id=str,Is_Previous_TSM_Removed_From_Opp_Team__c = false);
                accLst.add(acc);
            }
            system.debug('line no 94 '+accLst.size());        
            if(!accLst.isEmpty())
            {
                TriggerHandler.bypass('AccountTriggerHandler');
                update accLst;
                TriggerHandler.clearBypass('AccountTriggerHandler');
            }
        }
    }
   
}