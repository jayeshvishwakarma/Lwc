@isTest
private class TestZipToFIPSTerritoryController{

    static testmethod void myUnitTest1(){
        Profile profileUsed = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User testUser = new User();
        testUser.Email = 'test@test.com';
        testUser.Username = 'username1@first.com';
        testUser.LastName = 'test';
        testUser.Alias = 'test';
        testUser.ProfileId = profileUsed.Id;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.TimeZoneSidKey = 'America/Chicago';
        testUser.EmailEncodingKey = 'UTF-8';
        
        insert testUser;
        
        List<FIPS__c> fipsList = new List<FIPS__c>();
        
        FIPS__c fips = new FIPS__c();
        fips.Name='Manhattan - New York - USA'; 
        fips.FIPS_Code__c='13125'; 
        fips.Country__c='Canada'; 
        fips.State__c='Vancouver';
        fips.County__c='Vancouver';
       // Insert fips;  
        fipsList.add(fips);
        insert fipsList;
       
       // List<Hierarchy_Matrix__c> hmlist = new List<Hierarchy_Matrix__c>();
             
        Region__c r1 = new Region__c();
        r1.Name = 'name';
        insert r1;
        
        Territory__c terry = new Territory__c();
        terry.Name = 'TS07406';
        terry.Region__c =r1.id;
        insert terry;
      
       
        List<Territory_Assignment__c> Talist = new List<Territory_Assignment__c>();
        Territory_Assignment__c tAssignment = new Territory_Assignment__c();
        tAssignment.Territory__c = terry.id;
        tAssignment.FIPS__c = fips.id;
        Talist.add(tAssignment);
        
        Insert Talist;
                              
        List<Zip_to_Fips__c> zipList = new List<Zip_to_Fips__c>();
        Zip_to_Fips__c zipToFips = new Zip_to_Fips__c();
        zipToFips.Name ='31909';
        //zipToFips.Country__c ='col';
        //zipToFips.State__c ='tx';
        //zipToFips.Type__c ='type';
        zipToFips.FIPS_Code_Name__c = fipsList[0].id;
        zipToFips.City__c = 'New York';
        //zipToFips.Country__c = 'Vancouver';
        zipList.add(zipToFips);
        Insert zipList;    
        
         String zipInput ='31909';       
         
        ZipToFIPSTerritoryController controller = new ZipToFIPSTerritoryController();
        controller.showCity();
        controller.showTerritory();
        controller.reset();
        controller.testmethodcoverga();
        //List<controller.WrapHierarchy> wrapCntl = new List<controller.WrapHierarchy>();
        //CT_IDCSearchComponentController.filterWrapper filterWrapper = new CT_IDCSearchComponentController.filterWrapper();  
       // System.assertNotEquals(null, filterWrapper);
       ZipToFIPSTerritoryController.WrapHierarchy  wrap=new ZipToFIPSTerritoryController.WrapHierarchy();
        System.assertNotEquals(null, wrap);
    }

}