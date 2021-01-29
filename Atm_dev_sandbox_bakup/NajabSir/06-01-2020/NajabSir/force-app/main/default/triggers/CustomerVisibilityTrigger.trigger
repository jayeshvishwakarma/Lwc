trigger CustomerVisibilityTrigger on Customer_Visibility__c (before insert) {
    
    if(Trigger.isInsert){
      Bypass_Setting__c oBypassSettings=Bypass_Setting__c.getInstance(UserInfo.getUserId());
      boolean bIsRunTrigger=true;
      if(oBypassSettings!=null && oBypassSettings.bypass_Triggers__c!=null &&
                                         oBypassSettings.bypass_Triggers__c.contains('CustomerVisibilityTrigger'))
            bIsRunTrigger=false;
     if(bIsRunTrigger)   
      new CustomerVisibilityTriggerHandler().run();
    }  
     
}