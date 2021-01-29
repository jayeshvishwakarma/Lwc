global class UpdateLeadSchedulerBatch implements Database.Batchable<sObject> {
    private Set<Id> convertedLeadIds = new Set<Id>();
    private final string cronTriggerId;
    public UpdateLeadSchedulerBatch(Set<Id> leadIds, String cronTriggerId){
        convertedLeadIds.addAll(leadIds);
        this.cronTriggerId = cronTriggerId;
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Enquiry_Number__c, ConvertedOpportunity.External_Id__c FROM Lead WHERE IsConverted = true AND Id IN: convertedLeadIds AND ConvertedOpportunity.External_Id__c != null';
        System.debug('qry : '+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Lead> leads){
        System.debug('Hello : '+convertedLeadIds);
        List<Lead> updateLeadRecList = new List<Lead>();
        
        for(Lead obj : leads){
            updateLeadRecList.add(new Lead(Id = obj.Id, Enquiry_Number__c = obj.ConvertedOpportunity.External_Id__c));
        }
        if(updateLeadRecList.size() > 0){
            update updateLeadRecList;
            System.debug('Batch class executed successfully : '+ Datetime.now().hour() + ' and '+Datetime.now().minute());
        }else{
            System.debug('Batch class failed on : '+ Datetime.now().hour() + ' and '+Datetime.now().minute());
        }
    }
    global void finish(Database.BatchableContext bc){
        AsyncApexJob apexJob = [SELECT Id  FROM AsyncApexJob WHERE Id =: bc.getJobId()];
        System.debug('Job id : '+bc.getJobId());
        System.abortJob(apexJob.Id);
        List<CronTrigger> jobsToAbort = [select Id from CronTrigger where Id =: cronTriggerId];
        for (CronTrigger job : jobsToAbort) { 
            System.debug('CronTrigger id : ' + job.Id);
            System.abortJob(job.Id); 
        }
    }
}