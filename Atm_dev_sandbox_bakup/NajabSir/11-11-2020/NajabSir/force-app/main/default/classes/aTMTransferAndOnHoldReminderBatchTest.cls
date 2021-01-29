@isTest
public class aTMTransferAndOnHoldReminderBatchTest {
    
    static testmethod void test() {
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
        
        MC_Communication__c mc_communicationObj = new MC_Communication__c(
            Email_1__c = 'gitika1018@gmail.com',
            Case_Action__c = case_actionsObj.Id,
            Recipient_Phone_Numbers__c = '9650972207',
            Communication_Type__c = 'SMS',
            Type__c = 'Transfer Escalation' ,
            Escalation_Date_Time__c = system.today());
        insert mc_communicationObj;
        
        aTMTransferAndOnHoldReminderBatch c = new aTMTransferAndOnHoldReminderBatch();
        Database.executeBatch(c);
        aTMTransferAndOnHoldBatchScheduler sh1 = new aTMTransferAndOnHoldBatchScheduler();
        String sch = '0 0 13 * * ? *'; 
        system.schedule('Every Day', sch, sh1);
             
        
    }
}