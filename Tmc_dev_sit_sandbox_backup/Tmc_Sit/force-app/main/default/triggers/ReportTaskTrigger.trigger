/**
    * @Author:- Satish Kumar
    * @Company-: MSIL
    * @Description-: APEX Trigger on Task
    * =============================================================
    * Version   Date            Author      Modification
    * =============================================================
    * 1.0       23 Sept 2019    Nishant     Intial Version
    **/

trigger ReportTaskTrigger on ReportTask__c (Before delete, After Insert, After Update, Before Insert, Before Update) {
        new ReportTaskTriggerHandler().run();
}