/**
* @File Name          : DNCRequestControllerTest.cls
* @Description        : It is utilized for DNCRequestController Apex code coverage
* @Author             : Nitin Ghai
* @Group              : 
* Apex Class		  : DNCRequestController
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 10-17-2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author      		      Modification
*==============================================================================
* 1.0        15/06/2020               Nitin Ghai   		    	  Initial Version
**/
@isTest
public class DNCRequestControllerTest {
    
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
        //To Create Customer records
        List<Account> customerRec = TestDataFactory.createPersonAccount(1);
        insert customerRec[0];
        String caseJson ='{"Mobile_Number__c":"9123123232","Subject":"Customer Opted for DNC"}';
        BasicReturn result=DNCRequestController.createDNCRequest(caseJson,customerRec[0].Id);
        System.assertEquals(null, result.status) ;
        Test.stopTest(); 
    }
    @isTest
    public static void method1(){
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
        String caseJson ='{"Mobile_Number__c":"9123123232","Subject":"Customer Opted for DNC"}';
        BasicReturn result=DNCRequestController.createDNCRequest(caseJson,caseRec[0].Id);
        System.assertEquals(null, result.status) ;
        Test.stopTest(); 
    }

}