public without sharing class DataTableController {

    @AuraEnabled(Cacheable = true)
    public static List<Contact> getContacts(){
        List<Contact> lstContacts = [SELECT Id, FirstName, LastName, Name, Email, IsDeleted, AccountId 
                                     FROM Contact ORDER BY FirstName LIMIT 200];
        if(lstContacts.size() > 0){
           return lstContacts;
        }
        return null;
    }
}