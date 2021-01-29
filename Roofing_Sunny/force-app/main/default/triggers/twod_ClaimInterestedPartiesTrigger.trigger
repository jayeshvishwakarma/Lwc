trigger twod_ClaimInterestedPartiesTrigger on Claim_Interested_Parties__c (before insert,before Update) {
    
    /* Author: Sunny Singh (Capgemini)
     * Description: Added check against Custom Setting "Automation Controller", to see if trigger should run
     * Date: 11 December 2020
     */

    if(!Test.isRunningTest() && !Automation_Controller__c.getOrgDefaults().All_Triggers_enabled__c)  return;
    
    if(!Test.isRunningTest() && !Automation_Controller__c.getOrgDefaults().twod_ClaimInterestedPartiesTrigger__c)  return;
    
    List<String> typelist=new List<String>();
    List<Id> idlist=new List<Id>();            
    for(Claim_Interested_Parties__c con:Trigger.new)   
    {
        idlist.add(con.Claim__c);
        typelist.add(con.Type__c);
    }
    
    Map<Id,List<Claim_Interested_Parties__c>> mapcon=new Map<Id,List<Claim_Interested_Parties__c>>();
    List<Claim_Interested_Parties__c> listCIP=new List<Claim_Interested_Parties__c>();
    for(Claim_Interested_Parties__c con1:[select id,Type__c,Claim__c from Claim_Interested_Parties__c where Type__c IN:typelist and Claim__c In:idlist])        
    {
        if(mapcon.get(con1.Claim__c)==null){
            listCIP=new List<Claim_Interested_Parties__c>();            
        }else{
            listCIP=mapcon.get(con1.Claim__c);
        }
        listCIP.add(con1);
        mapcon.put(con1.Claim__c,listCIP);         
    }
    
    if(trigger.isBefore){
     if(trigger.isInsert){
        for(Claim_Interested_Parties__c cons:Trigger.new)
        {
            system.debug(mapcon);
            if(mapcon.get(cons.Claim__c)!=null)
            {            
                listCIP=mapcon.get(cons.Claim__c);
                for(Claim_Interested_Parties__c cip:listCIP){
                    if(cip.Type__c==cons.Type__c){
                        cons.addError('Claim Interested Parties with Type '+cons.Type__c+' already exist in the System'); 
                    }
                }            
            }
          }
        }
        if(trigger.isBefore){
         if(trigger.isUpdate){
        system.debug('abc');
        for(Claim_Interested_Parties__c cons:Trigger.new)
        {
            system.debug('parties'+mapcon);
            if(mapcon.get(cons.Claim__c)!=null)
            {            
                listCIP=mapcon.get(cons.Claim__c);
                for(Claim_Interested_Parties__c cip:listCIP){
                system.debug('qwert');

                   if(cip.id !=cons.id){
                     system.debug('asdf');
                    if(cip.Type__c==cons.Type__c){
                        cons.addError('Claim Interested Parties with Type '+cons.Type__c+' already exist in the System'); 
                    }
                 }            
              }
            }
        }
      }   
    }    
  }
}