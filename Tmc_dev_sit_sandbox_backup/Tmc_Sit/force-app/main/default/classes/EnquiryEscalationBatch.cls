/**
    * @Author:- Anuj Kumar
    * @Company-: Techmatrix Consulting
    * @Description-: Batch class to Mark Enquiry as Escalated
    * =============================================================
    * Version   Date             Author         Modification
    * =============================================================
    * 1.0       17 JULY 2020     Anuj Kumar     Intial Version
    **/
public without sharing class EnquiryEscalationBatch implements Database.Batchable<sObject> {
    
    //Start Method
    public Database.QueryLocator start(Database.BatchableContext BC){
        String partsOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsUtility.PARTS).getRecordTypeId();
        
        return Database.getQueryLocator([SELECT Id, Current_Follow_Up_Time__c, Level_Escalated__c, Escalated__c, 
            Time_for_Next_Escalation__c, Level_1_Notification__c, Level_2_Notification__c, Level_3_Notification__c, 
            Level_4_Notification__c, Level_5_Notification__c, Level_6_Notification__c, Level_7_Notification__c FROM Opportunity 
            Where recordTypeId =: partsOppRecordTypeId AND StageName =: ConstantsUtility.STAGE_NEW AND 
            (Time_for_Next_Escalation__c <=: System.Now())]);
            
    }
   
    //Execute method 
    public void execute(Database.BatchableContext BC, List<Opportunity> scope){
        
        system.debug('== scope '+scope != Null ? scope.size() : 0);
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        
        for(Opportunity opp: scope){
            opp.escalated__c = True;
            opportunityList.add(opp);
        }
        
        if(!opportunityList.isEmpty()){
            try{
                Update opportunityList;
            }catch(Exception ex){
                ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace(); ehst.componentName = 'EnquiryEscalationBatch'; ehst.userId=UserInfo.getUserId(); ExceptionHandler.LogError('EnquiryEscalationBatch', ex.getMessage(), 'EnquiryEscalationBatch', '', ehst);
            }
            
        }
        
    }
    
    //Finish Method
    public void finish(Database.BatchableContext BC){
    
    }
}