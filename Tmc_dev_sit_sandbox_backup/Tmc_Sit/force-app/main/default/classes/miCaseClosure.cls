/**
* @File Name          : miCaseClosure.cls
* @Description        : 
* @Author             : Nitin Ghai
* @Group              : 
* @Last Modified By   : Nitin Ghai
* @Last Modified On   : 13-10-2020
* @Modification Log   : 
**/
public class miCaseClosure {
    @AuraEnabled
    public static Case fetchCaseRecord(String recordId){
        Case caseData = new Case();
        if(String.isNotBlank(recordId)){
            caseData=[Select Id,Mode_of_Delivery__c,Date_of_Delivery__c,Tracking_Number__c,Courier_Company__c,Hand_Delivered__c,Customer_Intimated__c,Endorsement_Type__c,
                      Endorsement_Status__c,Documents_Pending__c,Endorsement_Date__c,Endorsement_Sent__c,NCB_Sent_Date__c,Claim_Final_Status__c,Claim_Not_Honoured_Reason__c,
                      Policy_Renewal_Status__c,Reason_for_non_renewal__c,MI_Renewal_Remarks__c,Refund_Date__c,Refund_Amount__c,Bank_Reference_No__c,Primary_Category__c,isClosed,
                      Secondary_Category__c,Case_Type__c FROM Case where Id=:recordId];
        }
        return caseData;
    }
}