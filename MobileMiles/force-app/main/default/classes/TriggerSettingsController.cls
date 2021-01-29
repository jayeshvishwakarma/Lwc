/*
        Name            :    Rajrishi Kaushik
        Author          :    iBirds Services
        Date            :    26 August 2020
        Description     :    Using in TriggerSettingComponent(LWC)
*/



public without sharing class TriggerSettingsController {
   
    @AuraEnabled(cacheable = true)
    public static Trigger_Settings__c getTriggerSettings(){
        
        
        List<Trigger_Settings__c> lstTriggerSettings = [SELECT Account_Trigger__c, AvailableSpeed_Trigger__c, Bestelling_MM_Trigger__c,
                                                        Bestellingproduct_Trigger__c, Opportunity_Trigger__c, Porteringen_mobiel_Trigger__c,
                                                        Quote_Trigger__c, VolP_Trigger__c
                                                        From Trigger_Settings__c
                                                       ];
        if(lstTriggerSettings.size() > 0){
            return lstTriggerSettings[0];
        }
        return null;
        
    }
    
    @AuraEnabled
    public static void updateTriggerSettings(Trigger_Settings__c objTriggerSetting){
        
            database.update(objTriggerSetting);
      
    }
}