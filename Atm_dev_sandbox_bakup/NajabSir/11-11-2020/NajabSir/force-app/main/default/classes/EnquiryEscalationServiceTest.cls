@isTest
public class EnquiryEscalationServiceTest {
    static list<User> spocUser = new list<User>();
    static list<User> hostessUser = new list<User>();
    static list<User> dseUser = new list<User>();
    
    @testSetup 
    static void createTestData(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            //For Code Creation
            List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
            insert forCodeList;
             
            
            //DealerShip Creation
            List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
            accList[0].For_Code__c = forCodeList[0].Id;
            accList[0].channel__c = 'EXC';
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
            
            List<Contact> spocConList = TestDataFactory.createTestContact(1, accList[0].Id);
            insert spocConList;
            
            //SPOC Creation
            spocUser = TestDataFactory.createUserData('Portal', 'Dealer Team Leads/Managers', spocConList);
            dseUser[0].Designation__c = 'NSM';
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
        
        
    }
    
    
    @istest
    Static void dealerUnallocatedEscalations(){
        Test.startTest();
        //Create Escalation Matrix
        List<Enquiry_Escalations__c> escaltionMatrix = TestDataFactory.CreateEnqEscalation('Dealer',
                                                                                           'Nexa','DSE Allocation Time',
                                                                                           new list<String>{'','','NSM','CEO','TSM'},
                                                                                           new list<Integer>{null,30,45,60,null});
        insert escaltionMatrix;
        
        
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
        insert oppList;
        
        List<Opportunity> oppQueryList = new list<Opportunity>([SELECT Id,OwnerId,Level_2_Notification__c,
                                                                Level_3_Notification__c,Level_4_Notification__c,
                                                                Type_of_Escalation__c,Time_for_Next_Escalation__c,
                                                                DSE_Allocation_Time__c
                                                                FROM Opportunity WHERE Id=:oppList[0].Id]);
        
        system.assertEquals('NSM', oppQueryList[0].Level_2_Notification__c);
        system.assertEquals('CEO', oppQueryList[0].Level_3_Notification__c);
        system.assertEquals('TSM', oppQueryList[0].Level_4_Notification__c);
        
        Test.stopTest();
        
        
    }
    
    
    @istest
    Static void dealerAllocatedEscalations(){
        Test.startTest();
        //Create Escalation Matrix
        List<Enquiry_Escalations__c> escaltionMatrix = TestDataFactory.CreateEnqEscalation('Dealer',
                                                                                           'Nexa','DSE Allocation Time',
                                                                                           new list<String>{'','','NSM','CEO','TSM'},
                                                                                           new list<Integer>{null,30,45,60,null});
        insert escaltionMatrix;
        
        
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
        insert oppList; 
        
        Test.stopTest(); 
        
    }
    
    
    
    
    @istest
    Static void ISLUnallocatedEscalations(){
        Test.startTest();
        List<Opportunity> optyList = new list<Opportunity>([SELECT Id,Escalated__c FROM Opportunity WHERE ISL_Rural__c=:'ISL']);
        optyList[0].Escalated__c = true;
        update optyList; 
        Test.stopTest();
        
    }
    
    @istest
    Static void ISLallocatedEscalations(){
        Test.startTest();
        List<Opportunity> optyList = new list<Opportunity>([SELECT Id,Escalated__c FROM Opportunity WHERE ISL_Rural__c=:'ISL']);
        optyList[0].Level_Escalated__c = 'Level 2';
        optyList[0].Escalated__c = true;
        update optyList; 
        Test.stopTest();
    }
    
    @istest
    Static void ISLLastallocatedEscalations(){
        Test.startTest();
        List<Opportunity> optyList = new list<Opportunity>([SELECT Id,Escalated__c FROM Opportunity WHERE ISL_Rural__c=:'ISL']);
        optyList[0].Level_Escalated__c = 'Level 2';
        optyList[0].Escalated__c = true;
        optyList[0].Last_Follow_Up_Update_Time__c = DateTime.now();
        update optyList; 
        Test.stopTest();
    }
    
    @istest
    Static void ArenaUnallocatedEscalationsLvl2(){
        Test.startTest();
        List<Enquiry_Escalations__c> ArenaescaltionMatrix = TestDataFactory.CreateEnqEscalation('Dealer',
                                                                                                    'Arena','DSE Allocation Time',
                                                                                                    new list<String>{'','','CSE;NCM;SM;NSM;GM;CEO;TSM;CBH;RM','DVM','EO'},
                                                                                                    new list<Integer>{null,30,45,60,null});
        insert ArenaescaltionMatrix;
        
        
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
        insert oppList; 
        
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
        List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
        EnquiryEscalationService enqService = new EnquiryEscalationService();
        enqService.checkBusinessHours(bhs[0].id,datetime.now(),3);
    }
}