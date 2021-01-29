/**
* @File Name          : SurveyResponseTrigger
* @Description        : Trigger for response field value populate in responsetext field.
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

trigger SurveyResponseTrigger on Survey_Response_CTI__c (before insert, before update) {
    new SurveyResponseTriggerHelper().run(); 
}