@isTest(seealldata=true)
global class twod_scheduleTwodLicenseReportsTest {
    global static testMethod void testTry(){
        Test.StartTest();
        twod_scheduleTwodLicenseReports sh1 = new twod_scheduleTwodLicenseReports();
        String sch = '0 5 5 * * ?';
        System.schedule('test', sch, sh1);
        Test.stopTest();
    }
}