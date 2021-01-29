/**
 * @File Name          : CreateInboundCaseTest.cls
 * @Description        : It is utilized for CreateInboundCase Apex code coverage
 * @Author             : Prashant Gahlaut
 * @Group              : 
 * Apex Class          : CreateInboundCase
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 10-17-2020
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                    Author                Modification
 *==============================================================================
 * 1.0        23/01/2020             Prashant Gahlaut       Initial Version
**/
@isTest
public class CreateInboundCaseTest {
    
    public static List<User> userList = [SELECT id FROM user where isPortalEnabled=true AND Designation__c!=NULL AND isActive=true limit 2 ];
    
    @testSetup 
    static void createTestData(){
        test.startTest();
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND isActive=true Limit 1];
        
        //For Code Creation
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;
        
        //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        accList[0].Parent_Workshop_Code__c='Test123';
        accList[0].Parent_MI_Code__c='Test123';
        insert accList;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        
        List<Category__c> catList = TestDataFactory.createCategory(1);
        insert catList;
        
        Implementation_Strategy__c ImplementationStrategyRecord8 = TestDataFactory.createImplementation('OpportunityVehicleTriggerServiceImpl','Vehicle_Sales');
        ImplementationStrategyRecord8.Use_Case__c = 'OpportunityTriggers';
        insert ImplementationStrategyRecord8;
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].ownerId = userList[0].Id;
        oppList[0].StageName = 'New';
        oppList[0].customer__c = personAccountList[0].id;
        insert oppList;
        
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
        
        list<Account> objList= TestDataFactory.createBusinessAccount(1,'User Account');
        objList[0].user__c = userList[0].Id;
        insert objList;
        
        List<AccountTeamMember> accTeam = TestDataFactory.createAccountTeamMember(1,userList[0].Id);
        accTeam[0].AccountId=objList[0].Id;
        insert accTeam;

        
        List<Case> csList = TestDataFactory.createCase(2, 'Dealer_Internal_Complaint');
        csList[0].Ownerid = userList[0].Id;
        csList[0].Business_Area__c=ConstantsUtility.DEALER_INTERNAL_ACCESSORIES;
        csList[1].Dealer_Name__c = accList[0].Id;
        csList[1].ownerId = userList[0].Id;
        csList[1].Business_Area__c=ConstantsUtility.DEALER_INTERNAL_SERVICE_BODYSHOP;
        csList[1].case_stage__c= '';
        csList[1].Status ='New';
        csList[1].Vehicle_Registration_Number__c = 'MH';
        insert csList;
        test.stopTest();
    }
    
    @isTest 
    static void testMethd(){
        Test.startTest();
        list<Account> acclist = new list<Account>([SELECT id,User__c,User__r.ManagerId from Account where  recordType.name = 'User Account' LIMIT 1]);
        list<Case> csList = new list<Case>([SELECT id,OwnerId,Dealer_Name__c,Business_Area__c from Case LIMIT 2]);
        list<Category__c> catList = new list<Category__c>([SELECT id,External_ID_Query__c from Category__c LIMIT 1]);
        list<opportunity> opplist = new list<opportunity>([SELECT id from opportunity LIMIT 1]);
        list<Account> cstmrIdList = [SELECT ID from account where isPersonAccount = true LIMIT 1];
        List<Case> csList2 = TestDataFactory.createCase(2, 'Dealer_Internal_Complaint');
        csList2[1].ownerId = userList[0].Id;
        csList2[1].Status ='New';
        string CaseJson = JSON.serialize(csList2[1]);
        system.runAs(userList[0]){
           CreateInboundCase.fetchCustomerDetails(cstmrIdList[0].Id);
        }
        csList[0].Business_Area__c = 'Accessories';
        update csList;
        
        CreateInboundCase.fetchCustomerDetails(opplist[0].Id);
        CreateInboundCase.fetchCategoryData(catList[0].External_ID_Query__c);
        CreateInboundCase.fetchCaseOwner('test','test');
        CreateInboundCase.fetchenquiryDealerRec(opplist[0].Id,'test',ConstantsUtility.DEALER_INTERNAL_SALES);
       	CreateInboundCase.updateCaseData(CaseJson,'test','Dealer_Internal_Complaint');
        CreateInboundCase.createHierarchyStructure(csList[1],acclist[0],'test');
        CreateInboundCase.createHierarchyStructure(csList[0],acclist[0],'test');
        Test.stopTest();
    }
    @isTest 
    static void testMethd1(){
        list<Account> dealerList = new list<Account>([SELECT id from Account where  recordType.name = 'Dealer']);
        list<Account> acclist = new list<Account>([SELECT id,User__c,User__r.ManagerId from Account where  recordType.name = 'User Account']);
        list<Case> csList = new list<Case>([SELECT id,OwnerId,Dealer_Name__c,Business_Area__c from Case where Business_Area__c=:ConstantsUtility.DEALER_INTERNAL_ACCESSORIES LIMIT 1]);
        list<Category__c> catList = new list<Category__c>([SELECT id,External_ID_Query__c from Category__c]);
        list<opportunity> opplist = new list<opportunity>([SELECT id from opportunity]);
        list<Account> cstmrIdList = [SELECT ID from account where isPersonAccount = true];
        List<Case> csList2 = TestDataFactory.createCase(2, 'Dealer_Internal_Complaint');
        csList2[1].ownerId = userList[0].Id;
        csList2[1].Status ='New';
        string CaseJson = JSON.serialize(csList[0]);
        Test.startTest();
        CreateInboundCase.fetchCustomerDetails(cstmrIdList[0].Id);
        CreateInboundCase.fetchCustomerDetails(opplist[0].Id);
        CreateInboundCase.fetchCategoryData(catList[0].External_ID_Query__c);
        CreateInboundCase.fetchCaseOwner('test','test');
        CreateInboundCase.fetchenquiryDealerRec('',dealerList[0].Id,ConstantsUtility.DEALER_INTERNAL_SALES);
        CreateInboundCase.updateCaseData(CaseJson,'test','Dealer_Internal_Complaint');
        CreateInboundCase.createHierarchyStructure(csList[0],acclist[0],userList[0].Id);
        
        Test.stopTest();
    }
    @isTest 
    static void testMethd2(){
        Test.startTest();
        list<Account> dealerList = new list<Account>([SELECT id from Account where  recordType.name = 'Dealer' LIMIT 1]);
        
        CreateInboundCase.fetchenquiryDealerRec('',dealerList[0].Id,ConstantsUtility.DEALER_INTERNAL_ACCESSORIES);
        Test.stopTest();
    }
}