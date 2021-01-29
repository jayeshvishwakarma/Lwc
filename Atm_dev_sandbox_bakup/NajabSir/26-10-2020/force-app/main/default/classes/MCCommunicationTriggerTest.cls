@isTest
public class MCCommunicationTriggerTest {
    
    
    static testMethod void method1() {
        List<Opportunity> opp = TestDataFactory.createTestOpportunity(1,'Vehicle Sales');
        opp[0].StageName = 'New';
        insert opp; 
        Case_Actions__c case_actionsObj = new Case_Actions__c(
            Name = 'NCH Legal',
            Approval_Status__c = 'Approved',
            Channel__c = 'Arena',
            Case_Type__c = 'Complaint',
            Business_Area__c = 'Sales',
            Case_Stage__c = 'Pre Sales',
            Primary_Category__c = 'Sales Initiation',
            Secondary_Category__c = 'Dirty Washroom',
            Hold_Till_Date__c = System.today(),
            Region_Code__c = 'C1',Case_Source__c = 'NCH',
            FCR_Conducted__c = 'No',
            Dealer_Code__c = '0813',
            Zone__c = 'Central',
           RecordTypeId = ConstantsUtility.Case_Action_MOS_Escalation_RecordType_Id,
        Escalation_Level__c = 'Red');
        insert case_actionsObj ;  
        
        List<MC_Communication__c> mcComm = TestDataFactory.createMCCommData(1,opp[0].Id);
        mcComm[0].Type__c = 'Send Brochure';
        mcComm[0].General_Field_2__c = 'test123';
        insert mcComm;
    }
    static testMethod void method2() {
        List<Opportunity> opp = TestDataFactory.createTestOpportunity(1,'Vehicle Sales');
        opp[0].StageName = 'New';
        insert opp; 
        Case_Actions__c case_actionsObj = new Case_Actions__c(
            Name = 'NCH Legal',
            Approval_Status__c = 'Approved',
            Channel__c = 'Arena',
            Case_Type__c = 'Complaint',
            Business_Area__c = 'Sales',
            Case_Stage__c = 'Pre Sales',
            Primary_Category__c = 'Sales Initiation',
            Secondary_Category__c = 'Dirty Washroom',
            Hold_Till_Date__c = System.today(),
            Region_Code__c = 'C1',Case_Source__c = 'NCH',
            FCR_Conducted__c = 'No',
            Dealer_Code__c = '0813',
            Zone__c = 'Central');
        insert case_actionsObj ;  
        
        List<MC_Communication__c> mcComm = TestDataFactory.createMCCommData(1,opp[0].Id);
        mcComm[0].Type__c = ConstantsUtility.ESCALATION_MC_TYPE ;
        mcComm[0].General_Field_2__c = 'test123';
        mcComm[0].SFMC_Flag__c = False ;
        insert mcComm;
        mcComm[0].SFMC_Flag__c= True ;
        update mcComm ;
    }
    
    
    static testMethod void method3() {
        
        
        List<Opportunity> opp = TestDataFactory.createTestOpportunity(1,'Vehicle Sales');
        opp[0].StageName = 'New';
        insert opp; 
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = New User(lastName = 'XYZ', 
                          email = 'xyz@gmail.com', 
                          Username = 'xyz12@xyz.com', 
                          ProfileId = p.Id,
                          CompanyName = 'TEST',
                          Title = 'title',
                          Alias = 'alias',
                          TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8',
                          LanguageLocaleKey = 'en_US',
                          LocaleSidKey='en_US'
                         ); 
        insert u;
        
        Case_Actions__c case_actionsObj = new Case_Actions__c(
            Name = 'NCH Legal',
            Approval_Status__c = 'Approved',
            Channel__c = 'Arena',
            Case_Type__c = 'Complaint',
            Business_Area__c = 'Sales',
            Case_Stage__c = 'Pre Sales',
            Primary_Category__c = 'Sales Initiation',
            Secondary_Category__c = 'Dirty Washroom',
            Hold_Till_Date__c = System.today(),
            Region_Code__c = 'C1',Case_Source__c = 'NCH',
            FCR_Conducted__c = 'No',
            Dealer_Code__c = '0813',
            Zone__c = 'Central',
            Transfer_Escalation_Date_Time__c = system.today()+4);
        
        insert case_actionsObj ;  
        
        List<MC_Communication__c> mcComm = TestDataFactory.createMCCommData(1,opp[0].Id);
        mcComm[0].Type__c = ConstantsUtility.SHOWROOM_WELCOME ;
        mcComm[0].General_Field_2__c = 'test123';
        mcComm[0].SFMC_Flag__c = False ;
        mcComm[0].Enquiry_MD__c = opp[0].Id;
        mcComm[0].Internal_User__c =  u.id;
        insert mcComm;
        
    }
    
    static testMethod void method4() {
        List<Opportunity> opp = TestDataFactory.createTestOpportunity(1,'Vehicle Sales');
        opp[0].StageName = 'New';
        insert opp; 
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = New User(lastName = 'XYZ', 
                          email = 'xyz@gmail.com', 
                          Username = 'xyz12@xyz.com', 
                          ProfileId = p.Id,
                          CompanyName = 'TEST',
                          Title = 'title',
                          Alias = 'alias',
                          TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8',
                          LanguageLocaleKey = 'en_US',
                          LocaleSidKey='en_US'
                         ); 
        insert u;
        
        Case c = New Case();
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'No';
            c.priority =   'Normal' ;
        c.recordtypeid =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();       
        insert c;
        
        Case_Actions__c case_actionsObj = new Case_Actions__c(
            Name = 'NCH Legal',
            Approval_Status__c = 'Approved',
            Channel__c = 'Arena',
            //Case_Type__c = 'Complaint',
            Business_Area__c = 'Sales',
            Case_Stage__c = 'Pre Sales',
            Primary_Category__c = 'Sales Initiation',
            Secondary_Category__c = 'Dirty Washroom',
            Hold_Till_Date__c = System.today(),
            Region_Code__c = 'C1',Case_Source__c = 'NCH',
            FCR_Conducted__c = 'No',
            Dealer_Code__c = '0813',
            Zone__c = 'Central',
           // Case_Number__c = c.id,
            Escalation_Level__c = 'Amber',
            recordtypeid = ConstantsUtility.Case_Action_MOS_Escalation_RecordType_Id
            );
        
        insert case_actionsObj ;  
        
 
        List<MC_Communication__c> mcComm = TestDataFactory.createMCCommData(1,opp[0].Id);
        mcComm[0].Status__c = 'Queued' ;
        mcComm[0].Type__c =    ConstantsUtility.TRANSFER_ESCALATION_MC_TYPE ;
        mcComm[0].Escalation_Date_Time__c = system.today();
        mcComm[0].Case_Action__c = case_actionsObj.id ;
        mcComm[0].Email_1__c = 'abc@tech.com';
        mcComm[0].Phone_1__c = '9760332056' ;
        mcComm[0].Internal_User__c =  u.id;
        insert mcComm ;
        mcComm[0].Status__c = ConstantsUtility.MC_Communication_Status_Picked ;
        mcComm[0].Counter__c = 12;
        mcComm[0].case_action__c = case_actionsObj.id;
      
         
        update mcComm;
        
        
        
    }
}