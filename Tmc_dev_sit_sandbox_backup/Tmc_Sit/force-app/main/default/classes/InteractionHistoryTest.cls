/**
 * @File Name          : InteractionHistoryTest.cls
 * @Description        : It is utilized for InteractionHistory Apex code coverage
 * @Author             : Nitin Ghai
 * @Group              : 
 * Apex Class		   : InteractionHistory
 * @Last Modified By   : 
 * @Last Modified On   : 08/06/2020
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0        18/03/2020             Nitin Ghai   		    	  Initial Version
 * 1.1        08/06/2020             Nitin Ghai   		    	  Added system.assertEquals
**/
@isTest
public class InteractionHistoryTest {
    
    @isTest
    public static void run(){
        test.startTest();
        // To Create Dealer records
        List<Account> dealerAccount =TestDataFactory.createBusinessAccount(1,'Dealer');
        dealerAccount[0].Name='premMotors';
        insert dealerAccount;
        
        InteractionHistory.fetchPickValues();
        //InteractionHistory.fetchCustomerId('test');
        List<Account> accList = InteractionHistory.fetchDealerAccounts('premMotors');
        system.assertEquals(1, accList.size());
        test.stopTest();
    }    
    @isTest
    public static void run1(){
        String caseRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MI_Renewal').getRecordTypeId();                          
        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '7';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'CaseMIRenewalTriggerServiceImpl';
        IS.Strategy_Key__c = 'MI_Renewal';
        IS.Use_Case__c = 'CaseTriggers';
        Insert IS;
        List<Account> customerRec = TestDataFactory.createPersonAccount(1);
        insert customerRec[0];
        List<Case> caseRec = TestDataFactory.createCase(1,Id.valueOf(caseRecordId));
        caseRec[0].Customer__c=customerRec[0].Id;caseRec[0].Status='New';caseRec[0].subject='';caseRec[0].Mobile_Number__c='9811271001';
        insert caseRec[0];
        InteractionHistory.fetchCustomerId(caseRec[0].Id);
    }
}