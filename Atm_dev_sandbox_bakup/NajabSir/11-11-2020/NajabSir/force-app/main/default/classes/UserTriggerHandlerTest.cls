/**
        * @Autho:- Nishant Prajapati
        * @Company-: Techmatrix Consulting
        * @Description-: Test class for User Trigger Handler.
        * =============================================================
        * Version   Date            Author      Modification
        * =============================================================
        * 1.0       10 Oct 2019    Nishant     Intial Version
        **/
    @istest
    public class UserTriggerHandlerTest {
        
        @testSetup
        static void CreateMethod(){
            List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
            insert forCodeList;
            
            //Accounts Creation
            List<Account> accList = TestDataFactory.createBusinessAccount(2, 'Dealer');
            accList[0].For_Code__c = forCodeList[0].Id;
            accList[0].Parent_Group__c = 'abc';
            accList[1].Parent_Group__c = 'abc';
            accList[0].Region_Code__c= 'E1';
            accList[1].Region_Code__c= 'E1';
            insert accList;
            
            //Contacts Creation 
            List<Contact> conList = TestDataFactory.createTestContact(1, accList[1].Id);
             conList[0].FirstName = 'abc';
             conList[0].LastName = 'abc';
             conList[0].MiddleName = 'abc';
            conList[0].Title = 'Mr.';
            conList[0].IsEvaluator__c = true;
            conList[0].MobilePhone = '9747453765';
            insert conList;
            
            //Contacts Creation 
            List<Contact> conList1 = TestDataFactory.createTestContact(1, accList[0].Id);
            conList1[0].FirstName = 'abc';
             conList1[0].LastName = 'abc';
             conList1[0].MiddleName = 'abc';
            conList1[0].Title = 'Mr.';
            conList1[0].IsEvaluator__c = true;
            conList1[0].MobilePhone = '9747453765';
            insert conList1;
            
            List<Profile> profileList= new list<Profile>([select id, name from Profile WHERE Name IN ('Dealer Accessories User', 'Dealer GM')]);
            List<User> user2create = TestDataFactory.createUserData('Portal', profileList[0].Name, conList);
            user2create[0].Dealer_Employee_Code__c = 'DEFX8876';
            user2create[0].MSPIN__c = 'DSE8899';
            insert user2create;
           }
        
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
        
        @isTest
        static void validateInactiveEvaluatorBatch(){
            List<Profile> profileList= [select id, name from Profile WHERE Name =: 'Dealer TV Evaluator'];
            
            if(profileList.size() > 0){
                List<User> user2create = new list<User>([SELECT id,contactId,contact.IsEvaluator__c from user where profile.name='Dealer Accessories User' and isActive = true and DMS_Active__c = true]);
                    Test.startTest();
                    user2create[0].ProfileId = profileList[0].Id;
                    update user2create[0];
                    inActiveTVEvaluatorSchedule myClass = new inActiveTVEvaluatorSchedule();   
                    String chron = '0 0 23 * * ?';        
                     system.schedule('Test Sched', chron, myClass);
                     test.stopTest();
                }    
            }
            
   }