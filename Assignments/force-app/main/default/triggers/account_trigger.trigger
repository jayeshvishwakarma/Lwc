/* Name : AccountTrigger
* Author : Jayesh Vishwakarma
* Date : 21 march 2020
* Description : This Trigger is used give the list of comma seperated values to helper.
* */


trigger account_trigger on Account (after insert) {
    
        if(Trigger.isAfter)
        {
            if(Trigger.isInsert)
            {
            List<Account> lstAccounts =new List<Account>();
                List<Account> lstAccounts1=new List<Account>();
            for(Account objAccount : Trigger.New)
            {
                if(objAccount.Comma_Seperated_Values__c!=null)lstAccounts1.add(objAccount);
                if(objAccount.Contact_Information__c!=null)
                {
                    lstAccounts.add(objAccount);
                }
            }
            if(lstAccounts1.size()>0) AccountTriggerHelper.createContactsOfAccount(lstAccounts1);
            System.debug('Account Trigger Chala');
            if(lstAccounts.size()>0) AccountTriggerHelper.createContactsByContactInformation(lstAccounts);
        }
    }
}