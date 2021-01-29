/**
* @File Name          : EmailMessageTrigger
* @Description        : Trigger for EmailMessage 
* @Author             : 
* @Group              : 
* @Last Modified By   : Gitika K
* @Last Modified On   : 7/17/2020, 11:26:51 AM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    7/17/2020, 11:26:51 AM                                Initial Version

**/
trigger EmailMessageTrigger on EmailMessage (after insert) {   
    new EmailMessageTriggerHandler().run();   
}