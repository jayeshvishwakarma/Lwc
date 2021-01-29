/**
 * @File Name          : NotificationPlatfromEventTriggerHandler.cls
 * @Description        : This trigger utility class  for Notification platform Event subscriber trigger
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
public without sharing class NotificationPlatfromEventTriggerHandler extends TriggerHandler {
  
    
    private List<Notification__e> newNotificationList;
    
    //constructor
    public NotificationPlatfromEventTriggerHandler() {
       
        this.newNotificationList = (list<Notification__e>) Trigger.New;
        
    }
    public override void afterInsert(){
        List<Notification__e> lstCVAccessGrantBatchStartNotification=new List<Notification__e>();
        for(Notification__e nVar: newNotificationList){
            if(nVar.Notification_Type__c==System.label.Customer_visibility_Grant_Access_Batch) // Check for relevant notification type
              lstCVAccessGrantBatchStartNotification.add(nVar);
        }
       if(lstCVAccessGrantBatchStartNotification.size()>0) 
        CustomerRecordVisibilityUtility.processBatchInitiateNotification(lstCVAccessGrantBatchStartNotification);
                                                                                
    }
}