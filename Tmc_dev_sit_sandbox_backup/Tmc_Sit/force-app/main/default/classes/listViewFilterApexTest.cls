/**
* @File Name          : listViewFilterApexTest.cls
* @Description        : It is utilized to verify listViewFilterApex Apex Class
* @Author             : Rajesh Ramachandran
* @Group              :
* Apex Class          : listViewFilterApex
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 10-17-2020
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0    19/06/2020                   Mahith Madwesh               Initial Version
**/

@isTest
public with sharing class listViewFilterApexTest {
    
    @future()
    static void makeSetupObjectData(List<Id> lstConId) {
        List<Contact> lstCon = [SELECT Id, LastName FROM Contact WHERE Id IN: lstConId];//new List<Contact>();
        List<Contact> lstCon1 = new List<Contact>();
        lstCon1.add(lstCon[0]);
        lstCon.remove(0);
        System.debug('lstConId::'+lstConId);
        System.debug('::lstCon1::'+lstCon1);
        System.debug('::lstCon::'+lstCon);
        
        list<user> subordinateUsers = TestDataFactory.createUserData('Portal', 'Call Center/Workshop Manager', lstCon1);
		UserRole userRole_1 = [SELECT Id FROM UserRole LIMIT 1];

        for(User usr : subordinateUsers) {
            usr.UserRoleId = userRole_1.Id;
        }
        insert subordinateUsers;
        
        list<user> userList = TestDataFactory.createUserData('Portal', 'Call Center Executive Service', lstCon);
                for(user su: userList){
            su.ManagerId = subordinateUsers[0].Id;
        }
        for(User usr : userList) {
            usr.UserRoleId = userRole_1.Id;
        }
        insert userList;
    }
    
    @TestSetup
    static void makeData() {
        List<Implementation_Strategy__c> impList= new List<Implementation_Strategy__c>();
        Implementation_Strategy__c ImplementationStrategyRecord1 = TestDataFactory.createImplementation('CaseVehicleServiceTriggerServiceImpl','Service');
        Implementation_Strategy__c ImplementationStrategyRecord2 = TestDataFactory.createImplementation('CaseMIRenewalTriggerServiceImpl','MI_Renewal');
        Implementation_Strategy__c ImplementationStrategyRecord3 = TestDataFactory.createImplementation('CaseDoNoCallRequestsTriggerServiceImpl','Do_No_Call_Requests');
        Implementation_Strategy__c ImplementationStrategyRecord4 = TestDataFactory.createImplementation('CaseDICTriggerServiceImpl','Dealer_Internal_Complaint');
        Implementation_Strategy__c ImplementationStrategyRecord5 = TestDataFactory.createImplementation('CaseDIFTriggerServiceImpl','Dealer_Internal_Feedback');
        Implementation_Strategy__c ImplementationStrategyRecord6 = TestDataFactory.createImplementation('CaseDIRTriggerServiceImpl','Dealer_Internal_Request');
        Implementation_Strategy__c ImplementationStrategyRecord7 = TestDataFactory.createImplementation('CaseDIQTriggerServiceImpl','Dealer_Internal_Query');
        impList.add(ImplementationStrategyRecord1);
        impList.add(ImplementationStrategyRecord2);
        impList.add(ImplementationStrategyRecord3);
        impList.add(ImplementationStrategyRecord4);
        impList.add(ImplementationStrategyRecord5);
        impList.add(ImplementationStrategyRecord6);
        impList.add(ImplementationStrategyRecord7);
        Database.insert(impList,false); 
        
        list<account> accList = TestDataFactory.createPersonAccount(1);
        insert accList;
        list<account> busineesAccList = TestDataFactory.createBusinessAccount(2, 'Dealer');
        for(account a: busineesAccList){
            a.Name='Prem Test Motors';
            a.Parent_Workshop_Code__c='9511';

        }
        insert busineesAccList;
        
        List<Contact> conList = TestDataFactory.createTestContact(10, busineesAccList[0].Id);
        insert conList;
        //added by shubham:start
		List<Id> lstConId = new List<Id>();
        for(Contact con : conList){
            lstConId.add(con.Id);
        }
        //added by shubham : end
        List<Contact> conList1 = TestDataFactory.createTestContact(1, busineesAccList[0].Id);
        insert conList1;
        
        //added by shubham: start
         for(Contact con : conList1){
            lstConId.add(con.Id);
        }
        //added by shubham : end
        makeSetupObjectData(lstConId);
/*
        list<user> subordinateUsers = TestDataFactory.createUserData('Portal', 'Call Center/Workshop Manager', conList1);
		UserRole userRole_1 = [SELECT Id FROM UserRole LIMIT 1];

        for(User usr : subordinateUsers) {
            usr.UserRoleId = userRole_1.Id;
        }
        
        insert subordinateUsers; 

        list<user> userList = TestDataFactory.createUserData('Portal', 'Call Center Executive Service', conList);
                for(user su: userList){
            su.ManagerId = subordinateUsers[0].Id;
        }
        insert userList;
*/
        list<user> userList = [Select Id, Name, userName, Profile.Name, UserRole.name From user where Profile.Name = 'Call Center Executive Service'];
        list<Account> objList = TestDataFactory.createBusinessAccount(1, 'User Account');
        objList[0].user__c = userList[0].id;
        insert objList;


        list<AccountTeamMember> createAccountTeamMember = TestDataFactory.createAccountTeamMember(1, userList[0].id);
        createAccountTeamMember[0].AccountId = objList[0].Id;
        insert createAccountTeamMember;


        Id callCampaignRectypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Call_Campaign').getRecordTypeId();
        list<Campaign> CampaignList = TestDataFactory.createCampaign(1);
        for ( Campaign cp : CampaignList ) {
            cp.Ownerid = userList[0].Id;
            cp.Dealership__c=busineesAccList[0].Id;
            cp.isActive = true;
            // cp.RecordTypeId = callCampaignRectypeId;
            cp.Status='In Progress';
        }
        insert CampaignList;

        Id InsuranceRenewalRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MI_Renewal').getRecordTypeId();

        // to get the developer name of record type using schema
        list<case> casesList = TestDataFactory.createCase(2, InsuranceRenewalRecordType);
        for ( case c : casesList ) {
            c.status = 'New';
            c.Expiry_Date__c = date.newinstance(2020, 06, 15);  // date.parse('2020-06-15');
            c.Type = 'Renewal';
            c.CampaignId__c = CampaignList[0].Id;
            c.ownerId = userList[0].Id;
            c.Pickup_Date__c = date.newinstance(2020, 06, 15);  // date.parse('15/06/2020');
            c.Customer__c = accList[0].Id;


        }
        insert casesList;



        case casesList1 =  casesList.get(0);

        casesList1.Status = 'Closed';

        update casesList1;

        Id RenewalCallRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('MI_Renewal_Call').getRecordTypeId();

        list<task> tasksList = TestDataFactory.createTask(2, RenewalCallRecordType);
        list<task> newTasks = new list<task>();
        for ( task t : tasksList ) {
            t.Case__c = casesList[0].Id;
            t.whatId = casesList[0].Id;
            t.status = 'Open';
            t.Priority = 'High';
            t.campaignId__c=CampaignList[0].Id;
            t.ActivityDate = date.newinstance(2020, 06, 10);  // date.parse('10/06/2020');

            t.OwnerId = userList[0].Id;
            t.Service_Type__c = 'Renewal';
            t.Contact_ID__c = accList[0].Id;
            newTasks.add(t);
        }
        insert newTasks;

        task task1 = newTasks.get(0);

        task1.Status = 'In Progress';
        update task1;

    }

    
    
    @isTest
    static void getCurrentTeamUsersTest() {
        test.startTest();
        integer userCount = [select count(  ) from User where Email = 'standarduser@testorg.com'];
        //commented by shubham
        //system.assertEquals(11, userCount);
        list<user> usersList = listViewFilterApex.getCurrentTeamUsers('');
        //system.assertEquals(11, usersList.size(), 'Gettting team user failed');
        list<user> usersList1 = listViewFilterApex.getCurrentTeamUsers('Testing');
        //system.assertEquals(2, usersList1.size(), 'Gettting team user failed2');
		list<user> usersList2 = listViewFilterApexV1.getCurrentTeamUsers('');
        list<user> usersList3 = listViewFilterApexV1.getCurrentTeamUsers('Testing');
        
        test.stopTest();
    }

    @isTest
    static void saveTaskChangeOwnersTest() {
        test.startTest();
        list<user> usersList = [select Id from user where Email = 'standarduser@testorg.com'];
        //commented by shubham
        //system.assertEquals(11, usersList.size(), 'Gettting users from soql failed');
        list<task> insertedTasks = [select Id,Status,Subject,Case__c from task];
        system.assertEquals(2, insertedTasks.size(), 'Gettting inserted tasks failed');
        list<case> insertedCases = [select Id,ClosedDate,Status,CaseNumber from case];
        system.assertEquals(2, insertedCases.size(), 'Gettting inserted cases failed');
        map<string,string> resultMap = listViewFilterApex.saveTaskChangeOwners(insertedTasks, usersList[3].Id,false);
        system.assertEquals(2,resultMap.size(), 'saveTaskChangeOwnersTest failed');

        map<string,string> resultMap1 = listViewFilterApex.saveTaskChangeOwners(insertedTasks, usersList[3].Id,true);
        system.assertEquals(2,resultMap1.size(), 'saveTaskChangeOwnersTest failed false');
        test.stopTest();
    }

    @istest
    static void saveCaseChangeOwnerTest() {
        test.startTest();
        list<user> usersList = [select id from user where Email = 'standarduser@testorg.com'];
        //commented by shubham
        //system.assertEquals(11, usersList.size(), 'Gettting users from soql failed');
        list<case> insertedCases = [select Id,ClosedDate,Status,CaseNumber from case];
        system.assertEquals(2, insertedCases.size(), 'Gettting inserted cases failed');
        map<string,string> resultMap = listViewFilterApex.saveCaseChangeOwner(insertedCases, usersList[0].Id,false);
        system.assertEquals(2,resultMap.size(), 'saveCaseChangeOwnerTest failed');

        map<string,string> resultMap1 = listViewFilterApex.saveCaseChangeOwner(insertedCases, usersList[0].Id,true);
        system.assertEquals(2,resultMap1.size(), 'saveCaseChangeOwnerTest failed false');
        test.stopTest();
    }

    @isTest
    static void getCasesTest() {
        test.startTest();
        list<user> usersList = [select id from user where Email = 'standarduser@testorg.com'];
        //commented by shubham
        //system.assertEquals(11, usersList.size(), 'Gettting users from soql failed');
        list<case> insertedCases = [SELECT Id, Type, Expiry_Date__c,Pickup_Date__c, Status FROM case];
        //commented by shubham
        //system.assertEquals(2, insertedCases.size(), 'Gettting inserted cases failed');
        list<Campaign> insertedCampaigns = [SELECT Id, Name, Dealership__r.Parent_Group__c from Campaign LIMIT 1];
        //commented by shubham
        //system.assertEquals(1, insertedCampaigns.size(), 'Gettting campaings cases failed');

        list<case> casesList = listViewFilterApex.getCases('', 'MI Renewal', '', '', '','','','');
        //system.assertEquals(2, casesList.size(), 'getCasesTest failed');
        test.stopTest();
    }

    @isTest
    static void caseStatuspicklistValuesTest() {
        test.startTest();
        Map<String, String> picklistMap = listViewFilterApex.getpicklistValues('Case','Status');
        system.assertEquals(picklistMap.size()>0, picklistMap.size()>0);
        test.stopTest();
    }
/*
    @isTest
    static void campaignTypepicklistValuesTest() {
        test.startTest();
        Map<String, String> picklistMap = listViewFilterApex.campaignTypepicklistValues();
        system.assertEquals(picklistMap.size()>0, picklistMap.size()>0);
        test.stopTest();
    }


    @isTest
    public static void vehicleModelpicklistValuesTest(){
            test.startTest();
        Map<String, String> picklistMap = listViewFilterApex.vehicleModelpicklistValues();
        system.assertEquals(picklistMap.size()>0, picklistMap.size()>0);
        test.stopTest();
    }
*/
    @isTest
    static void createDailingListTest(){
        test.startTest();
        list<case> insertedCases = [SELECT Id, Type, Expiry_Date__c, Status FROM case];

        map<string,string> dailiangListMap = listViewFilterApex.createDailingList(insertedCases);
        system.assertEquals(2, dailiangListMap.size());
        test.stopTest();
    }

    @isTest
    static void getUserProfileNameTest(){
        test.startTest();
        Id callCampaignRectypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Call_Campaign').getRecordTypeId();

        list<user> usersList = [select Id from user where Email = 'standarduser@testorg.com' and account.name='Prem Test Motors'];
        system.assertEquals(11, usersList.size(), 'Gettting users from soql failed');

        List<Campaign> lscmpn = [Select Id,Name,Dealership__c, Dealership__r.Parent_Workshop_Code__c, isActive,Status,RecordTypeId FROM Campaign ];
        system.assertEquals(1, lscmpn.size(), 'Gettting campaign failed');

        system.runAs(usersList[0]){
             listViewFilterApex.getUserProfileName();
        }

        test.stopTest();
    }


    @isTest
    static void getTasksTest(){
        test.startTest();

        list<user> usersList = [select id from user where Email = 'standarduser@testorg.com'];
        //commented by shubham
        //system.assertEquals(11, usersList.size(), 'Gettting users from soql failed');

        list<Campaign> insertedCampaigns = [SELECT Id, Name, Dealership__r.Parent_Group__c from Campaign LIMIT 1];
        system.assertEquals(1, insertedCampaigns.size(), 'Gettting campaings cases failed');

        list<task> insertedTasks = [select id,Service_Type__c,ActivityDate from task];
        system.assertEquals(2, insertedTasks.size(), 'Gettting inserted tasks failed');

        list<string> taskPriority = new list<string>();
        taskPriority.add('High');
        list<string> owneridlist = new list<string>();
        list<string> campaignTypeList = new list<string>();
        campaignTypeList.add('Paid Service');
        list<string> modellist = new list<string>();
        modellist.add('BALENO');
        list<task> tasksList = listViewFilterApex.getTasks('', campaignTypeList, '', '',owneridlist,'High','','','',modellist,'TEST');
        //system.assertEquals(1, tasksList.size(), 'Getting Tasks Failed');

        test.stopTest();

    }

    @isTest
    public static void updateAppointmentDatesTest(){
        test.startTest();
        list<user> usersList = [select id from user where Email = 'standarduser@testorg.com'];
                //commented by shubham
        //system.assertEquals(11, usersList.size(), 'Gettting users from soql failed');

        list<case> insertedCases = [SELECT Id,CaseNumber,Type, Expiry_Date__c,Pickup_Date__c, Status,ClosedDate FROM case];
        system.assertEquals(2, insertedCases.size(), 'Gettting inserted cases failed');

        list<Campaign> insertedCampaigns = [SELECT Id, Name, Dealership__r.Parent_Group__c from Campaign LIMIT 1];
        system.assertEquals(1, insertedCampaigns.size(), 'Gettting campaings cases failed');

        map<string,string> updateListMap = listViewFilterApex.updateAppointmentDates(insertedCases,'2020-06-20T07:38:00.000Z' );
        system.assertEquals(2, updateListMap.size(), 'updateAppointmentDates failed');

        test.stopTest();

    }

    @isTest
    public static void tryCatchBlockTest(){
        test.startTest();
        list<user> usersList = [select id from user where Email = 'standarduser@testorg.com'];
        //commented by shubham
        //system.assertEquals(11, usersList.size(), 'Gettting users from soql failed');
        list<case> insertedCases = [SELECT Id,CaseNumber,Type, Expiry_Date__c,Pickup_Date__c, Status FROM case];
        system.assertEquals(2, insertedCases.size(), 'Gettting inserted cases failed');

        list<task> insertedTasks = [select id,Service_Type__c,ActivityDate from task];
        system.assertEquals(2, insertedTasks.size(), 'Gettting inserted tasks failed');

        map<string,string> updateListMap = listViewFilterApex.updateAppointmentDates(insertedCases,'2020-06-20T07:38:00.000Z' );
        system.assertEquals(0, updateListMap.size(), 'updateAppointmentDates failed');

        map<string,string> dailiangListMap = listViewFilterApex.saveCaseChangeOwner(insertedCases, usersList[1].Id, true);
        system.assertEquals(0, dailiangListMap.size());

        map<string,string> saveTaskMap = listViewFilterApex.saveTaskChangeOwners(insertedTasks, usersList[1].Id, true);
        system.assertEquals(0, saveTaskMap.size());

        test.stopTest();

    }

}