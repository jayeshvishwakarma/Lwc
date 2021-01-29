/*
        Name            :    VoIPTrigger 
        Author          :    iBirds Services
        Date            :    13 August 2019
        Description     :    Used to perform action on VoIP__c records
*/
trigger VoIPTrigger on VoIP__c (after insert, after update) {
    List<Trigger_Settings__c> lstTriggerSettings = [SELECT VolP_Trigger__c From Trigger_Settings__c];
   
   if(lstTriggerSettings.size()>0 && lstTriggerSettings[0].VolP_Trigger__c){
    //To call Web Http Request when Contract_duur_afloopdatum_wijzigen__c is checked (13/8/2019) by shikha
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        Set<ID> contractIds = new Set<ID>();

        for(VoIP__c voip : Trigger.new){
          if(System.IsBatch() == false && System.isFuture() == false){ 
              if((Trigger.isInsert && voip.Contract_duur_afloopdatum_wijzigen__c == true) || (Trigger.isUpdate && trigger.oldMap.get(voip.id).Contract_duur_afloopdatum_wijzigen__c != voip.Contract_duur_afloopdatum_wijzigen__c && voip.Contract_duur_afloopdatum_wijzigen__c == true)){
                  contractIds.add(voip.id);
              }
          }
        }
        //call web service
        if(contractIds.size() > 0){
            VoIPTriggerHelper.VoIPModifyContractTerminationGREXX(contractIds);
        }
        
    }  
}
}