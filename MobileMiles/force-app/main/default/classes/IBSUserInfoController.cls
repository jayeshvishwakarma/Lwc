public without sharing class IBSUserInfoController {
    /**
        Name        :   getUserInfo
        Date        :   24 May 2020
        Description :   Function is use for user Info based on Account Id
        Developer   :   
     */
    @AuraEnabled
    public static List<account> getUserInfo(String accId){            
        if(String.isNotBlank(accId)){           
           List<Account> accList = [SELECT Id,owner.name,owner.Email,owner.Extension,owner.Pasfoto_ovaal__c ,Name  FROM Account 
                                WHERE Id = :accId];
                                return accList;
        }else{
            throw new AuraHandledException('Account Id not found.');
        }    
    }
}