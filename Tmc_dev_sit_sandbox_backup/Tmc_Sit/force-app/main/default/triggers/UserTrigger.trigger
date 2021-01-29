/**
* @File Name          : userTrigger
* @Description        : Trigger for User
* @Author             : Nishant Prajapati
* @Group              : 
* @Last Modified By   : 
* @Last Modified On   : 1/10/2019
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        1/10/2019                 Nishant               Initial Version
**/
trigger UserTrigger on User (before insert, before update, after insert, after update) {
    new UserTriggerHandler().run(); 
}