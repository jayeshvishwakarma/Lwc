/**
* @File Name          : CustomerProfileTrigger.trigger
* @Description        : Apex Trigger for Customer Profile
* @Author             : 
* @Group              : 
* @Last Modified By   : Prabhat Sharma
* @Last Modified On   : 19/08/2019, 12:12:16 AM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    13/08/2019, 03:14:54 PM      Prabhat Sharma         Initial Version
**/

trigger CustomerProfileTrigger on Customer_Profile__c (before insert,before update ,after update) {
     new CustomerProfileTriggerHandler().run();
}