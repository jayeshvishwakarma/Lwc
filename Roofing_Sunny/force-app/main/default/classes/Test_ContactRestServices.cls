@isTest
public class Test_ContactRestServices {

    @isTest static void doGet() {
        Test.startTest();
    //create account
    Account acc = new Account();
    //enter details  
    acc.Name = 'Test Account';
    acc.Type ='test';
   acc.BillingStreet ='test';
    insert acc;
      List<account> AccountList = new List<Account>();
     Id PayerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Indirect Accounts').getRecordTypeId(); 
     Account acc1 = new Account();
    //enter details  
    acc1.Name = 'Test Account';
    acc1.Type ='test';
   acc1.BillingStreet ='test';
   acc1.LOB__c ='1501';
   acc1.Hierarchy_Level_BPCS__c ='2-Payer';
   acc1.SAP_ACCOUNT__c ='3001425';
    acc1.RecordTypeId =PayerId ;
    AccountList.add(acc1);
    insert AccountList;
    
    
    //Create a contact
    List<contact> contList = new List<Contact>();
    Contact con = new Contact();
    con.lastname ='testlastname';
    con.FirstName='testforstname';
    con.MailingStreet='Test';
   con.MailingCity ='test';
   con.MailingState='ap';
   con.MailingPostalCode='31900';
   con.MailingCountry='test';
    con.AccountId =AccountList[0].id;
    con.phone='903908400';
    con.email ='test@gmail.com';
    //insert con;
    contList.add(con);
    insert contList;
    
    List<Account> accountsWithContacts=new List<Account>();
   
    if(AccountList !=null  && AccountList.size() >0 && contList.size() >0)
    {
     accountsWithContacts.add(AccountList[0]);
    }
  

   RestRequest req = new RestRequest(); 
   RestResponse res = new RestResponse();

    req.requestURI = '/services//api/Contact/'+con.accountId;  //Request URL
    // req.requestBody = Blob.valueof(Body);
     req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response= res;
    //CaseAttachment.getCaseById();
    ContactRestServices.doget();
    Test.stopTest();
    }
    }