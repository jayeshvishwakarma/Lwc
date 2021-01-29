/**
* @File Name          : LostEnquiresController.cls
* @Description        : This class is for All Lost Enquiries Approval/Rejection for TL/
* @Author             : 
* @Group              : 
* @Created By         : Navin Soni
* @Created Date       : 05/05/2020
*/
public without sharing class LostEnquiresController { 
    public static boolean isValidUser{get;set;}   
    @AuraEnabled public static List<LostEnquiresWrapper> listOfLEWrapper{get;set;} 
    @AuraEnabled(cacheable = true)
    public static List<LostEnquiresWrapper> fetchLostEnquires(){
        String Lost_Enquiries_Access = Label.Lost_Enquiries_Access;
        Set<String> setOfLostEnquiriesAccess = new Set<String>();
        listOfLEWrapper = new List<LostEnquiresWrapper>();
        List<Opportunity> listOfEnquires = new List<Opportunity>();
        Id currentUserId = userInfo.getUserId();
        if(String.isNotBlank(Lost_Enquiries_Access)){
            if(Lost_Enquiries_Access.contains(';')){
                setOfLostEnquiriesAccess.addAll(Lost_Enquiries_Access.split(';'));
            }else{
                setOfLostEnquiriesAccess.add(Lost_Enquiries_Access);
            }
        }
        System.debug('setOfLostEnquiriesAccess  -'+setOfLostEnquiriesAccess );
        if(setOfLostEnquiriesAccess != null && setOfLostEnquiriesAccess.size() > 0){
            String designation = getDesignation(currentUserId);
            System.debug('@@## designation  - '+designation );
            if(String.IsNotBlank(designation) && setOfLostEnquiriesAccess.contains(designation)){
                List<ProcessInstance> listOfProcessInstance = [SELECT TargetObjectId, CompletedDate, SubmittedById  FROM ProcessInstance 
                                                            where TargetObject.Type = 'Opportunity' and Status = 'Pending' Limit 10000];
                Set<String> setOfEnquireIds = new Set<String>();
                System.debug('@@## listOfProcessInstance '+listOfProcessInstance );
                for(ProcessInstance objProcess : listOfProcessInstance){
                    setOfEnquireIds.add(objProcess.TargetObjectId);
                }
                System.debug('@@## setOfEnquireIds '+setOfEnquireIds );
                listOfEnquires = [Select Id, Name, DMS_Enquiry_Name__c, StageName, Account.Name, Variant__c, Variant__r.Name, CloseDate, Mobile__c, DSE_Name__c,Owner.Dealer_Account__c
                                FROM Opportunity where Id IN : setOfEnquireIds AND 
                                Owner.ManagerId =: UserInfo.getUserId() limit 5000]; 
                System.debug('@@## listOfEnquires '+listOfEnquires );

                if(listOfEnquires != null && listOfEnquires.size() > 0){
                    for(Opportunity objOpp : listOfEnquires){
                        LostEnquiresWrapper objEW = new LostEnquiresWrapper();
                        objEW.objOpp = objOpp;
                        objEW.dealerId = objOpp.Owner.Dealer_Account__c;
                        objEW.OppURL = '/dealers/s/opportunity/'+objOpp.Id;
                        listOfLEWrapper.add(objEW);
                    }
                }
                System.debug('@@## listOfLEWrapper '+listOfLEWrapper );
                isValidUser = TRUE;            
                System.debug('@@## 1 isValidUser '+isValidUser );
            }else{
                isValidUser = FALSE;   
                System.debug('@@## 1 isValidUser '+isValidUser );
            }      
        }
        return listOfLEWrapper;
    }

    @AuraEnabled(cacheable = false)
    public static boolean getValidUser(){
        Id currentUserId = userInfo.getUserId();
        String designation = getDesignation(currentUserId);
        System.debug('@@## designation  - '+designation );
        String Lost_Enquiries_Access = Label.Lost_Enquiries_Access;
        Set<String> setOfLostEnquiriesAccess = new Set<String>();
        if(String.isNotBlank(Lost_Enquiries_Access)){
            if(Lost_Enquiries_Access.contains(';')){
                setOfLostEnquiriesAccess.addAll(Lost_Enquiries_Access.split(';'));
            }else{
                setOfLostEnquiriesAccess.add(Lost_Enquiries_Access);
            }
        }
        if(String.IsNotBlank(designation) && setOfLostEnquiriesAccess.contains(designation)){
            return true;
        }
        return false;
    }

    // This method is use to check current user Designation.
    public static String getDesignation(Id currentUserId){
        String currentUserDesignation = '';
        if(currentUserId != null){
            list<User> listOfUser = new list<User>([SELECT Id, Designation__c FROM USER WHERE Id =: currentUserId AND Designation__c != null]);
            currentUserDesignation = (listOfUser != null && listOfUser.size()>0) ? listOfUser[0].Designation__c : '';
        }
        return currentUserDesignation;
    }

    // This method is use for Accept/Reject all Enquiry record.
    @AuraEnabled
    public static void ApprovalAllEnquiryRecordSF(List<LostEnquiresWrapper> listOfLEWrapper, boolean isApproveReject) {
        System.debug('@@## listOfLEWrapper '+listOfLEWrapper);
        System.debug('@@## isApproveReject '+isApproveReject);
        List<Opportunity> listOfApproveEnquires = new List<Opportunity>();
        if(listOfLEWrapper != null && listOfLEWrapper.size() > 0){
            for(LostEnquiresWrapper objLEW : listOfLEWrapper){
                if(objLEW.isSelected){
                    listOfApproveEnquires.add(objLEW.objOpp);
                }
            }
            if(listOfApproveEnquires != null && listOfApproveEnquires.size() > 0){
                Map<Id, ProcessInstanceWorkitem> mapOfProcessInstanceWorkitem = new Map<Id, ProcessInstanceWorkitem>();
                //Getting Work Item Id
                for(ProcessInstanceWorkitem objPTWI : [Select Id, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId IN : listOfApproveEnquires]){
                    mapOfProcessInstanceWorkitem.put(objPTWI.ProcessInstance.TargetObjectId, objPTWI);
                }
                System.debug('@@## listOfApproveEnquires '+listOfApproveEnquires);
                List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest> ();
                for(Opportunity objOpp : listOfApproveEnquires) {
                    Approval.ProcessWorkitemRequest req1 = new Approval.ProcessWorkitemRequest();
                    req1.setComments('Submitted for approval by Lost Enquiry Tab.');
                    //Approve or Reject Record
                    if(isApproveReject){
                        req1.setAction('Approve');
                    }else{
                        req1.setAction('Reject');
                    }
                    if(mapOfProcessInstanceWorkitem != null && mapOfProcessInstanceWorkitem.containsKey(objOpp.Id)){
                        req1.setWorkitemId(mapOfProcessInstanceWorkitem.get(objOpp.Id).Id);
                    }
                    requests.add(req1);
                }
                System.debug('@@## requests '+requests);
                if(requests != null && requests.size() > 0){
                    try {
                        // Submit the request for approval
                        Approval.ProcessResult[] processResults = Approval.process(requests);
                        System.debug('@@## processResults '+processResults);
                    }catch (System.DmlException e) {
                        System.debug('@@## Exception Is ' + e.getMessage());
                        ExceptionHandler.stackTrace trace = new ExceptionHandler.stackTrace();
                        trace.componentName = 'Lost Enquiry Tab';
                        trace.userId = UserInfo.getUserId();
                        ExceptionHandler.LogError('LostEnquiresController', e.getMessage(), 'Approval.ProcessSubmitRequest', '', trace);
                    }
                }
            }
        }
    }

    // wrapper class
    public class LostEnquiresWrapper{
        @AuraEnabled public Opportunity objOpp{get;set;}
        @AuraEnabled public boolean isSelected{get;set;}  
        @AuraEnabled public String dealerId{get;set;}    
        @AuraEnabled public String OppURL{get;set;}     
        public LostEnquiresWrapper(){
            objOpp = new Opportunity();
            isSelected = FALSE;
            dealerId = '';
            OppURL = '';
        }
    }
    
    // This funcion is used to get user list as per search key and dealer Id
    @AuraEnabled(cacheable=true)
    public static BasicReturn getUserList(String dealerId, String name)    {
        System.debug('Inside getUserList');
        System.debug(dealerId);
        BasicReturn br = new BasicReturn();
        try{
            String var='%'+name+'%';
            List<User> userList = [select Id,Name,toLabel(Designation__c),Profile.Name from User where IsPortalEnabled=true and contact.accountId=:dealerId and isActive=true and Name like:var and Profile.Name = 'Dealer Team Leads/Managers'];
            br.dataList=userList;
            br.message='Success';
            br.status='Success';
            br.code=200;
        }
        catch(Exception e){
            br.message=e.getMessage();br.status='Error';br.code=0;
        }
        System.debug(br);
        return br;
    }

    // This method is use to change Enquiry Owner.
    @AuraEnabled(cacheable=true)
    public static void changeEnquiryOwner(List<LostEnquiresWrapper> listOfLEWrapper, String ownerId){
        System.debug('@@## ownerId '+ownerId);
        System.debug('@@## listOfLEWrapper '+listOfLEWrapper);
        List<Opportunity> listOfApproveEnquires = new List<Opportunity>();
        if(listOfLEWrapper != null && listOfLEWrapper.size() > 0){
            for(LostEnquiresWrapper objLEW : listOfLEWrapper){
                if(objLEW.isSelected && string.isNotBlank(ownerId)){
                    listOfApproveEnquires.add(objLEW.objOpp);
                }
            }
            if(listOfApproveEnquires != null && listOfApproveEnquires.size() > 0){
                List<ProcessInstance> listOfProcessInstance = [SELECT TargetObjectId, CompletedDate, SubmittedById  FROM ProcessInstance 
                                                                WHERE TargetObject.Type = 'Opportunity' AND Status = 'Pending' 
                                                                AND TargetObjectId IN : listOfApproveEnquires Limit 10000];
                system.debug('@@## listOfProcessInstance '+listOfProcessInstance.size());
                if(listOfProcessInstance != null && listOfProcessInstance.size() > 0){
                    List<ProcessInstanceWorkitem> listOfProcessInstanceWorkitem = [SELECT Id, OriginalActorId, OriginalActor.Name, ProcessInstanceId, ActorId, Actor.Name FROM ProcessInstanceWorkitem WHERE ProcessInstanceId IN : listOfProcessInstance Limit 10000];
                    for(ProcessInstanceWorkitem objProcessInstance : listOfProcessInstanceWorkitem){
                        objProcessInstance.OriginalActorId = ownerId;
                        objProcessInstance.ActorId = ownerId;
                    } 
                    system.debug('@@## ProcessInstanceWorkitem '+listOfProcessInstanceWorkitem);
                    if(listOfProcessInstanceWorkitem != null && listOfProcessInstanceWorkitem.size() > 0){
                        update listOfProcessInstanceWorkitem;
                    }
                }
            }
        }
    }
}