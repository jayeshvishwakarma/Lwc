/**
* @File Name          : GenerateOTPValidationTest.cls
* @Description        : Test class for GenerateOTPValidation SFMC API.
* @Author             : Nishant Prajapati
*==============================================================================
* Ver             Author                   Modification
*==============================================================================
* 1.0             Nishant Prajapati           Initial Version
**/
@isTest(seeAllData = false)
public class GenerateOTPValidationTest{
    @testSetup
    static void testrecordcreation(){
    
        Implementation_Strategy__c ImplementationStrategyRecordOpp = TestDataFactory.createImplementation('OpportunityVehicleTriggerServiceImpl','Vehicle_Sales');
        ImplementationStrategyRecordOpp.Use_Case__c = 'OpportunityTriggers';
        insert ImplementationStrategyRecordOpp;
        
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;
        
        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = label.Integration_user;
        
        if(opplist.size() > 0)
            opplist[0].Mobile__c= '9001256780';
        
        insert opplist;
        //insert Account
        list<Account> accList = TestDataFactory.createPersonAccount(1);
        Insert accList;
    }
    
    @istest
    static void otptest(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new GenerateOTPMockClass()); 
        list<Opportunity> opplist = new list<opportunity>([Select id from opportunity]);
        GenerateOTPValidation.saveOtp('123456',opplist[0].id,new map<String, Object>());
        list<Opportunity> opplistQuery = new list<opportunity>([Select id,OTP_Base_Value__c from opportunity]);
        test.stopTest();
    }
    
    @istest
    static void otptestAcc(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new GenerateOTPMockClass()); 
        list<Account> accListQuery = new list<Account>([Select id,PersonMobilePhone,OTP_Base_Value__c from Account where isPersonAccount =true]);
        GenerateOTPValidation.saveOtp('123456',accListQuery[0].id,new map<String, Object>());
        test.stopTest();
    }
    @istest
    static void otptestCVScenario(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new GenerateOTPMockClass()); 
        list<Account> accListQuery = new list<Account>([Select id,PersonMobilePhone,OTP_Base_Value__c from Account where isPersonAccount =true]);
        GenerateOTPValidation.saveOtp('123456',accListQuery[0].id,new map<String, Object>{'CUSOTOMER_VISIBILITY_OTP'=>'CUSOTOMER_VISIBILITY_OTP'});
        test.stopTest();
    }
    @istest
    static void otptestcaseScenario(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new GenerateOTPMockClass()); 
         
        list<account> dealerList = TestDataFactory.createDealerAccount(1);
        insert dealerList;
        list<Category__c> CategoryList= TestDataFactory.createCategories(1,'Primary');
        insert CategoryList;
        List<Implementation_Strategy__c> ImplementationStrategyRecordList = new List<Implementation_Strategy__c>();
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        
        ImplementationStrategyRecordList.add(ImplementationStrategyRecord);
        insert ImplementationStrategyRecordList;
        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
       
        List<case> casesList = TestDataFactory.createCase(1, ComplaintRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'No';
            c.Case_Type__c='Complaint';
            c.Business_Area__c='Sales';
            c.Channel__c='Arena';
            c.Dealer_Name__c=dealerList[0].id;
            c.Primary_Category_ID__c=CategoryList[0].id;
            c.Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":[{"stakeHolder":"L3A","refName":"TSM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"shashank@maruti.com.invaild"},{"stakeHolder":"L1","refName":"","recordId":"","phone":"","email":""},{"stakeHolder":"L2A","refName":"Arena QCM","recordId":"'+Userinfo.getUserId()+'","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msilQuery":null,"msgp":null,"msds":null,"loyaltyProgram":null,"finance":[{"stakeHolder":"L3A","refName":"TSM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"shashank@maruti.com.invaild"}],"accessories":[{"stakeHolder":"L3A","refName":"TSM MSGA","recordId":"'+Userinfo.getUserId()+'","phone":"1234567890","email":"akhil.jain@maruti.co.in.invalid"},{"stakeHolder":"L4","refName":"MGA Accessories Zonal","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"MGA DVM_All","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"Accessories EO","recordId":"'+Userinfo.getUserId()+'","phone":"9897876767","email":"deepak.thukral@maruti.co.in.invalid"}]}';
            c.Selected_Hierarchy_Type__c='sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
            c.OTP_Base_Value__c='344334';
            c.mobile_number__C='9877898989';
            c.FCR_Conducted__c = 'Yes';
        }
       insert casesList;
        GenerateOTPValidation.saveOtp('123456',casesList[0].id,new map<String, Object>{'CUSOTOMER_VISIBILITY_OTP'=>'CUSOTOMER_VISIBILITY_OTP'});
        test.stopTest();
    }
}