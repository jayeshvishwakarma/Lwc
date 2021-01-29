public class ContactRecordsController {
    
    public List<Contact> lstContacts {get;set;}
    public String accountName{get;set;}
    public ContactRecordsController()
    {
        String contactId=ApexPages.currentPage().getParameters().get('recId');
        lstContacts= [ SELECT firstName,lastName,phone,email,Account.Name
                                     FROM Contact
            						 WHERE AccountId = :contactId
        			 ];
        if(lstContacts.size()>0)
        {
        accountName=lstContacts.get(0).Account.Name;
        }
        if(lstContacts.size()==0)
         {
       		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Contact of this Account'));
         }
    	}
    public PageReference backToAccount()
    {
        return Page.accountdetails;
    }

}