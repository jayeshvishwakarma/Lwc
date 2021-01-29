/**
* @File Name          : SendNotificationToUserTest
* @Description        :
* @Author             : Najab Maghribi
* @Group              :
* @Last Modified By   : Najab Maghribi
* @Last Modified On   : 29/10/2020 03:00 PM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    23/10/2020 10:30 AM         Najab Maghribi            Initial Version
**/
@isTest
public class SendNotificationToUserTest {
    @isTest
    private static void testschedule(){
		Test.StartTest();
		sendNotificationToUser sendNotify = new sendNotificationToUser();
		String sch = '0 0 9 * * ?'; 
		system.schedule('Test sendNotify', sch, sendNotify); 
		Test.stopTest();   
    }
}