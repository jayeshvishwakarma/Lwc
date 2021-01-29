/*
        Name        :   UnsubscribeEmailsControllerTest
        Date        :   26th June 2019
        Author      :   IBirds Software Services.
        Description :   This Class is use to cover the UnsubscribeEmailsController Class.
*/

@isTest
public class UnsubscribeEmailsControllerTest {
    @isTest
    public Static void doTest(){
        Account accTestRecord = new Account();
        accTestRecord.Name = 'Test';
        insert accTestRecord; //insert Account 
        
        UnsubscribeEmailsController.turnOnOffFlag('Account', 'Opt_out_actiemails__c', accTestRecord.Id, true);
        accTestRecord = [select id, Opt_out_actiemails__c from Account where id =: accTestRecord.id];
        system.assertEquals(accTestRecord.Opt_out_actiemails__c, true);
    }
}