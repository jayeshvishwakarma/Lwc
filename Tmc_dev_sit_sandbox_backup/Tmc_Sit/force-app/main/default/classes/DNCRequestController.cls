/**
* @File Name          : DNCRequestController.cls
* @Description        : This class is used for DNC Request
* @Author             : Sunit KumarChand
* @Group              : 
* @Last Modified By   : Nitin Ghai
* @Last Modified On   : 10/06/2020, 01:53:23 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    22/05/2020, 11:37:23 AM     Sunit Kumar Chand       Initial Version
* 1.1    13/06/2020, 11:37:23 AM     Nitin Ghai              Added RecordType Condition
* 1.2    15/06/2020, 11:37:23 AM     Nitin Ghai              Appended Dealer Name and User Account
* 1.3    10/06/2020, 01:53:23 PM     Nitin Ghai              Addded user query and if If Manager is submitting DNC request
                                                             it will get approved directly
**/
public with sharing class DNCRequestController {
    /**
Author: Sunit kumar chand
Company: Techmatrix
Description: It will create case of DNC request
Inputs: dncData string & parentRecordId(Account or Case Id)
Returns: Object(BasicReturn)
History:
================
1.0     22 May 2020      Sunit     Initial Version
*/
    
    @AuraEnabled
    public static BasicReturn createDNCRequest(String dncData,String parentRecordId)
    {
        BasicReturn br=new BasicReturn();
        br.code=200;
        try{
            String caseRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Do_No_Call_Requests').getRecordTypeId();
            Id userAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('User_Account').getRecordTypeId();
            Case cs=String.isNotBlank(dncData) ? (Case)JSON.deserialize(dncData, Case.class) : NULL;
            List<String> profileName=(Label.DNC_Manager).split(';');
            if(cs!=NULL){
                List<Account> userAcc = [select id,User__c,User__r.Contact.AccountID
                                         From Account WHERE RecordTypeId = :userAccountRecordTypeId AND User__c<>NULL AND User__c =:UserInfo.getUserId()];
                User loggedinUser = [Select Id,Profile.Name from User where Id=:UserInfo.getUserId()];
                if(String.isnotblank(parentRecordId) && parentRecordId.startsWith('500')){
                    List<Case> csRec = [Select Customer__c from Case where ID=:parentRecordId];
                    cs.Customer__c= csRec.size()>0 ? csRec[0].Customer__c : NULL;
                }else if(String.isnotblank(parentRecordId) && parentRecordId.startsWith('001')){
                    cs.Customer__c=parentRecordId;
                }
                cs.Status=profileName.size()>0 && loggedinUser!=NULL && profileName.contains(loggedinUser.Profile.Name) ? 'Approved' : 'New';
                cs.RecordTypeId= caseRecordId;
                if(userAcc.size()>0){
                    cs.Dealer_Name__c=String.isNotBlank(userAcc[0].User__r.Contact.AccountID) ? userAcc[0].User__r.Contact.AccountID : NULL;
                    cs.AccountId=String.isNotBlank(userAcc[0].id) ? userAcc[0].id : NULL; // Populating User Account of DNC Case Owner
                }
                insert cs; 
            }
            
        }
        catch(Exception e){
            br.code=001;br.message=e.getMessage();ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace();ehst.componentName='dncRequest - LWC';ehst.userId=UserInfo.getUserId();ExceptionHandler.LogError('DNCRequestController - Class','dncData---->'+dncData+' \n'+e.getMessage()+' - Line Number: '+e.getLineNumber(), 'createDNCRequest : Method','', ehst);
        }
        
        return br;
    }
}