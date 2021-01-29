/**
* @File Name          : AgentWorkTrigger
* @Description        : Trigger for AgentWork
* @Group              :
* @Last Modified By   : 
* @Last Modified On   : 
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    27/08/2020                  Anas Yar Khan                        Initial Version
**/
trigger AgentWorkTrigger on AgentWork (after insert,after update) {
	new AgentWorkTriggerHandler().run();
}