/* Name : AccountTriggerHelper
* Author : Jayesh Vishwakarma
* Date : 21 march 2020
* Description : This helper is used take list by trigger and create contact of that accounf by first and last name.
* */

public class AccountTriggerHelper {
    
    public static void createContactsOfAccount(List<Account> lstAccounts)
    {
        List<Contact> lstContacts=new List<Contact>();
        for(Account objAccount : lstAccounts)
        {
            String[] seperateValuesByComma=objAccount.comma_seperated_values__c.split(',');
            for(String objString : seperateValuesByComma)
            {
                String[] seperateValuesBySpace=objString.split(' ');
                Contact objContact=new Contact();
                if(seperateValuesBySpace.size()>1)
                {
                    objContact.FirstName=seperateValuesBySpace[0];
                    objContact.LastName=seperateValuesBySpace[1];
                }
                else
                {
                    objContact.LastName=seperateValuesBySpace[0];
                }
                objContact.AccountId=objAccount.id;
                lstContacts.add(objContact);
            }
        }
        insert lstContacts;
    }
    
    public static void createContactsByContactInformation(List<Account> lstAccounts)
    {
        List<Contact> lstContacts=new List<Contact>();
        for(Account objAccount : lstAccounts)
        {
            String[] ContactInformation=objAccount.Contact_Information__C.split(',');
            Contact objContact=new Contact();
            for(String objString : ContactInformation)
            {
                objContact.FirstName=objString.substringAfter(':');
                objContact.Email=objString.substringAfter(':');
                objContact.Phone=objString.substringAfter(':');
                objContact.Description=objString.substringAfter(':');
                lstContacts.add(objContact);
                
            }
            for(Contact objContact2 : lstContacts)
            {
                if(objAccount.Id==objContact2.AccountId) database.update(lstContacts);
            }
        }
        
    }
    
}