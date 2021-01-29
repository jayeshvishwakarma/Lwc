@isTest
public class CustomInteractionLogTest {
    static testMethod void test() {
        Account a = new Account(name='Tester');
        insert a;
        ApexPages.StandardController sc = new ApexPages.standardController(a);
        CustomInteractionLog customtLog=new CustomInteractionLog(sc);
        customtLog.setCallAttachedData();
        customtLog.setCallEndData();
        customtLog.save();
        customtLog.saveAndNew();       
         
    }
}