/*********************************************************************************
* Test Class: {TestUtilityClass}
* Created by {DateCreated 12/02/2014} 
----------------------------------------------------------------------------------
* Utility Test Data: {TestClassUtility.cls}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Madan 12/02/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/
@isTest(SeeAllData=true)
private class TestUtilityClass {
    //START Added by Kritika Bhati for S-490562 on 24/7/2017
    static testMethod void myUnitTest5() {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        UtilityClass.sendEmails(emails);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        // Set recipients to two contact IDs.
        // Replace IDs with valid record IDs in your org.
        message.toAddresses = new String[] { 'abcD000000QDexS', 'x12D000000QDfW5' };
        message.subject = 'Opt Out Test Message';
        message.plainTextBody = 'This is the message body.';
        emails.add(message);
        try{
        UtilityClass.sendEmails(emails);
        }
        catch(exception e){
            
        }
         
     
    }
    static testMethod void myUnitTest6() {
           User demoTM = TestClassUtility.createTestUser('System Administrator Integration', 'ts', 'test5@testabc.com', 'testUser5', 'test5@testxyz.com', 'TM', true);
        System.runAs(demoTM){
             UtilityClass.userDetail = demoTM;
             UtilityClass.getLJQStatusOptionsByRole();
             UtilityClass.getLJQStatusMapByRole();
            Region__c region = TestClassUtility.createRegion('testname', 'tst', true);
            Territory__c territory = TestClassUtility.createTerritory('testname', '100', 'Commercial', region.id, true);
            String terrId = territory.Id;
            
            Set<Id> pcrIds = new Set<Id>();
           // Price_Change_Request__c pcr = TestClassUtility.createPriceChangeRequest(territory.Id, true);
           // Price_Change_Request__c pcr1 = TestClassUtility.createPriceChangeRequest(territory.Id, true);
           // pcrIds.add(pcr.Id);
           // pcrIds.add(pcr1.id);
            
            Account customer1 = TestClassUtility.createAccount('test Account',null, 'All_Other_Accounts', 'Other', 'Other', territory.Id, true);
            UtilityClass.buildOptionWithAddress(customer1);
            UtilityClass.fetchShipToAccounts(terrId);
            //UtilityClass.clonePCRs(pcrIds);
            UtilityClass.LJQ_STATUS_FOR_SHARED_TM = null;
            
        //    Map<String, Hierarchy_Matrix__c> hierarchyMatrixMap = null; 
            UtilityClass.fetchHierarchyMatrix();
            
      }
    }
    //End S-490562

    static testMethod void myUnitTest() {
        UtilityClass obj = new UtilityClass();
        
        User u = UtilityClass.userDetail;
        
    //    Map<String, Hierarchy_Matrix__c> mapHierarchyMatrix = UtilityClass.fetchHierarchyMatrix();
        
        Region__c region = TestClassUtility.createRegion('testname', 'tst', true);
        Territory__c territory = TestClassUtility.createTerritory('testname', '100', 'Commercial', region.id, true);

    //    List<Hierarchy_Matrix__c> territoryHierarchyMatrix = UtilityClass.readTerritoryHierarchyMatrixForTM(territory.Id, u.Id);
        EmailTemplate ET = [Select Id, name,developerName From EmailTemplate where (not developerName like '%_cc') limit 1 ];
        String templateApiName = ET.developerName;
        system.debug('templateApiNamee'+templateApiName);
        String pdfAttachmentURL = '/'+region.Id;
        String s = UtilityClass.emailPDF(new List<String>{'test@test.com'}, 'testsubject', 'testtextBody', '/apex/pdfAttachmentURL');
        s = UtilityClass.emailPDF(new List<String>{'test@test.com'}, 'testsubject', 'testtextBody', '');
        s = UtilityClass.emailPDF(null, 'testsubject', 'testtextBody', '');
        s = UtilityClass.emailPDF(new List<String>{'test@test.com'}, '', 'testtextBody', '');
        s = UtilityClass.emailPDF(new List<String>{'test@test.com'}, 'testsubject', '', '');
        
        s = UtilityClass.emailExcel(new List<String>{'test@test.com'}, 'testsubject', 'testtextBody', '/apex/pdfAttachmentURL');
        s = UtilityClass.emailExcel(new List<String>{'test@test.com'}, 'testsubject', 'testtextBody', '');
        s = UtilityClass.emailExcel(null, 'testsubject', 'testtextBody', '');
        s = UtilityClass.emailExcel(new List<String>{'test@test.com'}, '', 'testtextBody', '');
        s = UtilityClass.emailExcel(new List<String>{'test@test.com'}, 'testsubject', '', '');
        
        List<SelectOption> options = UtilityClass.getPicklistValues('Account', 'Type');
        
        Boolean isEmpty = UtilityClass.isEmpty(null);
        /*Large_Job_Quote__c ljq =  new Large_Job_Quote__c();
        ljq.Territory__c =territory.id;
        insert ljq;*/
        UtilityClass.isLJQ = true;
        Contact temp = new Contact(FirstName = 'CTR', LastName = 'User', MailingState = 'AL');  
                insert temp;
        UtilityClass.sendTemplatedEmail(new List<String>(), new List<String>{'test@test.com'},new List<String>{'test@test.com'}, templateApiName, temp.id/*, ljq.id*/, null, false, null );
        
        s = UtilityClass.parseGenericError('_EXCEPTION,testtesttesttest:testtesttesttesttest_EXCEPTION,');
        s = UtilityClass.parseGenericError('DUPLICATE_VALUE' + 'Project_Name__c');
        
        UtilityClass.ProgressBarSteps progressObj = new UtilityClass.ProgressBarSteps(1, 'test', 'test');
        s = UtilityClass.dateToStr(System.today());
        User demoRM = TestClassUtility.createTestUser('System Administrator Integration', 'ts', 'test3@testabc.com', 'testUser3', 'test3@testxyz.com', 'RM', true);
        User demoTM = TestClassUtility.createTestUser('System Administrator Integration', 'ts', 'test5@testabc.com', 'testUser5', 'test5@testxyz.com', 'TM', true);
        User demoPC = TestClassUtility.createTestUser('System Administrator Integration', 'ts', 'test4@testabc.com', 'testUser4', 'test4@testxyz.com', 'PC', true);
        User demoDM = TestClassUtility.createTestUser('System Administrator Integration', 'ts', 'test2@testabc.com', 'testUser2', 'test2@testxyz.com', 'DM', true);
        System.runAs(demoRM){
            UtilityClass.getLJQStatusOptionsByRole();
            UtilityClass.getLJQStatusListByRole();
            UtilityClass.getPCRStatusOptionsByRole();
            UtilityClass.getPCRStatusListByRole();
            UtilityClass.getPCRStatusMapByRole();
            UtilityClass.getBPCRStatusOptionsByRole();
            UtilityClass.getBPCRStatusListByRole();
            UtilityClass.getBPCRStatusMapByRole();
        
        }
        System.runAs(demoDM){
            UtilityClass.getLJQStatusOptionsByRole();
            UtilityClass.getLJQStatusListByRole();
            UtilityClass.getPCRStatusOptionsByRole();
            UtilityClass.getPCRStatusListByRole();
            UtilityClass.getPCRStatusMapByRole();
            UtilityClass.getBPCRStatusOptionsByRole();
            UtilityClass.getBPCRStatusListByRole();
            UtilityClass.getBPCRStatusMapByRole();
            
        }
        
    }
    static testMethod void myUnitTest2() {
        UtilityClass obj = new UtilityClass();
        
        User u = UtilityClass.userDetail;
        
    //    Map<String, Hierarchy_Matrix__c> mapHierarchyMatrix = UtilityClass.fetchHierarchyMatrix();
        
        Region__c region = TestClassUtility.createRegion('testname', 'tst', true);
        Territory__c territory = TestClassUtility.createTerritory('testname', '100', 'Commercial', region.id, true);

    //    List<Hierarchy_Matrix__c> territoryHierarchyMatrix = UtilityClass.readTerritoryHierarchyMatrixForTM(territory.Id, u.Id);

        EmailTemplate ET = [Select Id, name,developerName From EmailTemplate where (not developerName like '%_cc') limit 1 ];
        String templateApiName = ET.developerName;
        String pdfAttachmentURL = '/'+region.Id;
        String s = UtilityClass.emailPDF(new List<String>{'test@test.com'}, 'testsubject', 'testtextBody', '/apex/pdfAttachmentURL');
        s = UtilityClass.emailPDF(new List<String>{'test@test.com'}, 'testsubject', 'testtextBody', '');
        s = UtilityClass.emailPDF(null, 'testsubject', 'testtextBody', '');
        s = UtilityClass.emailPDF(new List<String>{'test@test.com'}, '', 'testtextBody', '');
        s = UtilityClass.emailPDF(new List<String>{'test@test.com'}, 'testsubject', '', '');
        
        s = UtilityClass.emailExcel(new List<String>{'test@test.com'}, 'testsubject', 'testtextBody', '/apex/pdfAttachmentURL');
        s = UtilityClass.emailExcel(new List<String>{'test@test.com'}, 'testsubject', 'testtextBody', '');
        s = UtilityClass.emailExcel(null, 'testsubject', 'testtextBody', '');
        s = UtilityClass.emailExcel(new List<String>{'test@test.com'}, '', 'testtextBody', '');
        s = UtilityClass.emailExcel(new List<String>{'test@test.com'}, 'testsubject', '', '');
        
        List<SelectOption> options = UtilityClass.getPicklistValues('Account', 'Type');
        
        Boolean isEmpty = UtilityClass.isEmpty(null);
        
        UtilityClass.isLJQ = true;
        UtilityClass.sendTemplatedEmail(new List<String>(), new List<String>{'test@test.com'},new List<String>{'test@test.com'}, templateApiName, null, /*null,*/ null, false, null );
        s = UtilityClass.parseGenericError('_EXCEPTION,testtesttesttest:testtesttesttesttest_EXCEPTION,');
        s = UtilityClass.parseGenericError('DUPLICATE_VALUE' + 'Project_Name__c');
        
        UtilityClass.ProgressBarSteps progressObj = new UtilityClass.ProgressBarSteps(1, 'test', 'test');
        s = UtilityClass.dateToStr(System.today());
        User demoRM = TestClassUtility.createTestUser('System Administrator Integration', 'ts', 'test3@testabc.com', 'testUser3', 'test3@testxyz.com', 'RM', true);
        User demoTM = TestClassUtility.createTestUser('System Administrator Integration', 'ts', 'test5@testabc.com', 'testUser5', 'test5@testxyz.com', 'TM', true);
        User demoPC = TestClassUtility.createTestUser('System Administrator Integration', 'ts', 'test4@testabc.com', 'testUser4', 'test4@testxyz.com', 'PC', true);
        User demoDM = TestClassUtility.createTestUser('System Administrator Integration', 'ts', 'test2@testabc.com', 'testUser2', 'test2@testxyz.com', 'DM', true);
        
        System.runAs(demoTM){
            UtilityClass.getLJQStatusOptionsByRole();
            UtilityClass.getLJQStatusListByRole();
            UtilityClass.getPCRStatusOptionsByRole();
            UtilityClass.getPCRStatusListByRole();
            UtilityClass.getPCRStatusMapByRole();
            UtilityClass.getBPCRStatusOptionsByRole();
            UtilityClass.getBPCRStatusListByRole();
            UtilityClass.getBPCRStatusMapByRole();
        
        }
        
        System.runAs(demoDM){
            UtilityClass.getLJQStatusOptionsByRole();
            UtilityClass.getLJQStatusListByRole();
            UtilityClass.getPCRStatusOptionsByRole();
            UtilityClass.getPCRStatusListByRole();
            UtilityClass.getPCRStatusMapByRole();
            UtilityClass.getBPCRStatusOptionsByRole();
            UtilityClass.getBPCRStatusListByRole();
            UtilityClass.getBPCRStatusMapByRole();
            
        }
        
    }
    static testMethod void myUnitTest3() {
        UtilityClass obj = new UtilityClass();
        obj.testmethodcoverga();
        
        User u = UtilityClass.userDetail;
        
    //    Map<String, Hierarchy_Matrix__c> mapHierarchyMatrix = UtilityClass.fetchHierarchyMatrix();
        
        Region__c region = TestClassUtility.createRegion('testname', 'tst', true);
        Territory__c territory = TestClassUtility.createTerritory('testname', '100', 'Commercial', region.id, true);

        // public static List<Hierarchy_Matrix__c> readTerritoryHierarchyMatrixForTM (String territoryId, String TMUser
      //   List<Hierarchy_Matrix__c> territoryHierarchyMatrix = UtilityClass.readTerritoryHierarchyMatrixForTM(territory.Id, u.Id);
       // List<Hierarchy_Matrix__c> territoryHierarchyMatrix = UtilityClass.readTerritoryHierarchyMatrixForTM(territory.Id, u.Id);
        // public static List<Territory__c> ProductAvailabilityTMTrerritories(String territoryId){
        List<Territory__c> territoryList = UtilityClass.ProductAvailabilityTMTrerritories(territory.Id);
        List<string> emailList= UtilityClass.removeSystemUsreEmails(new List<string>{'test@test.com'});
        //set<string> stringSet = UtilityClass.PCR_STATUS_FOR_SHARED_TM();
        //(String plant, String ivdate, String part, String org, String soldto, String shipto, String payer, String idc, String division1, String material)
        List<CustomerResponse> customerResponeList = UtilityClass.getCustomerPricing('Test','Test','Test','Test','Test','Test','Test','Test','Test','Test');
        // public static List<PAPResponse> getPriceAreaPricing(String plant, String ivdate, String district, String org, String material, String division1, String ividc)
        List<PAPResponse> parResponseList = UtilityClass.getPriceAreaPricing('Test','Test',/*'Test',*/'Test','Test','Test','Test');
        
        //getPCRTMEmails(List<String> emailList, List<Hierarchy_Matrix__c> hierarchyMatrix, sObject ljq)
        
        /*Large_Job_Quote__c ljq =  new Large_Job_Quote__c();
        ljq.Territory__c =territory.id;
        insert ljq;*/
        //List<String> emailList =UtilityClass.getPCRTMEmails(new List<string>{'test@test.com'},territoryHierarchyMatrix,ljq);
        EmailTemplate ET = [Select Id, name,developerName From EmailTemplate where (not developerName like '%_cc') limit 1 ];
       // EmailTemplate ET = [Select Id, name,developerName From EmailTemplate limit 1 ];
        String templateApiName =ET.developerName;//Constants.LJQ_Completed_Email;//
       
       
        String pdfAttachmentURL = '/'+region.Id;
        String s = UtilityClass.emailPDF(new List<String>{'test@test.com'}, 'testsubject', 'testtextBody', '/apex/pdfAttachmentURL');
        s = UtilityClass.emailPDF(new List<String>{'test@test.com'}, 'testsubject', 'testtextBody', '');
        s = UtilityClass.emailPDF(null, 'testsubject', 'testtextBody', '');
        s = UtilityClass.emailPDF(new List<String>{'test@test.com'}, '', 'testtextBody', '');
        s = UtilityClass.emailPDF(new List<String>{'test@test.com'}, 'testsubject', '', '');
        
        s = UtilityClass.emailExcel(new List<String>{'test@test.com'}, 'testsubject', 'testtextBody', '/apex/pdfAttachmentURL');
        s = UtilityClass.emailExcel(new List<String>{'test@test.com'}, 'testsubject', 'testtextBody', '');
        s = UtilityClass.emailExcel(null, 'testsubject', 'testtextBody', '');
        s = UtilityClass.emailExcel(new List<String>{'test@test.com'}, '', 'testtextBody', '');
        s = UtilityClass.emailExcel(new List<String>{'test@test.com'}, 'testsubject', '', '');
        
        List<SelectOption> options = UtilityClass.getPicklistValues('Account', 'Type');
         Contact temp = new Contact(FirstName = 'CTR', LastName = 'User', MailingState = 'AL');  
                insert temp;
        
        Boolean isEmpty = UtilityClass.isEmpty(null);
        UtilityClass.isLJQ = true;
        system.debug('templateApiNameeee'+templateApiName);
        UtilityClass.sendTemplatedEmail(new List<String>{'test@test.com','test1@test.com','test@test.com'}, new List<String>{'test@test.com','test1@test.com'},new List<String>{'test@test.com','test1@test.com'}, templateApiName,null,/*null,*/ null, false, null );
        UtilityClass.sendTemplatedEmail(new List<String>{'test@test.com','test1@test.com','test@test.com'}, new List<String>{'test@test.com','test1@test.com'},new List<String>{'test@test.com','test1@test.com'}, templateApiName, null, null, /*null,*/ false, null ,false);
        UtilityClass.sendTemplatedEmail(new List<String>{'test@test.com','test1@test.com','test@test.com'}, new List<String>{'test@test.com','test1@test.com'},new List<String>{'test@test.com','test1@test.com'}, templateApiName, null, null, null, /*false,*/ null ,false,null);
        
        s = UtilityClass.parseGenericError('_EXCEPTION,testtesttesttest:testtesttesttesttest_EXCEPTION,');
        s = UtilityClass.parseGenericError('DUPLICATE_VALUE' + 'Project_Name__c');
        
        UtilityClass.ProgressBarSteps progressObj = new UtilityClass.ProgressBarSteps(1, 'test', 'test');
        s = UtilityClass.dateToStr(System.today());
        User demoRM = TestClassUtility.createTestUser('System Administrator Integration', 'ts', 'test3@testabc.com', 'testUser3', 'test3@testxyz.com', 'RM', true);
        User demoTM = TestClassUtility.createTestUser('System Administrator Integration', 'ts', 'test5@testabc.com', 'testUser5', 'test5@testxyz.com', 'TM', true);
        User demoPC = TestClassUtility.createTestUser('System Administrator Integration', 'ts', 'test4@testabc.com', 'testUser4', 'test4@testxyz.com', 'PC', true);
        User demoDM = TestClassUtility.createTestUser('System Administrator Integration', 'ts', 'test2@testabc.com', 'testUser2', 'test2@testxyz.com', 'DM', true);
        System.runAs(demoDM){
            UtilityClass.getLJQStatusOptionsByRole();
            UtilityClass.getLJQStatusListByRole();
            UtilityClass.getPCRStatusOptionsByRole();
            UtilityClass.getPCRStatusListByRole();
            UtilityClass.getPCRStatusMapByRole();
            UtilityClass.getBPCRStatusOptionsByRole();
            UtilityClass.getBPCRStatusListByRole();
            UtilityClass.getBPCRStatusMapByRole();
            
            
        }
    }
}