@isTest
public class PurgeCustomerVisibilitySchedular_test{

  @istest
  static void runschedular(){
  
    String jobId = System.schedule('testBasicScheduledApex',
      '20 30 8 10 2 ?', 
         new PurgeCustomerVisibilityRecordsSchedular());
  
  }


}