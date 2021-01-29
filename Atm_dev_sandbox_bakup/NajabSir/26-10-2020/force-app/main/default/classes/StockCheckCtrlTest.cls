/**
 * @File Name          : StockCheckCtrlTest.cls
 * @Description        : 
 * @Author             : Anuj Kumar
 * @Group              : 
 * @Last Modified By   : Anuj Kumar
 * @Last Modified On   : 30/7/2019 05:30 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    29/7/2019 04:30 PM          Anuj Kumar            Initial Version
**/

@isTest
private class StockCheckCtrlTest{
    
    @testSetup
    static void CreateRecords(){
     //For Code Creation
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;
        
         //Accounts Creation
        List<Account> accountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accountList[0].For_Code__c = forCodeList[0].Id;
        insert accountList;
        
        List<Contact> conList = TestDataFactory.createTestContact(1, accountList[0].Id);
        conList[0].LastName = 'Test Sc2';
        insert conList;
        System.assertEquals(1, conList.size());
        List<User> userList= new List<User>();
        User usr = TestDataFactory.generateUserData('Dealer Hostess', conList[0].Id, 'CEO');
        //usr.Designation__c='GM';
        userList.add(usr);
        
        
        List<Account> accountListDse = TestDataFactory.createBusinessAccount(2, 'Dealer');
        accountListDse[0].For_Code__c = forCodeList[0].Id;
        accountListDse[0].Dealer_Map_Code__c='123';
        accountListDse[1].For_Code__c = forCodeList[0].Id;
        accountListDse[1].Dealer_Map_Code__c='123';
        insert accountListDse;
        
        List<Contact> conListDse = TestDataFactory.createTestContact(1, accountListDse[0].Id);
        List<Contact> conListDse1 = TestDataFactory.createTestContact(1, accountListDse[1].Id);
        conListDse[0].LastName = 'Test Sc2';
        conListDse1[0].LastName = 'Test Sc21';
        conListDse.add(conListDse1[0]);
        insert conListDse;
        //insert usr;
        User usrDSE = TestDataFactory.generateUserData('Dealer Sales Executive', conListDse[0].Id, 'CEO');
        usrDSE.Designation__c='GM';
        userList.add(usrDSE);
        User usrDSE1 = TestDataFactory.generateUserData('Dealer Sales Executive', conListDse[1].Id, 'CEO');
        usrDSE1.Designation__c='GHA';
        userList.add(usrDSE1);
        insert userList;
        //insert usr;
        
        list<product2> productList = TestDataFactory.createProducts('Variants', 1);
        productList[0].Model__c = 'BA';
        productList[0].Enquiry__c = 'Yes';
        
        Insert productList;  
        
        List<Asset> assetList = new List<Asset>(); 
        for(Asset ast : TestDataFactory.CreateAssetsRecords(productList)){
            ast.accountId  = accountList[0].Id;
            
            assetList.add(ast);
        }
        
        Insert assetList;
    }
    
    static testMethod Void codeCoverageMethodForScenario2(){
        
        list<product2> productList = new list<product2>([SELECT Id from product2]);
        System.assertEquals(1, productList.size());
        List<Account> accList = new list <Account>([SELECT id from account where isPersonAccount = false]);
        
        List<Color_Variant_Master__c> colorList = TestDataFactory.createColorVarientRealetdToProduct(1, productList[0].Id);
        list<User> usr = new list<user>([SELECT id from user where profile.Name='Dealer Hostess' and isActive=true]);
        system.runAs(usr[0]){
            Test.startTest();
                StockCheckCtrl.retriveOutletAndForCodeInfo();
                
                StockCheckCtrl.retriveOutletAndForCodeFromAccount(accList[0].Id);
                
                StockCheckCtrl.retriveModelVarient('Ciaz', 'C', productList[0].Id);
                
                StockCheckCtrl.retriveColorVarient(productList[0].Id);
                
                StockCheckCtrl.getResponse();
            Test.stopTest();
        }
        
    }
    
    static testMethod Void codeCoverageMethodForScenario3(){
      list<product2> productList = new list<product2>([SELECT Id from product2]);
        System.assertEquals(1, productList.size());
        List<Account> accList = new list <Account>([SELECT id from account where isPersonAccount = false]);
        
        List<Color_Variant_Master__c> colorList = TestDataFactory.createColorVarientRealetdToProduct(1, productList[0].Id);
        list<User> usr = new list<user>([SELECT id from user where profile.Name='Dealer Hostess' and isActive=true]);
        system.runAs(usr[0]){
            Test.startTest();
                StockCheckCtrl.retriveOutletAndForCodeInfo();
                
                StockCheckCtrl.retriveOutletAndForCodeFromAccount(accList[0].Id);
                
                StockCheckCtrl.retriveModelVarient('Ciaz', 'A',productList[0].Id);
                
                StockCheckCtrl.retriveColorVarient(productList[0].Id);
                
                StockCheckCtrl.getResponse();
            Test.stopTest();
        }
    }
    
    static testMethod Void codeCoverageMethodForScenario4(){
        list<product2> productList = new list<product2>([SELECT Id from product2]);
        System.assertEquals(1, productList.size());
        List<Account> accList = new list <Account>([SELECT id from account where isPersonAccount = false]);
        
        List<Color_Variant_Master__c> colorList = TestDataFactory.createColorVarientRealetdToProduct(1, productList[0].Id);
        list<User> usr = new list<user>([SELECT id from user where profile.Name='System Administrator' and isActive=true]);
        system.runAs(usr[0]){
        Test.startTest();
                StockCheckCtrl.retriveOutletAndForCodeInfo();
                
                StockCheckCtrl.retriveOutletAndForCodeFromAccount(accList[0].Id);
                
                StockCheckCtrl.retriveModelVarient('Ciaz', 'A',productList[0].Id);
                
                StockCheckCtrl.retriveColorVarient(productList[0].Id);
                
                StockCheckCtrl.getResponse();
            Test.stopTest();
        }
        
    }
    static testMethod Void codeCoverageMethodForScenario5(){
        list<product2> productList = new list<product2>([SELECT Id from product2]);
        System.assertEquals(1, productList.size());
        List<Account> accList = new list <Account>([SELECT id from account where isPersonAccount = false]);
        
        List<Color_Variant_Master__c> colorList = TestDataFactory.createColorVarientRealetdToProduct(1, productList[0].Id);
        list<User> usr = new list<user>([SELECT id from user where profile.Name='Dealer Sales Executive' and isActive=true]);
        system.runAs(usr[0]){
           Test.startTest();
                StockCheckCtrl.retriveOutletAndForCodeInfo();
                
                StockCheckCtrl.retriveOutletAndForCodeFromAccount(accList[0].Id);
                
                StockCheckCtrl.retriveModelVarient('Ciaz', 'A',productList[0].Id);
                
                StockCheckCtrl.retriveColorVarient('');
                
                StockCheckCtrl.getResponse();
            Test.stopTest();
        }
        
    }
    static testMethod Void codeCoverageMethodForScenarioNotinCeoGMset(){
        System.debug('Inside codeCoverageMethodForScenarioNotinCeoGMset');
        list<product2> productList = new list<product2>([SELECT Id from product2]);
        System.assertEquals(1, productList.size());
        List<Account> accList = new list <Account>([SELECT id from account where isPersonAccount = false]);
        accList[0].Dealer_Map_Code__c = 'Test Code';
        update accList;
        List<Color_Variant_Master__c> colorList = TestDataFactory.createColorVarientRealetdToProduct(1, productList[0].Id);
        list<User> usr = new list<user>([SELECT id from user where profile.Name='Dealer Sales Executive' and isActive=true and Designation__c='GHA']);
        System.debug(usr);
        system.runAs(usr[0]){
       Test.startTest();
                StockCheckCtrl.retriveOutletAndForCodeInfo();
                
                StockCheckCtrl.retriveOutletAndForCodeFromAccount(accList[0].Id);
                
                StockCheckCtrl.retriveModelVarient('Ciaz', 'A',productList[0].Id);
                
                StockCheckCtrl.retriveColorVarient(productList[0].Id);
                StockCheckCtrl.getAccounts('S');
                StockCheckCtrl.getResponse();
            Test.stopTest();
        }
        
    }
    
    
    static testMethod Void codeCoverageMethodForScenarioCeoGMset(){
        list<product2> productList = new list<product2>([SELECT Id from product2]);
        System.assertEquals(1, productList.size());
        List<Account> accList = new list <Account>([SELECT id from account where isPersonAccount = false]);
        accList[0].Dealer_Map_Code__c = 'Test Code';
        update accList;
        List<Color_Variant_Master__c> colorList = TestDataFactory.createColorVarientRealetdToProduct(1, productList[0].Id);
        list<User> usr = new list<user>([SELECT id from user where profile.Name='Dealer Sales Executive' and isActive=true and Designation__c='GM']);
        System.debug(usr);
        system.runAs(usr[0]){
       Test.startTest();
                StockCheckCtrl.retriveOutletAndForCodeInfo();
                
                StockCheckCtrl.retriveOutletAndForCodeFromAccount(accList[0].Id);
                
                StockCheckCtrl.retriveModelVarient('Ciaz', 'A',productList[0].Id);
                
                StockCheckCtrl.retriveColorVarient(productList[0].Id);
                StockCheckCtrl.getAccounts('S');
                StockCheckCtrl.getResponse();
            Test.stopTest();
        }
        
    }
    
    /*static testMethod Void codeCoverageMethodForScenario1(){
        list<product2> productList = new list<product2>([SELECT Id from product2]);
        System.assertEquals(1, productList.size());
        List<Account> accList = new list <Account>([SELECT id from account where isPersonAccount = false]);
        accList[0].Dealer_Map_Code__c = 'Test Code';
        update accList;
        
        
        List<Color_Variant_Master__c> colorList = TestDataFactory.createColorVarientRealetdToProduct(1, productList[0].Id);
        list<User> usr = new list<user>([SELECT id from user where Profile.Name='Dealer Hostess' and title ='Sales Executive' and isActive=true]);
        
        system.runAs(usr[0]){
            Test.startTest();
                StockCheckCtrl.retriveOutletAndForCodeInfo();
                
                StockCheckCtrl.retriveOutletAndForCodeFromAccount(accList[0].Id);
                
                StockCheckCtrl.retriveModelVarient('Ciaz', 'C',productList[0].Id);
                
                StockCheckCtrl.retriveColorVarient(productList[0].Id);
                
                StockCheckCtrl.getResponse();
                StockCheckCtrl.isContactAccessPermission();
                StockCheckCtrl.getAccounts('S');
            Test.stopTest();
        }
        
    }*/
    
}