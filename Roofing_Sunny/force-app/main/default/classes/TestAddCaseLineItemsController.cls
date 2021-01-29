/*
        Name           : TestAddCaseLineItemsController 
        Author         : Mukesh Bhardwaj 
        Date           : 9th May 2013
        Description    : Test Class Which show the behaviour of addCaseLineItemsController class.

*/
@isTest (seeAllData=true)
public class TestAddCaseLineItemsController {
      /*************************Method when Order is Null*****************************/
    public static TestMethod void unitTest(){
        
        Case caseObj = new Case();
        insert caseObj;

        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj); 
        addCaseLineItemsController addCaseLineItemObj = new addCaseLineItemsController(sc);        
        
    }
    /*************************Method for CaseLineItem******************************/
    public static TestMethod void unitTest1(){
        Order orderobj = new Order(Name='TestOrder');
        insert orderObj;
        
        Case caseObj = new Case(Order__c=orderObj.id);
        insert caseObj;

      /*  Case_Line_Item__c cItemObj = new Case_Line_Item__c(Order__c=orderObj.id);
        insert cItemObj;*/
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj); 
        addCaseLineItemsController addCaseLineItemObj = new addCaseLineItemsController(sc);  
        //addCaseLineItemObj.saveAll();
        addCaseLineItemObj.addRec();
        addCaseLineItemObj.deleteRec();
        addCaseLineItemObj.closePopup();
        addCaseLineItemObj.showPopup();
        
    }
    /*************************Method for OrderLineItem******************************/
    public static TestMethod void unitTest2(){
        Order orderobj = new Order(Name='TestOrder');
        insert orderObj;
        
        Case caseObj = new Case(Order__c=orderObj.id);
        insert caseObj;

        OrderItem oItemObj = new OrderItem(OrderId=orderObj.id);
        insert oItemObj;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj); 
        addCaseLineItemsController addCaseLineItemObj = new addCaseLineItemsController(sc);  
        
    }
}