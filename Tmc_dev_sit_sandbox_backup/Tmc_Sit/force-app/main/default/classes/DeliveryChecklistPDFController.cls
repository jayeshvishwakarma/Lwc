/* 
* @File Name          : DeliveryChecklistPDFController.cls
* @Description        : Apex class to show delivery checklist details on a PDF
* @Author             : 
* @Group              : 
* @Last Modified By   : Prabhat Sharma
* @Last Modified On   : 9/16/2019, 01:05:33 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0     9/16/2019, 01:05:33 PM      Prabhat Sharma             Initial Version
**/

public class DeliveryChecklistPDFController {
    public list<SurveyQuestionResponse__c> surveyQuestionResponseList{get;set;}
    public string CustomerName{get;set;}
    public String OwnerName{get;set;}
    public string ownerPhone{get;set;}
    public string ownerEmail{get;set;}
    public string invoiceNumber{get;set;}
    public date invoiceDate{get;set;}
    public string dealerName{get;set;}
    
    public String userChannel {get;set;}
    
    public DeliveryChecklistPDFController(){
    
    
        userChannel = [SELECT Id,Channel__c FROM User WHERE Id=:UserInfo.getUserId()].Channel__c;
        
        // ConstantsUtility.COMMERCIAL_LINEOFBUSINESS
        String surveyName = (userChannel == ConstantsUtility.COMMERCIAL_LINEOFBUSINESS) ? label.Commercial_Delivery_Checklist : label.DeliveryChecklistSurvey;
        
        surveyQuestionResponseList = new list<SurveyQuestionResponse__c>();
        string enquiryId = ApexPages.currentPage().getParameters().get('id');
        if(string.isNotBlank(enquiryId)){
            list<SurveyTaker__c> surveytakerlist = new list<SurveyTaker__c>([Select Enquiry__c,Enquiry__r.First_Name__c,Enquiry__r.Last_Name__c,
                                                                             Enquiry__r.Owner.Name,Enquiry__r.Owner.Phone,
                                                                             Enquiry__r.Owner.email,Enquiry__r.Invoice_Number__c,
                                                                             Enquiry__r.Invoice_Date__c,Enquiry__r.Dealership__r.name,
                                                                             (select Remarks__c,Date_Expected__c,response__c,Survey_Question__r.Question__c,
                                                                              Survey_Question__r.OrderNumber__c 
                                                                              from Survey_Question_Answers__r
                                                                              where Survey_Question__r.Survey__r.Name =: surveyName
                                                                              ORDER BY Survey_Question__r.OrderNumber__c ASC)
                                                                              from SurveyTaker__c
                                                                              where Enquiry__c=:enquiryId]);
            if(surveytakerlist.size()>0){
                for(SurveyTaker__c stclist : surveytakerlist){
                    CustomerName = stclist.Enquiry__r.First_Name__c+' '+stclist.Enquiry__r.Last_Name__c;
                    OwnerName = stclist.Enquiry__r.Owner.Name;
                    ownerPhone = stclist.Enquiry__r.Owner.Phone;
                    ownerEmail = stclist.Enquiry__r.Owner.email;
                    invoiceNumber = stclist.Enquiry__r.Invoice_Number__c;
                    invoiceDate = stclist.Enquiry__r.Invoice_Date__c;
                    dealerName = stclist.Enquiry__r.Dealership__r.name;
                    for(SurveyQuestionResponse__c sc : stclist.Survey_Question_Answers__r){
                        surveyQuestionResponseList.add(sc);
                     }
                }
            }
        }
    }
}