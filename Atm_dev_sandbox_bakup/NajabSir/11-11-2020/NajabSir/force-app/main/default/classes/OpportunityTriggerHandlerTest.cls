@isTest(seeAlldata=False)
public class OpportunityTriggerHandlerTest {
    static list<User> spocUser = new list<User>();
    
    @testSetup 
    static void createTestData(){
        
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
        insert accessoriesopplist;
        
         
        
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
    }
    
    @isTest static void testSPOCAssignment(){
        Test.startTest();
        List<Opportunity> oppLists = new list<Opportunity>([SELECT OwnerId FROM Opportunity WHERE Recordtype.Name=:'Vehicle Sales']);
        List<Account> dealers = new list<Account>([SELECT Sales_SPOC_1__c FROM Account WHERE Recordtype.Name=:'Dealer']);
        system.assertEquals(label.Integration_user, oppLists[0].OwnerId);
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
        Test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id ,svoc_id__c from opportunity WHERE Recordtype.Name=:'Vehicle Sales']);
        for(opportunity opp : opplist){
            opp.Email__c = 'test@blah.com';
            opp.SVOC_ID__c = 'TMC1234';
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
        User u = [SELECT id from User where Id=: label.Integration_User];
        System.runAs(u){
            
            Test.startTest();
            list<Color_Variant_Master__c> colorList = new list<Color_Variant_Master__c>([SELECT id from Color_Variant_Master__c]);
            List<Opportunity> oppList = new list<Opportunity>([SELECT id FROM Opportunity]);
            for(opportunity opp : oppList){
                opp.StageName = ConstantsUtility.RETAIL_NAME;
                opp.Gate_Pass_Date__c = System.today();
            }
            update oppList;
            
            
            List<Opportunity> oppList2 = new list<Opportunity>([SELECT id FROM Opportunity]);
            for(opportunity opp : oppList2){
                opp.StageName = ConstantsUtility.STAGE_PREBOOKING;
            }
            update oppList2;
            for(opportunity opp : oppList2){
                opp.StageName = ConstantsUtility.STAGE_NEW;
            }
            update oppList2;
            Test.stopTest();
         }
    }
    
    @isTest
    static void closeFollowups(){
        Test.startTest();
        list<opportunity> opplist = new list<opportunity>([SELECT id ,svoc_id__c,customer__c, StageName from opportunity WHERE Recordtype.Name=:'Vehicle Sales']);
        opplist[0].StageName = 'Retail';
        update opplist[0];
        Test.stopTest();
    }
}