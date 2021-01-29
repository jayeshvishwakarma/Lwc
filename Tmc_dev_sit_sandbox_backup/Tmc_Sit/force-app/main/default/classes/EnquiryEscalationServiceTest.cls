@isTest
public class EnquiryEscalationServiceTest {
    static list<User> spocUser = new list<User>();
    static list<User> spocUserManager = new list<User>();
    static list<User> hostessUser = new list<User>();
    static list<User> dseUser = new list<User>();

    @testSetup
    static void createTestData(){
        TriggerHandler.bypass('UserTriggerHandler');
        
        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';

        Insert IS;

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            //For Code Creation
            List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
            insert forCodeList;

            list<product2> productList = TestDataFactory.createProducts('Variants', 1);
            productList[0].Model__c = 'BA';
            productList[0].Enquiry__c = 'Yes';
            Insert productList;

            list<PricebookEntry> priceBooklist = TestDataFactory.createPricebookEntry(1,productList[0].Id);
            insert priceBooklist;

            //DealerShip Creation
            List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
            accList[0].For_Code__c = forCodeList[0].Id;
            accList[0].channel__c = 'EXC';
            accList[0].Territory_Sales_Manager__c = userinfo.getUserId();
            insert accList;

            //DealerShip Creation
            List<Account> ArenaDealerShip = TestDataFactory.createBusinessAccount(1, 'Dealer');
            ArenaDealerShip[0].For_Code__c = forCodeList[0].Id;
            ArenaDealerShip[0].channel__c = 'NRM';
            insert ArenaDealerShip;

            //Contacts Creation
            List<Contact> ArenaconList = TestDataFactory.createTestContact(1, ArenaDealerShip[0].Id);
            insert ArenaconList;

            List<User> ArenaSpocUser = TestDataFactory.createUserData('Portal', 'Dealer Team Leads/Managers', ArenaconList);
            ArenaSpocUser[0].Designation__c = 'NSM';
            insert ArenaSpocUser;

            //Contacts Creation
            List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
            insert conList;

            //Hostess Creation
            hostessUser = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
            hostessUser[0].Designation__c = 'LHS';
            insert hostessUser;

            List<Contact> dseConList = TestDataFactory.createTestContact(1, accList[0].Id);
            insert dseConList;

            //DSE Creation
            dseUser = TestDataFactory.createUserData('Portal', 'Dealer Sales Executive', dseConList);
            dseUser[0].Designation__c = 'SAE';
            insert dseUser;

            List<Contact> spocManagerConList = TestDataFactory.createTestContact(1, accList[0].Id);
            insert spocManagerConList;

            //SPOC Manager Creation
            spocUserManager = TestDataFactory.createUserData('Portal', 'Dealer Team Leads/Managers', spocManagerConList);
            spocUserManager[0].Designation__c = 'NSM';
            insert spocUserManager;

            List<Contact> spocConList = TestDataFactory.createTestContact(1, accList[0].Id);
            insert spocConList;

            //SPOC Creation
            spocUser = TestDataFactory.createUserData('Portal', 'Dealer Team Leads/Managers', spocConList);
            spocUser[0].Designation__c = 'NSM';
            spocUser[0].ManagerId = spocUserManager[0].Id;
            insert spocUser;

            //Create Person Account
            List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
            insert personAccountList;

            //Create Business Account
            list<Account> dseUserAccount= TestDataFactory.createBusinessAccount(1,'User Account');
            dseUserAccount[0].user__c = dseUser[0].id;
            insert dseUserAccount;

            //Create Business Account
            list<Account> spocUserAccount= TestDataFactory.createBusinessAccount(1,'User Account');
            spocUserAccount[0].user__c = spocUser[0].id;
            insert spocUserAccount;


            //Create Escalation Matrix
            List<Enquiry_Escalations__c> escaltionMatrix = TestDataFactory.CreateEnqEscalation('Dealer',
                                                                                               'ISL','DSE Allocation Time',
                                                                                               new list<String>{'','','NSM','CEO','TSM'},
                                                                                               new list<Integer>{null,30,45,60,null});
            insert escaltionMatrix;

            //Create enquiry
            List<Opportunity> opptyist = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
            opptyist[0].StageName = 'New';
            opptyist[0].Customer__c= personAccountList[0].Id;
            opptyist[0].LeadSource= 'Showroom Walk-In';
            opptyist[0].ownerId = spocUser[0].id;
            opptyist[0].Line_Of_Business__c = 'Nexa';
            opptyist[0].ISL_Rural__c = 'ISL';
            opptyist[0].Model_Code__c = 'BA';
            opptyist[0].Variant__c = productList[0].Id;
            opptyist[0].Dealership__c = accList[0].Id;
            insert opptyist;

            //--------------------------------------
            //
            //ARENA ENQUIRY TEST
            List<UserRole> UserRoleidList = new list<UserRole>([SELECT id,developerName from UserRole where developerName IN ('Arena_TSM_C1','Sale_Arena_CBH_C',
                                                                                                                              'Sale_Arena_RM_C1','Sale_Arena_DVM',
                                                                                                                              'EO_ALL_ALL')]);
            map<String,string> UserRoleIdMap = new map<String,string>();
            for(UserRole u : UserRoleidList){
                UserRoleIdMap.put(u.developerName,u.id);
            }

            //Creating EO Internal Users
            list<User> eoInternalUser = new list<user>();
            eoInternalUser = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{});
            eoInternalUser[0].UserRoleid = UserRoleIdMap.get('EO_ALL_ALL');
            insert eoInternalUser;

            //Creating DVM Internal Users
            list<User> dvmInternalUser = new list<user>();
            dvmInternalUser = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{});
            dvmInternalUser[0].UserRoleID = UserRoleIdMap.get('Sale_Arena_DVM');
            dvmInternalUser[0].ManagerId = eoInternalUser[0].id;
            insert dvmInternalUser;

            //Creating RM Internal Users
            list<User> rmInternalUser = new list<user>();
            rmInternalUser = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{});
            rmInternalUser[0].UserRoleid = UserRoleIdMap.get('Sale_Arena_RM_C1');
            rmInternalUser[0].ManagerId = dvmInternalUser[0].id;
            insert rmInternalUser;

            //Creating CBH Internal Users
            list<User> cbhInternalUser = new list<user>();
            cbhInternalUser = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{});
            cbhInternalUser[0].UserRoleid = UserRoleIdMap.get('Sale_Arena_CBH_C');
            cbhInternalUser[0].ManagerId = rmInternalUser[0].id;
            insert cbhInternalUser;

            //Creating TSM Internal Users
            list<User> tsmInternalUser = new list<user>();
            tsmInternalUser = TestDataFactory.createUserData('Internal', 'Maruti Sales User', new list<contact>{});
            tsmInternalUser[0].UserRoleid = UserRoleIdMap.get('Arena_TSM_C1');
            tsmInternalUser[0].ManagerId = cbhInternalUser[0].id;
            insert tsmInternalUser;

            ArenaDealerShip[0].Territory_Sales_Manager__c = tsmInternalUser[0].id;
            update accList;

            //SPOC assignment to dealership
            accList[0].Sales_SPOC_1__c = spocUser[0].Id;
            update accList;
        }

        TriggerHandler.clearBypass('UserTriggerHandler');
    }


    @istest
    Static void dealerUnallocatedEscalations(){
    
        Test.startTest();
        
        TriggerHandler.bypass('OpportunityTriggerHandler_Strategy');
        
        //Create Escalation Matrix
        List<Enquiry_Escalations__c> escaltionMatrix = TestDataFactory.CreateEnqEscalation('Dealer',
                                                                                           'Nexa','DSE Allocation Time',
                                                                                           new list<String>{'','','NSM','CEO','TSM'},
                                                                                           new list<Integer>{null,30,45,60,null});
        insert escaltionMatrix;

        list<product2> productList = TestDataFactory.createProducts('Variants', 1);
        productList[0].Model__c = 'BA';
        productList[0].Enquiry__c = 'Yes';
        Insert productList;

        list<PricebookEntry> priceBooklist = TestDataFactory.createPricebookEntry(1,productList[0].Id);
        insert priceBooklist;

        List<Account> customer = new list<Account>([SELECT Id FROM Account WHERE IsPersonAccount=true]);

        //Fetch Dealer Account
        List<Account> dealer = new list<Account>([SELECT Id FROM Account WHERE Recordtype.Name='Dealer']);

        //Fetch Hostess
        List<User> hostess = new list<User>([SELECT Id FROM User WHERE Contact.AccountId=:dealer[0].Id and Profile.Name='Dealer Hostess']);

        //Create enquiry
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].StageName = 'New';
        oppList[0].Customer__c= customer[0].Id;
        oppList[0].LeadSource= 'Showroom Walk-In';
        oppList[0].ownerId = hostess[0].id;
        oppList[0].Line_Of_Business__c = 'Nexa';
        oppList[0].Model_Code__c = 'BA';
        oppList[0].Variant__c = productList[0].Id;

        insert oppList;

        List<Opportunity> oppQueryList = new list<Opportunity>([SELECT Id,OwnerId,Level_2_Notification__c,
                                                                Level_3_Notification__c,Level_4_Notification__c,
                                                                Type_of_Escalation__c,Time_for_Next_Escalation__c,
                                                                DSE_Allocation_Time__c
                                                                FROM Opportunity WHERE Id=:oppList[0].Id]);

        //system.assertEquals('NSM', oppQueryList[0].Level_2_Notification__c);
        //system.assertEquals('CEO', oppQueryList[0].Level_3_Notification__c);
        //system.assertEquals('TSM', oppQueryList[0].Level_4_Notification__c);
        
        TriggerHandler.clearBypass('OpportunityTriggerHandler_Strategy');
        
        Test.stopTest();
    }


    @istest
    Static void dealerAllocatedEscalations(){
        Test.startTest();
        
        TriggerHandler.bypass('OpportunityTriggerHandler_Strategy');
        
        //Create Escalation Matrix
        List<Enquiry_Escalations__c> escaltionMatrix = TestDataFactory.CreateEnqEscalation('Dealer',
                                                                                           'Nexa','DSE Allocation Time',
                                                                                           new list<String>{'','','NSM','CEO','TSM'},
                                                                                           new list<Integer>{null,30,45,60,null});
        insert escaltionMatrix;

        list<product2> productList = TestDataFactory.createProducts('Variants', 1);
        productList[0].Model__c = 'BA';
        productList[0].Enquiry__c = 'Yes';
        Insert productList;

        list<PricebookEntry> priceBooklist = TestDataFactory.createPricebookEntry(1,productList[0].Id);
        insert priceBooklist;

        List<Account> customer = new list<Account>([SELECT Id FROM Account WHERE IsPersonAccount=true]);

        //Fetch Dealer Account
        List<Account> dealer = new list<Account>([SELECT Id FROM Account WHERE Recordtype.Name='Dealer']);

        //Fetch DSE
        List<User> dse = new list<User>([SELECT Id,Designation__c FROM User WHERE Contact.AccountId=:dealer[0].Id and Profile.Name='Dealer Sales Executive']);

        //Create enquiry
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].StageName = 'New';
        oppList[0].Customer__c= customer[0].Id;
        oppList[0].LeadSource= 'Showroom Walk-In';
        oppList[0].ownerId = dse[0].id;
        oppList[0].Line_Of_Business__c = 'Nexa';
        oppList[0].Model_Code__c = 'BA';
        oppList[0].Variant__c = productList[0].Id;
        insert oppList;
        
        TriggerHandler.clearBypass('OpportunityTriggerHandler_Strategy');
        
        Test.stopTest();

    }




    @istest
    Static void ISLUnallocatedEscalations(){
        Test.startTest();
        TriggerHandler.bypass('OpportunityTriggerHandler_Strategy');
        
        List<Opportunity> optyList = new list<Opportunity>([SELECT Id,Escalated__c FROM Opportunity WHERE ISL_Rural__c=:'ISL']);
        optyList[0].Escalated__c = true;
        update optyList;
        
        TriggerHandler.clearBypass('OpportunityTriggerHandler_Strategy');
        
        Test.stopTest();

    }

    @istest
    Static void ISLallocatedEscalations(){
        Test.startTest();
        
        TriggerHandler.bypass('OpportunityTriggerHandler_Strategy');
        
        List<Opportunity> optyList = new list<Opportunity>([SELECT Id,Escalated__c FROM Opportunity WHERE ISL_Rural__c=:'ISL']);
        optyList[0].Level_Escalated__c = 'Level 2';
        optyList[0].Escalated__c = true;
        update optyList;
        
        TriggerHandler.clearBypass('OpportunityTriggerHandler_Strategy');
        
        Test.stopTest();
    }

    @istest
    Static void ISLLastallocatedEscalations(){
        Test.startTest();
        
        TriggerHandler.bypass('OpportunityTriggerHandler_Strategy');
        
        List<Opportunity> optyList = new list<Opportunity>([SELECT Id,Escalated__c FROM Opportunity WHERE ISL_Rural__c=:'ISL']);
        optyList[0].Level_Escalated__c = 'Level 2';
        optyList[0].Escalated__c = true;
        optyList[0].Last_Follow_Up_Update_Time__c = DateTime.now();
        update optyList;
        
        TriggerHandler.clearBypass('OpportunityTriggerHandler_Strategy');
        
        Test.stopTest();
    }

    @istest
    Static void ArenaUnallocatedEscalationsLvl2(){
        Test.startTest();
        
        TriggerHandler.bypass('OpportunityTriggerHandler_Strategy');
        
        List<Enquiry_Escalations__c> ArenaescaltionMatrix = TestDataFactory.CreateEnqEscalation('Dealer',
                                                                                                    'Arena','DSE Allocation Time',
                                                                                                    new list<String>{'','','CSE;NCM;SM;NSM;GM;CEO;TSM;CBH;RM','DVM','EO'},
                                                                                                    new list<Integer>{null,30,45,60,null});
        insert ArenaescaltionMatrix;

        list<product2> productList = TestDataFactory.createProducts('Variants', 1);
        productList[0].Model__c = 'AN';
        productList[0].Enquiry__c = 'Yes';
        Insert productList;

        list<PricebookEntry> priceBooklist = TestDataFactory.createPricebookEntry(1,productList[0].Id);
        insert priceBooklist;

        List<Account> customer = new list<Account>([SELECT Id FROM Account WHERE IsPersonAccount=true]);

        //Fetch Dealer Account
        List<Account> dealer = new list<Account>([SELECT Id FROM Account WHERE Recordtype.Name='Dealer' And channel__c = 'NRM']);

        //Fetch DSE
        List<User> dse = new list<User>([SELECT Id,Designation__c FROM User WHERE Contact.AccountId=:dealer[0].Id and Profile.Name='Dealer Team Leads/Managers']);

        //Create enquiry
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].StageName = 'New';
        oppList[0].Customer__c= customer[0].Id;
        oppList[0].LeadSource= 'Showroom Walk-In';
        oppList[0].ownerId = dse[0].id;
        oppList[0].Line_Of_Business__c = 'Arena';
        oppList[0].Model_Code__c = 'AN';
        oppList[0].Variant__c = productList[0].Id;
        insert oppList;
        
        TriggerHandler.clearBypass('OpportunityTriggerHandler_Strategy');
        
        Test.stopTest();
    }
    @istest
    Static void CheckingBusinessHours(){
        List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
        EnquiryEscalationService enqService = new EnquiryEscalationService();
        enqService.checkBusinessHours(bhs[0].id,datetime.now().addhours(5),300);
    }

    @istest
    Static void CheckingBusinessHours2(){
        Date today = system.today();

        DateTime myDateTime = DateTime.newInstance(today.year(), today.month(),today.day(), 21, 8, 16);
        List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
        List<BusinessHours> bhs1=[select id from BusinessHours where IsDefault!=true];
        EnquiryEscalationService enqService = new EnquiryEscalationService();
        enqService.checkBusinessHours(bhs[0].id,datetime.now(),3);
        enqService.checkBusinessHours(bhs1[0].id,myDateTime,3);
    }

}