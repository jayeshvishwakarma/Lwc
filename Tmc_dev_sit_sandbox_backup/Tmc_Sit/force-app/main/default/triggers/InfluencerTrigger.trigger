/**
* @File Name          : InfluencerTriggerHelper.cls
* @Description        : Trigger for Influencer 
* @Author             : Anuj Kumar
* @Group              : 
* @Last Modified By   : 
* @Last Modified On   : 
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    4/02/2020, 9:14:54 PM       Anuj Kumar                         Initial Version
**/
trigger InfluencerTrigger on Influencer__c (before insert,before update, after insert, after update) {
    new InfluencerTriggerHandler().run();
    
}