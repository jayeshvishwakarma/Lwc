/**
 * @File Name          : ProcessCustomerVisibilityAccess_batch.cls
 * @Description        : This batch class is used to grant access to customer account records
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
global with sharing class ProcessCustomerVisibilityAccess_batch implements Database.Batchable<sObject>{

   global  String sQuery;
   
   global   boolean bIsRetryMode;

   global ProcessCustomerVisibilityAccess_batch(boolean bIsRetryMode){
       this.bIsRetryMode=bIsRetryMode;

    
   }
    global ProcessCustomerVisibilityAccess_batch(){
        this.bIsRetryMode=false;
    }
  
   global Database.QueryLocator start(Database.BatchableContext BC){
      // Find out pending records for customer visibility records  
      sQuery='SELECT Id, OwnerId, IsDeleted, Name,  Dealer_Public_Group_Name__c, SVOC_ID__c, Customer_Account__c, Start_Datetime__c, End_Datetime__c, ';
      sQuery+='End_Date_Reason__c, Transaction_Type__c, Transaction_Date__c, Security_Master_Unique_Key__c, Integration_Failure_Reason__c, ';
      sQuery+='Access_Processing_Status__c, MSIL_User_ID__c,Access_processing_Failure_Reason__c, Sync_Status__c, Sync_Datetime__c, Related_User__c, Do_Not_Sync__c ';
      sQuery+='FROM Customer_Visibility__c where Access_Processing_Status__c=\''+system.label.Access_Process_Status_Pending+'\' ';
      sQuery+=' or Access_Processing_Status__c=\''+system.label.Access_Process_Status_Failure+'\'';
      sQuery+=' order by Customer_Account__c';
      return Database.getQueryLocator(sQuery);
   }

   global void execute(Database.BatchableContext BC, List<sObject> lstRecordsToBeProcessed){
      try{ 
       Map<String,List<Customer_Visibility__c>>  mapResponse=new Map<String,List<Customer_Visibility__c>> ();
       mapResponse=CustomerRecordVisibilityUtility.grantAccessToCustomerAccount((List<Customer_Visibility__c>)lstRecordsToBeProcessed,
                                                                                true,false,false);
      }
     catch(Exception ex){
         ExceptionHandler.LogError('ProcessCustomerVisibilityAccess_batch', ex.getMessage(),null,null, null); 
     }    
    }

   global void finish(Database.BatchableContext BC){
       if(!bIsRetryMode){
           // rerun batch one more time to process failed records.
           Database.executeBatch(new ProcessCustomerVisibilityAccess_batch(true),Integer.valueOf(System.label.ProcessCustomerVisibilityAccess_batch_Chunk_Size));
       }
   }
}