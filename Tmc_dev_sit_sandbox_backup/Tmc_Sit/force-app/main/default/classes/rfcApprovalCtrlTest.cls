@isTest
public class rfcApprovalCtrlTest{
    static list<User> spocUser = new list<User>();
    static list<User> spocUser1 = new list<User>();
    @testSetup
    static void createTestData(){
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

         //For Code Creation
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;

         //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;

        //Contacts Creation
        List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert conList;

        List<Contact> conList1 = TestDataFactory.createTestContact(1, accList[0].Id);
        insert conList1;

        spocUser = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
        insert spocUser;

        spocUser1 = TestDataFactory.createUserData('Portal', 'Dealer Sales Executive', conList1);
        insert spocUser1;
        List<AccountContactRelation> acr = [select id , roles from AccountContactRelation];
        for(AccountContactRelation acrl : acr){
         acrl.roles ='True Value Manager';
        }

        update acr;


        // create an opportunity with stage booking

        List<Opportunity> oppLists = TestDataFactory.createTestOpportunity(2,'Vehicle Sales');
        for(opportunity oppList :oppLists){
        oppList.stageName = 'New';
        }
        insert oppLists;
        for(opportunity oppList :oppLists){
        oppList.stageName = 'Booking';
        oppList.Dealership__c = accList[0].id;
        }
        update oppLists;

        rfc__c rfc = new rfc__c();
        rfc.Enquiry__c = oppLists[0].id;
        rfc.RFC_Status__c = 'Pending with FM';
        rfc.Payment__c =  ConstantsUtility.Payment_DealerFinance;
        rfc.Active__c=true;
        rfc.Exchange__c = ConstantsUtility.YES;
        insert rfc;
        rfc__c rfc1 = new rfc__c();
        rfc1.Enquiry__c = oppLists[1].id;
        //rfc.RFC_Status__c = 'Pending with FM';
        rfc1.Payment__c =  ConstantsUtility.Payment_DealerFinance;
        rfc1.Active__c=true;
        insert rfc1;

    }


    @isTest static void testAccountContactRole(){
        List<AccountContactRelation> acr = [select id , roles from AccountContactRelation];
        for(AccountContactRelation acrl : acr){
         //acrl.roles ='True Value Manager';
          acrl.roles = ConstantsUtility.QCM+';'+ConstantsUtility.True_Value_Manager+';'+ConstantsUtility.Accounts_Manager+';'+ConstantsUtility.Allotment_Manager+';'+ConstantsUtility.ACR_FINANCE_MANAGER+';'+ConstantsUtility.SHOWROOM_MANAGER ;
        }
        Test.startTest();
         update acr;
        Test.stopTest();

    }

     @isTest static void testUpdateRfc(){
        test.starttest();
        List<AccountContactRelation> acr = [select id , roles from AccountContactRelation];
        for(AccountContactRelation acrl : acr){
          acrl.roles = ConstantsUtility.QCM+';'+ConstantsUtility.True_Value_Manager+';'+ConstantsUtility.Accounts_Manager+';'+ConstantsUtility.Allotment_Manager+';'+ConstantsUtility.ACR_FINANCE_MANAGER+';'+ConstantsUtility.SHOWROOM_MANAGER ;
        }

        update acr;

        List<RFC__c> rfcList = [select id from rfc__c];

        for(rfc__C rfcObj : rfcList){
          rfcObj.Exchange__c = ConstantsUtility.YES;
          rfcObj.Payment__c =  ConstantsUtility.Payment_DealerFinance;
        }
        update rfcList;

        for(rfc__C rfcObj : rfcList){
          rfcObj.Exchange__c = ConstantsUtility.YES;
        }
        update rfcList;

        for(rfc__C rfcObj : rfcList){
          rfcObj.True_Value_Approval_Status__c ='Pending';
          rfcObj.Exchange__c = ConstantsUtility.YES;
        }
        update rfcList;
        for(rfc__C rfcObj : rfcList){
          rfcObj.Accounts_Approval_Status__c = 'Pending';
          rfcObj.Exchange__c = ConstantsUtility.YES;
        }
        update rfcList;

        for(rfc__C rfcObj : rfcList){
          rfcObj.SM_Approval_Status__c = 'Pending';
        }
        update rfcList;



        test.stoptest();
    }

    // rfc approval controller list
    @isTest static void testGetMDTListData5(){
        Test.startTest();
        rfcApprovalCtrl.getMDTListData('FM');
        Test.stopTest();
    }
    // covering rfc controller class
     @isTest static void testGetAccContRelationValidataion(){
        List<RFC__c> rfc = [select id,name from rfc__c];
        Test.startTest();
        rfcApprovalCtrl.getAccContRelationValidataion('FM',rfc[0].id);
        rfcApprovalCtrl.getLookupData('abc', '12357');
        Test.stopTest();

    }


    // test for the preliminary checklist trigger

    @isTest static void testPreliminaryChecklist(){
        Test.startTest();
        List<User> userList = [select id from user where profile.name='Dealer Sales Executive' and contactid != null and isActive = true];

        List<AccountContactRelation> acr = [select id , roles from AccountContactRelation];
        for(AccountContactRelation acrl : acr){
          acrl.roles = ConstantsUtility.ACR_FINANCE_MANAGER;
        }
        update acr;

        List<Opportunity> oppList = [select id , name from opportunity];
        for(opportunity opp : oppList){
         opp.VIN__c ='KLSDJFSDLKJFSD';
         opp.Allotment_Status__c='Allotted';
        }

        update oppList;

        //system.runAs(userList[0]){
        List<Preliminary_Checklist__c> pcList = [select id,Profession_Type__c from Preliminary_Checklist__c];
        PreliminaryChecklistCtrl.getProfessionType(pcList[0].id);
        PreliminaryChecklistCtrl.getMDTListData('Checklist FM','Self employed');
        PreliminaryChecklistCtrl.getAccContRelationValidataion('Checklist FM', pcList[0].id);
        //}

        test.stoptest();
    }

    @isTest static void removeAccountContactRelationTest(){
      List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;
     List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;

        //Contacts Creation
        List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert conList;
        conList[0].accountid = null;
        update conList ;
    }


}