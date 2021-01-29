/**
* @File Name          : OpportunityTriggerHandler.cls
* @Description        : Trigger handler class for Opportuntiy (Enquiry)
* @Author             :
* @Group              :
* @Last Modified By   : Prabhat Sharma
* @Last Modified On   : 7/30/2019, 04:43:33 PM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    7/05/2019, 9:14:54 PM                                Initial Version
**/

trigger OpportunityTrigger on opportunity (before insert,before update, after insert, after update) {
   //   new OpportunityTriggerHandler().run();
      new OpportunityTriggerHandler_Strategy().run();
}