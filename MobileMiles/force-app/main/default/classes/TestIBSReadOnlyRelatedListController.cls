/**
Name        :        TestIBSReadOnlyRelatedListController 
Date        :        26th May 2020
Author      :       
Description :        Test Class for IBSReadOnlyRelatedListController 
**/
@isTest
public class TestIBSReadOnlyRelatedListController {
    @isTest
    static void test1(){
        String objectName = 'Contact';
        String fieldNames = 'FirstName,LastName,Email';
        String parentFieldApiName = 'AccountId';
        String parentType = 'Record Detail';    
        String whereClause = 'Name != null';
        String orderBy = 'Name ASC';
        String isFromEvent = 'false';
        String recordId = '';
        
        Account accObj =  new Account(Name = 'Alice');
        insert accObj;
        Contact conObj = new Contact(FirstName = 'Alice', LastName = 'Community', Email = 'AliceComm@gmail.com', AccountId = accObj.Id);
        insert conObj;
        IBSReadOnlyRelatedListController.getSobjectData(objectName, fieldNames, accObj.Id, parentFieldApiName ,parentType, whereClause, orderBy, isFromEvent);
        Profile  proObj = [SELECT ID  FROM profile WHERE name =  'Cloud ÉÉN Community'];
        
        User usr = TestIBSUtil.createTestUser(proObj.Id, conObj.Id, 'Test FirstName', 'Test LastName');
        system.runAs(usr){
            IBSReadOnlyRelatedListController.getUserId();
            parentType = 'Current User';            
            IBSReadOnlyRelatedListController.getSobjectData(objectName, fieldNames, accObj.Id, parentFieldApiName ,parentType, whereClause, orderBy, isFromEvent);
            parentType = 'Current Contact';
            IBSReadOnlyRelatedListController.getSobjectData(objectName, fieldNames, accObj.Id, parentFieldApiName ,parentType, whereClause, orderBy, isFromEvent);
            parentType = 'Current Account';
            IBSReadOnlyRelatedListController.getSobjectData(objectName, fieldNames, accObj.Id, parentFieldApiName ,parentType, whereClause, orderBy, isFromEvent);
        }
        
        IBSReadOnlyRelatedListController.getFlds('Attachment','Name');
    }
    
}