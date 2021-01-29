/* Name : OpportunityTrigger
* Author : Jayesh Vishwakarma
* Date : 20 march 2020
* Description : This Trigger is used to give the list of Opoortunities Which has Change the Stage.
* */

trigger OpportunityTrigger on Opportunity (before insert) {

   if(Trigger.isAfter){
       if(Trigger.isUpdate){
           
           List<Opportunity> lstUpdatedOpportunities;
           for(Opportunity objOpp : Trigger.New){
               Opportunity objOldOpp = Trigger.OldMap.get(ObjOpp.Id);
               
               if(ObjOpp.StageName != objOldOpp.StageName){
                   
                   lstUpdatedOpportunities.add(ObjOpp);
               }
           }
           
           OpportunityTriggerHelper.CreateAssests(lstUpdatedOpportunities);
       }
   }
}