@isTest
public class ChangeOwnerCaseTest {
    
    @isTest
    static void getUserListTest(){
        Test.startTest();
        Implementation_Strategy__c imS = TestDataFactory.createImplementation('CaseMOSCaseTriggerServiceImpl','MOS_Complaints');
        insert imS;
        List<Group> newGroupList = TestDataFactory.createPublicGroup(1);
        newGroupList[0].Type = 'Queue';
        newGroupList[0].Name = 'Test';
        newGroupList[0].DeveloperName = 'Test';
        insert newGroupList;
        
        List<Account> newAcct = TestDataFactory.createBusinessAccount(1,'Business Account');
        insert newAcct;
        List<Contact> newCntct = TestDataFactory.createTestContact(1,newAcct[0].id);
        insert newCntct;
        List<User> userList = TestDataFactory.createUserData('Internal','ATM - Corporate Call Centre Agent',newCntct);
        userList[0].FirstName = 'Test';
        userList[0].LastName = 'Test';
        userList[0].isActive = true;
        insert userList;
        List<Product2> product = TestDataFactory.createProducts('Variants',1);
        product[0].Model__c = 'CI';
        insert product;
        List<Color_Variant_Master__c> colorVariantMaster = TestDataFactory.createColorVarientRealetdToProduct(1,product[0].id);
        insert colorVariantMaster;
        Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MOS Case').getRecordTypeId(); 
        List<Case> caseList = TestDataFactory.createCase(1,caseRecTypeId);
        caseList[0].Color__c = colorVariantMaster[0].id;
        caseList[0].Vehicle_Model__c = 'CI';
        caseList[0].Model__c = 'CI';
        caseList[0].Variant__c = product[0].id;
        caseList[0].MOS_Case_Source__c = 'M-Call';
        caseList[0].Job_Type__c = 'Accidental';
        caseList[0].MOS_Case_Stage__c = 'Reached';
        insert caseList;
        
        ChangeOwnerCase.getUserList(userList[0].FirstName);
        system.runAs(userList[0]){
            ChangeOwnerCase.checkLoggedinUserType(caseList[0].id);
            ChangeOwnerCase.changeOwner(caseList[0].id,userList[0].id);
            ChangeOwnerCase.changeOwner(caseList[0].id,caseList[0].id);
        }
        Test.stopTest();
    }
    
    /*@isTest
    static void checkLoggedinUserType(){
        Test.startTest();
        Implementation_Strategy__c imS = TestDataFactory.createImplementation('CaseMOSCaseTriggerServiceImpl','MOS_Complaints');
        insert imS;
        List<Account> newAcct = TestDataFactory.createBusinessAccount(1,'Business Account');
        insert newAcct;
        List<Contact> newCntct = TestDataFactory.createTestContact(1,newAcct[0].id);
        insert newCntct;
        List<User> userList = TestDataFactory.createUserData('Internal','ATM - Corporate Call Centre TL/ Manager',newCntct);
        insert userList;
        
        
        system.runAs(userList[0]){
            ChangeOwnerCase.checkLoggedinUserType(caseList[0].id);
            ChangeOwnerCase.changeOwner(caseList[0].id,userList[0].id);
        }
        Test.stopTest();
    }*/
    
}