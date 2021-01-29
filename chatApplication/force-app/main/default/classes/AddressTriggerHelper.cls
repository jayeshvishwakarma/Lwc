/* Name : AddressTriggerHelper
* Author : Jayesh Vishwakarma
* Date : 20 march 2020
* Description : This Trigger Helper is used take list of Contacts which have active Address assign to most recent address.
* */
public class AddressTriggerHelper {
    
    public static void addMostRecentAddress(List<Contact> lstContacts)
    {
		List<Account> lstAccounts =new List<Account>();
        for(Contact objContact : lstContacts)
        {
            objContact.Account.most_recent_address__c=objContact.Addresses__r.get(0).Name;
            lstAccounts.add(objContact.Account);
        }
        update lstAccounts;
    }    
}