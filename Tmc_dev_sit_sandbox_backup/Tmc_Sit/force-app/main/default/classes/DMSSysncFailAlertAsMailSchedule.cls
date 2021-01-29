/**
* @File Name          : DMSSysncFailAlertAsMailSchedule.cls
* @Description        : Apex Class to schedule alert for enquiry sync
* @Author             : Rahul Sharma
* @Group              : MSIL
**/

global class DMSSysncFailAlertAsMailSchedule implements Schedulable {
   global void execute(SchedulableContext SC) {
      
      //Calling the data extract script
      DMSSysncFailAlertAsMail.extractFailEnquiryData(null,null);
      
   }
}