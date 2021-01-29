trigger sendApprovalProcessComments on Opportunity (after update) {
List<Trigger_Settings__c> lstTriggerSettings = [SELECT Opportunity_Trigger__c From Trigger_Settings__c];
   
   if(lstTriggerSettings.size()>0 && lstTriggerSettings[0].Opportunity_Trigger__c){
    //Bulkfiy
    list<Id> oppIds = new list<Id>();
    for (Opportunity o : Trigger.new){
        oppIds.add(o.Id);
    }
    //Query database for email template
    list<EmailTemplate> et = [SELECT Id, Name FROM EmailTemplate WHERE Name = 'INTERNAL - Afwijzing goedkeuringsverzoek vf' LIMIT 1];
    for (Opportunity o : Trigger.new){
        //Verify opportunity was just changed to rejected
        if (o.Rejected__c && !Trigger.oldMap.get(o.Id).Rejected__c && !et.isEmpty()){                               
            //Send email asynchronously and reset rejected field
            sendRejectionEmail.sendEmail(o.Id,et[0].Id);
        }
    }
}
}