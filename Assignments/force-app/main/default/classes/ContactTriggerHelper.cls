/* Name : ContactTriggerHelper
* Author : Jayesh Vishwakarma
* Date : 19 march 2020
* Description : This Helper Class is used to add my Date value.
* */
public class ContactTriggerHelper {
    
    public static void createApexSharing(List<Contact> lstContacts){
        List<ContactShare> lstContactShares = new List<ContactShare>(); 
        for(Contact con : lstContacts){
			ContactShare contactShr = new ContactShare(); 
            
        }
        
        
    }
/*public static void addMyDateValue(List<Contact> lstContacts,Set<Id> setAccountIds){
Map <Id,List<Contact>> mapContacts=new Map<Id, List<Contact>>();
for(Id objId : setAccountIds){
List<Contact> lstTempContacts=new List<Contact>();
for(Contact objContact : lstContacts){
if(objId==objContact.AccountId){
lstTempContacts.add(objContact);
}
}
mapContacts.put(objId,lstTempContacts);
}      

List<Account> lstAccounts=[Select id, myDate__c,(Select id from contacts) from account where id in :setAccountIds];

for(Account objAccount : lstAccounts){
// Date accountMyDate=objAccount.MyDate__c.addMonths(objAccount.contacts.size()+1);
Date accountMyDate=objAccount.MyDate__c.addMonths(objAccount.contacts.size()+1);
for(Contact objContact : mapContacts.get(objAccount.id)){
objContact.MyDate__c=accountMyDate;
accountMyDate=accountMyDate.addMonths(1);
}
}
}*/
    
    
    ////Contact_trigger Method
    
    /*public static void changeRating(List<Contact> lstContactsWithAccount,List<Contact> lstContactsWithoutAccount)
{
List<Contact> lstContacts=[SELECT id,Name,Contact_Rating__c,Account.Rating,Account.Counter__c
FROM Contact 
WHERE id IN : lstContactsWithAccount
];
for(Contact objContact : lstContacts)
{
objContact.Account.Counter__C++;
objContact.Contact_Rating__c=objContact.Account_Rating__c;
}
database.update(lstContacts);


List<Account> lstAccounts=new List<Account>();
Account objAccount =new Account();
for(Contact objContact2 : lstContactsWithoutAccount)
{
String AccountName = objContact2.Email.subStringBetween('@','.');
String AccountSiteName='www.'+AccountName+'.com';
objAccount.Name=AccountName;
objAccount.Site=AccountSiteName;
lstAccounts.add(objAccount);
}

List<Account> lstAccounts2=[SELECT id,name
FROM Account
];

List<Account> lstAddAccounts = new List<Account>();
for(Account objAccountTemp : lstAccounts2)
{
for(Account objAccountTemp2 : lstAccounts)
{

if(objAccountTemp.Name==objAccountTemp2.Name && objAccountTemp.Site==ObjAccountTemp2.Site)
{
for(Contact objContact :lstContactsWithoutAccount)
{
objContact.Account.Counter__C++;
objContact.Contact_Rating__c=objContact.Account_Rating__c;
}
database.update(lstContactsWithoutAccount);
}
else
{
lstAddAccounts.add(objAccountTemp2);
}

}
}
database.insert(lstAddAccounts);


}*/
    
    
    // Sum OF Amounts
    
    
   public static void sumOFAmounts(Set<Id> setAccIds)
    {
        
        List<Account> lstAccounts=[SELECT Id,Rollup_Amount_X__c, Rollup_Amount_Y__c, Rollup_Amount__c,
                                   (Select Id,AccountId, Amount_X__c, Amount_Y__c,Type__C
                                    From Contacts)
                                   From Account 
                                   Where Id IN : setAccIds
                                  ];
        System.debug('list Account ki size '+lstAccounts.size());
        
        for(Account objAccount : lstAccounts)
        {
            
            if(objAccount.Rollup_Amount__c==null || objAccount.RollUp_Amount_x__c==null || objAccount.Rollup_Amount_y__c==null)
            {
                objAccount.Rollup_Amount_Y__c=objAccount.RollUp_Amount_x__c=objAccount.Rollup_Amount__c=0;
            }
            
            for(Contact objContact : objAccount.Contacts)
            {
                if(objContact.Type__c == 'Positive')
                {
                    objAccount.RollUp_Amount_x__c +=objContact.Amount_x__c;
                }
                else if(objContact.Type__c == 'Negative')
                {    
                    objAccount.Rollup_Amount_y__c +=objContact.Amount_y__c;
                }
                objAccount.Rollup_Amount__c += objContact.Amount_x__c+objContact.Amount_y__c;
            }
        }
        Database.update(lstAccounts);
    }
    
    // Check Box OnOFF
    
   public static void checkboxOnOff(List<Contact> lstFilteredContacts)
    {
        Set<Id> setAccountIds=new Set<ID>();
        for(Contact objContact : lstFilteredContacts)
        {
            setAccountIds.add(objContact.AccountId);
        }
        System.debug(setAccountIds);
        List<Account> lstAccountsWithChilds=[SELECT Id,name,(SELECT id,Name,Dead__C FROM Contacts)
                                             FROM Account
                                             WHERE id IN : setAccountIds
                                            ];
        
        System.debug('listAccountWith Childs wali '+lstAccountsWithChilds.size());
        for(Account objAccount : lstAccountsWithChilds)
        {
            Integer count=0;
            for(Contact objContact : objAccount.Contacts)
            {
                if(objContact.Dead__c==true)
                {
                    count++;
                }  
            }
            Integer percentage=((count)/(objAccount.Contacts.size()))*100;
            if(percentage >= 70)
            {
                objAccount.Need_Intel__c=true;
            }
        }
    }
    
    
}