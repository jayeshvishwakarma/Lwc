@isTest
private class UtilityHelperTest {
   public  static DateTime customDate=system.now();
	@testSetup
    static void CreateRecordForCustomSetting(){
    	CDC_TimeSet__c cs = new CDC_TimeSet__c();
        cs.Name='test';
        cs.TimeSetUp__c=customDate;
         insert cs;

          UserEvaluatorFlag__c  mcs=new UserEvaluatorFlag__c();
    	 mcs.Name='Test';
    	 mcs.Inactive_Batch_Run__c=true;
    	 mcs.isInsert__c=true;
    	 insert mcs;

    }

	@isTest
    public static void retrievTimeCDCTest() {
    	Test.startTest();
          UtilityHelper.retrievTimeCDC();
    	Test.stopTest();


        
    }
    @isTest
    public static void updateAndRetreiveEvalFlagTest1() {



    	 Test.startTest();
          UtilityHelper.updateAndRetreiveEvalFlag(true,'Fetch','inactiveBatch');
    	Test.stopTest();

        
    }

     @isTest
    public static void updateAndRetreiveEvalTest2() {
    	 Test.startTest();
          UtilityHelper.updateAndRetreiveEvalFlag(true,'Fetch','Isinsert');
    	Test.stopTest();
        
    }

      @isTest
    public static void updateAndRetreiveEvalTest3() {
    	 Test.startTest();
          UtilityHelper.updateAndRetreiveEvalFlag(true,'update','inactiveBatch');
    	Test.stopTest();
        
    }
      @isTest
    public static void updateAndRetreiveEvalTest4() {
    	 Test.startTest();
          UtilityHelper.updateAndRetreiveEvalFlag(true,'update','Isinsert');
    	Test.stopTest();
        
    }

      @isTest
    public static void updateEvalSettingTest1() {
    	 Test.startTest();
          UtilityHelper.updateEvalSetting(true,'Isinsert');
    	Test.stopTest();
        
    }
     @isTest
    public static void updateEvalSettingTest2() {
    	 Test.startTest();
          UtilityHelper.updateEvalSetting(true,'inactiveBatch');
    	Test.stopTest();
        
    }
}