/**
* @File Name          : ComplaintCoordinatorTrigger
* @Description        : Trigger for Complaint Coordinator object
* @Author             : Deepak Kumar 
* @Group              :
* @Last Modified By   :
* @Last Modified On   : 14/07/2020
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    14/07/2020                       Initial Version
**/
trigger ComplaintCoordinatorTrigger on Complaint_Coordinator__c (before insert, before update, after insert, after update) {
    new ComplaintCoordinatorTriggerHandler().run();
}