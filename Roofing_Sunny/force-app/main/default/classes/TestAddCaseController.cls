/*
        Name           : TestAddCaseController
        Company        : Certainteed
        Author         : Mukesh Bhardwaj (Threshold Consulting)
        Date           : 7th May 2013
        Description    : Test Class Which show the behaviour of addCaseController class.

*/
@isTest
public class TestAddCaseController{
    public static TestMethod void unitTest1(){
        List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType='Case' and isActive=true];
       
        Map<String,String> rTypMap = new Map<String,String>{};
        for(RecordType rt: rtypes){
           rTypMap.put(rt.Name,rt.Id);
        }  
        
        Contact conObj = new Contact(FirstName='test',LastName='TestLast',Phone='12345',Email='test@test.com',MailingCity='TestCity',MailingState = 'CA', MailingStreet = 'Mailing Street');
        insert conObj;
        
        Account acc = new Account(Name='TestAcc');
        insert acc;
        
        Order orObj = new Order(Name='TestOrderNew',Ship_To__c=acc.id);
        insert orObj;
        
        Case cObj = new Case(RecordTypeId=rTypMap.get('General Case'),Order__c= orObj.id,ContactId=conObj.id);
        insert cObj;
        
        addCaseController addContObj = new addCaseController();
    }
     public static TestMethod void unitTest2(){
        List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType='Case' and isActive=true];
       
        Map<String,String> rTypMap = new Map<String,String>{};
        for(RecordType rt: rtypes){
           rTypMap.put(rt.Name,rt.Id);
        }  
        
        Contact conObj = new Contact(FirstName='test',LastName='TestLast',Phone='12345',Email='test@test.com',MailingCity='TestCity',MailingState = 'CA', MailingStreet = 'Mailing Street');
        insert conObj;
        
        Account acc = new Account(Name='TestAcc',SAP_ACCOUNT__c ='123456');
        insert acc;
        
        Order orObj = new Order(Name='TestOrder',Ship_To__c=acc.id);
        insert orObj;
        
        Case cObj = new Case(RecordTypeId=rTypMap.get('General Case'),Order__c= orObj.id,ContactId=conObj.id);
        insert cObj;
        
        Plants__c wObj = new Plants__c(Plant_code__c='51');
        insert wObj;
        
        ApexPages.currentPage().getParameters().put('on',orObj.Name);
        ApexPages.currentPage().getParameters().put('oed',String.valueOf(Date.Today()));
        ApexPages.currentPage().getParameters().put('cpo','2');
        ApexPages.currentPage().getParameters().put('ot','10');
        ApexPages.currentPage().getParameters().put('ssd',String.valueOf(Date.Today()));
        ApexPages.currentPage().getParameters().put('sti','123456');
        ApexPages.currentPage().getParameters().put('wh',wObj.id);
        
        addCaseController addContObj = new addCaseController();
        addContObj.saveCaseRec();
        
        ApexPages.currentPage().getParameters().put('on','TestNewOrder');
        addCaseController addContObj1 = new addCaseController();
         addContObj1.saveCaseRec();
    }
}