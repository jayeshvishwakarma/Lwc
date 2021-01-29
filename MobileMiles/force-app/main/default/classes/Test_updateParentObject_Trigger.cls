@isTest
public class Test_updateParentObject_Trigger {
    public static testMethod void runTest(){
        //Set up test data
        Account a = new Account(Name='Test Account',Bankrekeningnummer__c = 'NL88INGB0006166278');
        insert a;
        EZSign__Signature__c s = new EZSign__Signature__c(EZSign__Parent_Id__c = a.Id,Geboortedatum__c = System.now().date(), Legitimatienummer__c = 'Test', Looptijd_contract_Telfort_Zakelijk_vt__c  = '3 jaar', EZSign__Signature_Key__c = 'testKey', EZSign__Signature__c = 'Test Signature', EZSign__Signature_Name__c = 'Test Signature Name', EZSign__Signature_Date__c = System.now(), EZSign__Signature_URL__c = 'https://'+Label.SFServer+'.force.com/servlet/testURL');
        insert s;
        //Update signature record to fire trigger
        update s;
        //Verify trigger executed properly by inspecting parent record
        a = [SELECT Id, Name, Bankrekeningnummer__c, Geboortedatum__c, Legitimatienummer__c, Looptijd_contract_Telfort_Zakelijk_vt__c FROM Account WHERE Id = :a.Id];
        //Verify the parent fields were updated accordingly
       // System.assertEquals(a.Bankrekeningnummer__c,s.Bankrekeningnummer__c);
        System.assertEquals(a.Geboortedatum__c,s.Geboortedatum__c);
        System.assertEquals(a.Legitimatienummer__c,s.Legitimatienummer__c);
        System.assertEquals(a.Looptijd_contract_Telfort_Zakelijk_vt__c,s.Looptijd_contract_Telfort_Zakelijk_vt__c);
    }
}