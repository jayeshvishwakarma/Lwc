/**
* @File Name          : SurveyQuestionResponseTrigger.trigger
* @Description        : Apex Trigger for Survey Question Response
* @Author             : 
* @Group              : 
* @Last Modified By   : Prabhat Sharma
* @Last Modified On   : 17/10/2019, 12:12:16 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    17/10/2019, 03:14:54 PM      Prabhat Sharma         Initial Version
**/

trigger SurveyQuestionResponseTrigger on SurveyQuestionResponse__c (after insert) {
   new SurveyResponseTriggerHandler().run();
}