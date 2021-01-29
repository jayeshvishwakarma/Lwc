global class LeadConvertBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, isConverted, Is_Completed__c, Interested_in_New_Car__c, Interested_in_TV__c, Upsell_Cross_Sell_Tele_Caller__c FROM LeadStatus';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Lead> leads){
        if(leads.size() > 0){
            List<LeadStatus> leadStatus = [SELECT Id, MasterLabel, ApiName  FROM LeadStatus WHERE IsConverted = true LIMIT 1];
            if(leadStatus.size() > 0){
                List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
                for(Lead myLead : leads){
                    if(!myLead.isConverted && myLead.Is_Completed__c){
                        Database.LeadConvert leadConvertObj = new database.LeadConvert();
                        leadConvertObj.setLeadId(myLead.Id);
                        leadConvertObj.setConvertedStatus(leadStatus[0].ApiName);
                        leadConverts.add(leadConvertObj);
                        if(myLead.Interested_in_New_Car__c == 'Yes'){
                            //vehicleSales.add(myLead);
                        }else if(myLead.Interested_in_TV__c == 'No' && myLead.Upsell_Cross_Sell_Tele_Caller__c.contains('MSGA')){
                            //accessoriesSales.add(myLead);
                        }
                    }
                }
                if(!leadConverts.isEmpty()){
                    List<Database.LeadConvertResult> leadConvertedRecords = Database.convertLead(leadConverts, false);
                }
            }
        }
    }
    global void finish(Database.BatchableContext bc){
        
    }
}