/**
 * @File Name          : EditInboundCaseTest.cls
 * @Description        : It is utilized for EditInboundCase Apex code coverage
 * @Author             : Prashant Gahlaut
 * @Group              : 
 * Apex Class          : EditInboundCase
 * @Last Modified By   : Nitin
 * @Last Modified On   : 10-19-2020
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                    Author                Modification
 *==============================================================================
 * 1.0        23/01/2020             Prashant Gahlaut       Initial Version
**/
@isTest
public class EditInboundCaseTest {
    public static List<User> portalUserList = [SELECT id FROM user where isPortalEnabled=true AND Designation__c!=NULL AND isActive=true limit 2 ];
    @testSetup
    static void createTestData(){
        //For Code Creation
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        Insert accList;
        List<Contact> conList = TestDataFactory.createTestContact(2, accList[0].Id);
        insert conList;
        List<User> userList= TestDataFactory.createUserData('Portal', 'Call Center Executive Service', conList);
        insert userList;
        
        //Custom setting 
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
        
        //Custom Setting Case Action Validations
        Case_Action_Creation_check_Under_Case__c chck = new Case_Action_Creation_check_Under_Case__c();
        chck.RecordType_DeveloperName__c='Transfer';chck.Single__c=true;chck.Name='Test';
        insert chck;
        
        //creating category data
        List<Category__c> catList = TestDataFactory.createCategory(1);
        insert catList;
        //Create Business Account 
        list<Account> objList= TestDataFactory.createBusinessAccount(1,'User Account');
        objList[0].user__c = userList[0].Id;
        insert objList;
        //Creating Custom setting
        Dealer_Internal_Service_Escalation__c disObj = new Dealer_Internal_Service_Escalation__c(Name=ConstantsUtility.DEALER_INTERNAL_SERVICE_WORKSHOP+'@@'+ 'Level 1',Notification_Level__c='Level 1');
        insert disObj; 
        //Create dealer Inter complaint record type case
        List<Case> csList = TestDataFactory.createCase(3, 'Dealer_Internal_Complaint');
        csList[0].Ownerid = userList[0].Id;
        csList[0].Mobile_Number__c = '9876543210';
        csList[1].Mobile_Number__c = '9876543210';
        csList[0].Inbound_Case_Hierarchy__c = '{ "Level 1": [ "'+userList[0].Id+'" ], "Level 2": [ "'+userList[0].Id+'" ], "Level 3": [ ], "Level 4": [ ]}';
        csList[0].CCP_Next_Escalated_Level__c='Level 1';
        csList[0].Business_Area__c = ConstantsUtility.DEALER_INTERNAL_SALES;
        csList[0].CCP_Next_Escalation_Date_Time__c=System.now();
		csList[1].Inbound_Case_Hierarchy__c = '{ "Level 1": [ "'+userList[0].Id+'" ], "Level 2": [ "'+userList[0].Id+'" ], "Level 3": [ ], "Level 4": [ ]}';
        csList[1].Next_Escalation_Level__c='Level 1';
        csList[1].Next_Escalation_Date__c=System.now();
		csList[1].Business_Area__c = ConstantsUtility.DEALER_INTERNAL_SERVICE_WORKSHOP;
        csList[1].Dealer_Name__c= accList[0].Id;
		csList[1].Case_Stage__c = '';
		csList[1].Dealer_Name__c = accList[0].Id;
        csList[1].ownerId = userList[0].Id;
        csList[2].Business_Area__c ='MIBPL (Insurance)';
        csList[2].Channel__c='MI';
		csList[2].Case_Stage__c = '';
        insert csList;
        
        //Create dealer Inter Feedback record type case
        List<Case> csListFeedback = TestDataFactory.createCase(2, 'Dealer_Internal_Feedback');
        insert csListFeedback;
        //Create dealer Inter Request record type case
        List<Case> csListRequest = TestDataFactory.createCase(2, 'Dealer_Internal_Request');
        insert csListRequest;
        //Create dealer Inter Query record type case
        List<Case> csListQuery = TestDataFactory.createCase(2, 'Dealer_Internal_Query');
        insert csListQuery;
        
        Id caseActionRecordTypeId = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('Dealer_Internal_Case_Transfer').getRecordTypeId();
        List<Case_Actions__c> caList = TestDataFactory.createCaseActions(5,'test',caseActionRecordTypeId,csList[0].Id);
        caList[0].Business_Area__c = ConstantsUtility.DEALER_INTERNAL_SERVICE_BODYSHOP;
        caList[0].dealer_name__c = accList[0].Id;
        caList[0].Transferred_Dealer_Approver__c = portalUserList[0].Id;
        caList[1].Business_Area__c = ConstantsUtility.DEALER_INTERNAL_SERVICE_BODYSHOP;
        caList[1].dealer_name__c = accList[0].Id;
        caList[1].Insurance_Direct_Case_Closure__c=true;
        caList[1].RecordTypeId=ConstantsUtility.DEALERCLOSE_ACTION_RECORD_TYPE_ID;
        caList[1].Primary_Dealer_QCM__c=portalUserList[0].Id;
        caList[2].RecordTypeId=ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID;caList[2].Case_Type__c='Complaint';caList[2].Region_Code__c='C1';
        caList[3].RecordTypeId=ConstantsUtility.DUPLICATE_CASE_ACTION_RECORD_TYPE_ID;caList[3].Original_Complaint_No__c=csList[0].Id;caList[3].Case_Number__c=csList[2].Id;caList[3].Case_Type__c='Complaint';
        caList[3].Channel__c='Nexa';
        caList[4].RecordTypeId=ConstantsUtility.DEALERCLOSE_ACTION_RECORD_TYPE_ID;
        insert caList;
    }
    
    @isTest 
    static void testEditMethd(){
        list<User> userList = [SELECT id,Phone from user where isPortalEnabled =: true and isActive =: true and Phone != null limit 2 ];
        List<Case_Actions__c> caList = new list<Case_Actions__c>([SELECT id,Transferred_Dealer_Approver__c from Case_Actions__c]);
        list<Case> csList = new list<Case>([SELECT id,OwnerId,Dealer_Name__c,Mobile_Number__c from Case ]);
        list<Account> acclist = new list<Account>([SELECT id,User__c,User__r.ManagerId from Account where  recordType.name = 'User Account']);
        list<Account> dealerAccount = new list<Account>([SELECT id,User__c,User__r.ManagerId from Account where  recordType.name = 'Dealer']);
        Test.startTest();
        caList[0].Approval_Status__c = ConstantsUtility.Approved;
        caList[0].Case_Type__c = ConstantsUtility.INTERNAL_QUERY_CASE_TYPE;
        update caList;
        caList[0].Approval_Status__c = ConstantsUtility.STATUS_REJECTED;
        caList[0].Case_Type__c = ConstantsUtility.INTERNAL_FEEDBACK_CASE_TYPE;
        update caList;
        caList[0].Approval_Status__c = ConstantsUtility.Approved;
        caList[0].Case_Type__c = ConstantsUtility.INTERNAL_COMPLAINT_CASE_TYPE;
        caList[0].Insurance_Direct_Case_Closure__c = true;
        update caList;
        caList[0].Approval_Status__c = ConstantsUtility.STATUS_REJECTED;
        caList[0].Case_Type__c = ConstantsUtility.INTERNAL_REQUEST_CASE_TYPE;
        //caList[2].Insurance_Direct_Case_Closure__c=true;
        update caList;
        //caList[0].Approval_Status__c = ConstantsUtility.STATUS_REJECTED;
        caList[0].Recordtypeid = ConstantsUtility.ON_HOLD_CASE_ACTION_RECORD_TYPE_ID;
        caList[0].case_type__c = 'MSIL Query';
        caList[0].Business_Area__c = ConstantsUtility.DEALER_INTERNAL_SERVICE_BODYSHOP;
        update caList;
        string ManagerId = csList[0].OwnerId;
        string CaseJson = JSON.serialize(csList[1]);
        string caseActionJSON = JSON.serialize(caList[0]);
        EditInboundCase.fetchCaseData(csList[0].Id,'test','test','test');
        EditInboundCase.fetchBusinessAreaWorkshop('test','test');
        EditInboundCase.fetchCaseHierarchy(csList[0],acclist[0]);
        EditInboundCase.updateCaseData(CaseJson,userList[1].Id,true);
        EditInboundCase.createCaseActionRecord(caseActionJSON,userList[0].Id,csList[0].OwnerId,'test',ConstantsUtility.DEALER_INTERNAL_INSURANCE);
        CreateMcCommunicationRecord.createMIMCCommRecord('Dealer_Internal_Request',csList,'Customer');
        CreateMcCommunicationRecord.createMIMCCommRecord('Dealer_Internal_Request',csList,'Internal');
        miCaseClosure.fetchCaseRecord(csList[0].Id);
        Id caseActionRecordTypeIdd = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('Dealer_Internal_Case_Transfer').getRecordTypeId();
        List<Case_Actions__c> createCaList = TestDataFactory.createCaseActions(2,'test',caseActionRecordTypeIdd,csList[0].Id);
        createCaList[0].Transferred_Dealer_Approver__c = portalUserList[0].Id;
        string caseActionJSON2 = JSON.serialize(createCaList[0]);
        EditInboundCase.createCaseActionRecord(caseActionJSON2,userList[0].Id,csList[0].OwnerId,'test',ConstantsUtility.DEALER_INTERNAL_INSURANCE);
        Test.stopTest();
    }
    
    @isTest
    static void testEditMethd1(){
        test.startTest();
        list<Case> csList = new list<Case>([SELECT id,OwnerId,Dealer_Name__c,Mobile_Number__c from Case ]);
        list<User> userList = [SELECT id,Phone from user where isPortalEnabled =: true and isActive =: true and Phone != null and Profile.Name=:ConstantsUtility.DEALER_INTERNAL_MANAGER_PROFILE limit 1 ];
        List<Case_Actions__c> caList = new list<Case_Actions__c>([SELECT id,Business_Area__c,Dealer_name__c,Tertiary_Category_ID__c,Secondary_Category_ID__c,Primary_Category_ID__c from Case_Actions__c]);
        string caseActionJSON = JSON.serialize(caList[0]);
        EditInboundCase.createCaseActionRecord(caseActionJSON,userList[0].Id,csList[0].OwnerId,'test',ConstantsUtility.DEALER_INTERNAL_INSURANCE);
        test.stopTest();
    }
    @isTest 
    static void testPrimaryCatMethd(){
        list<User> userList = [SELECT id,Phone from user where isPortalEnabled =: true and isActive =: true and Phone != null limit 2 ];
        list<Category__c> catList = new list<Category__c>([SELECT id from Category__c]);
        list<Case> csList = new list<Case>([SELECT id,OwnerId from Case]);
        string CaseJson;
        string CaseJson2 = JSON.serialize(csList[1]);
        for(Case cs : csList){
            cs.Primary_Category_ID__c = catList[0].Id;
        }
        update csList;
        csList[0].Business_Area__c=ConstantsUtility.DEALER_INTERNAL_SERVICE_BODYSHOP;
        
        update csList;
        
        Test.startTest();
         EditInboundCase.fetchCaseData(csList[0].Id,'test','test','test');
         EditInboundCase.updateCaseData(CaseJson,userList[1].Id,true);
        Test.stopTest();
    }
    
    @isTest
    static void approveCaseAction(){
        List<Case_Actions__c> caList = new list<Case_Actions__c>([SELECT id,Business_Area__c from Case_Actions__c where RecordTypeId=:ConstantsUtility.TRANSFER_CASE_ACTION_RECORD_TYPE_ID]);
        for(Case_Actions__c ca : caList){
            ca.Approval_Status__c=ConstantsUtility.CASE_ACTION_APPROVAL_STATUS_APPROVED;
            ca.Transferred_Dealer_Approver__c=userInfo.getUserID();
        }
        update caList;
    }
    
}