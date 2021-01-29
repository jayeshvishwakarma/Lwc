/*
        Name        :    ContactUsController
        Date        :
        Author      :
        Descriptio  :    This controller is  used to Insert the case on community for contactus page.
*/
public class ContactUsController{
    public Lead leadObj {get;set;}
    public String company{get;set;}
    public String name{get;set;}
    public String email{get;set;}
    public String phoneno{get;set;}
    public String description{get;set;}
    public String subject {get;set;}
    public ContactUsController(){
        leadObj = new Lead();
    }
    
    public PageReference saveLead(){
        
       
        Case cs =  new Case(recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Contactformulier').getRecordTypeId(), 
                        SuppliedCompany = company,
                        subject = subject,
                        SuppliedName = name, 
                        SuppliedEmail = email, 
                        SuppliedPhone = phoneno, 
                        description = description,
                        ownerid = [SELECT Id, Name, DeveloperName, Type, Email FROM Group where developername = 'Service'].id);
                        
       
        insert cs;
                               
        // TODO: Change for Commuynity.
        PageReference pageRef = new PageReference(System.Label.cloudthankyouurl);
        //pageRef.setRedirect(true);
        return pageRef;
    }
}