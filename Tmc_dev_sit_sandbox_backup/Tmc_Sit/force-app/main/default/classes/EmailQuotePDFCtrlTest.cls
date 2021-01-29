/**
 * @File Name          : EmailQuotePDFCtrlTest.cls
 * @Description        :
 * @Author             : Anuj Kumar
 * @Group              :
 * @Last Modified By   : Anuj Kumar
 * @Last Modified On   : 26/08/2019 05:30 PM
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    26/08/2019 05:30 PM          Anuj Kumar            Initial Version
**/

@isTest
private class EmailQuotePDFCtrlTest{
    @testSetup
    static void CreateRecords(){
        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
        
      quote_Template_Infos__c qt = new Quote_Template_Infos__c();
        qt.SetupOwnerId=UserInfo.getOrganizationId();
        qt.Quote_Arena__c = 'arenaId';
        qt.Quote_Nexa__c = 'nexaId';
        insert qt;
       
        //For Code Creation
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;
        
         //Accounts Creation
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        userAccountList[0].For_Code__c = forCodeList[0].Id;
        insert userAccountList;
       
        List<Contact> conList = TestDataFactory.createTestContact(1, userAccountList[0].Id);
        insert conList;
        System.assertEquals(1, conList.size());
       
        List<User> usr = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
        insert usr; 
        
         List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Current_Open_Follow_up__c = null;
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = usr[0].Id;
        
        Opportunity opp = oppList[0];
        opp.First_Name__c = 'Test Name';
        opp.Dealership__c = userAccountList[0].Id;
        opp.Line_Of_Business__c = 'Nexa';
        insert oppList;
        System.assertEquals(1, oppList.size());
        
        List<Quote> quoteList = TestDataFactory.generateQuoteData(1, oppList[0].Id);
        insert quoteList;
        System.assertEquals(1, quoteList.size());
    }
   
    static testMethod Void codeCoverageMethodForScenario1(){
   
        list<user> usr = new list<user>([SELECT id from user]);
        system.runAs(usr[0]){
        List<Quote> quoteList = new list<Quote>([SELECT id from Quote]);
        Test.startTest();
            EmailQuotePDFCtrl.retriveQuoteTemplateInfo(quoteList[0].id);
            EmailQuotePDFCtrl.createPublicLinkForFile(quoteList[0].id);
        Test.stopTest();
       }
    }
}