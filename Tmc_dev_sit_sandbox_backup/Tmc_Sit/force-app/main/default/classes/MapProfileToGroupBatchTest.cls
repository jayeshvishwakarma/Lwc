@isTest
public class MapProfileToGroupBatchTest {
    @isTest
    static void validateUserTrigger(){
        List<Profile> profileList= [select id, name from Profile WHERE Name IN ('Dealer Accessories User', 'Dealer GM')];
        
        if(profileList.size() > 0){
            List<User> user2create = new list<User>([SELECT id from user where profile.name='Dealer Accessories User' and isActive = true]);
            system.runAs(user2create[0]){
                Test.startTest();
                insert new Custom_Validation_Exception_Setting__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass_Validation_Rules__c=true);
                insert new Schedule_Apex_Job_Time__c(SetupOwnerId=UserInfo.getOrganizationId(), Time_in_minutes__c= 2);
                user2create[0].Profile = profileList[1];
                update user2create[0];
                MapProfileToGroupBatch BatchObj = new MapProfileToGroupBatch();
                database.executeBatch(BatchObj);
                Test.stopTest();
            }
            
        }
    }
}