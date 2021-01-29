/**
* @File Name          : EmailMessageTriggerHandler.cls
* @Description        : Trigger handler class for EmailMessage
* @Author             : 
* @Group              : 
* @Last Modified By   : Gitika 
* @Last Modified On   : 
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    7/17/2020, 11:26:51 AM                                Initial Version

**/
public without sharing class EmailMessageTriggerHandler extends TriggerHandler {

    public list<EmailMessage> newEmaiMessageList;

    public EmailMessageTriggerHandler() {
        this.newEmaiMessageList = (List<EmailMessage>) Trigger.new;
    }

    
    //Method to run on Before Insert
    public override void afterInsert() {
        //method to update the external Id fields on the Object
        populateDetailsOnCase();
    }
    
    
     /**
       Author: Gitika
       Company: Techmatrix
       Description: 
       Returns: void
       History:
       * Ver         Date                     Author                    Modification
       *==============================================================================
       * 1.0                       Gitika                   Initial Version
   **/
    public void populateDetailsOnCase(){
        // set used to store case ids
        set<Id> parentIds = new set<Id>();
        set<Id> parentIdsTocloseMilestone = new set<Id>();
         // list used to update case
        List<Case> caseToUPdate = new list<Case>();
         // list to store unique key
        list<string> uniqueKeyList = new list<string>();
        // map of unique key With Queue Id for assignment
        map<string,string> mapOfUniqueKeyWithQueueId = new map<string,string>();
        list<task> listToInsertTask = new list<task>();
        
        set<string> queueNames= new set<string>();
        queueNames.add(ConstantsUtility.PENDING_CUSTOMER_RESPONSE_EMAIL_TEAM);
        queueNames.add(ConstantsUtility.PENDING_CUSTOMER_RESPONSE);
        queueNames.add(ConstantsUtility.PENDING_MSIL_RESPONSE);

        map<string,string> mapOfqueueNamesWithQueueId = new map<string,string>();

        for(EmailMessage msg : this.newEmaiMessageList){
            parentIds.add(msg.Parentid);
        }
        
        Try{
        if(parentIds.size()>0){
            /**** Added to fetch Suzuki Connect Constant values from custom setting (added by Sunit) ****/
            Constant_Value__c cv=ProjectUtility.getConstantValue('Suzuki Connect');
            /********************************************************************************************/
            for(Group grp : [SELECT Id, Name, DeveloperName, Email, Type FROM Group where Type = :ConstantsUtility.QUEUE And DeveloperName in :queueNames]){
                mapOfqueueNamesWithQueueId.put(grp.DeveloperName,grp.id);}
        
            map<id,Case> mapOfParentIdWithCase = new map<id,Case>([Select MSIL_Non_SF_Stakeholder_Email__c,
                                                                   No_of_Inbound_Emails_count__c,Status,recordtypeid,
                                                                   Email_Queue_Id__c,First_Response_Completed__c,
                                                                   MSIL_Remarks__c,Additional_Information__c,
                                                                   No_of_Outbound_Emails__c,Email__c,Channel__c,
                                                                   Business_area__c,case_Type__c,OwnerId,mobile_number__c
                                                                   from case where id in:parentIds]);  
            
            for(Id caseId : mapOfParentIdWithCase.keyset()){

                case cs = mapOfParentIdWithCase.get(caseId);
                string Key = (cs.Channel__c!=null?cs.Channel__c:'');
                        Key+= (cs.Case_Type__c!=null?cs.Case_Type__c:'');
                        Key+= (cs.Business_Area__c!=null?cs.Business_Area__c:'');
                        uniqueKeyList.add(key);
            }
            
            if(uniqueKeyList.size()>0){
                mapOfUniqueKeyWithQueueId = caseTriggerHelper.getQueueAssignment(uniqueKeyList); 
            }
            
            for(EmailMessage msg : this.newEmaiMessageList){
                // Outgoing mail 
                if(msg.Incoming == false && msg.ToAddress != null && mapOfParentIdWithCase.containskey(msg.ParentId) 
                  ){
                    Task newTask = new Task();
                   // newTask.Business_Line__c=string.isNotBlank(mapOfParentIdWithCase.get(msg.ParentId).Case_Type__c) ? mapOfParentIdWithCase.get(msg.ParentId).Case_Type__c:null;
                    newTask.Service_Type__c=ConstantsUtility.EMAIL_TO_CUSTOMER_FROM_EMAIL_COMPOSER;
                    newTask.Case__c=msg.ParentId;
                    newTask.Whatid=msg.ParentId;
                    newTask.Customer_Mobile__c=string.isNotBlank(mapOfParentIdWithCase.get(msg.ParentId).mobile_number__c) ? mapOfParentIdWithCase.get(msg.ParentId).mobile_number__c:null;
                    newTask.Type=ConstantsUtility.CASE_SOURCE_EMAIL;
                    newTask.recordtypeid=ConstantsUtility.TASK_General_FOLLOW_UP_RECORD_TYPE_ID;
                    newTask.subject =ConstantsUtility.EMAIL_TO_CUSTOMER_FROM_EMAIL_COMPOSER;
                    listToInsertTask.add(newTask);  
                       case caseObj = new case();
                       caseObj.id=msg.ParentId;
                    // Email to customer   
                       if(mapOfParentIdWithCase.get(msg.ParentId).Email__c != null && msg.ToAddress == string.valueof(mapOfParentIdWithCase.get(msg.ParentId).Email__c)){
                         caseObj.No_of_Outbound_Emails__c=mapOfParentIdWithCase.get(msg.ParentId).No_of_Outbound_Emails__c+1;
                       // First Response completion check for Email Case Recordtype
                             if(mapOfParentIdWithCase.get(msg.ParentId).recordTypeid==ConstantsUtility.EMAIL_CASE_CASE_RECORD_TYPE_ID && msg.Status__c==ConstantsUtility.CASE_PENDING_CUSTOMER_RESPONSE && mapOfParentIdWithCase.get(msg.ParentId).First_Response_Completed__c==false ){
                               caseObj.First_Response_Completed__c=true;
                               parentIdsTocloseMilestone.add(msg.ParentId);
                       // subsequent Response completion check for Email Case Recordtype
                             }else if(mapOfParentIdWithCase.get(msg.ParentId).recordTypeid==ConstantsUtility.EMAIL_CASE_CASE_RECORD_TYPE_ID && mapOfParentIdWithCase.get(msg.ParentId).First_Response_Completed__c==true && mapOfParentIdWithCase.get(msg.ParentId).No_of_Outbound_Emails__c>0){
                               parentIdsTocloseMilestone.add(msg.ParentId);}
                          
                         caseObj.Status  = msg.Status__c==ConstantsUtility.CASE_PENDING_CUSTOMER_RESPONSE ? ConstantsUtility.CASE_PENDING_CUSTOMER_RESPONSE : mapOfParentIdWithCase.get(msg.ParentId).Status;
                         caseObj.OwnerId = msg.Status__c==ConstantsUtility.CASE_PENDING_CUSTOMER_RESPONSE ?
                                           (mapOfParentIdWithCase.get(msg.ParentId).recordTypeid==ConstantsUtility.EMAIL_CASE_CASE_RECORD_TYPE_ID?
                                            mapOfqueueNamesWithQueueId.get(ConstantsUtility.PENDING_CUSTOMER_RESPONSE_EMAIL_TEAM):mapOfqueueNamesWithQueueId.get(ConstantsUtility.PENDING_CUSTOMER_RESPONSE) ) : mapOfParentIdWithCase.get(msg.ParentId).OwnerId;
                           /**** Added for Suzuki Connect ****/    
                           if(msg.Status__c==ConstantsUtility.REASSIGNED_ADD_INFO && mapOfParentIdWithCase.get(msg.ParentId).RecordTypeId==ConstantsUtility.DEALER_SUZUKI_CONNECT_CASE_RECORD_TYPE_ID){
                                   caseObj.OwnerId=System.label.Panasonic_Queue;
                                   caseObj.Status=ConstantsUtility.REASSIGNED_ADD_INFO;
                               }
                           /**********************************/
                             }
                    // Email from StakeHolder Outside salesforce
                        else if(mapOfParentIdWithCase.get(msg.ParentId).MSIL_Non_SF_Stakeholder_Email__c!=null && msg.ToAddress == string.valueof(mapOfParentIdWithCase.get(msg.ParentId).MSIL_Non_SF_Stakeholder_Email__c)){
                            System.debug('Inside for 6');
                                caseObj.Status=ConstantsUtility.CASE_PENDING_MSIL_RESPONSE;
                                caseObj.OwnerId = mapOfqueueNamesWithQueueId.containskey(ConstantsUtility.PENDING_MSIL_RESPONSE) ? mapOfqueueNamesWithQueueId.get(ConstantsUtility.PENDING_MSIL_RESPONSE) :mapOfParentIdWithCase.get(msg.ParentId).OwnerId;
                             }
                      
                      
                      //Added by Prabhat - to close the case - to be removed
                      if((mapOfParentIdWithCase.get(msg.ParentId).recordTypeid==ConstantsUtility.EMAIL_CASE_CASE_RECORD_TYPE_ID  || mapOfParentIdWithCase.get(msg.ParentId).recordTypeid==ConstantsUtility.MSIL_QUERY_CASE_RECORD_TYPE_ID)
                      && msg.Status__c=='Closed'){
                          caseObj.Status = 'Closed';
                          parentIdsTocloseMilestone.add(msg.ParentId);
                      }
                      caseToUPdate.add(caseObj);
                   }
                // Incoming mail
                if(msg.Incoming == true && msg.FromAddress != null && mapOfParentIdWithCase.containskey(msg.ParentId) ){
                    case caseObj = new case();
                    caseObj.id=msg.ParentId;
                    caseObj.No_of_Inbound_Emails_count__c=mapOfParentIdWithCase.get(msg.ParentId).No_of_Inbound_Emails_count__c+1;
                  
                  if((mapOfParentIdWithCase.get(msg.ParentId).No_of_Inbound_Emails_count__c>0 && mapOfParentIdWithCase.get(msg.ParentId).recordTypeid==ConstantsUtility.EMAIL_CASE_CASE_RECORD_TYPE_ID) ||
                      mapOfParentIdWithCase.get(msg.ParentId).recordTypeid!=ConstantsUtility.EMAIL_CASE_CASE_RECORD_TYPE_ID){
                                                    
                        String message =label.New_Response_Email;    
                        if (message.contains('{now}') && message.contains('{emailID}')) {
                            message = message.replace('{now}', String.valueOf(DateTime.now()));
                            message = message.replace('{emailID}', msg.FromAddress);}
                            caseObj.Additional_Information__c=(mapOfParentIdWithCase.get(msg.ParentId).Additional_Information__c!=null)? mapOfParentIdWithCase.get(msg.ParentId).Additional_Information__c+ConstantsUtility.NEW_LINE+message : message;  
                    
                    // When case is not Closed
                    if(mapOfParentIdWithCase.get(msg.ParentId).Status != ConstantsUtility.CASE_CLOSED){
                        	System.debug(' Email testing');
                           // Reply is received from Customer
                            if(mapOfParentIdWithCase.get(msg.ParentId).Email__c != null && msg.FromAddress==mapOfParentIdWithCase.get(msg.ParentId).Email__c){
                                System.debug(' Email testing 1');
                                caseObj.Status=ConstantsUtility.CASE_CUSTOMER_RESPONSE_RECEIVED; 
                                caseObj.Time_Assigned_to_Customer__c=system.now();
                               /**** Added to update case owner to suzuki connect queue(added by Sunit) ****/
                                if(mapOfParentIdWithCase.get(msg.ParentId).RecordTypeId==ConstantsUtility.DEALER_SUZUKI_CONNECT_CASE_RECORD_TYPE_ID && mapOfParentIdWithCase.get(msg.ParentId).Channel__c=='Arena'){
                                    caseobj.OwnerId = cv.Arena_Suzuki_Connect_Queue_Id__c;  
                                }
                                if(mapOfParentIdWithCase.get(msg.ParentId).RecordTypeId==ConstantsUtility.DEALER_SUZUKI_CONNECT_CASE_RECORD_TYPE_ID && mapOfParentIdWithCase.get(msg.ParentId).Channel__c=='Nexa'){
                                    caseobj.OwnerId = cv.Nexa_Suzuki_Connect_Queue_Id__c;   
                                }
                               /*****************************************************************************/
                                if(mapOfParentIdWithCase.get(msg.ParentId).recordTypeid==ConstantsUtility.EMAIL_CASE_CASE_RECORD_TYPE_ID && mapOfParentIdWithCase.get(msg.ParentId).Email_Queue_Id__c != null){
                                caseObj.OwnerId=mapOfParentIdWithCase.get(msg.ParentId).Email_Queue_Id__c; }
                                if(mapOfParentIdWithCase.get(msg.ParentId).recordTypeid==ConstantsUtility.MSIL_QUERY_CASE_RECORD_TYPE_ID){
                                string Key = (mapOfParentIdWithCase.get(msg.ParentId).Channel__c!=null?mapOfParentIdWithCase.get(msg.ParentId).Channel__c:'');
                                Key+= (mapOfParentIdWithCase.get(msg.ParentId).Case_Type__c!=null?mapOfParentIdWithCase.get(msg.ParentId).Case_Type__c:'');
                                Key+= (mapOfParentIdWithCase.get(msg.ParentId).Business_Area__c!=null?mapOfParentIdWithCase.get(msg.ParentId).Business_Area__c:'');
                             
                                if(mapOfUniqueKeyWithQueueId.containskey(Key)){
                                    caseobj.OwnerId = mapOfUniqueKeyWithQueueId.get(Key);   
                                }
                                
                            }
                            // Reply is received from StakeHolder
                            }else if(mapOfParentIdWithCase.get(msg.ParentId).MSIL_Non_SF_Stakeholder_Email__c!=null && msg.FromAddress==mapOfParentIdWithCase.get(msg.ParentId).MSIL_Non_SF_Stakeholder_Email__c){
                                caseObj.Status=ConstantsUtility.CASE_OPEN_STAKEHOLDER_RESPONDED; 
                                string Key = (mapOfParentIdWithCase.get(msg.ParentId).Channel__c!=null?mapOfParentIdWithCase.get(msg.ParentId).Channel__c:'');
                                Key+= (mapOfParentIdWithCase.get(msg.ParentId).Case_Type__c!=null?mapOfParentIdWithCase.get(msg.ParentId).Case_Type__c:'');
                                Key+= (mapOfParentIdWithCase.get(msg.ParentId).Business_Area__c!=null?mapOfParentIdWithCase.get(msg.ParentId).Business_Area__c:'');
                             
                                if(mapOfUniqueKeyWithQueueId.containskey(Key)){
                                    caseobj.OwnerId = mapOfUniqueKeyWithQueueId.get(Key);   
                                }   
                            }
  
                      
                    }
                    // When case is  Closed
                    else{
                        caseObj.Status= ConstantsUtility.CASE_CLOSED_REPLY_RECEIVED; 
                        string Key = (mapOfParentIdWithCase.get(msg.ParentId).Channel__c!=null?mapOfParentIdWithCase.get(msg.ParentId).Channel__c:'');
                        Key+= (mapOfParentIdWithCase.get(msg.ParentId).Case_Type__c!=null?mapOfParentIdWithCase.get(msg.ParentId).Case_Type__c:'');
                        Key+= (mapOfParentIdWithCase.get(msg.ParentId).Business_Area__c!=null?mapOfParentIdWithCase.get(msg.ParentId).Business_Area__c:'');
                     
                        if(mapOfUniqueKeyWithQueueId.containskey(Key)){
                            caseobj.OwnerId = mapOfUniqueKeyWithQueueId.get(Key);   
                        }
   
                    }
                }
                caseToUPdate.add(caseObj);
              }
           }
            if(parentIdsTocloseMilestone.size()>0){
                List<String> milestoneNames = new List<String>();
                milestoneNames.add(ConstantsUtility.CASE_MILESTONE_FIRST_RESPONSE);
                milestoneNames.add(ConstantsUtility.CASE_MILESTONE_SUBSEQUENT_RESPONSE);
                MilestoneUtils.completeMilestone(parentIdsTocloseMilestone, milestoneNames, DateTime.now()); 
            }
              
        }
        //Bypass removed by Sunit for Suzuki connect
        //TriggerHandler.bypass('CaseTriggerHandler_Strategy');
        update caseToUPdate; 
        //TriggerHandler.clearBypass('CaseTriggerHandler_Strategy');
        if(listToInsertTask.size()>0){
            insert listToInsertTask;
        }
        
    }catch (exception e) {
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();
            ehst.componentName = 'EmailMessageTriggerHandler';
            ehst.userId = UserInfo.getUserId();
            ExceptionHandler.LogError('EmailMessageTriggerHandler', e.getMessage() + e.getLineNumber(), 'populateDetailsOnCase', '', ehst);
        }
    }
}