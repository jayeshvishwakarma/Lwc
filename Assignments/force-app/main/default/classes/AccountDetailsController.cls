public class AccountDetailsController {
    
    public String accountRecordId {get;set;}
    
    public List<Account> getLstAccounts()
    {
        return [SELECT Id, Name, Phone, Industry, Rating ,type
                FROM Account
                
                LIMIT 20
               ];   
    }
    
    public PageReference showContacts()
    {
        // System.debug('Button Chala :' + accountRecordId );
        PageReference pgContactRecords= Page.contactRecords;
        pgContactRecords.getParameters().put('recId',accountRecordId);
        
        return pgContactRecords;
        
    }
    
    public PageReference addAccount()
    {
        PageReference pgAddAccount=Page.addaccount;
        return pgAddAccount;
    }
    public PageReference editContact()
    {
        PageReference pgEditContact=Page.editcontact;
        return pgEditcontact;
    }
    public void deleteRecord()
    {
        
		System.debug('Chala' +accountRecordId); 
        try
        {
        List<Account> lstAccounts=[select id from Account where id=:accountRecordId];
        if(lstAccounts.size()>0)
        {
            delete lstAccounts;
        }}catch(Exception e)
        {
            System.debug(e.getMessage());
        }
    	
    }
    
}