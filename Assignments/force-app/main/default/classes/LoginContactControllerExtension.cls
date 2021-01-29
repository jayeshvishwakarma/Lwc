public class LoginContactControllerExtension {
    public Contact objContact;
    
    public Boolean isSignUpSection{get;set;}
    public boolean isResetPasswordSection{get;set;}
    public Boolean isLoginSection{get;set;}
    public boolean isForgotPasswordSectionEnable{get;set;}
    
    public LoginContactControllerExtension(ApexPages.StandardController sc)
    {
        
        isLoginSection=true;
        isSignUpSection=isForgotPasswordSectionEnable=isResetPasswordSection=false;
        this.objContact=(Contact) sc.getRecord();	
    }
    
    public PageReference login()
    {
        System.debug('EMAIL:'+objContact.Email);
        System.debug('Password:'+objContact.Password__c);
        
        
        for(Contact objContactTemp : [SELECT id,firstName,Email,password__C 
                                      FROM COntact 
                                      WHERE email =:objContact.Email])
        {
            if(objContact.Email==objContactTemp.Email && objContact.Password__c==objContactTemp.Password__c)
            {
                System.debug('Name on Login :' +objContactTemp.firstName);
                PageReference pref = page.survey_questions;
                pref.getParameters().put('EmailIdFromLoginPage',objContact.Email);
			    pref.getParameters().put('nameFromLoginPage',objContactTemp.FirstName);
                System.debug('Login hua');
                return pref;
            }
        }
        ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Email Id Or Password'));
        return null;
    }
    
    public void backToLogin()
    {
        isLoginSection=true;
        isForgotPasswordSectionEnable=isResetPasswordSection=isSignUpSection=false;
        
    }
    
    public void signUpTable()
    {
        IsForgotPasswordSectionEnable=isLoginSection=isResetPasswordSection=false;
        isSignUpSection=true;
    }
    
    public void forgotPasswordsectionEnable()
    {
        isResetPasswordSection=isLoginSection=isSignUpSection=false;
        isForgotPasswordSectionEnable=true;
    }
    
    public void ValidateEmail()
    {
        List<Contact> lstContact=[SELECT id,Email,password__C 
                                  FROM COntact 
                                  WHERE email =:objContact.Email];
        if(lstContact.size()>0)
        {
            isForgotPasswordSectionEnable=false;
            isResetPasswordSection=true;
        }else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,' *** InValid Email Id ***'));
        }
    }
    
    public void resetPassword()
    {
        for(Contact objContactTemp : [SELECT id,Email,password__C 
                                      FROM COntact 
                                      WHERE email =:objContact.Email])
        {
            objContactTemp.Password__c=objContact.Password__c;
            Database.update(objContactTemp);
            isResetPasswordSection=false;
            isLoginSection=true;
            
            System.debug('Updated :' +objContact);
            
        }
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Your Password is Reset'));
    }
    
    public PageReference createContact()
    {
        System.Debug('Create wala chala : '+objContact);
        try
        {
            insert objContact;
            isSignUpSection=False;
            isLoginSection=true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Your Contact is Created'));
            System.debug(objContact);
            System.debug('Contact INserted');
            System.debug('_________________::::::'+objContact.Password__c);
            
        }catch(Exception objException)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,objException.getMessage()));
        }
        
        return Page.login_contact;        
    }
    
}