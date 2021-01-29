/**
* @File Name          : CreateInboundCase.cls
* @Description        : 
* @Author             : Nitin Ghai
* @Group              : 
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 10-28-2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author      		      Modification
*==============================================================================
* 1.0    11/08/2020, 11:02:00 AM        Nitin Ghai                 Initial Version
* 1.1    02/09/2020, 11:02:00 AM        Nitin Ghai                 Added createChatterNotificationonCaseCreation method
* 1.2    02/09/2020, 11:02:00 AM        Nitin Ghai                 Added username paramter in fetchCaseOwner method 
* 1.3    09/09/2020, 11:02:00 AM        Nitin Ghai                 Task creation when Case a Case is created
* 1.4    10/09/2020, 11:02:00 AM        Nitin Ghai                 Added Insurance SPOC 1 & Insurance SPOC 2 fields
in fetchenquiryDealerRec method
**/
public without sharing class CreateInboundCase {
    
    /**
Author: Nitin Ghai
Company: Techmatrix
Description: It will fetch the Customer, Dealer Outlet & Opportunity information
Inputs: Customer Id
Returns: (Wrapper)Customer Data, Opportunity(Enquiry) & Dealer Outlet
**/
    @AuraEnabled        
    public static customerDealerRec fetchCustomerDetails(String recordId){
        customerDealerRec caseData = new customerDealerRec();
        try{
            if(String.isNotBlank(recordId)){
                String sObjName = '';
                sObjName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();       
                if (sObjName == 'Opportunity'){
                    caseData.enquiryData = [SELECT First_Name__c,Last_Name__c,Mobile__c,Email__c,customer__c,customer__r.personcontactid,Booking_Number__c,Invoice_Number__c,Model_Code__c,Variant__c,Color__c,Vehicle_Registration__c,VIN__c,
                                            Dealership__c,Dealership__r.Name,Dealership__r.Zone__c,Dealership__r.Dealer_Code__c, Dealership__r.Dealer_Type__c,Dealership__r.For_Code__c,
                                            Dealership__r.Region_Code__c,Owner.Channel__c,Dealership_Channel__c,Dealership__r.For_Code__r.Name,
                                            Dealership__r.BillingStreet,Dealership__r.BillingCity,Dealership__r.BillingCountry,Dealership__r.BillingState,Dealership__r.BillingPostalCode
                                            FROM Opportunity
                                            WHERE Id = :recordId
                                            LIMIT 1
                                           ];
                    if(String.isNotBlank(caseData.enquiryData.customer__c)){
                        caseData.registrationNumberList = [SELECT id,Name,Current_Insurance_Reference_Number__c FROM Asset WHERE AccountId =:caseData.enquiryData.customer__c AND RecordTypeID=:ConstantsUtility.ASSET_VEHICLE_RECORD_TYPE];
                    }
                }
                else if(sObjName == 'Account') {
                    caseData.customerdata = [SELECT PersonContactId,FirstName,LastName,PersonEmail,PersonMobilePhone 
                                             FROM Account WHERE Id=:recordId LIMIT 1];
                    caseData.registrationNumberList = [SELECT id,Name,Current_Insurance_Reference_Number__c FROM Asset WHERE AccountId =: recordId AND RecordTypeID=:ConstantsUtility.ASSET_VEHICLE_RECORD_TYPE];
                }
            }
            User us = [Select Id,AccountId,Account.Parent_MI_Code__c,Account.Parent_Workshop_Code__c,Profile.Name,Channel__c FROM User where Id=:userInfo.getUserId()];
            if(us!=NULL && (String.isNotBlank(us.Account.Parent_Workshop_Code__c) || String.isNotBlank(us.Account.Parent_MI_Code__c))){
                caseData.dealerOutletName=editInboundCase.fetchBusinessAreaWorkshop(us.Account.Parent_Workshop_Code__c,us.Account.Parent_MI_Code__c);
                caseData.parentWorkhopCode=us.Account.Parent_Workshop_Code__c;
                caseData.parentMiCode=us.Account.Parent_MI_Code__c;
                caseData.agentProfileName=us.Profile.Name;
                caseData.loggedUserChannel=us.Channel__c;
            }
            caseData.agentDealerId=us!=NULL && String.isNotBlank(us.AccountId) ? us.AccountId : '';
            caseData.caseRecMetadata = [Select DeveloperName,MasterLabel,Record_Type_Developer_Name__c FROM Case_Type_And_Case_RecordType_Matrix__mdt where Type__c='Inbound'];
        }
        catch(Exception e){
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();ehst.componentName = 'CreateDealerInboundCase - LWC';ehst.userId = UserInfo.getUserId();ExceptionHandler.LogError('CreateInboundCase - Class',e.getMessage()+' - Line Number: '+e.getLineNumber(), 'Case Object : fetchCustomerDetails - Method', '', ehst);
        }
        return caseData;
    }
    /**
Author: Nitin Ghai
Company: Techmatrix
Description: It will fetch Category data
Inputs: Category Filter
Returns: List<Category__c>
**/
    @AuraEnabled
    public Static List<Category__c> fetchCategoryData(String queryFilter){
        List<Category__c> categoryData = new List<Category__c>();
        if(String.isNotBlank(queryFilter)){
            categoryData=[SELECT Name,Type__c,Id,Direct_Case_Closure__c FROM Category__c WHERE Active__c = true AND External_ID_Query__c=:queryFilter ORDER BY Name ASC];
        }
        return categoryData;
    }
    /**
Author: Nitin Ghai
Company: Techmatrix
Description: It will fetch users related to Dealer
Inputs: Dealer Record Id & Name
Returns: List<User>
**/
    @AuraEnabled
    public Static List<User> fetchCaseOwner(String dealerId,String userName){
        List<User> userRec = new List<User>();
        if(String.isNotBlank(dealerId) && String.isNotBlank(userName)){
            String searchString = '%' + userName + '%';
            userRec = [Select Name,Title,toLabel(Designation__c),ManagerId from User where Contact.AccountId=:dealerId AND Name LIKE: searchString AND isActive=true ];
        }
        return userRec;
    }
    /**
Author: Nitin Ghai
Company: Techmatrix
Description: It will fetch Enquiry Owner,Sales SPOC's & Accessories SPOC's
Inputs: Enquiry Id,Dealer Id & Business Area
Returns: Wrapper (Enquiry Owner & Sales,Accessories SPOC's)
**/
    @AuraEnabled
    public static enquiryDealerdata fetchenquiryDealerRec(String enquiryRecId,String dealerId,String businessArea){
        enquiryDealerdata enqDealer = new enquiryDealerdata();
        try{
            if(String.isNotBlank(businessArea) && (businessArea==ConstantsUtility.DEALER_INTERNAL_SALES || businessArea==ConstantsUtility.DEALER_INTERNAL_FINANCE)){
                if(String.isNotBlank(enquiryRecId)){
                    enqDealer.enquiryOwner=[Select Id,OwnerId FROM Opportunity where Id=:enquiryRecId AND Owner.isActive=true];
                }else if(String.isNotBlank(dealerId)){
                    enqDealer.dealerdata=[Select Sales_SPOC_1__c,Sales_SPOC_2__c,Sales_SPOC_3__c,Sales_SPOC_4__c,Sales_SPOC_5__c
                                          FROM Account where Id=:dealerId];
                }
            }else if(String.isNotBlank(businessArea) && String.isNotBlank(dealerId) && (businessArea==ConstantsUtility.DEALER_INTERNAL_ACCESSORIES || businessArea==ConstantsUtility.DEALER_INTERNAL_INSURANCE)){
                enqDealer.dealerdata=[Select Accessories_SPOC_1__c,Accessories_SPOC_2__c,Insurance_SPOC_1__c,Insurance_SPOC_2__c
                                      FROM Account where Id=:dealerId];
            }
        }catch(exception e) {ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();ehst.componentName = 'CreateDealerInboundCase - LWC';ehst.userId = UserInfo.getUserId();ExceptionHandler.LogError('CreateInboundCase - Class',e.getMessage()+' - Line Number: '+e.getLineNumber(), 'Case Object : fetchenquiryDealerRec - Method', '', ehst);}
        return enqDealer;
    }
    /**
Author: Nitin Ghai
Company: Techmatrix
Description: It will create the Case & Prepare the Hierarchy Structure for Inbound Calling
Inputs: Case JSON,Case RecordType Developer name & Primary Dealer QCM
Returns: BasicReturn
**/
    @AuraEnabled
    public Static BasicReturn updateCaseData(String caseJson,String primaryDealerQCM,String caseRecType){
        BasicReturn br=new BasicReturn();
        br.code=200;
        String caseRecordId;
        try{
            List<Account> userAccount = new List<Account>();
            Case caseData =String.isNotBlank(caseJson) ? (Case) JSON.deserialize(caseJson, Case.class) : NULL;
            if(caseData!=NULL && String.isNotBlank(caseData.OwnerId)){
                userAccount = [Select ID,User__c,User__r.ManagerId from Account WHERE RecordTypeId=:ConstantsUtility.USER_ACCOUNT_RECORDTYPE_ID AND User__c!=NULL AND User__c=:caseData.OwnerId AND User__r.isActive=true limit 1 ];
            }
            if(userAccount.size()>0){
                caseData.RecordTypeId=String.isNotBlank(caseRecType) ? Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(caseRecType).getRecordTypeId() : NULL;
                if(caseData.Status==ConstantsUtility.CASE_STATUS_NEW){
                    caseData.Inbound_Case_Hierarchy__c=createHierarchyStructure(caseData,userAccount[0],primaryDealerQCM);
                }
                caseData.Mobile_SFMC__c=String.isNotBlank(caseData.Mobile_Number__c) ? '91'+caseData.Mobile_Number__c : '';
                caseData.AccountId = userAccount[0].id;
                insert caseData;
                if(String.isNotBlank(caseData.Id) && String.isNotBlank(ConstantsUtility.TASK_DEALER_INBOUND_CALL)){
                    Task tk = new Task();
                    tk.RecordTypeId=ConstantsUtility.TASK_DEALER_INBOUND_CALL;
                    tk.Service_Type__c=String.isNotBlank(caseData.Case_Type__c) ? caseData.Case_Type__c : '';
                    tk.Case__c=caseData.Id;tk.WhatId=caseData.Id;tk.Type='T';
                    tk.Customer_Mobile__c=String.isNotBlank(caseData.Mobile_Number__c) ? caseData.Mobile_Number__c : '';
                    tk.Disposition__c=ConstantsUtility.DEALER_INTERNAL_CALL_DISPOSITION;
                    tk.Subject = ConstantsUtility.DEALER_INTERNAL_CALL_SUBJECT;
                    tk.Contact_ID__c=String.isNotBlank(caseData.Customer__c) ? caseData.Customer__c : NULL;
                    tk.OwnerId=userinfo.getuserid();
                    tk.Status = ConstantsUtility.DEALER_INTERNAL_CALL_STATUS;
                    insert tk;
                 }
                br.status='Success';
                br.createdId=String.isNotBlank(caseData.Id) ? caseData.Id : NULL;
            }else{
                br.status='Error';  
                br.message=label.Case_Owner_Check;
            }
        }catch(exception e) {ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();ehst.componentName = 'CreateDealerInboundCase - LWC';ehst.userId = UserInfo.getUserId();ExceptionHandler.LogError('CreateInboundCase - Class',e.getMessage()+' - Line Number: '+e.getLineNumber(), 'Case Object : updateCaseData - Method', '', ehst);br.code=001;br.message=e.getMessage();br.status='Error';  }
        return br;
    }
    /**
Author: Nitin Ghai
Company: Techmatrix
Description: It will Prepare the Hierarchy Structure for Inbound Calling
Inputs: Case object,User Account Id & Primary Dealer QCM
Returns: Hierarchy Structure
**/
    public static String createHierarchyStructure(Case caseData,Account userAccount,String primaryDealerQCM){
        Map<String,Set<Id>> teamMemberRoleUserId= new Map<String,Set<Id>>();
        Map<String,Set<Id>> userDealerMap= new Map<String,Set<Id>> ();
        Map<String,String> accountTeamRoleMap= new Map<String,String> ();
        Map<String,List<String>> levelUserIdMap= new Map<String,List<String>> ();
        String caseInboundHierarchy;
        try{

            //add caseowner user in list of member roles to check as managers may be spoc users
            if (caseData!=NULL && String.isNotBlank(caseData.OwnerId)){
                User loggedinUser = [Select Id,Designation__c from User where Id=:caseData.OwnerId];
                if(String.isNotBlank(loggedinUser.Designation__c)){
                    if(!teamMemberRoleUserId.containsKey(loggedinUser.Designation__c)){
                        teamMemberRoleUserId.put(loggedinUser.Designation__c,new Set<Id>{loggedinUser.Id} );
                    }else{
                        teamMemberRoleUserId.put(loggedinUser.Designation__c,new Set<Id>{loggedinUser.Id} );
                    }
                }    
            }


            if(caseData!=NULL && String.isNotBlank(caseData.Dealer_Name__c) && (caseData.Business_Area__c==ConstantsUtility.DEALER_INTERNAL_SERVICE_BODYSHOP || caseData.Business_Area__c==ConstantsUtility.DEALER_INTERNAL_SERVICE_WORKSHOP)){
                                                                                    for(User us :[Select Title,Designation__c,Id from User where AccountId=:caseData.Dealer_Name__c AND isActive=True AND Designation__c!=NULL]){
                                                                                        if(!userDealerMap.containsKey(us.Designation__c)){
                                                                                            userDealerMap.put(us.Designation__c,new Set<Id>{us.Id} );
                                                                                        }else{
                                                                                            userDealerMap.get(us.Designation__c).add(us.Id);
                                                                                        }
                                                                                    }
                                                                                }
            if(userAccount!=NULL && String.isNotBlank(userAccount.Id)){
                for(AccountTeamMember acctm :[Select UserId,TeamMemberrole,User.name,User.Designation__c,AccountId FROM 
                                              AccountTeamMember where AccountId =: userAccount.Id
                                             ]){
                                                 if(String.isNotBlank(acctm.User.Designation__c)){
                                                     if(!teamMemberRoleUserId.containsKey(acctm.User.Designation__c)){
                                                         teamMemberRoleUserId.put(acctm.User.Designation__c,new Set<Id
                                                                                  >{acctm.UserId} );
                                                     }else{
                                                         teamMemberRoleUserId.get(acctm.User.Designation__c).add(acctm.UserId);
                                                     }
                                                 }
                                             }
            }
            if(caseData!=NULL && String.isNotBlank(caseData.Business_Area__c) && String.isNotBlank(caseData.Case_Type__c)){
                for(Inbound_Case_Escalation__mdt inb : [Select MasterLabel,Business_Area__c,Case_Type__c,Designation__c,Escalation_Level__c,
                                                        Escalation_Mode__c FROM Inbound_Case_Escalation__mdt 
                                                        where Business_Area__c=:caseData.Business_Area__c AND Case_Type__c=:caseData.Case_Type__c]){
                                                            if(inb.Escalation_Mode__c==ConstantsUtility.DEALER_INTERNAL_CASE_OWNER){
                                                                levelUserIdMap.put(inb.Escalation_Level__c,new List<String> {caseData.OwnerId});
                                                            }else if(inb.Escalation_Mode__c==ConstantsUtility.DEALER_INTERNAL_PRIMARY_QCM && 
                                                                     String.isNotBlank(primaryDealerQCM)){
             
                                                                         levelUserIdMap.put(inb.Escalation_Level__c,new List<String> {primaryDealerQCM});
                                                            }else if(inb.Escalation_Mode__c==ConstantsUtility.DEALER_INTERNAL_PRIMARY_QCM_MANAGER){
                                                                List<String> userData= new List<String>();
                                                                if(String.isNotBlank(primaryDealerQCM)){
                                                                    userData.add(primaryDealerQCM);
                                                                }
                                                                if(String.isNotBlank(userAccount.User__r.ManagerId)){
                                                                    userData.add(userAccount.User__r.ManagerId);
                                                                }
                                                                if(userData.size()>0){
                                                                    levelUserIdMap.put(inb.Escalation_Level__c,userData);
                                                                }
                                                            }else if(inb.Escalation_Mode__c==ConstantsUtility.DEALER_INTERNAL_OWNER_DEALERSHIP){
                                                                levelUserIdMap.put(inb.Escalation_Level__c,new List<String> {caseData.OwnerId});
                                                                accountTeamRoleMap.put(inb.MasterLabel+'-'+inb.Escalation_Level__c+'-'+inb.Business_Area__c,'Dealership Users'+'-'+inb.Escalation_Level__c+'-'+inb.Designation__c);
                                                            }else if(inb.Escalation_Mode__c==ConstantsUtility.DEALER_INTERNAL_ACCOUNT_TEAM){
                                                                accountTeamRoleMap.put(inb.MasterLabel+'-'+inb.Escalation_Level__c+'-'+inb.Business_Area__c,inb.Escalation_Level__c+'-'+inb.Designation__c);
                                                            }
                                                        }
            }
            if(teamMemberRoleUserId.size()>0 && accountTeamRoleMap.size()>0){
                for(String dt : accountTeamRoleMap.values()){
                    List<String> level = dt.split('-');
                    if(String.isNotBlank(level[0]) && String.isNotBlank(level[1])){
                        if(level[0]=='Dealership Users' && level.size()==3 && String.isNotBlank(level[2])){
                            if(!levelUserIdMap.containsKey(level[1]) && String.valueOf(userDealerMap.get(level[2]))!=NULL){
                                levelUserIdMap.put(level[1],new List<String> {(String.valueOf(userDealerMap.get(level[2]))).replaceAll('[{}\\s+]','')});
                            }else if(String.valueOf(userDealerMap.get(level[2]))!=NULL){
                                levelUserIdMap.get(level[1]).add(String.valueOf(userDealerMap.get(level[2])).replaceAll('[{}\\s+]',''));
                            }
                        }else{
                            if(!levelUserIdMap.containsKey(level[0]) && String.valueOf(teamMemberRoleUserId.get(level[1]))!=NULL){
                                levelUserIdMap.put(level[0],new List<String> {(String.valueOf(teamMemberRoleUserId.get(level[1]))).replaceAll('[{}\\s+]','')});
                            }else if(String.valueOf(teamMemberRoleUserId.get(level[1]))!=NULL){
                                levelUserIdMap.get(level[0]).add(String.valueOf(teamMemberRoleUserId.get(level[1])).replaceAll('[{}\\s+]',''));
                            }
                        }
                    }
                }
            }
            if(levelUserIdMap.size()>0){
                caseInboundHierarchy = JSON.serialize(levelUserIdMap);
            }
        }catch(exception e) {ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();ehst.componentName = 'CreateDealerInboundCase - LWC';ehst.userId = UserInfo.getUserId();ExceptionHandler.LogError('CreateInboundCase - Class',e.getMessage()+' - Line Number: '+e.getLineNumber(), 'Case Object : createHierarchyStructure - Method', '', ehst);}
        return caseInboundHierarchy;
    }
    
    //Wrapper created to store Dealer & Enquiry data for OWner assignment in Sales/Accesories business Area
    public class enquiryDealerdata{
        @AuraEnabled
        public Account dealerdata;
        @AuraEnabled
        public Opportunity enquiryOwner;
        public enquiryDealerdata(){
            dealerdata = new Account();
            enquiryOwner = new Opportunity();
        }
    }
    
    //Wrapper created to store Customer,Dealer List datail,Enquiry & Record Type Metadata
    public class customerDealerRec{
        @AuraEnabled
        public Account customerdata;
        @AuraEnabled
        public List<Account> dealerOutletName;
        @AuraEnabled
        public Opportunity enquiryData;
        @AuraEnabled
        public List<Asset> registrationNumberList;
        @AuraEnabled
        public List<Case_Type_And_Case_RecordType_Matrix__mdt> caseRecMetadata;
        @AuraEnabled
        public String parentWorkhopCode;
        @AuraEnabled
        public String parentMiCode;
        @AuraEnabled
        public String agentDealerId;
        @AuraEnabled
        public String agentProfileName;
        @AuraEnabled
        public String loggedUserChannel;
        public customerDealerRec(){
            customerdata = new Account();
            dealerOutletName = new List<Account>();
            enquiryData = new Opportunity();
            caseRecMetadata = new List<Case_Type_And_Case_RecordType_Matrix__mdt>();
            parentWorkhopCode='';parentMiCode='';agentDealerId='';agentProfileName='';loggedUserChannel='';
        }
    }
}