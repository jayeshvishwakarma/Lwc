@isTest
private class NewCustomerServiceTest{
    @isTest
    private static void unitTest(){
        String accNumber = '';
        
        Account accObj = new Account(Name = 'Customer Service');
        insert accObj;
        List<Account> accList = new List<Account>();
        accList = [SELECT Id,Accountnumber__c FROM Account WHERE Id=: accObj.Id LIMIT 1];
        
        if(accList.size() > 0){
            accNumber = accList[0].Accountnumber__c;
        }
        
        Contact conObj = new Contact(LastName = 'Service', Email = 'service@gmail.com');
        insert conObj;
        NewCustomerService service = new NewCustomerService();
        NewCustomerService.createCustomer(accNumber, 'CustomerService', 'Customer', 'Service', 'service@gmail.com', '98281122');
    }
    @isTest
    private static void unitTest1(){
        String accNumber = '';
        
        Account accObj = new Account(Name = 'Customer Service');
        insert accObj;
        List<Account> accList = new List<Account>();
        accList = [SELECT Id,Accountnumber__c FROM Account WHERE Id=: accObj.Id LIMIT 1];
        
        if(accList.size() > 0){
            accNumber = accList[0].Accountnumber__c;
        }
        
        NewCustomerService service = new NewCustomerService();
        NewCustomerService.createCustomer(accNumber, 'CustomerService', 'Customer', 'Service', 'service@gmail.com', '98281122');
    }
}