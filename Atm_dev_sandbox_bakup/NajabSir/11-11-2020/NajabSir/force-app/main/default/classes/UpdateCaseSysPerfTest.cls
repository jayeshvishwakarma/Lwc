/**
* @Description        : Test Class to test Bulk Case Updation
* @Author             : Nitin
**/
@isTest
public class UpdateCaseSysPerfTest {
    @testSetup static void method(){
        Implementation_Strategy__c imS = TestDataFactory.createImplementation('CaseMOSCaseTriggerServiceImpl','MOS_Complaints');
        insert imS;
        //Insert Dealer Record
        list<Account> businessList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        businessList[0].MOS_Category__c='MOS';
        insert businessList;
        //Insert Problem Category
        List<Problem_Category__c> createProb = TestDataFactory.createProblemCategory(1);
        insert createProb;
        String RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MOS_Complaints').getRecordTypeId(); // MOS Complaints record type Id
        // Insert Product Record
        List<Product2> prod = TestDataFactory.createProducts('Variants',1); 
        insert prod;
        // Insert Color Variant Master Record
        List<Color_Variant_Master__c> color = TestDataFactory.createColorVarientRealetdToProduct(1,prod[0].Id);
        insert color;
        //Insert MOS Case
        List<case> casesList = TestDataFactory.createCase(130,RecordTypeId);
        for (case caseObj : casesList) {
            caseObj.Variant__c=prod[0].Id;
            caseObj.Color__c=color[0].Id;
            caseObj.Problem_Category__c=createProb[0].Id;
            caseObj.Allocated_Dealer__c=businessList[0].Id;
            caseObj.Job_Type__c='Breakdown';
            caseObj.Model__c='AN';
            caseObj.Vehicle_Registration_Number__c='TAS012222';
            caseObj.Area__c='Test';
            caseObj.State__c='KL';
            caseObj.Channel__c='Arena';
            caseObj.MOS_Case_Source__c='M-Call';
            caseObj.Mobile_Number__c='9989887876';
            caseObj.Customer_Name__c='Tim Cook';
            caseObj.Warranty_Status__c='Y';
            caseObj.Registered_Contact_Number__c='9989881111';
            caseObj.MOS_Case_Stage__c = 'Out for Service';
        }
        insert casesList;
        //system.debug('casesList---->'+casesList.size());
    }
    
    static testmethod void mth(){
        List<Case> csRec = new List<Case>([Select Id,Description from Case where MOS_Case_Stage__c=:'Out for Service']);
        for(Case cs : csRec){
            cs.Description='Update Case Record';
        }
        update csRec;
    }
}