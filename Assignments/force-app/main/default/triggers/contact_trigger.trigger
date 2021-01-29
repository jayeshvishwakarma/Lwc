/* Name : ContactTrigger
* Author : Jayesh Vishwakarma
* Date : 19 march 2020
* Description : This Trigger is used give the id and Contacts to Helper.
* */


trigger contact_trigger on Contact (before insert, after insert, before update, after update, before delete, after delete, after undelete)
{
    Map<Id, Contact> mapNewContacts = Trigger.newMap;
    Map<Id, Contact> mapOldContacts = Trigger.oldMap;
    if(Trigger.isInsert){
        List<Contact> lstNewContacts = new List<Contact>();
            for(Contact con : [SELECT Id, FirstName, LastName 
                               FROM Contact 
                               WHERE Id IN :mapNewContacts.keySet()]){
                                   
                                   if(String.isEmpty(con.FirstName) || String.isEmpty(con.LastName)){
                                       lstNewContacts.add(con);
                                   }
                               }
        if(lstNewContacts.size() > 0){
        	ContactTriggerHelper.createApexSharing(lstNewContacts);
        }
    }
    
}    


/*if(Trigger.isInsert)
{
List<Contact> lstContacts=new List<Contact>();
Set<Id> setAccountIds=new Set<Id>();
for(Contact objContact : Trigger.New){
if(objContact.AccountId!=null){
lstContacts.add(objContact);
setAccountIds.add(objContact.AccountId);
}
}
if(lstContacts.size()>0){
ContactTriggerHelper.addMyDateValue(lstContacts,setAccountIds);
}
} 
If(Trigger.isAfter)
{
if(Trigger.isInsert)
{
// List<Contact> lstContactsWithoutAccount=new List<Contact>();
List<Contact> lstFilteredContacts=new List<Contact>();

for(Contact objContact : Trigger.New)
{
System.debug('Trigger Chala for Need Intel wala'+Trigger.New);

if(objContact.AccountId != null && objContact.Dead__c == true){
lstFilteredContacts.add(objContact);  
} 


}
ContactTriggerHelper.checkboxOnOff(lstFilteredContacts);
}
else
{
lstContactsWithoutAccount.add(objContact); 
}
if(Trigger.isUpdate){
Set<Id> setIds=new Set<Id>();
for(Contact objContact : Trigger.New)
{
if(objContact.AccountId!=null) {
setIds.add(objContact.AccountId);
}
System.debug('Id' +setIds);

// ContactTriggerHelper.changeRating(lstContactsWithAccount,lstContactsWithoutAccount);

ContactTriggerHelper.sumOfAmounts(setIds);

System.debug('Trigger chala helper pe bheja');
}
}
}*/