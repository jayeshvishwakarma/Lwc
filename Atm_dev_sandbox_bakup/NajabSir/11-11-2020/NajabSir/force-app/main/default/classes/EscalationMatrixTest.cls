/**
* @File Name          : EscalationMatrixTest.cls
* @Description        : Test Class of the apex class 'EscalationMatrix'
* @Author             : Gitika
**/
@IsTest
public class EscalationMatrixTest {
    @testSetup static void createTestData() {
        
        String stakeHolderJson = TestDataFactory.createStakeHolderJSON(ConstantsUtility.ACCOUNT_OBJ);
        list<Account> dealerList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        dealerList[0].Stakeholder_Hierarchy__c = stakeHolderJson;
        insert dealerList;
    
        list<Category__c> CategoryList= TestDataFactory.createCategories(1,'Primary');
        insert CategoryList;
        Implementation_Strategy__c ImplementationStrategyRecord = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        insert ImplementationStrategyRecord;
        Id ComplaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        List<case> casesList = TestDataFactory.createCase(2, ComplaintRecordType);
    
        for (case c : casesList) {
            c.status = 'New';
            c.Type = 'Renewal';
            c.FCR_Conducted__c = 'Yes';
            c.Customer_Satisfied_With_FCR__c='No';
            c.Case_Type__c='Complaint';
            c.Business_Area__c='Sales';
            c.Channel__c='Arena';
            c.Dealer_Name__c=dealerList[0].id;
            c.Primary_Category_ID__c=CategoryList[0].id;
           c.Stakeholders_JSON__c=stakeHolderJson;
            c.Selected_Hierarchy_Type__c='sales';
            c.Assigned_Date__c=system.now();
            c.Region_Code__c ='C2';
        }
        insert casesList; 
    }
    static testMethod void method1() {
        Test.startTest();
        list<case> caseList = [select id,Stakeholders_JSON__c,Selected_Hierarchy_Type__c from case];
         EscalationMatrix.getEscalationMatrix(caseList[0].Stakeholders_JSON__c,caseList[0].Selected_Hierarchy_Type__c);
        Test.stopTest();
    }
    static testMethod void designAttributeTest() {
        Test.startTest();
        EscalationMatrixDesignAttributes attributes = new EscalationMatrixDesignAttributes();
        VisualEditor.DynamicPickListRows rows = attributes.getValues();
        attributes.getDefaultValue();
        Test.stopTest();
    }


}