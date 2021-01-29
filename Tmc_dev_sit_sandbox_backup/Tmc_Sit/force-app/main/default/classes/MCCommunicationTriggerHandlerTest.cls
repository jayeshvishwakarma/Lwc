@IsTest
public class MCCommunicationTriggerHandlerTest {
	@testSetup static void createTestData() {
        List<Contact> conList = new List<Contact>();
        List<User> lstUserAdmin = TestDataFactory.createUserData('Internal', 'System Administrator', null);
        insert lstUserAdmin;
        System.runAs(lstUserAdmin[0]) {
            List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
            insert forCodeList;
            List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
            accList[0].For_Code__c = forCodeList[0].Id;
            Insert accList;
            conList = TestDataFactory.createTestContact(2, accList[0].Id);
            insert conList;   
        }

        List<User> userList= TestDataFactory.createUserData('Portal', 'Call Center Executive Service', conList);
        UserRole userRole_1 = [SELECT Id FROM UserRole LIMIT 1];

        for(User usr : userList) {
            usr.UserRoleId = userRole_1.Id;
        }
        insert userList;
        
        System.runAs(lstUserAdmin[0]) {
            list<account> dealerList = TestDataFactory.createDealerAccount(1);
            insert dealerList;
            list<Category__c> CategoryList= TestDataFactory.createCategories(1,'Primary');
            insert CategoryList;
            Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
            List<Implementation_Strategy__c> impList1= new List<Implementation_Strategy__c>();
            impList1.add(ImplementationStrategyRecord);
            insert impList1;
            List<Implementation_Strategy__c> impList= new List<Implementation_Strategy__c>();
            Implementation_Strategy__c ImplementationStrategyRecord1 = TestDataFactory.createImplementation('OpportunityVehicleTriggerServiceImpl','Vehicle_Sales');
            ImplementationStrategyRecord1.Use_Case__c='OpportunityTriggers';
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
            // Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
            List<case> casesList = TestDataFactory.createCase(1, 'Dealer_Internal_Complaint');
            for (case c : casesList) {
                c.status = 'New';
                c.Type = 'Renewal';
                c.FCR_Conducted__c = 'No';
                c.Case_Type__c='Dealer Internal Complaint';
                c.Business_Area__c='Sales';
                c.Case_Stage__c = 'Pre Sales';
                c.Channel__c='Arena';
                c.Dealer_Name__c=dealerList[0].id;
                c.Primary_Category_ID__c=CategoryList[0].id;
                c.Stakeholders_JSON__c = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
                //                c.Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":[{"stakeHolder":"L3A","refName":"TSM","recordId":"0057F000006zces","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"0057F000006zcem","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"0057F000006zcel","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"0057F000006zcf1","phone":"9897876767","email":"shashank@maruti.com.invaild"},{"stakeHolder":"L1","refName":"","recordId":"","phone":"","email":""},{"stakeHolder":"L2A","refName":"Arena QCM","recordId":"0051s000000dDbJAAU","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msilQuery":null,"msgp":null,"msds":null,"loyaltyProgram":null,"finance":[{"stakeHolder":"L3A","refName":"TSM","recordId":"0057F000006zces","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"0057F000006zcem","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"0057F000006zcel","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"0057F000006zcf1","phone":"9897876767","email":"shashank@maruti.com.invaild"}],"accessories":[{"stakeHolder":"L3A","refName":"TSM MSGA","recordId":"0057F000006zcf8","phone":"1234567890","email":"akhil.jain@maruti.co.in.invalid"},{"stakeHolder":"L4","refName":"MGA Accessories Zonal","recordId":"0057F000006zcei","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"MGA DVM_All","recordId":"0057F000006zcf7","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"Accessories EO","recordId":"0057F000006zcfI","phone":"9897876767","email":"deepak.thukral@maruti.co.in.invalid"}]}';
                c.Selected_Hierarchy_Type__c='sales';
                c.Assigned_Date__c=system.now();
                c.Region_Code__c ='C2';
                c.ownerId=userList[0].id;
            }
            insert casesList;
            System.debug('casesList::'+ casesList[0]);
            System.debug('ConstantsUtility.DEALER_INTERNAL_CASE_TRANSFER::'+ ConstantsUtility.DEALER_INTERNAL_CASE_TRANSFER);
            System.debug('lstUserAdmin::'+ lstUserAdmin[0]);

            list<Case_Actions__c> caseActions = TestDataFactory.createCaseActions(1, 'Dealer Internal Transfer', ConstantsUtility.DEALER_INTERNAL_CASE_TRANSFER, casesList[0].Id);
            caseActions[0].Transfer_Escalation_Date_Time__c = Datetime.now().addHours(-1);
            System.debug('caseActions::'+caseActions);
            insert caseActions;
            List<Opportunity> oppList=TestDataFactory.createTestOpportunity(1,'Vehicle Sales');
            oppList[0].StageName='New';
            insert oppList;
            list<MC_Communication__c> mcList=TestDataFactory.createMCCommData(3,null);
            mcList[0].Case__c=casesList[0].id;
            mcList[1].Enquiry_MD__c=oppList[0].Id;
            mcList[1].Type__c = ConstantsUtility.ESCALATION_MC_TYPE;
            mcList[1].Case_Action__c=caseActions[0].Id;
            mcList[2].Enquiry_MD__c=oppList[0].Id;
            mcList[2].Type__c = ConstantsUtility.SHOWROOM_WELCOME;
            mcList[2].Case_Action__c=caseActions[0].Id;
            mcList[2].Internal_User__c=userList[0].id;
            insert mcList;
        }
    }
    @IsTest static void createAndUpdate(){
        List<Case> cases=[SELECT id,Registration_No__c,Case_Sub_Type__c,Business_Area__c,Owner.Name,Case_Type__c,Channel__c,Origin,CreatedDate,Mode__c,Case_Stage__c,CaseNumber,Dealer_Code__c,Dealer_Name__r.Name
                                FROM Case];
        System.debug(cases);
       list<MC_Communication__c> mcList=[select id,General_Field_1__c,To_Address__c,Status__c,Type__c from MC_Communication__c];
        mcList[0].General_Field_1__c = '';
        mcList[0].Status__c = 'Picked';
        mclist[0].To_Address__c='test@test.com';
        mcList[0].Escalated_Level__c='Level 1';
        mcList[0].Type__c=ConstantsUtility.DEALER_INTERNAL_RESOLUTION_ESCALATION;
        mcList[1].SFMC_Flag__c=true;
        mcList[1].Escalation_Date_Time__c=System.now();
        update mcList;
        
    }
}