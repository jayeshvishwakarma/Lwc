@istest(SeeAllData=true)
public class CustomerModifyIBANSchedulerTest{
    @istest(SeeAllData=true)
    public static void  CustomerModifyIBANSchedulerTestMethod() {
        String chron_exp = '0 0 23 * * ?';
        List<Account> accountList = [SELECT id, iRMA_id__c, Name, Straat__c, Huisnummer__c, Huisnummer_toevoeging__c, 
                                     Postcode__c, ShippingCity, Phone, E_mailadres_bedrijf__c, ExternalId__c, KvK_nummer__c, 
                                     Rechtsvorm__c 
                                     FROM Account
                                     Limit 10];
         if(accountList.size()>0){
             for(Account accO : accountList){
                 accO.IRMA_MKB_Office__c = true; 
                 accO.Check_Temp_Status__c = false;
                 accO.temp_status_msg__c = null;  
             }
         }
         update accountList;                          
        //Schedule the next job, and give it the system time so name is unique
        test.startTest();
        System.schedule('CustomerModify IBANScheduler' + System.now().getTime(),chron_exp, new CustomerModifyIBANScheduler());
    	test.stopTest();
    }
}