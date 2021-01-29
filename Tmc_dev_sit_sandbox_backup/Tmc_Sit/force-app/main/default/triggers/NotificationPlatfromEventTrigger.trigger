trigger NotificationPlatfromEventTrigger on Notification__e (after insert) {

    new NotificationPlatfromEventTriggerHandler().run();

}