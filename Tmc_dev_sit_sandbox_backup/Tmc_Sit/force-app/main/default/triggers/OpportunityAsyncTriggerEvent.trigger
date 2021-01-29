trigger OpportunityAsyncTriggerEvent on OpportunityChangeEvent (after insert) {
    System.debug('---->OpportunityAsyncTriggerEvent');
    List<Id> convertLeadSet = new List<Id>();
    for (OpportunityChangeEvent oppEvent : Trigger.New) {
        //Get event header fields
        EventBus.ChangeEventHeader header = oppEvent.ChangeEventHeader;
        //header.changetype == 'UPDATE' &&
        System.debug('oppEvent: '+oppEvent);
        if (oppEvent.External_Id__c != null) {
            convertLeadSet.addAll(oppEvent.ChangeEventHeader.getRecordIds());
        }
    }
    if(convertLeadSet.size() > 0){
        System.debug('convertLeadSet: '+convertLeadSet);
        List<Lead> leadConvertList = [SELECT Id, Enq_External_Id__c, Enquiry_Number__c, ConvertedOpportunity.External_Id__c,
                                      ConvertedOpportunity.DMS_Enquiry_Name__c   FROM Lead WHERE 
                                      IsConverted = true AND ConvertedOpportunityId IN: convertLeadSet 
                                      AND (RecordType.DeveloperName = 'aCRM' OR RecordType.DeveloperName = 'Inbound_True_Value_Prospect')];
        List<Lead> updateLeadRecList = new List<Lead>();
        System.debug('leadConvertList: '+leadConvertList.size());
        for(Lead obj : leadConvertList){
            if(obj.Enq_External_Id__c != obj.ConvertedOpportunity.External_Id__c)
                updateLeadRecList.add(new Lead(Id = obj.Id, Enq_External_Id__c = obj.ConvertedOpportunity.External_Id__c, 
                        Enquiry_Number__c = obj.ConvertedOpportunity.DMS_Enquiry_Name__c));
        }
        if(updateLeadRecList.size() > 0){
            System.debug('updateLeadRecList: '+updateLeadRecList.size());
            update updateLeadRecList;
        }
    }else{
        System.debug('convertLeadSet in else: '+convertLeadSet.size());
    }
}