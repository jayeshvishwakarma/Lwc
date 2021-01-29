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
        if(leadStatus.size() > 0){
            List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
            for(Lead myLead : leads){
                Database.LeadConvert leadConvertObj = new database.LeadConvert();
                leadConvertObj.setLeadId(myLead.Id);
                leadConvertObj.setConvertedStatus(leadStatus[0].ApiName);
                leadConverts.add(leadConvertObj);
            }
            if(!leadConverts.isEmpty()){
                List<Database.LeadConvertResult> leadConvertedRecords = Database.convertLead(leadConverts, false);
                Set<Id> resultIds = new Set<Id>();
                for(Database.LeadConvertResult obj : leadConvertedRecords){
                    if(obj.isSuccess())
                    	resultIds.add(obj.getLeadId());
                    //obj.getOpportunityId();
                }
                if(resultIds.size() > 0){
                    UpdateLeadScheduler sch = new UpdateLeadScheduler(resultIds);
                    /*String exp = '20 30 8 10 2 ?';
                    String jobID = system.schedule('Merge Job', exp, sch);*/
                }
            } 
        }
    }
}