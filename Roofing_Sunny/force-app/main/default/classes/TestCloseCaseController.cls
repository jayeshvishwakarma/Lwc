/*
        Name           : TestCloseCaseController
        Company        : Certainteed
        Author         : Mukesh Bhardwaj (Threshold Consulting)
        Date           : 7th May 2013
        Description    : Test Class for CloseCaseController class.

*/
@isTest
public class TestCloseCaseController{

    public static TestMethod void unitTest1(){
        test.StartTest();
        Account a = new Account(Name='Test',SAP_ACCOUNT__c ='shipToId');
        insert a;
        
        Order orObj = new Order(Name='TestOrder',PONumber='po1234');
        insert orObj;
        
        Case cObj = new Case(Order__c= orObj.id, Status='New', AccountId=a.Id);
        insert cObj; 

        ApexPages.currentPage().getParameters().put('po', 'po1234');
        ApexPages.currentPage().getParameters().put('st', 'shipToId');
        closeCaseController closeContObj = new closeCaseController();
        closeContObj.WrapperList.get(0).selected = true;
        closeContObj.CloseCase();
        test.StopTest();
    }
    public static TestMethod void unitTest2(){
    
        test.StartTest();
        Account a = new Account(Name='Test',SAP_ACCOUNT__c='shipToId');
        insert a;
        
        Order orObj = new Order(Name='TestOrder',PONumber='po1234');
        insert orObj;
        
        Case cObj = new Case(Order__c= orObj.id, Status='New', AccountId=a.Id);
        insert cObj; 

        ApexPages.currentPage().getParameters().put('po', 'po1234');
        ApexPages.currentPage().getParameters().put('st', 'shipToId22');
        closeCaseController closeContObj = new closeCaseController();
        closeContObj.CloseCase();
        test.StopTest();
    }
    public static TestMethod void unitTest3(){
        test.StartTest();
        Account a = new Account(Name='Test',SAP_ACCOUNT__c='shipToId');
        insert a;
        
        Order orObj = new Order(Name='TestOrder',PONumber='po1234');
        insert orObj;
        
        Case cObj = new Case(Order__c= orObj.id, Status='New', AccountId=a.Id);
        insert cObj; 

        ApexPages.currentPage().getParameters().put('po', 'po123422');
        ApexPages.currentPage().getParameters().put('st', 'shipToId');
        closeCaseController closeContObj = new closeCaseController();
        closeContObj.CloseCase();
        test.StopTest();
    }
    public static TestMethod void unitTest4(){
        test.StartTest();
        Account a = new Account(Name='Test',SAP_ACCOUNT__c='shipToId');
        insert a;
        
        Order orObj = new Order(Name='TestOrder',PONumber='po1234');
        insert orObj;
        
        Case cObj = new Case(Order__c= orObj.id, Status='New', AccountId=a.Id);
        insert cObj; 

        ApexPages.currentPage().getParameters().put('po', '');
        ApexPages.currentPage().getParameters().put('st', '');
        closeCaseController closeContObj = new closeCaseController();
        closeContObj.CloseCase();
        test.StopTest();
    }
    public static TestMethod void unitTest5(){
        test.StartTest();
        Account a = new Account(Name='Test',SAP_ACCOUNT__c='shipToId');
        insert a;
        
        Order orObj = new Order(Name='TestOrder',PONumber='po1234');
        insert orObj;
        
        Case cObj = new Case(Order__c= orObj.id, Status='New', AccountId=a.Id);
        insert cObj; 

        ApexPages.currentPage().getParameters().put('po', 'po123412');
        //ApexPages.currentPage().getParameters().put('st', '');
        closeCaseController closeContObj = new closeCaseController();
        closeContObj.CloseCase();
        test.StopTest();
    }
    public static TestMethod void unitTest6(){
        test.StartTest();
        Account a = new Account(Name='Test',SAP_ACCOUNT__c='shipToId');
        insert a;
        
        Order orObj = new Order(Name='TestOrder',PONumber='po1234');
        insert orObj;
        
        Case cObj = new Case(Order__c= orObj.id, Status='New', AccountId=a.Id);
        insert cObj; 

        //ApexPages.currentPage().getParameters().put('po', 'po123412');
        ApexPages.currentPage().getParameters().put('st', '3322334');
        closeCaseController closeContObj = new closeCaseController();
        closeContObj.CloseCase();
        test.StopTest();
    }
}