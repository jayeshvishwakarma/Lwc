/**
* @Author-: Sunit Kumar Chand
* @Company-: Techmatrix Consulting
* @Description-: This class is used to create custom log record with @AuraEnabled(continuation=true)
* @Last Modified By   : Sunit Kumar Chand
* @Last Modified On   : 04/02/2020, 12:36:33 PM
* @Modification Log   : Intial Version
* =============================================================
*  Version   Date            Author      Modification
* =============================================================
*  1.0       04 Feb 2020    Sunit     Intial Version
* 
**/
public class AsyncExceptionHandler implements Queueable{
	private String className;
    private String recordID;
    private String errorMessage;
    private String objectName;
    private String userId;
    private String componentName;
    public AsyncExceptionHandler(String className,String recordID,String errorMessage,String objectName,String userId,String componentName){
    	this.className=className;
        this.recordID=recordID;
        this.errorMessage=errorMessage;
        this.objectName=objectName;
        this.userId=userId;
        this.componentName=componentName;
    }
    public void execute(QueueableContext context) {
             Custom_Error__c customObj = new Custom_Error__c(Error_source__c=className,
                                                        Record_ID__c=recordID,
                                                        Error_Message__c=errorMessage,
                                                        Object_Type__c=objectName,
                                                        User__c=userId,
                                                        Component_Name__c=componentName
                                                        );
        // Inserting the record of Exception
        if (Schema.sObjectType.Custom_Error__c.isCreateable()) {
            insert customObj;
        }
    }
     

}