/**
* @File Name          : InfluencerTriggerHandlerTest.cls
* @Description        : Test class for InfluencerTriggerHandler 
* @Author             : Anuj Kumar
* @Group              : 
* @Last Modified By   : 
* @Last Modified On   : 4/02/2020, 5:57:34 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    4/02/2020, 5:57:34 PM     Anuj Kumar               Initial Version

**/
@isTest
public class InfluencerTriggerHandlerTest {
    
    @isTest static void testInfluencerDetailsAssignment(){
        
        //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        
        accList[0].Dealer_Map_Code__c = 'Test Map';
        accList[0].Parent_Group__c = 'Test Group';
        accList[0].Dealer_Location__c = 'Test Location';
        insert accList;
        
        Test.startTest();
        List<Influencer__c> influencerList = TestDataFactory.createTestInfluencer(1, accList[0].Id);
        insert influencerList;
        influencerList[0].Dealership__c= accList[0].Id;
        update influencerList;
        Test.stopTest();
        
    }
    
    @isTest static void testInfluencerDetailsAssignmentWithPortalUser(){
        //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        
        accList[0].Dealer_Map_Code__c = 'Test Map';
        accList[0].Parent_Group__c = 'Test Group';
        accList[0].Dealer_Location__c = 'Test Location';
        insert accList;
        
        List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert conList;
        System.assertEquals(1, conList.size());
        
        List<User> usr = TestDataFactory.createUserData('Portal', 'Dealer Sales Executive', conList);
        insert usr;
        
        List<Influencer__c> influencerList = TestDataFactory.createTestInfluencer(1, accList[0].Id);
        influencerList[0].Dealership__c = accList[0].Id;
        insert influencerList;
        
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        userAccountList[0].User__c = usr[0].Id;
        insert userAccountList;
        
        system.runAs(usr[0]){
            try{
                Influencer__c inf = new Influencer__c();
                inf.Name = 'Test Inf';
                inf.Hierarchy__c = userAccountList[0].Id;
                insert inf;
            }catch(Exception ex){}
        }
        
        system.runAs(usr[0]){
            try{
                Influencer__c inf = new Influencer__c();
                inf.Name = 'Test Inf';
                inf.Dealership__c = accList[0].Id;
                inf.Hierarchy__c = userAccountList[0].Id;
                insert inf;
            }catch(Exception ex){}
        }
    }
    
}