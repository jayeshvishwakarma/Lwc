/**
* @File Name          : CaseActionsTrigger
* @Description        : Trigger for Case Actions
* @Group              :
* @Last Modified By   : 
* @Last Modified On   : 04/03/2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    7/05/2019, 9:14:54 PM                         Initial Version
**/
trigger CaseActionsTrigger on Case_Actions__c (after insert,before insert,before update,after update) {
	new CaseActionsTriggerHandler().run();
}