/*------------------------------------------------------------------------------------
Author:        Nitin Ghai
Description:   Lost Case Feedback Controller - This class take Input as Case Record Id and Task JSON
               This class is used to update when it is Lost Case Scenario(MI Insurance)

History
Date            Author                Comments
--------------------------------------------------------------------------------------
08-04-2020      Nitin Ghai            Initial Release
20-06-2020      Nitin Ghai            Updated updateCasetoLost Method
------------------------------------------------------------------------------------*/
public class LostCaseFeedback {
    @AuraEnabled
    public static String updateCasetoLost(String recordId,String taskJSON,String apiErrorMessage){
        String response;
        Savepoint sp = Database.setSavepoint();
        try{
            Task tskData = String.isNotBlank(taskJSON) ? (Task) JSON.deserialize(taskJSON, Task.class) : NULL;
            if(tskData!=NULL){
                tskData.Call_End__c=System.now();
                update tskData;
                
                if(String.isNotBlank(recordId)){
                    Case lostCase = new Case();
                    lostCase.Id=recordId;
                    lostCase.Status='Lost';
                    lostCase.Reason_for_Lost__c=String.isNotblank(tskData.Disposition__c) ? tskData.Disposition__c : '';
                    lostCase.Last_Follow_Up_Remarks__c=String.isNotblank(tskData.Disposition__c) ? tskData.Disposition__c : '';
                    lostCase.DPS_Sync_Error__c =  String.isnotBlank(apiErrorMessage) ? apiErrorMessage : '';
                    update lostCase;
                }
                
                response='SUCCESS';
            }
        }catch(exception e){
           response='ERROR';Database.rollback(sp);ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace();ehst.componentName='indtLostCaseAnalysis - LWC';ehst.userId=UserInfo.getUserId();ExceptionHandler.LogError('LostCaseFeedback - Class','taskJSON---->'+taskJSON +'/n'+e.getMessage()+' - Line Number: '+e.getLineNumber(), 'updateCasetoLost : Method','', ehst); 
        }
        return response;
    }
}