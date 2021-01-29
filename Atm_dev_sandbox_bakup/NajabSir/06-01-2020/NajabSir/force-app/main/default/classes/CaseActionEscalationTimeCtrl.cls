/*
 * Author : Anas Yar Khan
 * Company : Techmatrix Consulting
 * Description :  1.This class is used to show current escalation running on the case and the time remaining in escalating to Next Level (Function : getEscalationNew)
 * 				  2.This class is also used to show error message if escalation is not configured correctly for the case (Function : getDetails)
 */ 
public without sharing class CaseActionEscalationTimeCtrl {
    
    //Wrapper class to return to LWC on load
    public class CaseWrapperDetailNew{
        @auraEnabled
        public String escalationName;    //Field to store escalation name
        @auraEnabled
        public String status;            //Field to store the status of Case Action
        @auraEnabled
        public String level;             //Field to the store the escalation level
        @auraEnabled
        public String escalatingToNextLevelIn;      //Field to store the remaining time before escalation
        
    }  
    
    //This function call when the component loaded or refreshed after a paricular time
    //Recieve the id of the MOS Case
    //Returns the list of Wrapper class
    @AuraEnabled
    public static List<CaseWrapperDetailNew> getEscalationNew(String recordId) {
        List<CaseWrapperDetailNew> listCaseWrapperDetailNew = new List<CaseWrapperDetailNew>();     //Initialization of Wrapper Class
        //Iterating over Queued MC communication record
        for(MC_Communication__c  mcRecord : [SELECT Id,Case_Action__r.Name,Case_Action__r.Escalation_Level__c,Escalation_Date_Time__c  
                                             FROM MC_Communication__c
                                             WHERE Case__c = :recordId 
                                             AND Status__c = :ConstantsUtility.MC_Communication_Status_Queued
                                             AND Case_Action__r.Escalation_Status__c = :ConstantsUtility.Case_Action_Escalation_Status_Active 
                                             AND Escalation_Date_Time__c != NULL 
                                             ORDER BY Case_Action__r.Escalation_Level__c DESC,Escalation_Date_Time__c]) {
                                                 
                                                 CaseWrapperDetailNew caseWrapperObject = new CaseWrapperDetailNew();
                                                 caseWrapperObject.escalationName = mcRecord.Case_Action__r.Name.split('-')[1];    //Name of the Case Action is expected as case Number and type of escalation
                                                 caseWrapperObject.status = ConstantsUtility.Case_Action_Escalation_Status_Active;
                                                 caseWrapperObject.level = mcRecord.Case_Action__r.Escalation_Level__c;
                                                 
                                                 
                                                 //Logic to calculate the remaining time
                                                 Long dt1Long = DateTime.now().getTime();
                                                 Long dt2Long = mcRecord.Escalation_Date_Time__c.getTime();
                                                 Long milliseconds = dt2Long - dt1Long;
                                                 Long seconds = milliseconds / 1000;
                                                 Long minutes = seconds / 60;
                                                 Long Remainder = Math.Mod(seconds,60);
                                                 Long hours = minutes / 60;
                                                 Long days = hours / 24; 
                                                 
                                                 String timeRemaining = String.valueOf(minutes) + ' minutes '+ String.valueOf(Remainder) +' seconds';
                                                 caseWrapperObject.escalatingToNextLevelIn = timeRemaining;
                                                 listCaseWrapperDetailNew.add(caseWrapperObject);
                                             }
        return listCaseWrapperDetailNew;

    }
    //**************End of getEscalationNew Function**********************
    
    
    //This method is called only once when component loads
    //Recieve a Id of Case record
    //Returns the String 
    @AuraEnabled
    public static String getDetails(String recordId) {
        
        String message = '';
        Boolean showMessage = false;
        for(Case cs : [SELECT Escalation_Follow_up__c,Escalation_Allocation__c,Escalation_Reach__c 
                       FROM Case 
                       WHERE id = :recordId]) {
            if(String.isBlank(cs.Escalation_Follow_up__c)) {
                message += ConstantsUtility.MOS_FollowUp_Escalation+',';
                showMessage = true;
            }
            if(String.isBlank(cs.Escalation_Allocation__c)) {
                message += ConstantsUtility.Allocation_Escalation+',';
                showMessage = true;
            }
            if(String.isBlank(cs.Escalation_Reach__c)) {
                message += ConstantsUtility.Reach_Escalation+',';
                showMessage = true;
            }
        }
        if(showMessage) {
        	message = message.removeEnd(',');
       	    message += ConstantsUtility.EscalationErrorMOS;    
        }
        return message;
    }
    
	//************End of getDetails Methods********************    
}