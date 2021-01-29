/**
* @File Name          : CurrentAccuntRelatedCasesCtrlTest.cls
* @Description        : It is utilized for CurrentAccuntRelatedCasesCtrl Apex code coverage
* @Author             : Nitin Ghai
* @Group              : 
* Apex Class		  : CurrentAccuntRelatedCasesCtrl
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 10-17-2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author      		      Modification
*==============================================================================
* 1.0        18/06/2020               Nitin Ghai   		    	  Initial Version
**/
@isTest
public class CurrentAccuntRelatedCasesCtrlTest {
    
    @isTest
    public static void method(){
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
        Test.startTest();
        Id caseRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MI_Renewal').getRecordTypeId();
        //To Create Customer records
        List<Account> customerRec = TestDataFactory.createPersonAccount(1);
        insert customerRec[0];
        //To Create Case records
        List<Case> caseRec = TestDataFactory.createCase(1,caseRecordId);
        caseRec[0].Customer__c=customerRec[0].Id;caseRec[0].Status='New';
        insert caseRec[0];
        List<Case> cs=CurrentAccuntRelatedCasesCtrl.fetchData(caseRec[0].Id);
        System.assertEquals(0,cs.size()) ;
        Test.stopTest(); 
    }
}