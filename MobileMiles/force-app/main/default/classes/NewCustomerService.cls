public class NewCustomerService {
	@AuraEnabled
    public static string createCustomer(string accNumber, string title, string fname, string lname, string email, string phone){
       List<Account> accList = [select id from account where Accountnumber__c =: accNumber];
        if(accList.size() > 0){
            List<Contact> lstContacts = [select id from contact where email =: email];
            if(lstContacts.size() > 0){
                return 'Op dit e-mailadres is al een account actief';
            }else{
                Contact con = new Contact(salutation = title, firstname = fname, lastname = lname, email = email, phone = phone, accountid = accList[0].Id, OwnerId = Label.Service_User);
                
                insert con;
            }
            return 'Success';
        }else{
            return 'Er is een onjuist klantnummer ingevuld';
        }
    }
}