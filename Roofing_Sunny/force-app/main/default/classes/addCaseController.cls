/*
    Name: addCaseController
    Company: Certainteed
    Author: Mukesh Bhardwaj (Threshold Consulting)
    Comments: Controller for add Case VF page
    Changes: 4th May, 2013 Initial version.
*/
public Class addCaseController{  

    private Order orderRec {get;set;}
    private Case caseRec {get;set;}
    private Account acc {get;set;} 
    private Plants__c wareHouse {get;set;}
    private String generalCaseRTId {get;set;}     
    private String orderNumber {get;set;}
    //private String orderEntryDate {get;set;}    
    private String custPO {get;set;}
    //private String orderTotal {get;set;}
    //private String schduleShipDate {get;set;}
    private String shipToId {get;set;}
    private String wareHouseCode {get;set;} 
    private boolean errorFlag;
    private boolean insertOrder {get;set;}
      
    public addCaseController(){ 
        errorFlag = false;
        insertOrder = false;      
        orderNumber = ApexPages.currentPage().getParameters().get('on');        
        //orderEntryDate = ApexPages.currentPage().getParameters().get('oed');        
        custPO = ApexPages.currentPage().getParameters().get('cpo');
        //orderTotal = ApexPages.currentPage().getParameters().get('ot'); 
        //schduleShipDate = ApexPages.currentPage().getParameters().get('ssd');
        shipToId= ApexPages.currentPage().getParameters().get('sti');
        wareHouseCode = ApexPages.currentPage().getParameters().get('wh'); 
        
        if(orderNumber == '' || orderNumber == null){    //error when Order Number not Found.
            errorFlag = true;
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Order Number not found.');
            ApexPages.addMessage(errorMsg);
        }
        /*if(orderEntryDate == '' || orderEntryDate == null){    //error when Order Entry Date not Found..
            errorFlag = true;
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Order Entry Date not found.');
            ApexPages.addMessage(errorMsg);
        } */
        if(custPO == '' || custPO == null){    //error when Customer PO# not Found.
            errorFlag = true;
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Customer PO# not found.');
            ApexPages.addMessage(errorMsg);
        }
        /*if(orderTotal == '' || orderTotal == null){    //error when Order Total not Found.
            errorFlag = true;
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Order Total not found.');
            ApexPages.addMessage(errorMsg);
        }*/  
        /*if(schduleShipDate == '' || schduleShipDate == null){    //error when Schedule Ship Date not Found.
            errorFlag = true;
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Scheduled Ship Date not found.');
            ApexPages.addMessage(errorMsg);
        }*/
        if(shipToId == '' || shipToId == null){    //error when Ship To Account not Found.
            errorFlag = true;
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Ship-To Id not found.');
            ApexPages.addMessage(errorMsg);
        } 
        if(wareHouseCode == '' || wareHouseCode == null){    //error when wareHouseCode not Found.
            errorFlag = true;
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Warehouse Code not found.');
            ApexPages.addMessage(errorMsg);
        }           
        
        if(!errorFlag){
            checkOrderNumber();
        }                              
    }
    
    public void checkOrderNumber(){
        Schema.DescribeSObjectResult caseSobj = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> rtMapByName = caseSobj.getRecordTypeInfosByName();
        generalCaseRTId = rtMapByName.get('General Case').getRecordTypeId();
        
        List<Account> acList = [Select Id, SAP_ACCOUNT__c from Account where SAP_ACCOUNT__c =: shipToId LIMIT 1];
        if(acList.size() > 0)
            acc = acList.get(0);
        
        List<Plants__c> whList = [Select Id from Plants__c where Plant_Code__c = :wareHouseCode];
        if(whList.size() > 0)
            wareHouse = whList.get(0);
            
        List<Order> orderList = [Select Id, Name, OwnerId, EffectiveDate, PONumber, Planned_Ship_Date__c from Order WHERE Order_Num__c =: orderNumber LIMIT 1];
        if(orderList.size() > 0)
            orderRec = orderList.get(0);

        if(orderRec != null){
            caseRec = new Case();
            caseRec.Order__c = orderRec.id;
            //caseRec.OwnerId = orderRec.Ownerid;
            orderRec.OwnerId = UserInfo.getUserId();
            caseRec.Order_Number__c = orderNumber;
            if(acc != null)
                caseRec.AccountId = acc.id;  
            if(wareHouse != null)
                caseRec.Location__c = wareHouse.Id;                 
            caseRec.RecordTypeId = generalCaseRTId;                  
        }
        else{ // if orderNumber Not Match from any database Order record Create New Order
            orderRec = new Order();
            orderRec.Name = orderNumber;
            orderRec.Order_Num__c = orderNumber;
            //orderRec.Order_Entry_Date__c = Date.valueOf(orderEntryDate);
            orderRec.PONumber = custPO;
            orderRec.OwnerId = UserInfo.getUserId();
            //orderRec.Order_Total__c = Decimal.valueOf(orderTotal);
            //orderRec.Schedule_Date__c = Date.valueOf(schduleShipDate);
            if(acc != null)
                orderRec.Ship_To__c = acc.id;
            if(wareHouse != null)
                orderRec.Manufacturing_Plant__c = wareHouse.Id;
            insertOrder = true;
        }
    }                   
     
    public PageReference saveCaseRec(){ 
        if(!errorFlag){
            if(insertOrder){
                try{
                    insert orderRec;
                }catch(System.Exception e){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage(), e.getMessage());
                    ApexPages.addMessage(myMsg);
                    return null;
                }
            }
            if(insertOrder){
                caseRec = new Case();
                caseRec.Order__c = orderRec.id;
                caseRec.Order_Number__c = orderNumber;
                //caseRec.OwnerId = orderRec.OwnerId;
                caseRec.OwnerId = UserInfo.getUserId();
                if(acc != null)
                    caseRec.AccountId = acc.id;
                if(wareHouse != null)
                    caseRec.Location__c = wareHouse.Id;
                caseRec.RecordTypeId = generalCaseRTId;
            }
            try{
                insert caseRec;
            }catch(System.Exception e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage(), e.getMessage());
                ApexPages.addMessage(myMsg);
                return null;
            }
            pageReference pg = new pageReference('/'+caseRec.Id+'/e?retURL=%2F'+caseRec.id);
            return pg;
        }
        else
            return null; 
    }

}