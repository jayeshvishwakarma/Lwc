public class AccountSaveExtension {
    public Account objAccount;
    public String name{get;set;}
    public String phone{get;set;}
    public String industry{get;set;}
    public String rating{get;set;}
    public String type{get;set;}
    public String website{get;set;}
    
    public AccountSaveExtension(ApexPages.StandardController sc)
    {
        this.objAccount=(Account) sc.getRecord();
    }
    
    public PageReference Save()
    {
        try
        {
                insert objAccount;
            //System.debug(objAccount);
        }catch(Exception objException)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,objException.getMessage()));
        }
        
        return Page.accountdetails;
    }
    public PageReference Back()
    {
        return Page.accountdetails;
    }
    
    
}