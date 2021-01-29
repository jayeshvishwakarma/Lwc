/**
* @File Name          : CaseTrigger
* @Description        : Trigger for case
* @Author             : Nishant Prajapati
* @Group              : 
* @Last Modified By   : 
* @Last Modified On   : 04/03/2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    7/05/2019, 9:14:54 PM         Nishant                Initial Version
* 2.0   03/04/2020, 6:15:00 PM         Nitin                  Added after Insert event
**/  
trigger CaseTrigger on Case (before insert,after Insert,before update,after update,before delete ) {
  // new CaseTriggerHandler().run();
   new CaseTriggerHandler_Strategy().run();
   

}