trigger copyApprovalProcessComments on Opportunity (before update) {
    //Bulkfiy
    List<Trigger_Settings__c> lstTriggerSettings = [SELECT Opportunity_Trigger__c From Trigger_Settings__c];
    
    if(lstTriggerSettings.size()>0 && lstTriggerSettings[0].Opportunity_Trigger__c){
    list<Id> oppIds = new list<Id>();
    for (Opportunity o : Trigger.new){
        oppIds.add(o.Id);
    }
    //Query database for approval process steps
    list<ProcessInstanceStep> steps = [SELECT ProcessInstanceId, ProcessInstance.TargetObjectId, StepStatus, Comments FROM ProcessInstanceStep WHERE ProcessInstance.TargetObjectId in :oppIds ORDER BY CreatedDate DESC];
    //Moving email template query to sendApprovalProcessComments trigger
    //Query database for email template
    //list<EmailTemplate> et = [SELECT Id, Name FROM EmailTemplate WHERE Name = 'INTERNAL - Afwijzing goedkeuringsverzoek vf' LIMIT 1];
    for (Opportunity o : Trigger.new){
        //Verify opportunity was just changed to rejected
        if (o.Rejected__c && !Trigger.oldMap.get(o.Id).Rejected__c){
            //Copy comments from most recent step
            for (ProcessInstanceStep step : steps){
                if (o.Id == step.ProcessInstance.TargetObjectId){
                    o.Comments__c = step.Comments;
                    //Commenting out the logic below and inserting into async method
                    //to be called by after update trigger
                    /*
                    //Reset rejected field
                    o.Rejected__c = false;
                    //Set up email
                    //New instance of a single email message
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    //Send email to opportunity owner
                    mail.setTargetObjectId(o.OwnerId);
                    //Set email template
                    mail.setTemplateId(et[0].Id);
                    //Set opportunity record
                    mail.setWhatId(o.Id);   
                    //Set save as activity to false
                    mail.setSaveAsActivity(false);
                    //Send email
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    */
                    //Break loop
                    break;
                }
            }
        }
    }
    }
}