/**
* @File Name          : SurveyResponseTriggerHelper
* @Description        : Trigger handler for response field value populate in responsetext field.
* @Author             : Najab Maghribi
* @Group              :
* @Last Modified By   :
* @Last Modified On   : 21-October-2020
* @Modification Log   :
*======================================================================================================
* Ver            Date                           Author                      Modification
*======================================================================================================
* 1.0        21-October-2020                 Najab Maghribi               Initial Version
**/

public class SurveyResponseTriggerHelper extends TriggerHandler{
    private list<Survey_Response_CTI__c> surveyResponseList; // Used to store the list of new User
    private Map<Id, User> oldUserMap; // Used to store Map of old User
    public SurveyResponseTriggerHelper() {
        this.surveyResponseList= (list<Survey_Response_CTI__c>) Trigger.new;
    }

    public override void beforeInsert() {
        assignSurveyResponse();
    }

    public override void beforeUpdate() {
        assignSurveyResponse();
    }

    // Populate SurveyResponseCTI Response field value in ResponseText field.
    public void assignSurveyResponse(){
        if(surveyResponseList.size() > 0 ){
            for(Survey_Response_CTI__c surveyResponseRec: surveyResponseList){
                 if(string.isNotBlank(surveyResponseRec.Response__c) && surveyResponseRec.Response__c.length() <= 255){
                    surveyResponseRec.ResponseText__c = surveyResponseRec.Response__c;
                 }else{
                     surveyResponseRec.ResponseText__c = '';
                 }
            }
        }
    }
}