/*
Author : Satyajit Chanda
Class: Portal_Case_Soap_Controller
Description : This is the SOAP web services class to integrate Hybris to Salesforce.
Modification : 
1.added new field Product_Notes__c in the CaseLineItem on 8/28/2017.
2.Change the inner class name from OrderLineItemDetails to CaseLineItemDetail on 8/28/2017.
3.added createdDate in case level on 9/7/2017.
4.Last four hours case record should fetch logic implemented on 9/12/2017.
*/

global with sharing class Portal_Case_Soap_Controller{

     global with sharing class CaseDetails{
      webservice ID CaseID;
      webservice String PortalCaseId;//PortalCaseId__c
      webservice String CaseNumber;//CaseNumber
      webservice String AdditionalContactName;//SuppliedName
      webservice String AdditionalContactEmail;//SuppliedEmail
      webservice String AdditionalContactPhoneNumber;//SuppliedPhone
      webservice String ReportedByName;//Contact.Name
      webservice String ReportedPersonPhNo;//Contact.Phone
      webservice String ReportedPersonEmail;//Contact.Email
      webservice String SoldToNo;//Order__r.Order_For_Account__r.BPCS_Account_ID__c
      webservice String ShipToNo;//Order__r.Ship_To_Account__r.BPCS_Account_ID__c
      webservice String PayerNo;//Order__r.Order_For_Account__r.parent.BPCS_Account_ID__c
      webservice String CaseResolution;//Resolution__c
      webservice String IssueType;//Type
      webservice String Subject;//Subject             
      webservice String CaseDescription;//Description    
      webservice String CustomerPoNumber;//Order__r.Customer_PO__c
      webservice String InvoiceNumber;//Order__r.Invoice_Number__c
      webservice String OrderNumber;//Order__r.BPCS_Order__c
      webservice String Division;//Account.Sales_Org__c      
      webservice String ProductNotes;//Order_Line_Items__c
      webservice String Url;//Documents__c     
      webservice String CaseType;//RecordType.Name
      webservice String CaseStatus;//Status
      webservice DateTime CaseCreatedDate;//CreatedDate;
      webservice List<CaseCommentDetail> CaseComments;
      webservice List<CaseLineItemDetail> CaseLineItems;        
    }         
    global with sharing class CaseCommentDetail{
        webservice Id CommentsId;        
        webservice Boolean isPublic;//IsPublished
        webservice String Notes;//CommentBody        
        webservice DateTime NotesAddedDate;//CreatedDate
        webservice String ContactNamewhoaddedNotes;//CreatedBy.Name
    }
    global with sharing class CaseLineItemDetail{
      webservice id OrderLineItemId;
      webservice String Products;//Product_Received__r.Name
      webservice Integer QTYAffected;//csLineItem.Quantity_Received__c
      webservice Integer QTYShipped;//csLineItem.Quantity_Ordered__c
      webservice String LineItemNo;//Item_Number__c
      webservice String Description;//Product_Ordered__r.Description
      webservice String Name;//Product_Ordered__r.Name
      webservice String ProductNote;//Product_Notes__c
    } 


    webService static List<CaseDetails> getPortalCases() {
      List<CaseDetails> lst_Casedetails = new List<CaseDetails>();
        
      Map<Id,Case> map_Cases = new Map<Id,Case>();
      Set<Id> set_OrderIds = new Set<Id>();
      Datetime fourHourBack = Datetime.now().addHours(-4);     
      List<Case> lst_Cases = [SELECT Id, CaseNumber, PortalCaseId__c, SuppliedName, SuppliedEmail, SuppliedPhone, Contact.Name, Contact.Phone, Contact.Email, Resolution__c, Type, Subject, CreatedById, 
                              CreatedDate, LastModifiedDate, Description, Account.LOB__c, Order_Line_Items__c, Documents__c, 
                              RecordType.Name, Status, 
                              Order__c, Order__r.Sold_To__r.SAP_ACCOUNT__c, Order__r.Ship_To__r.SAP_ACCOUNT__c, Order__r.Sold_To__r.Parent.SAP_ACCOUNT__c, 
                              Order__r.PONumber, Order__r.Invoice_Number__c, Order__r.BPCS_Order__c,Origin,CreatedBy.Name,
                              (SELECT Id,CommentBody,IsPublished,CreatedDate,CreatedBy.Name FROM CaseComments WHERE CreatedBy.Name != 'Integration User' AND IsPublished = True AND (Lastmodifieddate >= :fourHourBack OR CreatedDate >= :fourHourBack))
                              //FROM Case WHERE Order__C != null AND PortalCaseId__c != null AND (Lastmodifieddate = TODAY OR CreatedDate = TODAY)];
                              FROM Case WHERE Order__c != null AND PortalCaseId__c != null AND RecordType.Name != 'General Case' AND (Lastmodifieddate >= :fourHourBack OR CreatedDate >= :fourHourBack)];     
        for(Case cs : lst_Cases){
            map_Cases.put(cs.id, cs);
            set_OrderIds.add(cs.Order__c);
        }
        
       /* Map<ID, List<Case_Line_Item__c>> map_csLineItems = new Map<ID, List<Case_Line_Item__c>>();
        List<Case_Line_Item__c> lst_csLineItems;
        for(Case_Line_Item__c csLineItem : [SELECT Id, Order__c,Product_Ordered__r.Description, Product_Ordered__r.Name, Product_Received__r.Name,Quantity_Received__c,Quantity_Ordered__c,Item_Number__c, Product_Notes__c  
                                            FROM Case_Line_Item__c WHERE Order__c in: set_OrderIds]){
            if(map_csLineItems.containsKey(csLineItem.Order__c)){
                lst_csLineItems = map_csLineItems.get(csLineItem.Order__c); 
                lst_csLineItems.add(csLineItem);                
            }
            else{
                lst_csLineItems = new List<Case_Line_Item__c>();    
                lst_csLineItems.add(csLineItem);                
            }
            map_csLineItems.put(csLineItem.Order__c, lst_csLineItems);
        }*/
        
        CaseDetails caseDetails;
        List<CaseCommentDetail> caseCmtDetailList;
        CaseCommentDetail caseCmtDetails;
        
        List<CaseLineItemDetail> caseLineItemDetailList;
        CaseLineItemDetail caseLineItemDetails;
        for(Case cs : lst_Cases){
            caseDetails = new CaseDetails();
            caseDetails.CaseID = cs.id;
            caseDetails.CaseNumber = cs.CaseNumber;
            caseDetails.PortalCaseId = cs.PortalCaseId__c;
            caseDetails.AdditionalContactName = cs.SuppliedName;
            caseDetails.AdditionalContactEmail = cs.SuppliedEmail;
            caseDetails.AdditionalContactPhoneNumber = cs.SuppliedPhone;
            caseDetails.ReportedByName = cs.Contact.Name;
            caseDetails.ReportedPersonPhNo =cs.Contact.Phone;
            caseDetails.ReportedPersonEmail = cs.Contact.Email;
            caseDetails.SoldToNo = cs.Order__r.Sold_To__r.SAP_ACCOUNT__c;
            caseDetails.ShipToNo = cs.Order__r.Ship_To__r.SAP_ACCOUNT__c;
            caseDetails.PayerNo = cs.Order__r.Sold_To__r.parent.SAP_ACCOUNT__c;
            caseDetails.CaseResolution = cs.Resolution__c;
            caseDetails.IssueType = cs.Type;
            caseDetails.Subject = cs.Subject;          
            if(cs.Origin == 'Portal' && cs.CreatedBy.Name == 'Integration User'){
                caseDetails.CaseDescription = cs.Description;
            }
            else {
                caseDetails.CaseDescription = '';
            }                           
            caseDetails.CustomerPoNumber = cs.Order__r.PONumber;
            caseDetails.InvoiceNumber = cs.Order__r.Invoice_Number__c;
            caseDetails.OrderNumber = cs.Order__r.BPCS_Order__c;
            caseDetails.Division = cs.Account.LOB__c;      
            caseDetails.ProductNotes = cs.Order_Line_Items__c;
            caseDetails.URL = cs.Documents__c;     
            caseDetails.CaseType = cs.RecordType.Name;
            caseDetails.CaseStatus = cs.Status;
            caseDetails.CaseCreatedDate = cs.CreatedDate;
            
            caseCmtDetailList = new List<CaseCommentDetail>();
            if(cs.CaseComments != null){
                for(CaseComment csCmt : cs.CaseComments){                
                    caseCmtDetails = new CaseCommentDetail();
                    caseCmtDetails.CommentsId = csCmt.Id;
                    caseCmtDetails.isPublic = csCmt.IsPublished;
                    caseCmtDetails.Notes = csCmt.CommentBody;
                    caseCmtDetails.NotesAddedDate = csCmt.CreatedDate;
                    caseCmtDetails.ContactNamewhoaddedNotes = csCmt.CreatedBy.Name;
                    caseCmtDetailList.add(caseCmtDetails);
                }
            }            
            caseDetails.CaseComments = caseCmtDetailList;
            
            caseLineItemDetailList = new List<CaseLineItemDetail>();
           /* if(map_csLineItems.get(cs.Order__c) != null){
                for(Case_Line_Item__c csLineItem : map_csLineItems.get(cs.Order__c)){
                    caseLineItemDetails = new CaseLineItemDetail();
                    caseLineItemDetails.OrderLineItemId = csLineItem.Id;
                    caseLineItemDetails.Products =  csLineItem.Product_Received__r.Name;
                    caseLineItemDetails.Description = csLineItem.Product_Ordered__r.Description;
                    caseLineItemDetails.Name = csLineItem.Product_Ordered__r.Name;
                    if(csLineItem.Quantity_Received__c != null)
                        caseLineItemDetails.QTYAffected = Integer.valueOf(csLineItem.Quantity_Received__c);
                    if(csLineItem.Quantity_Ordered__c != null)
                        caseLineItemDetails.QTYShipped = Integer.valueOf(csLineItem.Quantity_Ordered__c);
                    caseLineItemDetails.LineItemNo = csLineItem.Item_Number__c;
                    caseLineItemDetails.ProductNote = csLineItem.Product_Notes__c;
                    
                    caseLineItemDetailList.add(caseLineItemDetails);
                }
            }  */          
            caseDetails.CaseLineItems = caseLineItemDetailList;
            
            lst_Casedetails.add(caseDetails);  
        }        
        return lst_Casedetails;
    } 
}