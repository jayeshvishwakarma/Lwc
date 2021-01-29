/**
    * @Author:- Anas Yar Khan
    * @Company-: Techmatrix Consulting
    * @Description-: APEX Trigger on Custom Activity
    * =============================================================
    * Version   Date            Author      Modification
    * =============================================================
    * 1.0       08 Oct 2020    Anas     Intial Version
    **/

trigger CustomActivityTrigger on Custom_Activity__c (before delete, after Insert, before Update, after update) {
	new CustomActivityTriggerHandler().run();
}