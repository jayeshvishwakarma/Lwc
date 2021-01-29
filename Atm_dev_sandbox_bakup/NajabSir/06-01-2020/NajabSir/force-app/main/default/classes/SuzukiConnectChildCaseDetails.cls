/**
* @File Name          : fetchTaskDetails.cls
* @Description        : 
* @Author             : Nitin Ghai
* @Group              : 
* @Last Modified By   : 
* @Last Modified On   : 
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    11/08/2020, 11:02:00 AM        Nitin Ghai                 Initial Version
**/
public class SuzukiConnectChildCaseDetails {
    
    @AuraEnabled
    public static fetchParentCaseTaskData getCaseData(String recordId){
        system.debug('recordId----->'+recordId);
        fetchParentCaseTaskData csData = new fetchParentCaseTaskData();
        csData.taskData=[Select Id,Disposition_Detail__c,Wrap_Up_Code__c,LastModifiedDate from Task where 
                         WhatId=:recordId 
                         AND RecordTypeId=:ConstantsUtility.TASK_QUERY_COMPLAINTS_CALL_DECOMPOSITIONS_RECORD_TYPE_ID 
                         ORDER BY LastModifiedDate DESC LIMIT 1];
        csData.parentCaseData=[Select Id,Status,Job_Status__c,Channel__c,Business_Area__c,Customer__c,First_Name__c,Middle_Name__c,Last_Name__c,Mobile_Number__c,Email__c,
                               Case_Stage__c,Case_Type__c,Subject,Dealer_Name__c,Description,Outlet_Type__c,RecordTypeId,City__c,Primary_Category__c,RecordType.DeveloperName,
                               IMEI_No__c,Sim_No__c,TCU_Expiry_Date__c,TCU_Sale_Date__c,TCU_Customer_Name__c,VIN_No__c,Odometer_Reading__c,Customer_Address__c,Model__c,Pin_Code__c,
                               TCU_Dealer_Code__c,TCU_Dealer_Name__c,Service_Activation_Date__c,TCU_Service_Status__c,TCU_Dealer_Address__c,OwnerId,Origin,Mode__c,FCR_Conducted__c,
                               Customer_Satisfied_With_FCR__c,NCH_Docket_Number__c,Preferred_Mode_Of_Communication__c,Top_Management_Executive__c,Additional_Information__c,
                               Enquiry__c,Booking_No__c,Invoice_No__c,Variant__c,Color__c,Vehicle_Registration_Number__c,For_Code__c,Dealer_Code__c,Dealer_Address__c,Region_Code__c,
                               Dealer_Type__c,Dealer_City__c FROM Case where Id=:recordId];
        csData.dealerSelectionMatrices=[SELECT Id,Outlet_Type__c,Dealer_Type__c,Dealer_Category__c,Dealer_Channel__c FROM Dealer_Selection_Matrix__c];
        return csData;
    }
    
    public static void saveChildCase(String caseJSON){
        
    }
    
    
    public class fetchParentCaseTaskData{
        @AuraEnabled public Case parentCaseData;
        @AuraEnabled public List<task> taskData;
        @AuraEnabled public List<Dealer_Selection_Matrix__c> dealerSelectionMatrices;
        
        public fetchParentCaseTaskData(){
            parentCaseData = new Case();taskData= taskData=new List<Task>();dealerSelectionMatrices = new List<Dealer_Selection_Matrix__c>(); 
        }
    }    
    
}