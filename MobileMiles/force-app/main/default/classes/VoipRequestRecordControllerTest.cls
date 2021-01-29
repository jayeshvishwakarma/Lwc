/*
        Name  		:  	 Jayesh Vishwakarma
        Author      :    iBirds Services
        Date        :    29-10-2020
        Description :    Used for testing a VoipRequestRecordController
*/

@isTest
public class VoipRequestRecordControllerTest {
    @isTest
    public static void unitTest(){
        Account objAccount = new Account();
        objAccount.Name = 'Test';
        objAccount.Voornaam_CP__c = 'Voip';
        objAccount.Achternaam_CP__c = 'Record';
        objAccount.E_mailadres_bedrijf__c = 'Test@voip.com';
        objAccount.Phone = '1234567890';
        insert objAccount; 
        
        VoIP_Request__c objVoipRequest = new VoIP_Request__c();
        objVoipRequest.Aantal_gebruikers__c = 10;
        objVoipRequest.Achternaam_CP__c = objAccount.Achternaam_CP__c ;
        objVoipRequest.Bedrijf__c = objAccount.Id;
        objVoipRequest.E_mailadres__c = objAccount.E_mailadres_bedrijf__c;
        objVoipRequest.Onbeperkt_bellen__c = true;
        objVoipRequest.Phone__c = objAccount.Phone;
        objVoipRequest.Te_porteren_nummers__c = 'This is for testing';
        objVoipRequest.Vast_nummer__c = 'Nieuw regionaal nummer';
        objVoipRequest.Voornaam_CP__c = objAccount.Voornaam_CP__c;
        objVoipRequest.Yealink_T41S__c = 10;
        
        VoipRequestRecordController.getAccount('');
        VoipRequestRecordController.getAccount(objAccount.Id);
        VoipRequestRecordController.createVoipRequestRecord(objVoipRequest);
    }
}