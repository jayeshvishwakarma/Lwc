global class LeadConvertSchedulerBatch implements Database.Batchable<sObject> {
    private final string convertedStatus;
    global LeadConvertSchedulerBatch(String convertedStatus){
        this.convertedStatus = convertedStatus;
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Interested_in_New_Car__c, Interested_in_TV__c, Upsell_Cross_Sell_Tele_Caller__c FROM Lead WHERE IsConverted = false AND Enq_Mode__c = \'MKTC\'';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Lead> leads){
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        for(Lead myLead : leads){
            if(myLead.Interested_in_New_Car__c == 'Yes' || (myLead.Interested_in_TV__c == 'No' && myLead.Upsell_Cross_Sell_Tele_Caller__c.contains('MSGA'))){
                Database.LeadConvert leadConvertObj = new database.LeadConvert();
                leadConvertObj.setLeadId(myLead.Id);
                leadConvertObj.setConvertedStatus(convertedStatus);
                leadConverts.add(leadConvertObj);
            }            
        }
        if(!leadConverts.isEmpty()){
            List<Database.LeadConvertResult> leadConvertedRecords = Database.convertLead(leadConverts, false);
        }
    }
    global void finish(Database.BatchableContext bc){
        /*AsyncApexJob apexJob = [SELECT Id  FROM AsyncApexJob WHERE Id =: bc.getJobId()];
        List<CronTrigger> jobsToAbort = [select Id from CronTrigger where Id =: cronTriggerId];
        for (CronTrigger job : jobsToAbort) { 
            System.abortJob(job.Id); 
        }*/
    }
}