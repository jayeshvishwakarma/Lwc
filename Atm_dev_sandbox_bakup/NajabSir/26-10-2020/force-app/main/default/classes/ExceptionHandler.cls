/**
 * @File Name          : ExceptionHandler.cls
 * @Description        : It basically preserve the record of all exception related messages 
 * @Author             : 
 * @Group              : 
 * @Last Modified By   : Ravi Gupta
 * @Last Modified On   : 05/08/2019
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    8/05/2019, 1:00:01 PM         Ravi Gupta                Initial Version
**/

//CODE REVIEWED BY: Prabhat Sharma - 24 Sept 2019


public without sharing class ExceptionHandler {
    
    
    /**
        Author: Ravi Gupta
        Company: Techmatrix
        Description: This method custom error record when an expception occurs
        Inputs: Name of class, Error message, Object name, record Id, and stack trace class object
        Returns: void
        History:
        ================
        1.0     05 Aug 2019      Ravi     Initial Version
    */
    public static void LogError(String className,String errorMessage,String objectName, String recordID,ExceptionHandler.stackTrace stacktrace){
        //Intantiating Customer Error object
        Custom_Error__c customObj = new Custom_Error__c(Error_source__c=className,
                                                        Record_ID__c=recordID,
                                                        Error_Message__c=errorMessage,
                                                        Object_Type__c=objectName,
                                                        User__c=stacktrace!=null ? stacktrace.userId : null,
                                                        Component_Name__c=stacktrace!=null ? stacktrace.componentName : null
                                                        );
        // Inserting the record of Exception
        insert customObj; // Removed IsCreatable check as Error Logs were not getting created.
    }
    
    @future
    public static void LogError_Future(String className,String errorMessage,String objectName, String recordID, String stackTrace){
        ExceptionHandler.LogError('UserTriggerHandler', errorMessage, 'User', '', null);
    }
    
    //Inner class to capture the logged in user and component name
    public class stackTrace{
        public string componentName;
        public String userId;
    }
}