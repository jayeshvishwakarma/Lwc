/**
* @File Name          : CategoryTrigger
* @Description        : Trigger for Category Master object
* @Author             : 
* @Group              : 
* @Last Modified By   : 
* @Last Modified On   : 04/06/2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    04/06/2020, 9:14:54 PM                         Initial Version
**/
trigger CategoryTrigger on Category__c (before insert,before update) {
    new CategoryTriggerHandler().run();
}