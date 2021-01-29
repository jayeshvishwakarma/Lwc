@isTest
public class FinanceChecklistPDFControllerTest {
    @testSetup
    static void recordCreation(){
        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';

        Insert IS;
		
		SF_Retry_Custom_Setting__c cs = new SF_Retry_Custom_Setting__c();
        cs.Name='test';
        cs.LoginEndPoint__c = 'test.com';
        cs.PassWord__c= 'test.com';
        cs.updatePatchEndPoint__c= 'test.com';
        cs.UserName__c = 'test.com';
        cs.Retry__c = false;
        insert cs;

        Opportunity opp = new Opportunity();
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].StageName = 'New';
        insert oppList;
        MC_Communication__c mcObj = new MC_Communication__c();
        mcObj.Enquiry_MD__c = oppList[0].Id;
        mcObj.LOB__c= 'Nexa';
        mcObj.Checklist_Type__c = 'Proprietorship';
        mcObj.Type__c = 'Finance Checklist';
        insert mcObj;


    }
    @isTest
    static void testFCPDFPositiveCase(){
        List<MC_Communication__c> mcList = new List<MC_Communication__c>([SELECT id from MC_Communication__c WHERE Checklist_Type__c = 'Proprietorship'
                                                                          and Type__c = 'Finance Checklist' LIMIT 1]);
        PageReference pageRef = Page.FinanceChecklistPDF;
        Test.setCurrentPage(pageRef);
        String mcId = 'A'+ EncodingUtil.base64Encode(Blob.valueOf(mcList[0].Id)) + 'Z';
        ApexPages.currentPage().getParameters().put('id',mcId);
        FinanceChecklistPDFController obj = new FinanceChecklistPDFController();
    }
    @isTest
    static void testFCPDFNegativeCase(){
        PageReference pageRef = Page.FinanceChecklistPDF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',null);
        FinanceChecklistPDFController obj = new FinanceChecklistPDFController();
    }

}