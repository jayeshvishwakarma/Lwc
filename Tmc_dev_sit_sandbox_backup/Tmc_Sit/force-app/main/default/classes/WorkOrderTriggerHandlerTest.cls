/**
* @File Name          : WorkOrderTriggerHandlerTest.cls
* @Description        : It is utilized for WorkOrder Trigger, WorkOrderGroupShareService and WorkOrderTriggerHandler Apex code coverage
* @Author             : Nitin Ghai
* @Group              : 
* Apex Class		  : WorkOrderGroupShareService and WorkOrderTriggerHandler
* @Last Modified By   : 
* @Last Modified On   : 15/04/2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author      		      Modification
*==============================================================================
* 1.0        3/20/2020               Nitin Ghai   		    	  Initial Version
* 1.1       15/04/2020               Nitin Ghai	                  Added Custom Setting record creation
**/
@isTest
public class WorkOrderTriggerHandlerTest {
    
    @isTest
    public static void method(){
        
        test.startTest();
        
        // To Create Dealer records
        List<Account> dealerAccount =TestDataFactory.createBusinessAccount(1,'Dealer');
        dealerAccount[0].Dealer_Map_Code__c='1044';
        dealerAccount[0].Dealer_Location__c='OKF';
        insert dealerAccount;
        
        // To create Contact records
        List<Contact> contactRec = TestDataFactory.createTestContact(1,dealerAccount[0].Id);
        insert contactRec;
        
        //To create Custom Setting record
        List<UserEvaluatorFlag__c> userEvalFlag =  TestDataFactory.createUserEvaluatorFlagRec(1,'TestRecord');
        insert userEvalFlag;
        system.debug('userEvalFlag------>'+userEvalFlag);
        
        //To Create Customer records
        List<Account> customerRec = TestDataFactory.createPersonAccount(1);
        insert customerRec;
        
        Profile profileRec = [SELECT Id,Name FROM Profile WHERE Name =: System.Label.Service_CCE_Profile LIMIT 1];
        
        // To Create Asset record and Link with Customer record
        List<Asset> assetRec = TestDataFactory.CreateAssetsRecords(1);
        assetRec[0].AccountId=customerRec[0].Id;
        assetRec[0].Registration_Number__c='HR30R7914';
        insert assetRec[0];
        
        //To Create Partner User records
        List<User> partnerUser = TestDataFactory.createUserData('Portal',profileRec.Name,contactRec);
        partnerUser[0].Dealer_Employee_Code__c='1044';
        insert partnerUser;
        
        // To create Public Group
        List<Group> publicGroup = TestDataFactory.CreateGroupRecords(1,dealerAccount[0].Parent_Group__c);
        insert publicGroup;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
        System.runAs (thisUser) {
            // To create Public Group members
            List<GroupMember> grpMem = TestDataFactory.CreateGroupMemberRecords(1,partnerUser[0].Id,publicGroup[0].Id);
            insert grpMem;
        }     
        
        // To create Work Order records
        List<WorkOrder> workOrdRec = TestDataFactory.CreateWorkOrderRecords(1,'Service Appointment',String.valueOf(assetRec[0].Id),String.valueOf(customerRec[0].Id),dealerAccount[0].Id);
        workOrdRec[0].SA_Code__c='1044';
        workOrdRec[0].OwnerId=partnerUser[0].Id;
        insert workOrdRec;
        
        // To Update Work Order records
        List<WorkOrder> workOrdRec1 = TestDataFactory.CreateWorkOrderRecords(1,'Service Appointment',String.valueOf(assetRec[0].Id),String.valueOf(customerRec[0].Id),dealerAccount[0].Id);
        workOrdRec1[0].Slot_Time__c='11:00-11:15';
        workOrdRec1[0].Id=workOrdRec[0].Id;
        update workOrdRec1;
        
        test.stopTest();
    } 
}