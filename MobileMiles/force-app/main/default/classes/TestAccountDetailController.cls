/*
        Name        :    TestAccountDetailController
        Date        :
        Author      :
        Descriptio  :    This test class cover the test coverage of AccountDetailController
*/
@isTest
private class TestAccountDetailController{
    @isTest
    private static void unitTest(){
        Test.startTest();
        //Inserting a record of Account
        Account acc = new Account(Name = 'Testing Account Record',Straat__c='testStraat',Huisnummer__c = 'Test Huisnummer');
        insert acc;
        
        Contact objCon = new Contact(lastName = 'Testing Contact Record',Email = 'Te@gmail.com', accountId = acc.id);
        insert objCon;
        
        /*Porteringen_mobiel__c  porteringMobile  = new  Porteringen_mobiel__c(Name = '06897458',Type_aanvraag__c = ' Nieuw nummer',Overige_landen_buiten_EU_bundel_100MB__c = true,Account__c = acc.Id);
        insert porteringMobile; */
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Cloud ÉÉN Community' LIMIT 1];
        User usr = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = 'testxyz123@test.com',
                           ProfileId = profileId.id,
                           ContactId = objCon.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert usr;
        
        
        
        System.runAs(usr){
            AccountDetailController controller = new AccountDetailController();
            controller.accObj.Straat__c = 'test str';
            controller.contactList[0].Email = 'test@gmail.com';
            controller.updateAccountDetail();
            controller.updateAccountDetailCheckbox();
            controller.updatePorteringList();
            controller.updateDetail();
            //acc.Straat__c = 'test str';
           // update acc;
        }
        Test.stopTest();
    }
}