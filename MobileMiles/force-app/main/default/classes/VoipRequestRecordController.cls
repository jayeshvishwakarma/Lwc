/*
        Name  		:  	 Jayesh Vishwakarma
        Author      :    iBirds Services
        Date        :    29-10-2020
        Description :    Used for creating a voip request record
*/


public without sharing class VoipRequestRecordController {
    
     @AuraEnabled(cacheable = true)
    public static Account getAccount(String recordId){
        
        
        List<Account> lstAccounts = [SELECT Id, Voornaam_CP__c, Achternaam_CP__c, E_mailadres_bedrijf__c, Phone
                                     FROM Account 
                                     WHERE Id = :recordId
                                    ];
        if(lstAccounts.size() > 0){
            return lstAccounts[0];
        }
        return null;
    }
    
    @AuraEnabled
    public static String createVoipRequestRecord(VoIP_Request__c objVoipRequest){
        System.debug('##### : '+objVoipRequest);
        insert objVoipRequest;
        return objVoipRequest.Id;
    }
}