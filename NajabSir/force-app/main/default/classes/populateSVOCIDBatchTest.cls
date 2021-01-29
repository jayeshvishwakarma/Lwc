@isTest
public with sharing class populateSVOCIDBatchTest {
    
    
    static testmethod void test() {
        
        //Create Test Data
        createData();
		
        //Run the batch job
        Test.startTest();
            populateSVOCIDBatch bat = new populateSVOCIDBatch('select id, Corporate_Code__c,FirstName,LastName,MiddleName,SVOC_ID__c,LastModified_SVOC_Time_Stamp__c,Employer_Name__c from Account where CREATEDDATE = TODAY');
            Database.executeBatch(bat,5000);        
        Test.stopTest();
        list<Account> accList = [select id, Corporate_Code__c,FirstName,LastName,MiddleName,SVOC_ID__c,LastModified_SVOC_Time_Stamp__c,Employer_Name__c 
                                    from Account 
                                    where CREATEDDATE = TODAY
                                    AND FirstName = 'FIRST'];

        for(Account acc :accList){
            if(acc.Corporate_Code__c != null){
                //Check if the employer is updated or not.
                system.assertNotEquals(acc.Employer_Name__c,null);
                //Check if the Last Modified SVOC date is stamped
                system.assertNotEquals(acc.LastModified_SVOC_Time_Stamp__c, null);
            }
        }

    }

    //Method to populate sample data.
    static void createData(){

        Corporate__c c = new Corporate__c();
        c.Corporate_Code__c = 'ABC';
        c.Name = 'Test';
        insert c;


        Account a = new Account();
        a.FirstName = 'first';
        a.LastName  = 'LAST';
        a.Corporate_Code__c = 'ABC';
        a.SVOC_ID__C = '1234567';
        insert a;

    }    
    
    public populateSVOCIDBatchTest() {

    }
}