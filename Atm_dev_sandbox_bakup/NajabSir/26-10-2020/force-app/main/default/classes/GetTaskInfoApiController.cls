/*
Author : Anas Yar Khan
Description : This class is used to return Boolean based on a particular field on task
*/

global class GetTaskInfoApiController {
    
    webservice static String getTaskInfoFunction(String taskId) {
        ModelClass modCls = new ModelClass();
        try {
            if(String.isNotBlank(taskId)) {
                   //fetching task corresponding to the provided task Id
                    if(fetchOpenRecord(taskId) == true){
                       modCls.message = ConstantsUtility.Response_message_Success;
                       modCls.isSuccess = true;
                       modCls.CTICallID = true;
                   }
                   else {
                       modCls.message = ConstantsUtility.Response_message_No_Task_Found;    
                   }
               }
            else {
                modCls.message = ConstantsUtility.Response_message_Task_Id_Missing;    
            }
        }
        catch(Exception e) {modCls.message = e.getMessage();ExceptionHandler.LogError('GetTaskInfoApiController', e.getMessage()+':'+e.getLineNumber(), 'Task details from GetTaskInfoApiController', '', null);
        }
        return JSON.serialize(modCls);
    } 


    public static boolean fetchOpenRecord(string recordId){

        Id currentRecordId = (Id)recordId; //get The current Id
        String sObjName = currentRecordId.getSObjectType().getDescribe().getName();
        system.debug('>>>>>>'+sObjName);
        List<sObject> listTask = new List<sObject>();
        if(sObjName.equalsIgnoreCase('Custom_Activity__c')){
             listTask = [SELECT Id  FROM Custom_Activity__c 
                                    WHERE Id = :currentRecordId AND Status__c = 'Open'];

        }else if(sObjName.equalsIgnoreCase('Custom_ActivTaskity__c')){
             listTask = [SELECT Id  FROM Task WHERE Id = :currentRecordId AND Status = 'Open'];
        }

        if(listTask.size() > 0 ){
            return true;
        }else{
            return false;
        }

    }
    
    //Wrapper class to return as a response
    global class ModelClass {
        public Boolean isSuccess;           //Boolean that represents whether the call to api is useful or not
        public Boolean CTICallID;           //Boolean that represnts whether CTI Call Id has value or not
        public String message;              //String that shows message 
        
        ModelClass() {
            message = '';
            CTICallID = false;
            isSuccess = false;
        }
    }
}