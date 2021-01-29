/**
* @File Name          : LeadTrigger.cls
* @Description        : Lead Trigger
* @Author             : Mahith Madwesh
* @Group              : 
* @Last Modified By   : Shaikh Mufiz
* @Last Modified On   : 29/10/2020
* @Modification Log   : aCRM script lead convert
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0         17/01/2020               Mahith Madwesh         Initial Version
*/
trigger LeadTrigger on Lead (after insert, before update, after update) {
    new LeadTriggerHandler().run();
}