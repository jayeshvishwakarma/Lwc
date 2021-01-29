global class UpdateLeadSchedulerBatch implements Database.Batchable<sObject> {
    Set<Id> convertedLeadIds = new Set<Id>();
    public UpdateLeadSchedulerBatch(Set<Id> leadIds){
        
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Enquiry_Number__c, ConvertedOpportunity.External_Id__c FROM Lead WHERE IsConverted = true AND Id IN: convertedLeadIds AND ConvertedOpportunity.External_Id__c != null';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Lead> leads){
        System.debug('Hello'+convertedLeadIds);
        List<Lead> updateLeadRecList = new List<Lead>();
        /*List<Lead> leadRecords = [SELECT Id, Enquiry_Number__c, ConvertedOpportunity.External_Id__c FROM Lead WHERE 
                                  IsConverted = true AND Id IN: convertedLeadIds AND ConvertedOpportunity.External_Id__c != null];*/
        
        for(Lead obj : leads){
            updateLeadRecList.add(new Lead(Id = obj.Id, Enquiry_Number__c = obj.ConvertedOpportunity.External_Id__c));
        }
        if(updateLeadRecList.size() > 0){
            update updateLeadRecList;
        }
    }
    global void finish(Database.BatchableContext bc){
        
    }
}