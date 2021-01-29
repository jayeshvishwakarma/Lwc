/**
 * @File Name          : ReportTaskTriggerHandler.cls
 * @Description        : Trigger handler class for Task
 * @Author             : Satish Kumar
 * @Group              :
 * @Last Modified By   : 
 * @Last Modified On   : 
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 
**/
public with sharing class ReportTaskTriggerHandler extends TriggerHandler{
    private list<ReportTask__c> newReportTaskList; //Used to store the list of new Cases
    private Map<Id, ReportTask__c> oldReportTaskMap; //Used to store the list of old Cases

    public ReportTaskTriggerHandler(){
        this.newReportTaskList = ( List<ReportTask__c> )Trigger.new;
        this.oldReportTaskMap = ( Map<Id, ReportTask__c> )Trigger.oldMap;
        //caseOwnerIdSet = new set<Id>();
        //caseOwnerToUserAccountMap = new Map<Id, Account>();
    }
    public override void beforeInsert(){}
    public override void beforeUpdate(){}
    public override void afterInsert(){
         //add work order share records to make appointment visible to dealer group       
        if(newReportTaskList.size()>0){
            createShareRecords(newReportTaskList);
        }
    }
    public override void afterUpdate(){
       // if(newReportTaskList.size()>0){
            createShareRecords(newReportTaskList);
        //}

    }

    public static void createShareRecords(List<ReportTask__c> newReportTaskList){
        Set<Id> taskIdSet = new Set<Id>();
        List<ReportTask__share> reportTaskShareList = new List<ReportTask__share>();
          Map<Id,String> reportTaskmap = new Map<Id,String>();
        for(ReportTask__c reportTask : newReportTaskList){
            if(reportTask.WhatId__c!=null){
                taskIdSet.add(reportTask.id);
                 system.debug('45 workshop'+taskIdSet);
            }
            
        }
//Commented because field has been deleted
        for(ReportTask__c reportTask : [SELECT id, Workshop__c,WhatId__c/*,WhatId__r.Dealer_Name__r.Service_TSM__c*/ FROM ReportTask__c WHERE Id  IN : taskIdSet]){           
                        if(reportTask.WhatId__c!=null){
                           //reportTaskmap.put(reportTask.id,reportTask.WhatId__r.Dealer_Name__r.Service_TSM__c);//storing service TSM
                           //system.debug('52 workshop'+reportTaskmap);
                        }
                    }

         if(reportTaskmap.size()>0){
                    system.debug('58 workshopMap'+reportTaskmap);
                    for(Id  reportTaskId:reportTaskmap.keySet()){
                             ReportTask__share reportTaskshare = new ReportTask__share();
                             reportTaskshare.accesslevel=label.WorkOrder_Share_Access;
                             reportTaskshare.parentId=reportTaskId;
                             reportTaskshare.UserOrGroupId=reportTaskmap.get(reportTaskId);
                             reportTaskShareList.add(reportTaskshare);
                        system.debug('66 workOrdShare'+reportTaskShareList);
                       }
                    } 

              system.debug('69 workOrdShare'+reportTaskShareList);
                  if(reportTaskShareList.size()>0){
                       //modified to handle errors due to bad data during load
                        Database.insert(reportTaskShareList,false);
                        system.debug('73 workOrdShare'+reportTaskShareList);
                       }
    }

}