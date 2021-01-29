/**
* @File Name          : LostEnquiresControllerTest
* @Description        : This class is for LostEnquiresController
* @Created By         : Navin Soni
* @Created Date       : 18/06/2020
*/
@isTest
public class LostEnquiresControllerTest{
    @testSetup
    static void createRecord(){
        
        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
        
        Implementation_Strategy__c IS2 = new Implementation_Strategy__c();
        IS2.Name  = '2';
        IS2.Identifier_Type__c = 'Record Type';
        IS2.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS2.Strategy_Key__c = 'Accessories_Sales';
        IS2.Use_Case__c = 'OpportunityTriggers';
        Insert IS2;
		
		SF_Retry_Custom_Setting__c cs = new SF_Retry_Custom_Setting__c();
        cs.Name='test';
        cs.LoginEndPoint__c = 'test.com';
        cs.PassWord__c= 'test.com';
        cs.updatePatchEndPoint__c= 'test.com';
        cs.UserName__c = 'test.com';
        cs.Retry__c = false;
        insert cs;
        
        list<Account> acclist = TestDataFactory.createBusinessAccount(1,'Dealer');
        insert acclist;
        acclist[0].Parent_Group__c = 'PREM';
        acclist[0].Dealer_Map_Code__c = '45342';
        acclist[0].Dealer_Location__c =  'DEL';
        update acclist[0];
        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        
        list<Opportunity> opplist = TestDataFactory.createTestOpportunity(1,'Vehicle Sales');
        for(Opportunity opp : opplist){
            opp.stageName = 'New';
            opp.Customer__c = personAccountList[0].Id;
            opp.Dealership__c = acclist[0].Id;
            opp.DMS_Enquiry_Name__c= 'ENQ51634';
         }
        insert opplist;
        
        Enq_Matching__c match = new Enq_Matching__c();
        match.Parent_Group__c ='PREM';
        match.Dealer_Map_Code__c ='45342';
        match.Dealer_Location__c ='DEL';
        match.Enquiry_Number__c ='ENQ51634';
        match.DMS_SF_Id__c =opplist[0].Id;
        
        insert match;
    }
    static list<User> spocUser = new list<User>();
    static testMethod void validateLostEnquires(){
        Test.startTest();
        
         //For Code Creation
        List<For_Code__c> forCodeList1 = TestDataFactory.createTestForCode(1);
        insert forCodeList1;
        
         //Accounts Creation
        List<Account> accList1 = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList1[0].For_Code__c = forCodeList1[0].Id;
        insert accList1;
        
        //Contacts Creation 
        List<Contact> conList1 = TestDataFactory.createTestContact(1, accList1[0].Id);
        insert conList1;
        
        spocUser = TestDataFactory.createUserData('Portal', 'Dealer Team Leads/Managers', conList1);
        spocUser[0].Designation__c = 'TL';
        insert spocUser;
        
        //Contacts Creation 
        List<Contact> conList2 = TestDataFactory.createTestContact(1, accList1[0].Id);
        insert conList2;
        
        list<User> dseUser = TestDataFactory.createUserData('Portal', 'Dealer Sales Executive', conList2);
        dseUser[0].Designation__c = 'SAE';
        dseUser[0].ManagerId = spocUser[0].Id;
        insert dseUser;
                        
        List<User> userDetail = [SELECT Id,ContactId,Contact.AccountId FROM User WHERE Id in:spocUser];
        
        Account acc = new Account();
        acc.name ='Test Nexa';
        acc.Sales_SPOC_1__c = spocUser[0].Id;
        acc.Sales_SPOC_2__c = spocUser[0].Id;
        acc.Sales_SPOC_3__c = spocUser[0].id;
        acc.Sales_SPOC_4__c = spocUser[0].id;
        acc.Sales_SPOC_5__c = spocUser[0].id;
        acc.Accessories_SPOC_1__c = spocUser[0].id;
        acc.Accessories_SPOC_2__c = spocUser[0].id;
        acc.Territory_Sales_Manager__c = spocUser[0].id;
        acc.Finance_Manager__c = spocUser[0].id;
        acc.TSM_ISL__c = spocUser[0].id;
        acc.TSM_Rural__c = spocUser[0].id;
        acc.TSM_MGA__c = spocUser[0].id;
        acc.Id = userDetail[0].Contact.AccountId;
        update acc;
        
        //Create Business Account 
        list<Account> objList= TestDataFactory.createBusinessAccount(1,'User Account');
        objList[0].user__c = spocUser[0].id;
        objList[0].Territory_Sales_Manager__c = userDetail[0].id;
        objList[0].TSM_ISL__c = userDetail[0].id;
        insert objList;
        
        //Create Product
        list<product2> productList = TestDataFactory.createProducts('Variants', 1);
        productList[0].Model__c = 'BA';
        productList[0].Enquiry__c = 'Yes';
        
        Insert productList;
       
        //Create Vehicle Enquiry
        String recortype = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Vehicle Sales').getRecordTypeId();
        String recortype2 = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Accessories Sales').getRecordTypeId();
        
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = label.Integration_user;
        
        
        for(Opportunity opp : opplist){
            opp.Dealership__c = acc.Id;
            opp.Accessories_DSE1__c = spocUser[0].id;
            opp.Type_of_Escalation__c = 'DSE Allocation Time';
            opp.Time_for_Next_Escalation__c = DateTime.newInstance(2019, 11, 15, 11, 25, 33);
            opp.RecordTypeId = recortype;
        }
        insert opplist;
        
        List<Opportunity> oppList2 = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList2[0].accountId = userAccountList[0].id;
        oppList2[0].StageName = 'Open';
        oppList2[0].Customer__c= personAccountList[0].Id;
        oppList2[0].ownerId = dseUser[0].Id;
               
        for(Opportunity opp : opplist2){
            opp.Dealership__c = acc.Id;
            opp.Accessories_DSE1__c = spocUser[0].id;
            opp.RecordTypeId = recortype2;
            opp.Vehicle_Registration__c = '12345';
        }
        insert opplist2;
        
        
        Bypass_Setting__c bypass = new Bypass_Setting__c();
        bypass.Skip_MC_Record_Creation__c = true;
        insert bypass;
                
        Task up_tk = new Task();
        up_tk.Enquiry_Scoring__c = 'F'; 
        up_tk.Reason__c = 'Finance problem';
        up_tk.SubReason__c = 'Loan not approved';
        up_tk.Enquiry_Stage__c = 'E';
        up_tk.WhatId = opplist2[0].id;
        Insert up_tk;
        
        //Submit Enquiry for Approval
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(opplist2[0].id);
        Approval.ProcessResult result = Approval.process(app);
        
        System.runAs(spocUser[0]) {
            LostEnquiresController.getValidUser();
            LostEnquiresController.getUserList(acc.Id, 'John');
            List<LostEnquiresController.LostEnquiresWrapper> listOfLostEnquiresWrapper = new List<LostEnquiresController.LostEnquiresWrapper>();
            listOfLostEnquiresWrapper = LostEnquiresController.fetchLostEnquires();
            listOfLostEnquiresWrapper[0].isSelected = True;
            LostEnquiresController.ApprovalAllEnquiryRecordSF(listOfLostEnquiresWrapper, True);
        }
        Test.stopTest();
    }
}