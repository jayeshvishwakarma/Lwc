/**
 * @File Name          : PurgeCustomerVisibilityRecords_batch.cls
 * @Description        : This batch class is used to delete invalid/old customer visibility records
 * @Author             : Subhojit Chakraborty
 * @Group              : 
 * @Last Modified By   : Subhojit Chakraborty
 * @Last Modified On   : 12/03/2019, 03:37:23 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    12/03/2019, 03:37:23 PM   Subhojit Chakraborty     Initial Version
 * 
 */ 
global with sharing class PurgeCustomerVisibilityRecords_batch implements Database.Batchable<sObject>{

   global  String sQuery;
   
  

   global PurgeCustomerVisibilityRecords_batch(){
       
    }
  
   global Database.QueryLocator start(Database.BatchableContext BC){
      Datetime dtSysNow=System.now();
      Datetime dtSys7DaysOld=dtSysNow.addDays(Integer.valueOf(System.label.CustomerVisibilityRecord_Delete_Threshold));
      //Find out records which are invalided or revoked more than 7 days ago
      sQuery='SELECT Id, OwnerId, IsDeleted, Name,  Dealer_Public_Group_Name__c, SVOC_ID__c, Customer_Account__c, Start_Datetime__c, End_Datetime__c, ';
      sQuery+='End_Date_Reason__c, Transaction_Type__c, Transaction_Date__c, Security_Master_Unique_Key__c, Integration_Failure_Reason__c, ';
      sQuery+='Access_Processing_Status__c, Access_processing_Failure_Reason__c, Sync_Status__c, Sync_Datetime__c, Related_User__c, Do_Not_Sync__c ';
      sQuery+='FROM Customer_Visibility__c where (Access_Processing_Status__c=\''+System.label.Access_Process_Status_Revoked+'\'';
      sQuery+=' or Access_Processing_Status__c=\''+system.label.Access_Process_Status_Invalidated+'\') ';
      if(!Test.isRunningTest())
      sQuery+=' and End_Datetime__c<=:dtSys7DaysOld';
      return Database.getQueryLocator(sQuery);
   }

   global void execute(Database.BatchableContext BC, List<sObject> lstRecordsToBeProcessed){
      try{ 
        delete lstRecordsToBeProcessed;
        Database.emptyRecycleBin(lstRecordsToBeProcessed); // Empty recycle bin for deleted records
      }
     catch(Exception ex){
         ExceptionHandler.LogError('PurgeCustomerVisibilityRecords_batch', ex.getMessage(),null,null, null); 
     }    
    }

   global void finish(Database.BatchableContext BC){
      
   }
}