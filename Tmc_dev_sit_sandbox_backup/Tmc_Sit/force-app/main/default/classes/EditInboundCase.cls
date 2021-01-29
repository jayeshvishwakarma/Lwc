/**
* @File Name          : EditInboundCase.cls
* @Description        : This class is used in both editDealerInboundCase & transferDealerInboundCase LWC
* @Author             : Nitin Ghai
* @Group              : 
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 10-13-2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author      		      Modification
*==============================================================================
* 1.0    25/08/2020, 11:02:00 AM        Nitin Ghai                 Initial Version
* 1.1    03/09/20202 11:02:00 AM        Nitin Ghai                 Added User Query to fetch Manager Id in fetchCaseData method
* 1.2    18/09/2020, 11:02:00 AM
**/
public without sharing class EditInboundCase {
    /**
Author: Nitin Ghai
Company: Techmatrix
Description: It will pull Case & Category related information
Inputs: Case Record Id
Returns: Wrapper(caseRelatedData)
**/
    @AuraEnabled
    public static caseRelatedData fetchCaseData(String caseId, String sourceObject, String workshopCodeData, String miCodeData){
        caseRelatedData caseInfo = new caseRelatedData();
        String CategoryFilter='';String PrimaryCategory='';
        List<String> categoryRecords = new List<String>();
        
        try{
            if(String.isNotBlank(caseId)){
                caseInfo.caseData= [Select Id,Business_Area__c,Case_Type__c,OwnerId,Owner.Name,Primary_Dealer_QCM__c,Dealer_Name__c,
                                    Primary_Category__c,Primary_Category_ID__c,Secondary_Category__c,Secondary_Category_ID__c,
                                    Tertiary_Category__c,Tertiary_Category_ID__c,Channel__c,Case_Stage__c,isClosed,
                                    RecordTypeId,Status,Dealer_Internal_Repeat__C,Dealer_Name__r.Name 
                                    FROM Case where Id=:caseId];
                if(caseInfo.caseData.size()>0){
                    caseInfo.userRec=[Select Id,ManagerId from User where Id=:caseInfo.caseData[0].OwnerId AND isActive=True];
                    if(String.isNotBlank(caseInfo.caseData[0].Channel__c)){
                        CategoryFilter=caseInfo.caseData[0].Channel__c;
                    }
                    if(String.isNotBlank(caseInfo.caseData[0].Case_Type__c)){
                        CategoryFilter+= '_' + caseInfo.caseData[0].Case_Type__c;
                    }
                    if(String.isNotBlank(caseInfo.caseData[0].Business_Area__c)){
                        CategoryFilter+= '_' + caseInfo.caseData[0].Business_Area__c;
                    }
                    if(String.isNotBlank(caseInfo.caseData[0].Case_Stage__c)){
                        CategoryFilter+= '_' + caseInfo.caseData[0].Case_Stage__c;
                    }
                    if(String.isNotBlank(CategoryFilter)){
                        categoryRecords.add(CategoryFilter+ '_' + ConstantsUtility.DEALER_INTERNAL_PRIMARY);
                        caseInfo.categoryFilterData=CategoryFilter;
                    }
                    if(String.isNotBlank(CategoryFilter) && String.isNotBlank(caseInfo.caseData[0].Primary_Category_ID__c)){
                        categoryRecords.add(categoryFilter+'_' + ConstantsUtility.DEALER_INTERNAL_SECONDARY + '_' +caseInfo.caseData[0].Primary_Category_ID__c);
                    }
                    if(String.isNotBlank(CategoryFilter) && String.isNotBlank(caseInfo.caseData[0].Secondary_Category_ID__c)){
                        categoryRecords.add(categoryFilter+'_' + ConstantsUtility.DEALER_INTERNAL_TERTIARY + '_' + caseInfo.caseData[0].Primary_Category_ID__c + '_' + caseInfo.caseData[0].Secondary_Category_ID__c);
                    }
                    if(categoryRecords.size()>0){
                        caseInfo.categoryData=[SELECT Name,Type__c,Id,Direct_Case_Closure__c FROM Category__c WHERE Active__c = true AND External_ID_Query__c IN: categoryRecords ORDER BY Name ASC];
                    }
                    if(String.isNotBlank(sourceObject) && sourceObject==ConstantsUtility.DEALER_INTERNAL_TRANSFER_CMP && (String.isNotBlank(workshopCodeData) || String.isNotBlank(miCodeData))){
                        caseInfo.parentWorshopCodeMicodeDealers=fetchBusinessAreaWorkshop(workshopCodeData,miCodeData);
                    }
                }
            }
        }catch(exception e){ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();ehst.componentName = 'EditDealerInboundCase - LWC';ehst.userId = UserInfo.getUserId();ExceptionHandler.LogError('EditInboundCase - Class',e.getMessage()+' - Line Number: '+e.getLineNumber(), 'Case Object : fetchCaseData - Method', '', ehst);
        }
        return caseInfo;
    }
    
     /**
    Author: Nitin Ghai
    Company: Techmatrix
    Description: It will fetch Dealership records
    Inputs: Parent Workshop Code & Parent MI Code
    Returns: List<Account>
    **/
    public static List<Account> fetchBusinessAreaWorkshop(String workshopCode,String miCode){
        List<Account> dealerData = new List<Account>();
        try{
            if(String.isNotBlank(workshopCode) || String.isNotBlank(miCode)){
                dealerData=[Select Id,Parent_Workshop_Code__c,Parent_MI_Code__c,Dealer_Address_F__c,Name,Dealer_Map_Code__c,For_Code__c,For_Code__r.Name,
                            Sales_SPOC_1__c,Sales_SPOC_2__c,Sales_SPOC_3__c,Sales_SPOC_4__c,Sales_SPOC_5__c,Accessories_SPOC_1__c,Accessories_SPOC_2__c,
                            Insurance_SPOC_1__c,Insurance_SPOC_2__c,Region_Code__c,Dealer_Type__c,Dealer_Code__c,Primary_Dealer_QCM__c,Service_CCM__c FROM Account 
                            where (Parent_Workshop_Code__c=:workshopCode OR Parent_MI_Code__c=:miCode) AND recordtypeid = :ConstantsUtility.DEALER_ACCOUNT_RECORDTYPE_ID];
            }
        }catch(exception e){ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();ehst.componentName = 'EditDealerInboundCase & TransferDealerInboundCase - LWC';ehst.userId = UserInfo.getUserId();ExceptionHandler.LogError('EditInboundCase - Class',e.getMessage()+' - Line Number: '+e.getLineNumber(), 'Case Object : fetchBusinessAreaWorkshop - Method', '', ehst);
        }
        return dealerData;
    }
    
    /**
    Author: Nitin Ghai
    Company: Techmatrix
    Description: It will pull Inbound Case Hierarchy Structure
    Inputs: caseData - Case Object
    Returns: String
    **/
    public static String fetchCaseHierarchy(Case caseData, Account acc){
        String caseHierStructure;
        try{
            if(caseData!=NULL && acc!=NULL){
                caseHierStructure=CreateInboundCase.createHierarchyStructure(caseData,acc,caseData.Primary_Dealer_QCM__c);
            }
        }catch(exception e){
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();ehst.componentName = 'EditDealerInboundCase & TransferDealerInboundCase - LWC';ehst.userId = UserInfo.getUserId();ExceptionHandler.LogError('EditInboundCase - Class',e.getMessage()+' - Line Number: '+e.getLineNumber(), 'Case Object : fetchCaseHierarchy - Method', '', ehst);
        }
        return caseHierStructure;
    }
    /**
Author: Nitin Ghai
Company: Techmatrix
Description: It will update the Case data & will prepare the Case hierarchy Structure(Edit Case Scenario)
Inputs: Case JSON
Returns: BasicReturn
**/
    @AuraEnabled
    public static BasicReturn updateCaseData(String caseJson,String previousCaseOwner,Boolean miCaseClosure){
        BasicReturn br=new BasicReturn();
        try{
            List<Account> userAcc = new List<Account>();
            Case caseData =String.isNotBlank(caseJson) ? (Case) JSON.deserialize(caseJson, Case.class) : NULL;
            if(caseData!=NULL && String.isNotBlank(caseData.OwnerId)){
                userAcc = [Select ID,User__c,User__r.ManagerId from Account WHERE RecordTypeId=:ConstantsUtility.USER_ACCOUNT_RECORDTYPE_ID AND User__c!=NULL AND User__c=:caseData.OwnerId AND User__r.isActive=true];
                if(userAcc.size()>0){
                    if(miCaseClosure==true){
                        caseData.Status='Closed';
                    }
                    if(caseData.Status!='Closed' && String.isNotBlank(previousCaseOwner) && previousCaseOwner!=caseData.OwnerId){
                        caseData.Inbound_Case_Hierarchy__c=fetchCaseHierarchy(caseData,userAcc[0]);
                    }
                    CaseStatusUtility.skipInternalCaseStatusUpdate=true;                    
                    update caseData;
                    CaseStatusUtility.skipInternalCaseStatusUpdate=false;
                    br.status='Success';
                }else{
                    br.message=ConstantsUtility.DEALER_INTERNAL_ACCOUNT_TEAM_MISSING;
                    br.status='Error';
                }
            }else{
                br.status='Error';
                br.message=label.UI_Error_Message;
            }
        }catch(exception e){br.status='Error';br.message=e.getMessage();ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();ehst.componentName = 'EditDealerInboundCase - LWC';ehst.userId = UserInfo.getUserId();ExceptionHandler.LogError('EditInboundCase - Class',e.getMessage()+' - Line Number: '+e.getLineNumber(), 'Case Object : updateCaseData - Method', '', ehst);}
        return br;
    }
    /**
    Author: Nitin Ghai
    Company: Techmatrix
    Description: It will create the Case Action record for Transfer functionality and will submit the Case Action record for approval(Case Transfer Scenario)
    Inputs: Case JSON
    Returns: String
    **/
    @AuraEnabled
    public static BasicReturn createCaseActionRecord(String recordJson,String caseActionDealerQCM,String transferDealerOwner,String dealerName,String parentCaseBusinessArea){
        BasicReturn br=new BasicReturn();
        try{
            List<Account> acc = new List<Account>();
            set<id> recordIds = new set<id>(); // set to store case ids
            Case_Actions__c caseActionData =String.isNotBlank(recordJson) ? (Case_Actions__c) JSON.deserialize(recordJson, Case_Actions__c.class) : NULL;
            if(caseActionData!=NULL){
                if(String.isNotBlank(caseActionData.Dealer_Name__c) && 
                   (caseActionData.Business_Area__c==ConstantsUtility.DEALER_INTERNAL_SERVICE_BODYSHOP || caseActionData.Business_Area__c==ConstantsUtility.DEALER_INTERNAL_SERVICE_WORKSHOP)){
                       List<User> us = [Select Id from User where AccountId=:caseActionData.Dealer_Name__c AND Profile.Name=:ConstantsUtility.DEALER_INTERNAL_MANAGER_PROFILE AND isActive=True LIMIT 1];
                       if(us.size()>0){
                           caseActionData.Transferred_Dealer_Case_Owner__c=us[0].Id;
                           caseActionData.Transferred_Dealer_Approver__c=us[0].Id;
                       }
                   }else{
                       caseActionData.Transferred_Dealer_Case_Owner__c = String.isNotBlank(transferDealerOwner) ? transferDealerOwner : Null;
                   }
                if(String.isNotBlank(caseActionData.Transferred_Dealer_Case_Owner__c)){
                    Case caseData = (Case) JSON.deserialize(recordJson, Case.class);
                    caseActionData.Inbound_Case_Hierarchy__c=fetchTransferCaseHierarchy(caseData,caseActionDealerQCM,caseActionData.Transferred_Dealer_Case_Owner__c);
                    caseActionData.RecordTypeId=String.isNotBlank(ConstantsUtility.DEALER_INTERNAL_CASE_TRANSFER) ? ConstantsUtility.DEALER_INTERNAL_CASE_TRANSFER : null;
                    if(String.isNotblank(caseActionDealerQCM) && (caseActionData.Business_Area__c==ConstantsUtility.DEALER_INTERNAL_SALES || caseActionData.Business_Area__c==ConstantsUtility.DEALER_INTERNAL_ACCESSORIES || 
                                                                  caseActionData.Business_Area__c==ConstantsUtility.DEALER_INTERNAL_FINANCE)){
                                                                      caseActionData.Transferred_Dealer_Approver__c=caseActionDealerQCM;
                                                                  }
                    else if(caseActionData.Business_Area__c==ConstantsUtility.DEALER_INTERNAL_INSURANCE && String.isNotBlank(caseActionData.Dealer_Name__c)){
                        List<User> usdata = [Select Id from User where AccountId=:caseActionData.Dealer_Name__c AND Profile.Name=:ConstantsUtility.DEALER_INTERNAL_INSURANCE_MANAGER_PROFILE AND isActive=True LIMIT 1];
                        if(usdata.size()>0){
                            caseActionData.Transferred_Dealer_Approver__c=usdata[0].Id;
                        }
                    }
                    if(caseActionData!=NULL && String.isNotBlank(caseActionData.Transferred_Dealer_Approver__c)){
                        insert caseActionData;
                        if(String.isNotBlank(caseActionData.Id)){
                            recordIds.add(caseActionData.Id);
                            if(String.isNotBlank(parentCaseBusinessArea) && parentCaseBusinessArea==ConstantsUtility.DEALER_INTERNAL_INSURANCE){
                                ApprovalRequestService.initiateApprovalRequests(recordIds,ConstantsUtility.DEALER_INTERNAL_CASE_TRANSFER_APPROVAL_MI); 
                            }else{
                            ApprovalRequestService.initiateApprovalRequests(recordIds,ConstantsUtility.DEALER_INTERNAL_CASE_TRANSFER_APPROVAL);
                            }
                            br.status='Success';
                        }
                    }else{
                        br.status='Error';
                        br.message=dealerName+' '+ConstantsUtility.DEALER_INTERNAL_L2_SPOC;
                    }
                }else{
                    br.status='Error';
                    br.message='Service SPOC is missing in '+dealerName+'. Please contact support team.';
                }
            }else{
                br.status='Error';
                br.message=label.UI_Error_Message;
            }
        }catch(exception e){br.status='Error';br.message=e.getMessage();ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();ehst.componentName = 'transferDealerInboundCase - LWC';ehst.userId = UserInfo.getUserId();ExceptionHandler.LogError('EditInboundCase - Class',e.getMessage()+' - Line Number: '+e.getLineNumber(), 'Case Object : createCaseActionRecord - Method', '', ehst);
        }
        return br;
    }
    
    /**
    Author: Nitin Ghai
    Company: Techmatrix
    Description: It will pull Inbound Case Hierarchy Structure for Case Action transfer request
    Inputs: caseData - Case Object, Dealer QCM & Owner
    Returns: String
    **/
    public static String fetchTransferCaseHierarchy(Case caseData, String dealerQCM, String childCaseOWner){
        String caseHierStructure;
        try{
            if(caseData!=NULL && String.isNotBlank(childCaseOWner)){
                caseData.OwnerId=childCaseOWner;
                List<Account> acc = new List<Account>();
                acc = [Select ID,User__c,User__r.ManagerId from Account WHERE RecordTypeId =:ConstantsUtility.USER_ACCOUNT_RECORDTYPE_ID AND User__c!=NULL AND User__c=:childCaseOWner AND User__r.isActive=true];
                if(acc.size()>0){
                    caseHierStructure=CreateInboundCase.createHierarchyStructure(caseData,acc[0],dealerQCM);
                }
            }
        }catch(exception e){ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();ehst.componentName = 'EditDealerInboundCase & TransferDealerInboundCase - LWC';ehst.userId = UserInfo.getUserId();ExceptionHandler.LogError('EditInboundCase - Class',e.getMessage()+' - Line Number: '+e.getLineNumber(), 'Case Object : fetchCaseHierarchy - Method', '', ehst);
        }
        return caseHierStructure;
    }
    
    public class caseRelatedData{
        @AuraEnabled
        public List<Case> caseData;
        @AuraEnabled
        public String categoryFilterData;
        @AuraEnabled 
        public List<Category__c> categoryData;
        @AuraEnabled 
        public List<User> userRec;
        @AuraEnabled
        public List<Account> parentWorshopCodeMicodeDealers;
        public caseRelatedData(){
            caseData= new List<Case>();
            categoryFilterData='';
            categoryData=new List<Category__c>();
            userRec=new List<User>();
            parentWorshopCodeMicodeDealers=new List<Account>();
        }
    }
}