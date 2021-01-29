/**
 * @File Name          : AdHocCampaignScriptController.cls
 * @Description        : to return survey url from custom setting based on name of the survey passed from component
 * @Author             : Rajesh Ramachandran
 * @Group              : 
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 4/24/2020, 12:15:49 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/23/2020   Rajesh Ramachandran     Initial Version
**/
public without sharing class AdHocCampaignScriptController {
   
    @AuraEnabled(cacheable=true)
    public static string getSurveyUrl(String surveyname){
                
        if (surveyname != null && surveyname != ''){
            List<Script_Survey_URl__mdt> lsSurveyUrls= [select DeveloperName,Survey_URL__c from Script_Survey_URl__mdt where DeveloperName = :surveyname limit 1];
            if(lsSurveyUrls != null && lsSurveyUrls.size() > 0){
                return lsSurveyUrls[0].survey_url__c;
            }
            else {
                return '';
            }
            
        }
        else {
            return '';
        }
    }
}