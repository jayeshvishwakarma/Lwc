/*
* Author: Anas Yar Khan
* Description: This class is used to create Task of record type follow up from a custom Lightning component
* Company: Techmatrix Consulting 
*/

public with sharing class FollowUpRelatedToController {
    
    //This method called when the component loads and return the instance of the WrapperClass
    //This method expects a case record id as a parameter
    @AuraEnabled
    public static WrapperClass getAllDetails(String caseRecordId){
        WrapperClass wrpCls = new WrapperClass();              //Initialization of wrapper class
        try {
            wrpCls.message = 'SUCCESS';
            List<String> listCallOrigin = getselectOptions(ConstantsUtility.CustomActivity,ConstantsUtility.callOriginFieldAPIName); //Getting all the values of Call Origin Picklist
            wrpCls.callPurposePicklist = getselectOptions(ConstantsUtility.CustomActivity,ConstantsUtility.callPurposeFieldAPIName); //Getting all the values of Call Purpose Picklist
            wrpCls.sendSMSPicklist = getselectOptions(ConstantsUtility.CustomActivity,ConstantsUtility.sendSMSFieldAPIName);         //Getting all the values of Send SMS Picklist
            
            //fetching details from Case
            List<Case> caseList = [SELECT Id,OwnerId,MOS_Case_Stage__c,Case_Type__c,
                                   Mobile_Number__c,Complaint_Status__c,CaseNumber,
                                   Technician_ID__c,Technician_ID__r.Phone,Allocated_Dealer__c,
                                   Allocated_Dealer__r.Stakeholder_Hierarchy__c,Channel__c,Allocated_Dealer__r.Phone
                                   FROM Case 
                                   WHERE Id =:caseRecordId];
            
            if(caseList != NULL && caseList.size() > 0){
                wrpCls.caseRecord = caseList[0];       //Map Case with CaseObj of Wrapper Class
                List<Account> listMSAllianzRecord = CaseTriggerHelper.getMSAllianzRecord();    //getting list of MS Allianz records
                wrpCls.mapCallOriginToPhoneNumbers.put('Customer',caseList[0].Mobile_Number__c);  //for Customer Call origin Phone Number is Mobile Number from Case
                wrpCls.mapCallOriginToPhoneNumbers.put('Technician',caseList[0].Technician_ID__r.Phone);  //for Technician Call origin Phone is Technician's Phone from Case
                
                //Populate Values of Call origin based on Channel and Allocated Dealer of Case
                if(listCallOrigin != NULL && listCallOrigin.size() > 0) {
                    for(String callOrigin : listCallOrigin) {
                        //Getting the Call origin values based on Channel and Allocated Dealer of Case
                        //If channel on case is Arena, Call origin will have only values related to Arena and vice-versa 
                        if(callOrigin.contains(ConstantsUtility.ARENA_CASE_CHANNEL) || callOrigin.contains(ConstantsUtility.NEXA_CASE_CHANNEL)) {
                            if(callOrigin.contains(caseList[0].Channel__c)) {
                            	wrpCls.callOriginPicklist.add(callOrigin);    
                            }
                        }
                        else {
                            //Call origin will have TL and Towing Agency values only if allocated dealer is MS Allianz
                            if(callOrigin == 'TL' || callOrigin == 'Towing Agency') {
                                if(listMSAllianzRecord != NULL && listMSAllianzRecord.size() > 0 && caseList[0].Allocated_Dealer__c == listMSAllianzRecord[0].Id) {
                                	wrpCls.callOriginPicklist.add(callOrigin);    
                                }
                                if(callOrigin == 'Towing Agency') {
                                    wrpCls.mapCallOriginToPhoneNumbers.put('Towing Agency',caseList[0].Allocated_Dealer__r.Phone); //For Towing Agency call origin, Phone number of Allocated Dealer from Case will be the key   
                                }
                            }
                            else {
                                wrpCls.callOriginPicklist.add(callOrigin);     
                            }
                        }
                    }    
                }
                //***********end of population of call origin values**************
                
                
                //Getting phone numbers from Allocated Dealer for other call origin
                if(caseList[0].Allocated_Dealer__r.Stakeholder_Hierarchy__c != NULL) {
                    Map<String,Object> mapStakeHoldersToPhoneNumbers = (Map<String,Object>)	JSON.deserializeUntyped(caseList[0].Allocated_Dealer__r.Stakeholder_Hierarchy__c); 
                    If(mapStakeHoldersToPhoneNumbers != NULL && mapStakeHoldersToPhoneNumbers.keySet().size() > 0) {
                        getPhoneNumbersFromHierarchy(caseList[0].Channel__c,mapStakeHoldersToPhoneNumbers,wrpCls.mapCallOriginToPhoneNumbers);    
                    }   
                }
                
                //For CallOrigin HO, Phone number of HO MOS will be the value
                //Getting user of HO MOS Role (Only one user is expected here)
                List<User> listUser = [SELECT Id,Phone FROM USER WHERE UserRole.Name = :ConstantsUtility.RoleHOMOS];
                if(listUser != NULL && listUser.size() > 0) {
                    wrpCls.mapCallOriginToPhoneNumbers.put('HO',listUser[0].Phone); //Mapping phone number of HO MOS with HO Key    
                }
                
                
                //Phone number of TL is coming from Allocated Dealer's related Contact only in case if Allocated Dealer is MS Allianz
                //Related Contact with Designation Team Leader
                if(listMSAllianzRecord != NULL && listMSAllianzRecord.size() > 0 && caseList[0].Allocated_Dealer__c == listMSAllianzRecord[0].Id) {
                    List<Contact> listContact = [SELECT Id,Phone FROM Contact WHERE AccountId = :caseList[0].Allocated_Dealer__c AND Designation__c = :ConstantsUtility.MSAllianzTeamLeader];
                    if(listContact != NULL && listContact.size() > 0) {
                        wrpCls.mapCallOriginToPhoneNumbers.put('TL',listContact[0].Phone);//Mapping phone number of TL     
                    }
                }
            }
        }
        catch(Exception e) {
            ExceptionHandler.LogError('FollowUpRelatedToController', e.getMessage()+':'+e.getLineNumber(), 'Follow Up Task Component on load', '', null);
            wrpCls.message = e.getMessage();
        }
        return wrpCls;
    }
    
    //*********End of getAllDetails methods************************
    
    //This Method is used to populate phone numbers corresponding to Call origin from Allocated Dealer hierarchy
    private static void getPhoneNumbersFromHierarchy(String channel,Map<String,Object> mapStakeHoldersToPhoneNumbers,Map<String,String> mapCallOriginToPhoneNumbers) {
        if(mapStakeHoldersToPhoneNumbers.containsKey(ConstantsUtility.Service+channel) && mapStakeHoldersToPhoneNumbers.get(ConstantsUtility.Service+channel) != NULL) {
            List<Object> listServiceStakeHolder = (List<Object>) mapStakeHoldersToPhoneNumbers.get(ConstantsUtility.Service+channel);
            if(listServiceStakeHolder != NULL && listServiceStakeHolder.size() > 0) {
                for(Object obj : listServiceStakeHolder) {
                    Map<String,Object> mapKeyToValue = (Map<String,Object>)Obj;
                    if(mapKeyToValue != NULL && mapKeyToValue.keySet().size() > 0) {
                        if((String)mapKeyToValue.get('stakeHolder') == ConstantsUtility.NOTIFIER_L1A) {
                            mapCallOriginToPhoneNumbers.put('WM',(String)mapKeyToValue.get('phone'));    
                        }
                        else if((String)mapKeyToValue.get('stakeHolder') == ConstantsUtility.NOTIFIER_L2A) {
                            mapCallOriginToPhoneNumbers.put('GM',(String)mapKeyToValue.get('phone'));
                        }
                        else if((String)mapKeyToValue.get('stakeHolder') == ConstantsUtility.NOTIFIER_L3A) {
                            mapCallOriginToPhoneNumbers.put('TSM '+channel,(String)mapKeyToValue.get('phone'));    
                        }
                        else if((String)mapKeyToValue.get('stakeHolder') == ConstantsUtility.MOSROC) {
                            mapCallOriginToPhoneNumbers.put('ROC '+channel,(String)mapKeyToValue.get('phone'));    
                        }
                        else if((String)mapKeyToValue.get('stakeHolder') == ConstantsUtility.NOTIFIER_L4) {
                            mapCallOriginToPhoneNumbers.put('RSM '+channel,(String)mapKeyToValue.get('phone'));    
                        }
                        else if((String)mapKeyToValue.get('stakeHolder') == ConstantsUtility.NOTIFIER_L5) {
                            mapCallOriginToPhoneNumbers.put('ZSH '+channel,(String)mapKeyToValue.get('phone'));    
                        }
                    }
                }
            }
        }	
    }
    //************End of getPhoneNumbersFromHierarchy****************
    
    
    //This method is used to get all the possible values of a picklist field
    //This method expects two parameters 1. API name of the Object 2. API name of the field
    //Returns a list of String
    private static List<String> getselectOptions(String objName,String fieldApiName) {
        List<String> picklistValuesList = new List<String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldApiName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistValuesList.add(pickListVal.getValue());
        } 
        return picklistValuesList;
    }
    //*************End of getselectOptions method********************
    
    
    //This method called to insert Task
    @AuraEnabled
    public static String saveFollowUp (Custom_Activity__c taskObject,Case caseObject) {
        try{
            if(taskObject != NULL){
                taskObject.Subject__c = taskObject.Call_Origin__c +' '+caseObject.Case_Type__c + ' ' + caseObject.MOS_Case_Stage__c;
                taskObject.Name = taskObject.Call_Origin__c +' '+caseObject.Case_Type__c + ' ' + caseObject.MOS_Case_Stage__c;
                taskObject.OwnerId =caseObject.OwnerId;
                taskObject.Due_Date_Time__c = DateTime.now().addMinutes(ConstantsUtility.Fifteen_Minutes);
                taskObject.Complaint_Status__c = caseObject.MOS_Case_Stage__c;
                //taskObject.ActivityDate = Date.today();
                taskObject.Case__c = caseObject.Id;
                taskObject.RecordTypeId = ConstantsUtility.CustomActivityMOSFollowUpRecordTypeId;
                taskObject.Status__c = ConstantsUtility.CustomActivityStatusOpen;
                insert taskObject;
                
                Task newTask = new Task();
                newTask.Subject = taskObject.Call_Origin__c +' '+caseObject.Case_Type__c + ' ' + caseObject.MOS_Case_Stage__c;
                newTask.OwnerId = caseObject.OwnerId;
                newTask.ActivityDate = Date.today();
                newTask.WhatId = caseObject.Id;
                newTask.RecordTypeId= ConstantsUtility.TASK_MOS_Follow_Up_RecordType_Id;
                newTask.Custom_Activity__c = taskObject.Id;
				insert newTask;
            }
            return 'SUCCESS#'+taskObject.Id;
        }
        catch(Exception e){
            ExceptionHandler.LogError('FollowUpRelatedToController', e.getMessage()+':'+e.getLineNumber(), 'Follow Up Task Creation MOS Case', '', null);
            return e.getMessage();
        }
    } 
    //********End of saveFollowUp****************
    
    //Wrapper class to return on load of the lightning component
    public class WrapperClass{
        @AuraEnabled   
        public List<String> callOriginPicklist; //Stores all the possible values of the Call Origin picklist field on Task based on the Channel,Allocated Dealer
        @AuraEnabled   
        public List<String> callPurposePicklist; //Stores all the possible values of the Call Purpose picklist field on Task
        @AuraEnabled   
        public List<String> sendSMSPicklist;    //Stores all the possible values of the Send SMS picklist field on Task
        @AuraEnabled   
        public Case caseRecord;                 //Stores the Case record from the Task is creating
        @AuraEnabled 
        public DateTime nextFollowUpTime;       //Stores the current time + 15 minutes
        @AuraEnabled
        public Map<String,String> mapCallOriginToPhoneNumbers;     // Stores the Key as Call Origin and Value as the corresponding phone number
        @AuraEnabled
        public String message;                  //Holds the state of the Server call
        @AuraEnabled
        public Datetime todayDate;
        public WrapperClass(){
            callOriginPicklist = new List<String>();
            callPurposePicklist = new List<String>();
            sendSMSPicklist = new List<String>();
            caseRecord = new Case();
            nextFollowUpTime = DateTime.now().addMinutes(ConstantsUtility.Fifteen_Minutes);
            mapCallOriginToPhoneNumbers = new Map<String,String>();
            message = 'SUCCESS';
            todayDate = system.now();
        }
    }
    //*************End of the Wrapper Class**************************
    
}