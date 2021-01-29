/**
* @Autho:- Najab Maghribi
* @Company-: Techmatrix Consulting
* @Description-: Scheduler class for Send Notification to user with specific condition.
* =============================================================
* Version   Date            Author      Modification
* =============================================================
* 1.0       27 Oct 2020    Najab     Intial Version
**/
global class SendNotificationToUser implements Schedulable {
   global void execute(SchedulableContext ctx) {
       NotificationSendToUsers.notificationToUsers();
       NotificationSendToUsers.aCRM_RemainderForDataPreparation();
   }   
}