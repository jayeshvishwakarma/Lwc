@isTest
public class BulkHoldCasesTriggerHandlerTest {
 @testSetup static void createTestData() {

        list<account> dealerList = TestDataFactory.createDealerAccount(1);
        insert dealerList;
        list<Category__c> CategoryList= TestDataFactory.createCategories(1,'Primary');
        insert CategoryList;
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        insert ImplementationStrategyRecord;
        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(2, ComplaintRecordType);
     	
     	//Id variantRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Variants').getRecordTypeId();
        List<Product2> productsList = TestDataFactory.createProducts( 'Variants',1);
     	productsList[0].Model__c = 'AK';
        insert productsList;
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'Yes'; // Made it yes for custom validation - FCR Conducted should be yes in order to initiate case creation
            c.Case_Type__c='Complaint';
            c.Business_Area__c='Sales';
            c.Channel__c='Arena';
            c.Model__c = 'AK'; // Added for custom validation - Model and Variant Required for Selected Case Type
            c.Variant__c = productsList[0].id; // Added for custom validation - Model and Variant Required for Selected Case Type
            c.Dealer_Name__c=dealerList[0].id;
            c.Primary_Category_ID__c=CategoryList[0].id;
            c.Stakeholders_JSON__c = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
            //c.Stakeholders_JSON__c='{"trueValue":null,"service":null,"sales":[{"stakeHolder":"L3A","refName":"TSM","recordId":"'+userinfo.getUserId().left(15)+'","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"0057F000006zcem","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"0057F000006zcel","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"0057F000006zcf1","phone":"9897876767","email":"shashank@maruti.com.invaild"},{"stakeHolder":"L1","refName":"","recordId":"","phone":"","email":""},{"stakeHolder":"L2A","refName":"Arena QCM","recordId":"0051s000000dDbJAAU","phone":"","email":"gitika.k@techmatrixconsulting.com"}],"msilQuery":null,"msgp":null,"msds":null,"loyaltyProgram":null,"finance":[{"stakeHolder":"L3A","refName":"TSM","recordId":"0057F000006zces","phone":"9897876767","email":"rushil@maruti.com.invaild"},{"stakeHolder":"L4","refName":"RM","recordId":"0057F000006zcem","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"CBH","recordId":"0057F000006zcel","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"MZH EO","recordId":"0057F000006zcf1","phone":"9897876767","email":"shashank@maruti.com.invaild"}],"accessories":[{"stakeHolder":"L3A","refName":"TSM MSGA","recordId":"0057F000006zcf8","phone":"1234567890","email":"akhil.jain@maruti.co.in.invalid"},{"stakeHolder":"L4","refName":"MGA Accessories Zonal","recordId":"0057F000006zcei","phone":"9897876767","email":"rm@maruti.com.invaild"},{"stakeHolder":"L5","refName":"MGA DVM_All","recordId":"0057F000006zcf7","phone":"9897876767","email":"cbh@maruti.com.invaild"},{"stakeHolder":"L6A","refName":"SNP Coordinator","recordId":"0051s000000eKQZ","phone":"9897876767","email":"snp@maruti.com.invaild"},{"stakeHolder":"L7A","refName":"SN Co Head","recordId":"0051s000000dJos","phone":"9897876767","email":"snpco@maruti.com.invaild"},{"stakeHolder":"L9","refName":"MZH","recordId":"0057F000006zcf0","phone":"9897876767","email":"ramsuresh@maruti.com.invaild"},{"stakeHolder":"L10","refName":"Accessories EO","recordId":"0057F000006zcfI","phone":"9897876767","email":"deepak.thukral@maruti.co.in.invalid"}]}';
            c.Selected_Hierarchy_Type__c='sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
            
        }
        insert casesList;
     
     List<Bulk_Hold_Cases__c> bulkHoldcasesList = TestDataFactory.createBulkHoldCase(1);
     insert bulkHoldcasesList;
   
     
     bulkHoldcasesList[0].Approval_Status__c='Approved';
     update bulkHoldcasesList;
     
    }
      static testMethod void updateCallTest() {
        Test.startTest();
        list<case> caseList = [select id,Bulk_Hold_Till_Date__c,Bulk_Hold_Status__c,Bulk_Hold_Start_Date__c from case];
        caseList[0].Bulk_Hold_Till_Date__c=system.today()+1;
        caseList[0].Bulk_Hold_Status__c='In Progress';
        caseList[0].Bulk_Hold_Start_Date__c=system.today();
        update caseList[0];
        Test.stopTest();
    }
}