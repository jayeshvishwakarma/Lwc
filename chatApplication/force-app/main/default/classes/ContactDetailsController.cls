public class ContactDetailsController {
   /* private String companyName;
    public String firstName {get;set;}
    public String lastName{get;set;}
    public String phone{get;set;}
    public String email{get;set;} */
    
    public Contact objContact {get;set;}
   
    public ContactDetailsController()
    {
       	List<Contact> lstContacts = [SELECT firstName,lastName,phone,email
         					  FROM contact
         					  WHERE Phone = '(212) 842-5500'
        					 ];
        if(lstContacts.size()>0)
        {
            objContact=lstContacts.get(0);
        }
            System.debug('Constructor Invoked........');   
    }
    
    
}