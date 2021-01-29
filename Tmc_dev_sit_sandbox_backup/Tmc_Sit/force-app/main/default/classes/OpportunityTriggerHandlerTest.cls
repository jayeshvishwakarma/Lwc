/**
 * @description       : 
 * @author            : Rajesh Ramachandran
 * @group             : 
 * @last modified on  : 10-19-2020
 * @last modified by  : Rajesh Ramachandran
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   10-19-2020   Rajesh Ramachandran   Initial Version
**/
@isTest(seeAlldata=False)
public class OpportunityTriggerHandlerTest {
    static list<User> spocUser = new list<User>();

    @testSetup
    static void createTestData(){

		SF_Retry_Custom_Setting__c cs = new SF_Retry_Custom_Setting__c();
        cs.Name='test';
        cs.LoginEndPoint__c = 'test.com';
        cs.PassWord__c= 'test.com';
        cs.updatePatchEndPoint__c= 'test.com';
        cs.UserName__c = 'test.com';
        cs.Retry__c = false;
        insert cs;

        Custom_Validation_Exception_Setting__c cv = new Custom_Validation_Exception_Setting__c();
        cv.Name = 'All';
        cv.Referral_Logic_Run__c = true;
        cv.Bypass_Validation_Rules__c= true;
        cv.AvoidStageChanges__c = ':Pre-Booking:Retail:Delivery/Closed Won:Closed Lost:';
        Insert cv;

        CDC_TimeSet__c cdc = new CDC_TimeSet__c();
        cdc.Name = 'First';
        cdc.TimeSetUp__c = system.today();

        Insert cdc;

        GlobalSwitchOn__c gs = new GlobalSwitchOn__c();
        gs.Name = 'Email';
        gs.Create_Dummy_Account__c = true;

        Insert gs;

        // Custom Setting
        List<Implementation_Strategy__c> isCSList = new List<Implementation_Strategy__c>();
        isCSList.add(TestDataFactory.createIS('1','Record Type','OpportunityVehicleTriggerServiceImpl','Vehicle_Sales','OpportunityTriggers'));
        isCSList.add(TestDataFactory.createIS('2','Record Type','OpportunityMSDSTriggerServiceImpl','MSDS','OpportunityTriggers'));
        isCSList.add(TestDataFactory.createIS('3','Record Type','OpportunityAccessoriesTriggerServiceImpl','Accessories_Sales','OpportunityTriggers'));
        isCSList.add(TestDataFactory.createIS('4','Record Type','OpportunityLoyaltyTriggerServiceImpl','Loyalty_Enrollment','OpportunityTriggers'));
	isCSList.add(TestDataFactory.createIS('5','Record Type','OpportunityPartsTriggerServiceImpl','Parts','OpportunityTriggers'));

        Insert isCSList;

        //Create Spoc user

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

        spocUser = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
        insert spocUser;

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
        personAccountList[0].BillingStreet = 'vVSSOmnEyxUmGAPhWGooznJbVNAZSanFedwzlhsPTJWwUfVJFVklVyORpByusuOWpcbhmbAEaRKhsWCIonnzFZknIZOPtttLXRxi';
        insert personAccountList;
        List<Opportunity> oppMasterList = new List<Opportunity>();
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
        oppMasterList.addAll(opplist);
        //insert opplist;

        List<Opportunity> oppList2 = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList2[0].accountId = userAccountList[0].id;
        oppList2[0].StageName = 'New';
        oppList2[0].Customer__c= personAccountList[0].Id;
        oppList2[0].ownerId = label.Integration_user;

        for(Opportunity opp : opplist2){
            opp.Dealership__c = acc.Id;
            opp.Accessories_DSE1__c = spocUser[0].id;
            opp.RecordTypeId = recortype2;
            opp.Vehicle_Registration__c = '12345';
        }
        //insert opplist2;
        oppMasterList.addAll(opplist2);
        //Create Accessoires Enquiry
        String accessoriesrecortype = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Accessories Sales').getRecordTypeId();

        List<Opportunity> accessoriesopplist = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        accessoriesopplist[0].accountId = userAccountList[0].id;
        accessoriesopplist[0].StageName = 'New';
        accessoriesopplist[0].Customer__c= personAccountList[0].Id;
        accessoriesopplist[0].ownerId = label.Integration_user;

        for(Opportunity opp : accessoriesopplist){
            opp.Dealership__c = acc.Id;
            opp.Vehicle_Registration__c = 'TYU56789';
            opp.RecordTypeId = accessoriesrecortype;
            opp.Booking_Cancellation_Reason__c = 'Post-Pone';
        }
        //insert accessoriesopplist;
        oppMasterList.addAll(accessoriesopplist);


        personAccountList[0].SVOC_ID__c = 'TMC12345';
        update personAccountList;

        //Create MC Communication Records
        list<MC_Communication__c> mcComList  = TestdataFactory.createMCCommData(3,opplist[0].Id);
        insert mcComList;



        //Create Color Variant Master
        List<Color_Variant_Master__c> colorList = TestdataFactory.createColorVarientRealetdToProduct(1, productList[0].Id);
        insert colorList;

        RandomUtility.generateRandomFromRange(1,5);
        RandomUtility.generateRandomNumber(3);
        RandomUtility.generateRandomBoolean();
        RandomUtility.findRandomStringFromList(new list<String>{'1','2','3'});

        User u = [Select Id from User where Name =: 'DMS Admin'];
        System.RunAs(u)
        {
            List<Opportunity> oppList4 = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
            oppList4[0].accountId = userAccountList[0].id;
            oppList4[0].StageName = 'New';
            oppList4[0].Customer__c= personAccountList[0].Id;
            oppList4[0].ownerId = label.Integration_user;
            oppList4[0].Dealership__c = acc.Id;
            oppList4[0].Accessories_DSE1__c = spocUser[0].id;
            oppList4[0].RecordTypeId = recortype2;
            oppList4[0].Vehicle_Registration__c = '12345';
            insert opplist4[0];
        }
        List<Opportunity> oppList4 = TestDataFactory.createTestOpportunity(1, ConstantsUtility.Opportunity_Loyalty_Enrolment_RECORDTYPE);
        oppList4[0].stageName= 'New';
      //  oppList4[0].Acc_Current_Month__c = 'New';
       // oppList4[0].stageName= 'New';
        //insert oppList4;
        oppMasterList.addAll(oppList4);

        insert oppMasterList;


    }
    static testmethod void validatePartsTrigger(){
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;

        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        personAccountList[0].BillingStreet = 'vVSSOmnEyxUmGAPhWGooznJbVNAZSanFedwzlhsPTJWwUfVJFVklVyORpByusuOWpcbhmbAEaRKhsWCIonnzFZknIZOPtttLXRxi';

        insert personAccountList;
        Test.startTest();
        List<Opportunity> oppPartList = TestDataFactory.createTestOpportunity(1, 'Parts');
        oppPartList[0].accountId = userAccountList[0].id;
        oppPartList[0].StageName = 'New';
        oppPartList[0].Current_Open_Follow_up__c = null;
        oppPartList[0].Customer__c= personAccountList[0].Id;

        insert oppPartList;

        update oppPartList;
        Test.stopTest();

    }

    static testmethod void validateUniquenessCheck(){
        //For Code Creation
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;

        //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        accList[0].Dealer_Map_Code__c= '101';
        accList[0].Dealer_Location__c = 'AJ';
        insert accList;
        Test.startTest();
        try{

        User u = [Select Id from User where Name =: 'DMS Admin'];
        System.RunAs(u)
        {
            List<Opportunity> oppList4 = TestDataFactory.createTestOpportunity(2, 'Vehicle Sales');
            oppList4[0].DMS_Enquiry_Name__c= 'DMS007';
            oppList4[1].DMS_Enquiry_Name__c= 'DMS007';
            oppList4[0].Dealership__c= accList[0].Id;
            oppList4[1].Dealership__c= accList[0].Id;
            oppList4[0].StageName= 'New';
            oppList4[1].StageName= 'New';
            insert oppList4[0];

            insert oppList4[1];
            update oppList4[0];
        }
            Test.stopTest();
        }catch(Exception ex){
            system.debug('error');
        }
    }

    /*static testmethod void validatecreateLoyaltyEnrolmentFollowUps(){
        Test.startTest();
        String recortypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get(ConstantsUtility.Opportunity_Loyalty_Enrolment_RECORDTYPE).getRecordTypeId();
        try{
            List<Opportunity> oppList4 = [Select id from Opportunity where recordTypeId =: recortypeId];

            if(!oppList4.isEmpty()){
                Opportunity opp = new Opportunity();
                opp.Id = oppList4[0].Id;
                opp.Acc_Value_Current_Month__c = 10;

                User u = [Select Id from User where Name =: 'DMS Admin'];
                u.Designation__c = 'QCM';
                update u;
                System.RunAs(u)
                {
                    opp.OwnerId = u.Id;
                    update opp;
                }
            }

        }catch(Exception ex){
            system.debug('error');
        }
        Test.stopTest();

    }*/

    @isTest static void testSPOCAssignment(){
        Test.startTest();
        List<Opportunity> oppLists = new list<Opportunity>([SELECT OwnerId FROM Opportunity WHERE Recordtype.Name=:'Vehicle Sales']);
        List<Account> dealers = new list<Account>([SELECT Sales_SPOC_1__c FROM Account WHERE Recordtype.Name=:'Dealer']);
        system.assertEquals(label.Integration_user, oppLists[0].OwnerId);
        Test.stopTest();
    }

    @isTest static void testAssignEnquirytoSalesSPOC(){
        Test.startTest();

        String recortype2 = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Accessories Sales').getRecordTypeId();

        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;

         //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;

        //Contacts Creation
        List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert conList;

        spocUser = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
        insert spocUser;

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

        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;

        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;

        User u = [Select Id from User where Name =: 'DMS Admin'];

        system.runAs(u){

            List<Opportunity> oppList2 = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
            oppList2[0].accountId = userAccountList[0].id;
            oppList2[0].StageName = 'New';
            oppList2[0].Customer__c= personAccountList[0].Id;
            oppList2[0].ownerId = label.Integration_user;

            for(Opportunity opp : opplist2){
                opp.Dealership__c = acc.Id;
                opp.Accessories_DSE1__c = spocUser[0].id;
                opp.RecordTypeId = recortype2;
                opp.Vehicle_Registration__c = '12345';
            }
            insert opplist2;
        }
        Test.stopTest();
    }

    @istest
    static void testupdateDealerUser(){
        Test.startTest();

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

        list<user> spoclist2 =new list<user>(TestDataFactory.createUserData('Portal', 'Dealer Team Leads/Managers', conList));
        insert spoclist2;
        //list<Account> acc = new list<account>([SELECT id,recordtypeId,user__c from account]);
        List<Opportunity> oppLists = new list<Opportunity>([SELECT OwnerId FROM Opportunity WHERE Recordtype.Name=:'Vehicle Sales']);
        for(opportunity opp: oppLists){
            opp.OwnerId = spoclist2[0].Id;
        }
        Bypass_Setting__c bypass = new Bypass_Setting__c();
        bypass.Skip_MC_Record_Creation__c = true;
        insert bypass;

        update oppLists;
        Test.stopTest();
    }

    @istest
    static void SVOCUpdateFieldsTest(){

        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        personAccountList[0].Phone_txt__c = '9876543210';
        personAccountList[0].Loyalty_Card_Number__c = '12344';
        insert personAccountList;

        Test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id ,svoc_id__c from opportunity WHERE Recordtype.Name=:'Vehicle Sales']);
        for(opportunity opp : opplist){
            opp.Email__c = 'test@blah.com';
            opp.SVOC_ID__c = 'TMC1234';

            //opp.customer__c = personAccountList[0].Id;
            opp.Referred_By_Mobile_Number__c = '9876543210';
            opp.Referred_By_Loyalty_Card_Number__c = '12344';
            opp.Loyalty_Program_Type__c = 'Maruti Suzuki Rewards';
            opp.LeadSource = 'WLK';

        }
        update opplist;
        Test.stopTest();
    }

    @istest
    static void SVOCUpdateFieldsTest2(){
        Test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id ,svoc_id__c,customer__c from opportunity WHERE Recordtype.Name=:'Vehicle Sales']);
        list<account> acclist = new list<account>();

        for(opportunity opp : opplist){
            Account acc = new account();
            acc.SVOC_ID__c = 'TMC1234';
            acc.Status__c = 'Prospect';
            acc.id = opp.Customer__c;
            acclist.add(acc);
        }
        if(acclist.size()>0)
            update acclist;

        for(opportunity opp : opplist){
            opp.Email__c = 'test@blah.com';
            opp.SVOC_ID__c = 'TMC1234';
            opp.Retail_Cancellation_Date__c = Date.newInstance(2016, 12, 9);
        }
        update opplist;
        Test.stopTest();
    }
    @istest
    static void SVOCUpdateFieldsTest3(){
        Test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id ,svoc_id__c,customer__c from opportunity WHERE Recordtype.Name=:'Vehicle Sales']);
        for(opportunity opp : opplist){

            opp.Email__c = 'test@blah.com';
            opp.SVOC_ID__c = 'TMC1234';
        }
        update opplist;

        for(opportunity opp : opplist){
            opp.Email__c = 'test@blah.com';
            opp.SVOC_ID__c = 'TMC123456';
        }
        update opplist;
        Test.stopTest();
    }

    @istest
    static void addOpportunityTeamMemberTest(){


        Test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id,Line_Of_Business__c from opportunity WHERE Recordtype.Name=:'Vehicle Sales']);
        for(opportunity opp :opplist){
            opp.Line_Of_Business__c = 'ISL';
            opp.ISL_Rural__c = 'ISL';
        }
        update opplist;
        Test.stopTest();
    }


    @istest
    static void addOpportunityTeamMemberTestRural(){
        Test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id,Line_Of_Business__c from opportunity WHERE Recordtype.Name=:'Vehicle Sales']);
        for(opportunity opp :opplist){
            opp.Line_Of_Business__c = 'ISL';
            opp.ISL_Rural__c = 'Rural';
        }
        update opplist;
        Test.stopTest();
    }

    @istest
    static void escalationMCTrigger(){
        Test.startTest();
        List<MC_Communication__c> mcList = new list<MC_Communication__c>();
        List<Opportunity> oppList = new list<Opportunity>([SELECT id FROM Opportunity]);
        for(MC_Communication__c mcComm : [SELECT id,Type__c,SFMC_Flag__c,General_Field_1__c,Escalation_Date_Time__c FROM MC_Communication__c WHERE Enquiry_MD__c in:oppList]){
            mcComm.SFMC_Flag__c = true;
            mcList.add(mcComm);
        }
        update mcList;
        Test.stopTest();
    }

    @istest
    static void updateEnquiryNameTest(){
        Test.startTest();
        List<User> userList = new list<User>();
        User u;
        if(label.Integration_User!=null){
            userList = [SELECT id from User where Id=: label.Integration_User];
            u = userList[0];
        }
        System.runAs(u){


            list<Color_Variant_Master__c> colorList = new list<Color_Variant_Master__c>([SELECT id from Color_Variant_Master__c]);
            List<Opportunity> oppList = new list<Opportunity>([SELECT id FROM Opportunity]);
            for(opportunity opp : oppList){
                opp.StageName = ConstantsUtility.RETAIL_NAME;
                opp.Gate_Pass_Date__c = System.today();
                opp.Referred_By_Mobile_Number__c= '9887689087';
                opp.Loyalty_DMS_Enrollment_ID__c= 'DMSEN007';
                opp.Leadsource= 'ADV';
            }
            try{
                Custom_Validation_Exception_Setting__c cs= new Custom_Validation_Exception_Setting__c();
                cs.Referral_Logic_Run__c= true;
                update cs;

                update oppList;
                List<Opportunity> oppList2 = new list<Opportunity>([SELECT id, stageName, Referred_By_Mobile_Number__c FROM Opportunity]);
                for(opportunity opp : oppList2){
                    opp.StageName = ConstantsUtility.STAGE_PREBOOKING;
                }
                update oppList2;
                for(opportunity opp : oppList2){
                    opp.StageName = ConstantsUtility.STAGE_NEW;
                    opp.LeadSource = 'DSA';
                    opp.Referred_By_Mobile_Number__c = '9887689088';
                }
                update oppList2;
                Test.stopTest();
            }Catch(Exception ex){
                system.debug('error');
            }

        }
    }

     @isTest
    static void closeFollowups(){
        Test.startTest();
        User u = [Select Id from User where Name =: 'DMS Admin'];
        list<opportunity> opplist = new list<opportunity>([SELECT id ,svoc_id__c,customer__c, StageName from opportunity WHERE Recordtype.Name=:'Vehicle Sales' and StageName =: 'New']);
        System.RunAs(u)
        {
        opplist[0].StageName = 'Retail';
        update opplist[0];
        }
        Test.stopTest();
    }

    @isTest
    static void closeFollowupsBooking(){
        Test.startTest();
        User u = [Select Id from User where Name =: 'DMS Admin'];
        list<opportunity> opplist = new list<opportunity>([SELECT id ,svoc_id__c,customer__c, StageName from opportunity WHERE Recordtype.Name=:'Vehicle Sales' and StageName =: 'New']);
        System.RunAs(u)
        {
        opplist[0].StageName = 'Booking';
        update opplist[0];
        }
        Test.stopTest();
    }

   @isTest
    static void retryEnquiry(){
        Test.startTest();

        SF_Retry_Custom_Setting__c cs = new SF_Retry_Custom_Setting__c();
        cs.Name='test1';
        cs.LoginEndPoint__c = 'test.com';
        cs.PassWord__c= 'test.com';
        cs.updatePatchEndPoint__c= 'test.com';
        cs.UserName__c = 'test.com';
        cs.Retry__c = true;
        insert cs;

        List<User> userList = new list<User>();
        User u;
        if(label.Integration_User!=null){
            userList = [SELECT id from User where Id=: label.Integration_User];
            u = userList[0];
        }

        System.runAs(u)
        {

        Test.setMock(HttpCalloutMock.class, new Msil_retryEnquiryMock());
        list<opportunity> opplist = new list<opportunity>([SELECT id ,svoc_id__c,customer__c, StageName,DMS_Sync_Error_Details__c,DMS_Enquiry_Name__c ,Enquiry_Retry_Count__c from opportunity WHERE Recordtype.Name=:'Vehicle Sales']);
        opplist[0].DMS_Sync_Error_Details__c= 'mule down';
        opplist[0].DMS_Enquiry_Name__c = '';
        update opplist[0];

        }
        Test.stopTest();
    }

    static testmethod void validateNotifiyEnqOwner(){
        Test.startTest();
        User u = [Select Id from User where Name =: 'DMS Admin'];
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;

        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;

        List<CDC_TimeSet__c> cdcList = [Select id, TimeSetUp__c from CDC_TimeSet__c];
        cdcList[0].TimeSetUp__c = null;

        update cdcList[0];

        System.RunAs(u)
        {
            List<Opportunity> oppList4 = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
            oppList4[0].accountId = userAccountList[0].id;
            oppList4[0].StageName = 'New';
            oppList4[0].Customer__c= personAccountList[0].Id;
            oppList4[0].Vehicle_Registration__c = '12345';
            insert opplist4[0];
            try{
                oppList4[0].StageName = 'Pre-Booking';
                oppList4[0].Pre_Booking_Number__c= null;
                oppList4[0].DMS_Sync_Error_Details__c= 'DEALER DETAIL NOT AVAILABLE FOR USERID:';
                update oppList4[0];

            }catch(Exception ex){
                system.debug('== error '+ex.getMessage());
            }

        }
        Test.stopTest();
    }



    static testmethod void validateLoyaltyHelper(){
        Test.startTest();
        List<Opportunity> oppList4 = TestDataFactory.createTestOpportunity(2, 'Vehicle Sales');
        oppList4[0].StageName= 'New';
        insert oppList4[0];
        String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales PSF Follow-Up').getRecordTypeId();
        OpportunityTriggerHelper.validateLoyalty(oppList4[0].Id);
        List<Task> taskList= TestDataFactory.createTask(1, taskRecordTypeId);
        insert taskList[0];
        UtilityClass.updateTaskTypeAccEnquiry('', '',oppList4[0].id, taskList[0].id);
        UtilityClass.getPowerPartnerUser();
        Test.stopTest();

    }

    static testmethod void validatefetchCustomerDetails(){
        Test.startTest();
        //For Code Creation
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;

        //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;

        list<Asset> assetList= TestDataFactory.CreateAssetsRecords(1);
        assetList[0].AccountId= accList[0].Id;
        insert assetList[0];

        OpportunityTriggerHelper.fetchCustomerDetails(assetList[0].Id);
        Test.stopTest();
    }

    static testmethod void validatesaveEnrollmentDetails(){
        Test.startTest();
        Id oppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vehicle Sales').getRecordTypeId();
        string jsonData= '{"Name":"Test", "recordTypeId":"'+oppRecTypeId+'","CloseDate":"'+String.valueof(System.today().addMonths(1))+'", "First_Name__c":"John","Middle_Name__c":"Brook","Last_Name__c":"Wright", "Line_Of_Business__c":"Nexa","StageName":"New"}';
        OpportunityTriggerHelper.saveEnrollmentDetails(jsonData);
        Test.stopTest();
    }

       static testmethod void accTestMethod(){
        Test.startTest();
        //For Code Creation
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;

         //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;

        List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert conList;

        spocUser = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
        insert spocUser;

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

        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;

        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        personAccountList[0].BillingStreet = 'vVSSOmnEyxUmGAPhWGooznJbVNAZSanFedwzlhsPTJWwUfVJFVklVyORpByusuOWpcbhmbAEaRKhsWCIonnzFZknIZOPtttLXRxi';

        insert personAccountList;
        //Create Accessoires Enquiry
        String accessoriesrecortype = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Accessories Sales').getRecordTypeId();

        List<Opportunity> accessoriesopplist = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        accessoriesopplist[0].accountId = userAccountList[0].id;
        accessoriesopplist[0].StageName = 'New';
        accessoriesopplist[0].Customer__c= personAccountList[0].Id;
        accessoriesopplist[0].ownerId = label.Integration_user;

        for(Opportunity opp : accessoriesopplist){
            opp.Dealership__c = acc.Id;
            opp.Vehicle_Registration__c = 'TYU56789';
            opp.RecordTypeId = accessoriesrecortype;
            opp.Booking_Cancellation_Reason__c = 'Post-Pone';
        }
        insert accessoriesopplist;Test.stopTest();
    }


    static testMethod void createMSDSData(){
        Test.startTest();
        List<Account> accList = [select id from Account where RecordType.Name='Dealer'];
        List<Account> userAccountList =  [select id from Account where RecordType.Name='User Account'];
         List<Contact> msdsconList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert msdsconList;

        Id assetMsdsTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Test Drive').getRecordTypeId();

        Asset a = new Asset();
        a.name = 'Ciaz';
        a.RecordTypeId = assetMsdsTypeId;
        a.AccountId= accList[0].Id;
        insert a;

        List<Product2> prodList = TestDataFactory.createProducts('MSDS Courses',1);
        prodList[0].isVAS__c = false;
        prodList[0].Category__c = 'A';
        insert prodList;

        Course_Rollout__c courseRollout = new Course_Rollout__c();
        courseRollout.Product__c = prodList[0].Id;
        courseRollout.Start_Date__c = System.today();
        courseRollout.End_Date__c =System.today().addDays(30);
        courseRollout.All_Region__c =true;
        courseRollout.All_State__c =true;
        courseRollout.All_Zone__c =true;
        insert courseRollout;

        List<User> msdsusr = TestDataFactory.createUserData('Portal', 'MSDS IT/Executive/FDE/Manager', msdsconList);
        insert msdsusr;
        List<Opportunity> msdsOppList = TestDataFactory.createMSDSTestOpportunity(1);

        msdsOppList[0].accountId = userAccountList[0].id;
        msdsOppList[0].StageName = 'Enquiry';
        msdsOppList[0].Preferred_Training_Vehicle__c = a.Id;
        msdsOppList[0].ownerId = msdsusr[0].Id;
        msdsOppList[0].Course__c = prodList[0].Id;
        insert msdsOppList;
        update msdsOppList;
        test.StopTest();
    }
    static testMethod void createMSDSData1(){
        Test.startTest();
        List<Account> accList = [select id from Account where RecordType.Name='Dealer'];
        List<Account> userAccountList =  [select id from Account where RecordType.Name='User Account'];
         List<Contact> msdsconList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert msdsconList;

         User u = [Select Id from User where Name =: 'DMS Admin'];
        System.RunAs(u)
        {

            List<Opportunity> msdsOppList = TestDataFactory.createMSDSTestOpportunity(1);

            msdsOppList[0].StageName = 'Enquiry';
            msdsOppList[0].Birthdate__c = system.today().addYears(-25);
            insert msdsOppList;

            msdsOppList[0].StageName = 'Enrolled';
            msdsOppList[0].Enrollment_Date__c = system.today();
            update msdsOppList;

            msdsOppList[0].Birthdate__c = system.today().addYears(-31);
            update msdsOppList;

            msdsOppList[0].Birthdate__c = system.today().addYears(-36);
            update msdsOppList;

            msdsOppList[0].Birthdate__c = system.today().addYears(-41);
            update msdsOppList;

            msdsOppList[0].Birthdate__c = system.today().addYears(-46);
            update msdsOppList;

            msdsOppList[0].Birthdate__c = system.today().addYears(-51);
            update msdsOppList;

            msdsOppList[0].Birthdate__c = system.today().addYears(-56);
            update msdsOppList;

            msdsOppList[0].Birthdate__c = system.today().addYears(-61);
            update msdsOppList;

            msdsOppList[0].Birthdate__c = system.today().addYears(-19);
            update msdsOppList;

        }
        test.StopTest();
    }

	  @isTest
    static void validateUpdateRelatedOpenActivity(){
        Test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id ,svoc_id__c,customer__c, StageName,OwnerId from opportunity WHERE Recordtype.Name=:'Vehicle Sales' and ownerId  =: label.Integration_user]);
        String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Pre Booking Follow-up').getRecordTypeId();
        List<Task> taskList = TestDataFactory.createTask(1, opplist[0], taskRecordTypeId);
        insert taskList[0];
        User u = [Select Id from User where Name =: 'DMS Admin'];
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;

         //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;

        //Contacts Creation
        List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert conList;

        spocUser = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
        insert spocUser;

        System.RunAs(u)
        {
        opplist[0].OwnerId = spocUser[0].Id;
        update opplist[0];
        }
        Test.stopTest();
    }
	
	 @isTest
    static void externalIdAndIdCombCheck(){
        Test.startTest();
        User u = [Select Id from User where Name =: 'DMS Admin'];
        list<opportunity> opplist = new list<opportunity>([SELECT id ,svoc_id__c,customer__c, StageName,External_Id__c from opportunity WHERE Recordtype.Name=:'Vehicle Sales' and StageName =: 'New' and External_Id__c != null]);
        System.debug('Opportunity Test');
        System.debug(opplist);
        System.RunAs(u)
        {
            opplist[0].External_Id__c= 'abc';
            Database.SaveResult result = Database.update(opplist[0], false);
            System.debug('Inside Opp Test');
            list<opportunity> opplist1 = new list<opportunity>([SELECT id ,svoc_id__c,customer__c, StageName,External_Id__c from opportunity WHERE Recordtype.Name=:'Vehicle Sales' and StageName =: 'New' and External_Id__c != null]);
            System.debug(opplist1);
            //System.assertEquals('SF Id and External Id Combination is not matching, External id is : ' + opplist1[0].External_id__c + ' against sf id : '+opplist1[0].Id,result.getErrors()[0].getMessage());
        }
        Test.stopTest();
    }

    @isTest static void testNAVEnquiryCreation(){
        Test.startTest();

        String recortype2 = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Vehicle Sales').getRecordTypeId();

        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;

         //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;

        //Contacts Creation
        List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert conList;

        spocUser = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
        insert spocUser;

        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;

        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;

        User u = [Select Id from User where Name =: 'DMS Admin'];

        system.runAs(u){

            List<Opportunity> oppList2 = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
            oppList2[0].accountId = userAccountList[0].id;
            oppList2[0].StageName = 'New';
            oppList2[0].Customer__c= personAccountList[0].Id;
            oppList2[0].ownerId = label.Integration_user;

            for(Opportunity opp : opplist2){
                opp.Dealership__c = accList[0].Id;
                opp.Accessories_DSE1__c = spocUser[0].id;
                opp.RecordTypeId = recortype2;
                opp.DMS_Enq_Mode__c= 'NAV';
            }
            insert opplist2;
        }
        Test.stopTest();
    }
    
     @isTest static void testNAVEnquiryCreation1(){
        Test.startTest();

        String recortype2 = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Vehicle Sales').getRecordTypeId();

        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;

         //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        insert accList;

        //Contacts Creation
        List<Contact> conList = TestDataFactory.createTestContact(2, accList[0].Id);
        insert conList;

        spocUser = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
        insert spocUser;

        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;

        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;

        User u = [Select Id from User where Name =: 'DMS Admin'];

        system.runAs(u){

            List<Opportunity> oppList2 = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
            oppList2[0].accountId = userAccountList[0].id;
            oppList2[0].StageName = 'New';
            oppList2[0].Customer__c= personAccountList[0].Id;
            oppList2[0].ownerId = label.Integration_user;

            for(Opportunity opp : opplist2){
                opp.Dealership__c = accList[0].Id;
                opp.Accessories_DSE1__c = spocUser[0].id;
                opp.RecordTypeId = recortype2;
                opp.DMS_Enq_Mode__c= 'NAV';
            }
            insert opplist2;
        }
        Test.stopTest();
    }
}