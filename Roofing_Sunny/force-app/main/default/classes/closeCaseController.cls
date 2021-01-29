/*
   Object: closeCaseController
   Company: Certainteed
   Author: Mukesh Bhardwaj (Threshold Consulting)
   Comments: Controller for the closeCase VF page
*/

public with sharing class closeCaseController {

    public String poNumber {get;set;} //PO Number from the URL
    public String orderNumber {get;set;} //order Number 
    public String shipTo {get;set;} //Ship To Number from the URL
    public String mode {get;set;} //sets the section header
    public String acName {get;set;} //Used for section header
    
    public List<Wrapper> WrapperList{get;set;}
    public Boolean isError{get;set;}
    
    public closeCaseController()
    {
        List<Case> caseList;
        isError = false;
        poNumber = ApexPages.currentPage().getParameters().get('po');
        shipTo = ApexPages.currentPage().getParameters().get('st');
        caseList = new List<Case>();
        WrapperList = new List<Wrapper>();
        
        if((poNumber == '' || poNumber == null) && (shipTo == '' || shipTo == null))
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Either PO or Ship To Customer must be specified in the URL. Please contact your System Administrator.'); //Error for missing Order Number.
            ApexPages.addMessage(myMsg);
            isError = true;
        }
        if(!isError)
        {
            Boolean poExists = false;
            if(poNumber != '' && poNumber != null)
            {
                List<Order> orderList = [Select Id, Name from Order where PONumber = :poNumber LIMIT 1];
                if(orderList.size() > 0)
                {
                    poExists = true;
                    mode = 'po';
                    String orderId = orderList.get(0).Id;
                    orderNumber = orderList.get(0).Name;
                    caseList = [Select Order__c, Id, 
                                        Status,     
                                        CaseNumber, 
                                        Account.name, 
                                        Contact.name, 
                                        Subject, 
                                        CreatedDate 
                                    from Case 
                                    where Order__c = :orderId 
                                        AND Status != 'Closed'];
                    if(caseList.size() > 0 ){
                        for(Case cs : caseList){
                            Wrapper w = new Wrapper();
                            w.cs = cs;
                            WrapperList.add(w);
                        }
                    }else{               
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, 'There are no open cases associated to the order number: '+orderNumber+'.\n PO# '+poNumber); //Error for Case.
                        ApexPages.addMessage(myMsg);
                        isError = true;
                    }                
                }
            }
            if((!isError) && (!poExists) && (shipTo != '' && shipTo != null))
            {
                List<Account> shipToAc = [Select Id, Name from Account where SAP_ACCOUNT__c =: shipTo LIMIT 1];
                if(shipToAc.size() > 0)
                {
                    acName = shipToAc.get(0).Name;
                    mode = 'st';
                    caseList = [Select Order__c, Id, 
                                        Status, 
                                        CaseNumber, 
                                        Account.Name, 
                                        Contact.Name, 
                                        Subject, 
                                        CreatedDate,
                                        Account.SAP_ACCOUNT__c
                                from Case 
                                where Account.SAP_ACCOUNT__c =: shipTo 
                                    AND Status != 'Closed'];
                    if(caseList.size() > 0 ){
                        for(Case cs : caseList){
                            Wrapper w = new Wrapper();
                            w.cs = cs;
                            WrapperList.add(w);
                        }
                    }else{               
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, 'There are no open cases associated to the Ship To Id: '+shipTo+'.'); //Error for Case.
                        ApexPages.addMessage(myMsg);
                        isError = true;
                    }
                }
                else
                {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Ship-To Id does not exists in Salesforce: '+shipTo+'.'); //Error for Case.
                    ApexPages.addMessage(myMsg);
                    isError = true;
                } 
            }
            else if((!poExists) && (shipTo == '' || shipTo == null))
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'The PO# specified does not exists in SFDC and Ship To is blank.'); //Error for Case.
                ApexPages.addMessage(myMsg);
                isError = true;
            }
        }
        
        
       /* else{
            List<Order> orderList = [Select Id from Order where Name = :orderNumber LIMIT 1];
            if(orderList.size() > 0)
            {
                Id orderId = orderList.get(0).Id;
                caseList = new List<Case>();
                WrapperList = new List<Wrapper>();
                caseList = [Select Order__c, Id, Status, CaseNumber, Account.name, Contact.name, Subject, CreatedDate from Case where Order__c = :orderId AND Status != 'Closed'];                
                if(caseList.size() > 0 ){
                    for(Case cs : caseList){
                        Wrapper w = new Wrapper();
                        w.cs = cs;
                        WrapperList.add(w);
                    }
                }else{               
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, 'There are no open cases associated to the order number: '+orderNumber); //Error for Case.
                    ApexPages.addMessage(myMsg);
                    isError = true;
                } 
            }
            else{               
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, 'No order can be found with the order number: '+orderNumber); //Error for missing order.
                ApexPages.addMessage(myMsg);
                isError = true;
            }
        }*/                  
    }

    //close selected cases. 
    public void CloseCase()
    {     
        try{ 
            List<Case> caseList = new List<Case>(); //To update
            Integer counter = 0;
            for(integer i = 0; i < WrapperList.size(); i++)
            {
                if(WrapperList.get(i).selected)
                {                  
                    counter = counter + 1;
                    WrapperList.get(i).cs.Status = 'Closed';
                    caseList.add(WrapperList.get(i).cs);
                    WrapperList.remove(i);
                }
            }
            if(counter == 0)
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Select at least one Case to Close.'); //Error if no check box is selected.
                ApexPages.addMessage(myMsg);
            }   
            if(caseList.size() > 0){
                upsert caseList;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Selected case(s) have been closed successfully.')); //Success message when saved successfully.
            }
        }
        catch(System.Exception e)
        {           
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage(),e.getMessage());
                ApexPages.addMessage(myMsg);     
                isError = true;   
        }
    }

    //Wrapper class
    public class Wrapper
    {
        public Case cs {get;set;}
        public Boolean selected {get; set;}
        public Wrapper()
        {   
            selected = false;       
        }
    }
}