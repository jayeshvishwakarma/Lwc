/**
* @File Name          : SurveyTakerCTITrigger
* @Description        : Trigger for Survey_Taker_CTI__c
* @Author             : Saloni Gupta
* @Group              :
* @Last Modified By   :
* @Last Modified On   : 26/11/2020
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        26/11/2020                Saloni               Initial Version
**/
trigger SurveyTakerCTITrigger on Survey_Taker_CTI__c (before insert,before update,after insert,after update) {
    new SurveyTakerCTITriggerHandler().run();
}