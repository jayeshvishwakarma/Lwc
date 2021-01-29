/**
 * @File Name          : RevokeCustomerVisibilityAccess_batch.cls
 * @Description        : This batch class is used to revoke access to customer account
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
global with sharing class RevokeCustomerVisibilityAccess_batch implements Database.Batchable<sObject>{

   global  String sQuery;
   
   global   boolean bIsRetryMode;
   global  Datetime dtSysNow=Datetime.newInstance(System.today().year(),System.today().month(),System.today().day(),
                                                23,59,59);
   global RevokeCustomerVisibilityAccess_batch(boolean bIsRetryMode){
       this.bIsRetryMode=bIsRetryMode;

    
   }
    global RevokeCustomerVisibilityAccess_batch(){
        this.bIsRetryMode=false;
    }
  
   global Database.QueryLocator start(Database.BatchableContext BC){
     
      // Check for old records with end date is in the past
      sQuery='SELECT Id, OwnerId, IsDeleted, Name,  Dealer_Public_Group_Name__c, SVOC_ID__c, Customer_Account__c, Start_Datetime__c, End_Datetime__c, ';
      sQuery+='End_Date_Reason__c, Transaction_Type__c, Transaction_Date__c, Security_Master_Unique_Key__c, Integration_Failure_Reason__c, ';
      sQuery+='Access_Processing_Status__c, Access_processing_Failure_Reason__c, Sync_Status__c, Sync_Datetime__c, Related_User__c, Do_Not_Sync__c ';
      sQuery+='FROM Customer_Visibility__c where Access_Processing_Status__c=\''+system.label.Access_Process_Status_Success+'\''; 
      sQuery+='and End_Datetime__c<=:dtSysNow order by Customer_Account__c';
      return Database.getQueryLocator(sQuery);
   }

   global void execute(Database.BatchableContext BC, List<sObject> lstRecordsToBeProcessed){
      try{ 
       Map<String,List<Customer_Visibility__c>>  mapResponse=new Map<String,List<Customer_Visibility__c>> ();
       mapResponse=CustomerRecordVisibilityUtility.revokeAccessToCustomerAccount((List<Customer_Visibility__c>)lstRecordsToBeProcessed,
                                                                                true,false,dtSysNow);
      }
     catch(Exception ex){
         ExceptionHandler.LogError('RevokeCustomerVisibilityAccess_batch', ex.getMessage(),null,null, null); 
     }    
    }

   global void finish(Database.BatchableContext BC){
       //Default Run the batch one more time to process failed records.
       if(!bIsRetryMode){
           Database.executeBatch(new RevokeCustomerVisibilityAccess_batch(true),Integer.valueOf(System.label.RevokeCustomerVisibilityAccess_batch_Chunk_Size));
       }
   }
}