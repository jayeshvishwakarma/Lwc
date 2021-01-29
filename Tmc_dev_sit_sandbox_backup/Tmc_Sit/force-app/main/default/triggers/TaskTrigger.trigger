/**
    * @Author:- Nishant Prajapati
    * @Company-: Techmatrix Consulting
    * @Description-: APEX Trigger on Task
    * =============================================================
    * Version   Date            Author      Modification
    * =============================================================
    * 1.0       23 Sept 2019    Nishant     Intial Version
    **/
trigger TaskTrigger on Task (Before delete, After Insert, After Update, Before Insert, Before Update) {
    new TaskTriggerHandler().run();
}