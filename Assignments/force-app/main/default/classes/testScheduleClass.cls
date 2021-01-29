global class testScheduleClass implements Schedulable {
   global void execute(SchedulableContext ctx) {
       List<Contact> lstContacts = [SELECT Name From Contact LIMIT 5];
       System.debug(lstContacts);
   }
}