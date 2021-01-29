@isTest(seeAllData = false)
private class dynamicDashboardControllerTest{

    static testMethod Void getConfigsTest(){
        Test.startTest();
        
         //Accounts Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        insert accList;
        
        //Contacts Creation
        List<Contact> conList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert conList;
        
         //User Creation
        List<User> usr = TestDataFactory.createUserData('Portal', 'Dealer Hostess', conList);
        insert usr;
        
        system.Runas(usr[0]){
        Report_Configuration__c rc = new Report_Configuration__c();
        rc.Report_Name__c = 'Total Walk-ins for the day';
        rc.User__c = usr[0].Id;
        rc.Sort_order__c = 1;
        insert rc;
        
        dynamicDashboardController.getConfigs();
        delete rc;
        
        dynamicDashboardController.getConfigs();
        
        dynamicDashboardController.getMyReportConfigs();
        }
        
        Report_Conf__c rcon = new Report_Conf__c();
        
        rcon.Name = 'Total Walk-ins for the day';
        rcon.Report_Query__c = 'select status, count(Id) c from Task where status=\'Completed\' and ActivityDate=TODAY and Type=\'S\' GROUP BY Status';
        
        Insert rcon;
        
        dynamicDashboardController.getReportQueryCount(rcon.id, '1');
        
        Report_Conf__c rconf = new Report_Conf__c();
        
        rconf.Name = 'Total Walk-ins for the day';
        rconf.Report_Query__c = 'select Id from Task';
        insert rconf;
        dynamicDashboardController.getReportQueryCount(rconf.id, '');
        
        Test.stopTest();
    }
}