/*
    Name    : addCaseLineItemsController 
    Company : Certainteed
    Author  : Mukesh Bhardwaj (Threshold Consulting)
    Comments: Controller for addCaseLineItems VF page
    Changes : 6th May, 2013 Initial version.
*/
public with sharing class addCaseLineItemsController {
    
    public Integer rIndex{get;set;}
    private String caseOrder;
//    public boolean displayDetailBlock{get;set;}
    public List<Wrapper> wrapList{get;set;}
    public boolean displayPopup {get; set;}
    private Case currentCase;
    
    public addCaseLineItemsController(ApexPages.StandardController controller) {
        displayPopup = false;
        wrapList = new List<Wrapper>();
        //Case currentCase;
        currentCase = (Case) controller.getRecord();
        Case cRec = [Select Id, Order__c, Order__r.Name from Case where id =: currentCase.id];
        //contractRecord.cObj = cRec;
        caseOrder = cRec.Order__c;
        if(cRec.Order__c == null){                          
            displayPopup = true;
           //ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Error, 'This is Only for Order Case LineItems');
          //  ApexPages.addMessage(errorMsg);
            //displayDetailBlock = False;         
        }else{
            displayPopup = false;
           // displayDetailBlock = True;

           /* List<Case_Line_Item__c> caseLineItemList = [Select Id, Line_Number__c, Name,Order__c, Quantity_Ordered__c, Price_Ordered__c, Price_Received__c,Quantity_Received__c,                                                         IsError__c, Item_Number__c, Product_Ordered__c,Order_Line_Item__c,                                                        Product_Received__c from Case_Line_Item__c                                                         where Order__c =: cRec.Order__c Order By Line_Number__c];

            System.debug('$$ CaseLineItem records on basis of Order::::'+caseLineItemList);
            if(caseLineItemList.size() == 0){
                System.debug('Call Order Line Items::');
                List<OrderItem> orderLineItemList = [Select Id, Name, OrderId, Qty_Ordered__c, Net_Price__c, 
                                                              Line_Number__c, Product__c from OrderItem 
                                                              where OrderId =: cRec.Order__c Order By Line_Number__c];
                
                if(orderLineItemList.size() > 0){                    
                    for(OrderItem o : orderLineItemList ){ 
                        Case_Line_Item__c cItem = new Case_Line_Item__c();                       
                        cItem.Price_Received__c = o.Net_Price__c;
                        cItem.Price_Ordered__c = o.Net_Price__c;
                        cItem.Quantity_Received__c = o.Qty_Ordered__c;
                        cItem.Quantity_Ordered__c = o.Qty_Ordered__c;
                        cItem.Order__c = o.OrderId;
                        cItem.Order_Line_Item__c = o.OrderId;
                        //cItem.Item_Number__c = String.valueOf(o.Line_Number__c);
                        cItem.Line_Number__c = o.Line_Number__c;
                        //cItem.Name = o.Name;  
                        cItem.Product_Ordered__c = o.Product__c;
                        cItem.Product_Received__c = o.Product__c;
                        Wrapper w = new Wrapper();
                        //w.cli = cItem;
                        w.index = wrapList.size();
                       
                        wrapList.add(w);
                    }                     
                }
            }
            else{
                
                for(Case_Line_Item__c c : caseLineItemList)
                {
                    Wrapper w = new Wrapper();
                    w.cli = c;                  
                    w.index = wrapList.size();
                    wrapList.add(w);
                }
            }*/
        }
    }

    //********************Method call when Press SaveLineItem Button********************************
   /* public pageReference saveAll(){
        List<Case_line_Item__c> cliToUpsert = new List<Case_line_Item__c>();
        for(Wrapper w : wrapList)
        {
            cliToUpsert.add(w.cli);
            System.debug('cli.Product:::'+w.cli.Product_Ordered__c);
        }
        System.debug('cli.Product:::'+cliToUpsert);
        
        if(cliToUpsert.size() > 0)
            upsert cliToUpsert;
        return (new PageReference('/apex/addCaseLineItems?id='+currentCase.Id)).setRedirect(true);    
    } */

    //********************Method call when we Delete any Ordered Line Item*********************************
    public PageReference deleteRec(){
        List<Wrapper> wrapListToDelete = new List<Wrapper>();
        System.debug('rIndex:::'+rIndex);
        for(Integer i=0; i<=wrapList.size(); i++)
        {
            if(i == rIndex)
            {
                wrapListToDelete.add(wrapList.get(i));
                wrapList.remove(i);
                break;
            }
        }
       /* List<Case_line_Item__c> cliTodelete = new List<Case_line_Item__c>();
        for(Wrapper w : wrapListToDelete)
        {
            if(w.cli.Id != null)
                cliTodelete.add(w.cli);
        }             
        if(cliTodelete.size() > 0)
          delete cliTodelete;    */      
        return null;
    } 
    
    // ********************Method call when we Add any Ordered Line Item(No Matching Ordered case)**************
    public pageReference addRec(){
        Wrapper w = new Wrapper();
       /* Case_Line_Item__c cli = new Case_Line_Item__c();
        cli.Line_Number__c = wrapList.size() + 1;
        cli.Price_Ordered__c = null;
        cli.Quantity_Ordered__c = null;
        cli.Order_Line_Item__c = null;
        cli.Order__c = caseOrder;
        cli.Product_Ordered__c = null;
        w.cli = cli; */
        w.index = wrapList.size();
        wrapList.add(w);
        return null;
    }
    public void closePopup() {        
        displayPopup = false;        
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
    public class Wrapper{
        public integer index {get;set;}
        //public Case_Line_Item__c cli {get;set;}
    }
}