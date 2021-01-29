/**
* @File Name          : CorporateGroupTrigger.cls
* @Description        : Trigger to perform many automation process base on requirement
* @Author             : 
* @Group              : 
* @Last Modified By   : Brijesh Singh
* @Last Modified On   : 11th Aug 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    11/08/2020, 9:14:54 PM                                Initial Version
**/

trigger CorporateGroupTrigger on Corporate_Group__c (before insert, before update) {
    for(Corporate_Group__c copObj : Trigger.New){
        //condition for before trigger event
        if(Trigger.isBefore){
            if(!copObj.Active__c && (Trigger.isInsert || Trigger.isUpdate && copObj.Active__c != Trigger.oldMap.get(copObj.Id).Active__c)){
                copObj.Inactive_Date__c = System.today();
            } 
        }
        
    }
}