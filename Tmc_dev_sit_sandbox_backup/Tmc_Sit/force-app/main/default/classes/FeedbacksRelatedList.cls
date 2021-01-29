/*------------------------------------------------------------------------------------
Author:        Nitin Ghai
Description:   FeedbacksRelatedList

History
Date            Author                  Comments
--------------------------------------------------------------------------------------
16-04-2020      Nitin Ghai              This class is used in FeedbacksRelatedList LWC
                                        to show the Feedbacks created for a Customer
------------------------------------------------------------------------------------*/
public with sharing class FeedbacksRelatedList {
    @AuraEnabled
    public Static List<SurveyTaker__c> getFeedbacks(String customerID){
        List<SurveyTaker__c> feedback = new List<SurveyTaker__c>();
        try{
            User userRecords = createAppointment.getCurrentUser();
            system.debug('userRecords--->'+userRecords.Dealer_Account__c);
            feedback = [Select Id,Name from SurveyTaker__c WHERE Customer__c=:customerId AND Dealer__c=:userRecords.Dealer_Account__c];
        }catch(exception e){
            ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace();ehst.componentName='FeedbacksRelatedList';ehst.userId=UserInfo.getUserId();
            ExceptionHandler.LogError('FeedbacksRelatedList', e.getMessage(), 'getFeedbacks', '', ehst);
        }
        return feedback;
    }
}