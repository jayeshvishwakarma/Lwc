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
        
        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';
        
        Insert IS;
		
		SF_Retry_Custom_Setting__c cs = new SF_Retry_Custom_Setting__c();
        cs.Name='test';
        cs.LoginEndPoint__c = 'test.com';
        cs.PassWord__c= 'test.com';
        cs.updatePatchEndPoint__c= 'test.com';
        cs.UserName__c = 'test.com';
        cs.Retry__c = false;
        insert cs;
        
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
       	List<Product2>proList = TestDataFactory.createProducts('Variants',1);
    	proList[0].ProductCode = 'AA4BS1';
        proList[0].Family = 'ALTO';
        proList[0].Channel__c = 'NRM';
        proList[0].Model__c = 'A';
    	insert proList;
        List<case> casesList = TestDataFactory.createCase(1, ComplaintRecordType);
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'Yes';
            c.Case_Type__c='Complaint';
            c.Business_Area__c='Sales';
            c.Channel__c='Arena';
            c.Dealer_Name__c=dealerList[0].id;
            c.Primary_Category_ID__c=CategoryList[0].id;
            //c.Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":[{"stakeHolder":"L3A","refName":"TSM","recordId":"0057F000006zces","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"0057F000006zcem","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"0057F000006zcel","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"0057F000006zcf1","phone":"9897876767","email":"shashank@maruti.com.invaild"},{"stakeHolder":"L1","refName":"","recordId":"","phone":"","email":""},{"stakeHolder":"L2A","refName":"Arena QCM","recordId":"0051s000000dDbJAAU","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msilQuery":null,"msgp":null,"msds":null,"loyaltyProgram":null,"finance":[{"stakeHolder":"L3A","refName":"TSM","recordId":"0057F000006zces","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"0057F000006zcem","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"0057F000006zcel","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"0057F000006zcf1","phone":"9897876767","email":"shashank@maruti.com.invaild"}],"accessories":[{"stakeHolder":"L3A","refName":"TSM MSGA","recordId":"0057F000006zcf8","phone":"1234567890","email":"akhil.jain@maruti.co.in.invalid"},{"stakeHolder":"L4","refName":"MGA Accessories Zonal","recordId":"0057F000006zcei","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"MGA DVM_All","recordId":"0057F000006zcf7","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"Accessories EO","recordId":"0057F000006zcfI","phone":"9897876767","email":"deepak.thukral@maruti.co.in.invalid"}]}';
            c.Stakeholders_JSON__c = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
            c.Selected_Hierarchy_Type__c='sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
            c.OTP_Base_Value__c='344334';
            c.mobile_number__C='9877898989';
            c.Model__c ='A';
            c.Variant__c = proList[0].Id;
        }
       insert casesList;
        GenerateOTPValidation.saveOtp('123456',casesList[0].id,new map<String, Object>{'CUSOTOMER_VISIBILITY_OTP'=>'CUSOTOMER_VISIBILITY_OTP'});
        test.stopTest();
    }
}