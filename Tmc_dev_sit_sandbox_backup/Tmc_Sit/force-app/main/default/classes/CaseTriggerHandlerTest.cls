/**
* @File Name          : CaseTriggerHandlerTest.cls
* @Description        : It is utilized for CaseTriggerHandler Apex code coverage
* @Author             : Rajesh Ramachandran
* @Group              : 
* Apex Class		  : CaseTriggerHandler
* @Last Modified By   : Sunit Kumar Chand
* @Last Modified On   : 10-20-2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author      		      Modification
*==============================================================================
* 1.0        18/06/2020               Nitin Ghai   		    	  Initial Version
**/
@isTest
public class CaseTriggerHandlerTest {
    
    @isTest
    public static void method(){
        Test.startTest();
        Bypass_Setting__c bypassSetting = new Bypass_Setting__c(Skip_Update_User_Account_on_Case__c =false); 
        insert bypassSetting;
        
        Id caseRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MI_Renewal').getRecordTypeId();
        Id dncCaseRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Do_No_Call_Requests').getRecordTypeId();
        String taskRecordId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SMR_Appointment').getRecordTypeId();
        Id caseServiceRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        User intergrationUser = [Select Id from User where Id=:System.label.Integration_User];

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
        
        //To Create Customer records
        List<Account> customerRec = TestDataFactory.createPersonAccount(1);
        insert customerRec[0];
        System.runAs(intergrationUser){
            
            //To Create Vehicle New Case records
            List<Case> caseRec = TestDataFactory.createCase(1,caseRecordId);
            caseRec[0].Customer__c=customerRec[0].Id;caseRec[0].Status='New';caseRec[0].subject='';caseRec[0].Mobile_Number__c='9811271001';
            List<Case> caseServiceRec = TestDataFactory.createCase(1,caseServiceRecordId);
            caseRec.add(caseServiceRec[0]);
            insert caseRec;
            
            //To create Task Records
            List<Task> tskRec = TestDataFactory.createTask(1,taskRecordId);
            tskRec[0].Case__c=caseRec[0].Id;
            insert tskRec;
            
            //Update Case to Converted
            for(Case cs:caseRec){
               cs.Status='Converted'; 
            }
            update caseRec;
            //cs.Id=caseRec[0].Id;
            //cs.Status='Converted';
            //update cs;
            
            //To Create DNC Case records
            List<Case> dncRec = TestDataFactory.createCase(1,dncCaseRecordId);
            dncRec[0].Customer__c=customerRec[0].Id;dncRec[0].Status='New';dncRec[0].subject='DNC Request';dncRec[0].Mobile_Number__c='9811271001';
            insert dncRec[0];
            
        }
        
        Test.stopTest(); 
    }
    @isTest
    public static void method1(){
        Test.startTest();
        Bypass_Setting__c bypassSetting = new Bypass_Setting__c(Skip_Update_User_Account_on_Case__c =true);
        insert bypassSetting;
        
        //To Create Customer records
        List<Account> customerRec = TestDataFactory.createPersonAccount(1);
        customerRec[0].SVOC_ID__c='Test Rec5678';
        insert customerRec[0];
        
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
        
        //For Code Creation
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;
        
        //Business Hour
        List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true LIMIT 1];
        
        // To Create Dealer records
        List<Account> dealerAccount =TestDataFactory.createBusinessAccount(1,'Dealer');
        dealerAccount[0].For_code__c=forCodeList[0].Id;
        dealerAccount[0].Business_Hours__c=bhs[0].Id;
        insert dealerAccount;
        
        // To create Contact records
        List<Contact> contactRec = TestDataFactory.createTestContact(1,dealerAccount[0].Id);
        insert contactRec;
        Profile profileRec = [SELECT Id,Name FROM Profile WHERE Name =: System.Label.Service_CCE_Profile LIMIT 1];
        
        //To Create Partner User records
        List<User> partnerUser = TestDataFactory.createUserData('Portal',profileRec.Name,contactRec);
        partnerUser[0].isActive=True;
        partnerUser[0].PortalRole = 'Manager';
        insert partnerUser;
        
        //To create User Account
        list<Account> objList= TestDataFactory.createBusinessAccount(1,'User Account');
        objList[0].user__c = partnerUser[0].Id;
        insert objList;
        
        List<Contact> contactRec1 = TestDataFactory.createTestContact(1,dealerAccount[0].Id);
        insert contactRec1;
        List<User> partnerUser1 = TestDataFactory.createUserData('Portal',profileRec.Name,contactRec1);
        partnerUser1[0].isActive=True;
        partnerUser1[0].PortalRole = 'Manager';
        insert partnerUser1;    
        
        //To create Account Team member
        List<AccountTeamMember> accTeam = TestDataFactory.createAccountTeamMember(1,partnerUser1[0].Id);
        accTeam[0].AccountId=objList[0].Id;
        insert accTeam;
        
        // To create Dealer Internal Cases
        List<Case> parentCaseRec = TestDataFactory.createCase(2, 'Dealer_Internal_Complaint');
        parentCaseRec[0].Dealer_Name__c = dealerAccount[0].Id;
        parentCaseRec[0].ownerId = partnerUser[0].Id;parentCaseRec[1].ownerId = partnerUser[0].Id;
        parentCaseRec[0].Business_Area__c=ConstantsUtility.DEALER_INTERNAL_SERVICE_BODYSHOP;
        parentCaseRec[0].case_stage__c= '';
        parentCaseRec[0].Vehicle_Registration_Number__c = 'MH';
        parentCaseRec[0].Status=ConstantsUtility.DEALER_INTERNAL_CASE_STATUS_TRANSFERRED;
        insert parentCaseRec;
        
        // To Create MC Communication records
        list<MC_Communication__c> mcList=TestDataFactory.createMCCommData(3,null);
        mcList[0].Case__c=parentCaseRec[1].id;
        mcList[0].Type__c = ConstantsUtility.DEALER_RESOLUTION_ESCALATION;
        mcList[1].Case__c=parentCaseRec[1].id;
        mcList[1].Type__c = ConstantsUtility.DEALER_INTERNAL_RESOLUTION_ESCALATION;
        mcList[2].Case__c=parentCaseRec[1].id;
        mcList[2].Type__c = ConstantsUtility.CCP;
        insert mcList;
        
        //Update Dealer Internal case to Closed
        Case csRec = new Case();
        csRec.Customer__c=customerRec[0].Id;
        csRec.Status=ConstantsUtility.CASE_CLOSED;
        csRec.ParentId=parentCaseRec[0].Id;
        csRec.Id=parentCaseRec[1].Id;
        csRec.SVOC_ID__c='Test Rec5678';
        update csRec;
        

        list<AccountTeamMember> accountTeam =  TestDataFactory.createAccountTeamMember(1,partnerUser[0].Id);
        accountTeam[0].AccountId=dealerAccount[0].Id;accountTeam[0].userId=partnerUser[0].Id;
        insert accountTeam;
        
        // To Create User Account records
        List<Account> userAccount =TestDataFactory.createBusinessAccount(1,'User Account');
        userAccount[0].User__c=partnerUser[0].Id;
        insert userAccount;
        
        //To create Custom Setting record
        List<UserEvaluatorFlag__c> userEvalFlag =  TestDataFactory.createUserEvaluatorFlagRec(1,'TestRecord');
        insert userEvalFlag;
        
        Id caseRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MI_Renewal').getRecordTypeId();
        Id dncCaseRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Do_No_Call_Requests').getRecordTypeId();
        
        //To Create Vehicle New Case records
        List<Case> caseRec = TestDataFactory.createCase(1,caseRecordId);
        caseRec[0].Customer__c=customerRec[0].Id;caseRec[0].Status='New';caseRec[0].subject='';caseRec[0].Mobile_Number__c='9811271001';caseRec[0].OwnerId=partnerUser[0].Id;      
        insert caseRec[0];

        //update case owner
        Case cs1 = new Case();
        cs1.Id=caseRec[0].Id;
        cs1.OwnerId=partnerUser1[0].id;
        update cs1;       
        
        //Update Case to Converted
        Case cs = new Case();
        cs.Id=caseRec[0].Id;
        cs.Status='Converted';
        update cs;

        List<Case> csl = new List<Case>{cs};

        CaseTeamRole role = [select Id from CaseTeamRole where Name = 'Agent Team' limit 1];
        CaseTeamMember ctm = new CaseTeamMember(ParentId=cs.id,TeamRoleId=role.id,MemberId=partnerUser[0].Id);
        List<CaseTeamMember> caseTeamList = new List<CaseTeamMember>{ctm};
        CaseTeamDeletion.caseTeamDelete(csl, caseTeamList);
        
        //To Create DNC Case records
        List<Case> dncRec = TestDataFactory.createCase(1,dncCaseRecordId);
        dncRec[0].Customer__c=customerRec[0].Id;dncRec[0].Status='New';dncRec[0].subject='DNC Request';dncRec[0].Mobile_Number__c='9811271001';
        insert dncRec[0];
        
        Test.stopTest(); 
    }
    
}