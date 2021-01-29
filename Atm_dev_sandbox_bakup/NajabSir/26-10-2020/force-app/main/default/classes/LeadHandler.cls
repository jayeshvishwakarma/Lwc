/**
* @File Name          : LeadHandler.cls
* @Description        : This class is created to convert a lead into oppprtunity.
* @Author             : Shaik Mufiz
* @Last Modified By   : Shaik Mufiz
* @Last Modified On   : 23/10/2020
*==============================================================================
* Ver     Date            Author                    Modification
*==============================================================================
* 1.0    23/10/2020      Shaik Mufiz                Initial Version
**/
public class LeadHandler{
    
    public static void autoLeadConvert(List<Lead> leads, String recordTypeName){
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        List<LeadStatus> leadStatus = [SELECT Id, MasterLabel, ApiName  FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        System.debug('leadStatus : '+leadStatus);
        for(Lead myLead : leads){
            Database.LeadConvert leadConvertObj = new database.LeadConvert();
            leadConvertObj.setLeadId(myLead.Id);
            leadConvertObj.setConvertedStatus(leadStatus[0].ApiName);
            leadConverts.add(leadConvertObj);
        }
        System.debug('leadConverts : '+leadConverts);
        List<Opportunity> opportunities = new List<Opportunity>();
        if(!leadConverts.isEmpty()){
            List<Database.LeadConvertResult> leadConvertedRecords = Database.convertLead(leadConverts, false);
            System.debug('leadConvertedRecords : '+leadConvertedRecords);
            List<String> errors = new List<String>();
                    
            for(Database.LeadConvertResult lcr : leadConvertedRecords){
                if(lcr.isSuccess()){
                    opportunities.add(new Opportunity(Id = lcr.getOpportunityId(), recordTypeId = recordTypeId));
                }else{
                    // Operation failed, so get all errors                
                    for(Database.Error err : lcr.getErrors()) {            
                       System.debug('error : '+err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
                
            }
            System.debug('opportunities : '+opportunities);
            if(opportunities.size() > 0){
                update opportunities;
                System.debug('Lead converted successfully.');
            }	
        }
    }
}