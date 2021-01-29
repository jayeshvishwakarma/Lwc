@isTest(SeeAllData = false)
public class Portal_Case_Soap_Controller_Test{

static testMethod void testgetPortalCases() {        
        List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType='Case' and isActive=true];       
        Map<String,String> rTypMap = new Map<String,String>{};
        
        for(RecordType rt: rtypes){
           rTypMap.put(rt.Name,rt.Id);
        }      
          
        Contact conObj = new Contact(FirstName='test',LastName='TestLast',Phone='12345',Email='test@test.com',MailingCity='TestCity',MailingState = 'CA', MailingStreet = 'Mailing Street');
        insert conObj; 
               
        Account acc = new Account(Name='TestAcc');
        insert acc;  
              
        Order orObj = new Order();
            orObj.Name='TestOrderNew';
            orObj.Sold_To__c=acc.id;
            orObj.Ship_To__c=acc.id;
            orObj.PONumber='01489828';
            //orObj.Invoice_Number__c='CT1546574';
            orObj.BPCS_Order__c='Test';
        insert orObj;
        
        Case cObj = new Case(RecordTypeId=rTypMap.get('Portal'),Order__c= orObj.id,ContactId=conObj.id);
            cObj.PortalCaseId__c = 'TestPortalCaseId';
            cObj.SuppliedName= 'Testname';
            cObj.SuppliedEmail= 'abc@cde.com';
            cObj.SuppliedPhone= '(999) 924-5712';
            cObj.Resolution__c= 'General Case';
            cObj.Type= 'Order Change';
            cObj.Subject= 'Test Soap';               
            cObj.Description= 'test Sucessfull';       
            cObj.Order_Line_Items__c = 'Test Comment 1';
            cObj.Documents__c= 'http://certainteedcustomerportal/maptest';     
            cObj.Status = 'Sucess'; 
        insert cObj;
        
        CaseComment obj_Comments = new CaseComment();
        obj_Comments.IsPublished = true;
        obj_Comments.CommentBody='Test';
        obj_Comments.ParentId = cObj.id;
        insert obj_Comments;
        
      /*  Case_Line_Item__c obj_LineItems = new Case_Line_Item__c();
        obj_LineItems.Order__c = orObj.id;
        insert obj_LineItems;
        
        obj_LineItems = new Case_Line_Item__c();
        obj_LineItems.Order__c = orObj.id;
        obj_LineItems.Quantity_Received__c = 10;
        insert obj_LineItems; */

        Test.startTest();
       
        Portal_Case_Soap_Controller.getPortalCases();
        
        Test.stopTest();
    }
}