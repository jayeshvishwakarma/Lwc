/**
* @File Name          : CallStartController.cls
* @Description        : This class is used for fetch and update Task
* @Author             : Sunit Kumar chand
* @Group              : 
* @Last Modified By   : Sunit Kumar Chand 
* @Last Modified On   : 15/09/2020, 9:30:23 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.1A    07/05/2020, 11:37:23 AM   Sunit Kumar Chand       Initial Version
* 1.1A    13/05/2020, 11:37:23 AM   Sunit Kumar Chand       Added customer visiablity part in fetchData method
* 1.1A    04/06/2020, 04:45:23 PM   Sunit Kumar Chand       Added dialling record id logic
* 1.1A    05/06/2020, 04:30:00 PM   Sunit Kumar Chand       Added Customer Mobile Name check
* 1.1A    09/06/2020, 09:30:00 PM   Nitin Ghai              Added diallingRecId param in updateTaskStatus method
* 1.1A    20/06/2020, 01:30:00 PM   Sunit Kumar Chand       Set null to Call end field
* 1.1A    15/09/2020, 01:30:00 PM   Sunit Kumar Chand       Added Rate customer field on fetchData task query
**/
public without sharing class CallStartController {
    
    
    /**
    Author: Sunit kumar chand
    Company: Techmatrix
    Description: It will update task object
    Inputs: Task Id
    Returns: 
    History:
    ================
    1.1A     11 May 2020      Sunit     Initial Version
    1.1A     04 Jun 2020      Sunit     Added dialling record id logic
    1.1A     09 Jun 2020      Nitin     Added diallingRecId param in updateTaskStatus method
    1.1A     20 Jun 2020      Sunit     Set null to Call end field
    */
    @AuraEnabled
    public static void updateTaskStatus(string recordId,String diallingRecId){
        Task ts=new Task();
        ts.Id=recordId;
        ts.Status='In Progress';
        ts.Call_Start__c=system.now();
        ts.Call_End__c=null;
        ts.Dialling_Record_ID__c=String.isBlank(diallingRecId) ? recordId : diallingRecId;
        update ts;
        
    }
    
    /**
Author: Sunit kumar chand
Company: Techmatrix
Description: It will fetch perticular task object
Inputs: Task Id
Returns: Task object
History:
=================
1.1A     08 May 2020      Sunit     Initial Version
1.1A     13 May 2020      Sunit     Added customer visiablity part
*/
    @AuraEnabled
    public static BasicReturn fetchData(string recordId) {
        List<Task> taskList= new List<Task>();
        List<Task> taskCheckList=new List<Task>();
        BasicReturn br=new BasicReturn();
        if(recordId.substring(0,3)=='500')
            {
        		taskCheckList=[Select Id from Task where OwnerId=:UserInfo.getUserId() and type='T' 
                               and Status='In Progress' and Case__c!=:recordId];
            }
        else{
            	taskCheckList=[Select Id from Task where OwnerId=:UserInfo.getUserId() and type='T' 
                               and Status='In Progress' and id!=:recordId];
        }
        
        if(taskCheckList.size()==0){
            if(recordId.substring(0,3)=='500')
            {
                
                taskList=[select id,ActivityDate,Asset__r.Name,Asset__c,Contact_ID__c,Customer_Mobile__c,
                          Status,CampaignId__r.Status,Case__c,Veh_Service_Due_Dt__c,Do_Not_Call_Numbers__c,
                          Mobile_Number_2__c,Mobile_Number_3__c,Feedback_Outcome__c,Service_Type__c,
                          CampaignId__r.Name,RecordType.DeveloperName,Call_back_Phone_Number__c,
                          Call_back_Date_Time__c,Disposition__c,Dialling_Record_ID__c,case__r.Dealer_Name__c, 
                          CampaignId__c,Vehicle_Registration_Number__c,Contact_ID__r.SVOC_ID__c,Enquiry__c,
                          Mobile_Number_4__c,Asset__r.Registration_Number__c,case__r.Dealer_Name__r.Channel__c,
                          Rate_Customer__c,case__r.Dealer_Name__r.Name,Contact_ID__r.name 
                          from Task where Case__c=:recordId and type='T' and (status='Open' 
                          OR status='In Progress') order by CreatedDate limit 1];
            }
            else{
                taskList=[select id,ActivityDate,Asset__r.Name,Asset__c,Contact_ID__c,Customer_Mobile__c,
                          Status,CampaignId__r.Status,Case__c,Veh_Service_Due_Dt__c,Do_Not_Call_Numbers__c,
                          Mobile_Number_2__c,Mobile_Number_3__c,Feedback_Outcome__c,Service_Type__c,
                          CampaignId__r.Name,RecordType.DeveloperName,Call_back_Phone_Number__c,
                          Call_back_Date_Time__c,Disposition__c,Dialling_Record_ID__c,case__r.Dealer_Name__c,
                          CampaignId__c,Vehicle_Registration_Number__c,Contact_ID__r.SVOC_ID__c,Enquiry__c,
                          Mobile_Number_4__c,Asset__r.Registration_Number__c,case__r.Dealer_Name__r.Channel__c,
                          Rate_Customer__c,case__r.Dealer_Name__r.Name,Contact_ID__r.name 
                          from Task where Id=:recordId and type='T' and (status='Open' OR status='In Progress')];
            }
        }
        else{
            br.status='Error';br.code=0;br.message=System.label.Task_In_Progress_Error_Message;return  br;
        }
        
        
        if(taskList.size()>0 &&  String.isNotBlank(taskList[0].Customer_Mobile__c)){
            br.status='Success';
            br.dataList=taskList;
            br.code=200;
            br.message='Success';
            Account userAccount = [SELECT Id, Account.Parent_Group__c FROM User WHERE Id =: UserInfo.getUserId()].Account;
            insert new Customer_Visibility__c(
                Dealer_Public_Group_Name__c = userAccount != null ? userAccount.Parent_Group__c : null,
                Related_User__c = UserInfo.getUserId(),
                Transaction_Type__c = 'OCC',
                Transaction_Date__c = System.now(),
                Start_Datetime__c = System.now(),
                End_Datetime__c =System.now()+3,
                Customer_Account__c = taskList[0].Contact_ID__c,
                SVOC_ID__c = taskList[0].Contact_ID__r.SVOC_ID__c,
                Access_Processing_Status__c = System.label.Access_Process_Status_Success,
                Sync_Status__c = System.label.Access_Sync_Status
            );
        }else if(taskList.size()>0 &&  String.isBlank(taskList[0].Customer_Mobile__c)){
            br.status='Error';br.code=0;br.message=System.label.Task_Mobile_Missing;
        }
        else{
            br.status='Error';br.code=0;br.message=System.label.Task_stage_error_message;
        }
        
        return  br;
        
    }
    
}