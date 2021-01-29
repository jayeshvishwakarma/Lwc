/*
        Name            :    Rajrishi Kaushik
        Author          :    iBirds Services
        Date            :    26 August 2020
        Description     :    Using in TriggerSettingController
*/

@isTest
public class TriggerSettingControllerTest {
	@isTest
    public static void testTriggerSettings(){
               Trigger_Settings__c settings = new Trigger_Settings__c();
               settings.Name='Default';
               settings.Account_Trigger__c=true;
               settings.AvailableSpeed_Trigger__c=true;
               settings.Bestelling_MM_Trigger__c=true;
               settings.Bestellingproduct_Trigger__c=true;
               settings.Opportunity_Trigger__c=true;
               settings.Porteringen_mobiel_Trigger__c=true;
               settings.Quote_Trigger__c=true;
               settings.VolP_Trigger__c=true;
               insert settings; 
        
                test.startTest();
                TriggerSettingsController.getTriggerSettings();
                TriggerSettingsController.updateTriggerSettings(settings);
                test.stopTest();
    }
}