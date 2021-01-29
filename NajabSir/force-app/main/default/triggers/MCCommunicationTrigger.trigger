/**
* @File Name          : MCCommunicationTrigger.cls
* @Description        : Trigger for MC Communication Object
* @Author             : 
* @Group              : 
* @Last Modified By   : Prabhat Sharma
* @Last Modified On   : 14/11/2019, 3:12:16 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    14/11/2019, 3:12:16 PM                               Initial Version 
**/
trigger MCCommunicationTrigger on MC_Communication__c (before Insert,after insert, after update) {
  new MCCommunicationTriggerHandler().run();
}