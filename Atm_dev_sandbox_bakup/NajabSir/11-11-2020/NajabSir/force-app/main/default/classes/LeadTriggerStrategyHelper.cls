/**
* @File Name          : LeadTriggerStrategyHelper
* @Description        : Trigger handler class for Lead.
* @Author             : Shaikh Mufiz
* @Last Modified By   : 
* @Last Modified On   : 
*==============================================================================
* Ver         Date          Modification
*==============================================================================
* 1.0    1/12/2020, 1 PM    Initial Version

**/
public without sharing class LeadTriggerStrategyHelper{
    
    private Map<Id, Lead> newLeadMap; //Used to store the map of new Lead
    private list<Lead> newLeadList; // Used to store the list of new Lead
    private Map<Id, Lead> oldLeadMap; // Used to store Map of old Lead
    private static LeadTriggerStrategyHelper instance = null;
    private Id vehicleSalesRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsUtility.OPPORTUNITY_VEHICLE_SALES_RECORDTYPE).getRecordTypeId();
    
    public static LeadTriggerStrategyHelper getInstance(List<Lead> newLeadList , Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){

        if(instance == null) instance = new LeadTriggerStrategyHelper();
        instance.newLeadList = newLeadList;
        instance.newLeadMap = newLeadMap;
        instance.oldLeadMap = oldLeadMap;
        return instance;
    }
    public void autoLeadConvert(List<Lead> leads){
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
                }
                if(resultIds.size() > 0){
                    DateTime currentTime = System.now();
                    currentTime = currentTime.addMinutes(5);
                    String hour = String.valueOf(currentTime.hour());
                    String min = String.valueOf(currentTime.minute()); 
                    String sec = String.valueOf(currentTime.second());
                    
                    UpdateLeadScheduler updateLeadSchObj = new UpdateLeadScheduler(resultIds);
                    String cronExp = sec + ' ' + min + ' ' + hour + ' * * ?';
                    System.schedule('Execute apex job at '+ String.valueOf(Datetime.now()), cronExp, updateLeadSchObj);
                }
            } 
        }
    }
    public void updateLeadStatus(){
        for(Lead obj : newLeadList){
            Lead oldLead = oldLeadMap.get(obj.Id);
            if(obj.Purchase_Interest__c != oldLead.Purchase_Interest__c){
                if(obj.Purchase_Interest__c == 'W' || obj.Purchase_Interest__c == 'C'){
                    obj.Status = 'Follow Up';
                }else if(obj.Purchase_Interest__c == 'P'){
                    obj.Status = 'Converted_Lost';
                }else if(obj.Purchase_Interest__c == 'H'){
                    obj.Enq_Mode__c = 'BAN'; // BAN => Telephone
                }
            }
        }
    }
    
    public void updateDefaultValues(){
        
        Map<String, String> sourceWithDestinationFieldMap = new Map<String, String>();
        
        //Populate the config value only once.
        for (Survey_Config__mdt surveyConfig : [SELECT MasterLabel, Destination_Field__c, Source_Field__c ,Type__c 
                    FROM Survey_Config__mdt where Object_Name__c = 'Lead']) {
            sourceWithDestinationFieldMap.put(surveyConfig.Source_Field__c, surveyConfig.Destination_Field__c);
        }
        
        system.debug('== sourceWithDestinationFieldMap '+sourceWithDestinationFieldMap);
        
        for(Lead obj : newLeadList){
            obj.LeadSource = 'CRM';
            if(String.isBlank(obj.Interested_in_New_Car__c))
                obj.Interested_in_New_Car__c = 'No';
            /*if(obj.FirstName != null)
                obj.FirstName__c = obj.FirstName;
            if(obj.LastName != null)
                obj.LastName__c = obj.LastName;
            if(obj.Title__c != null)
                obj.Title_Enquiry__c = obj.Title__c;
            if(obj.Gender__c != null)
                obj.Gender_Enquiry__c = obj.Gender__c;*/
                
            if(!sourceWithDestinationFieldMap.isEmpty()){
                for(String sourceField : sourceWithDestinationFieldMap.keySet()){
                    obj.put(sourceWithDestinationFieldMap.get(sourceField), obj.get(sourceField));
                }
            }
            
            system.debug('== obj '+obj);
        }
    }
    
    public void updateColorOnLeads(Boolean isInsert){
        List<Lead> listIterator = new List<Lead>();
        if(isInsert){
            listIterator = newLeadList;
        }else{
            listIterator = newLeadMap.values();
        }

        List<Id> ProductIDs = new List<Id> ();
        Map<Id, Product2> productMap = new Map<id, Product2>();

        for(Lead aCRM :listIterator){
            if((isInsert)&& (aCRM.Variant__c != null)){
                ProductIDs.add(aCRM.Variant__c);
            }else if((!isInsert) && (aCRM.Variant__c != null) && (oldLeadMap.get(aCRM.Id).Variant__c != aCRM.Variant__c) && (aCRM.Color__c == null)){ 
                ProductIDs.add(aCRM.Variant__c);
            }
        }

        if(ProductIDs.size() > 0){
            productMap = new map<id,Product2>([Select Id, (Select Id from Color_Variant_Masters__r limit 1) from product2 where Id IN:ProductIDs]);

            for(Lead aCRM : listIterator){
                if(aCRM.Variant__c != null && productMap.containsKey(aCRM.Variant__c) && productMap.get(aCRM.Variant__c).Color_Variant_Masters__r.size() > 0){
                    aCRM.Color__c = productMap.get(aCRM.Variant__c).Color_Variant_Masters__r[0].Id;
                }
            }
        }
    }
    public void convertLead(){
        List<Opportunity> oppsToCreate  = new List<Opportunity>();
        for(Lead newLead : newLeadList){
            Lead oldLead = oldLeadMap.get(newLead.Id);
            if(newLead.Status != oldLead.Status && newLead.Status == 'Converted_won'){
                Opportunity newOpp = new Opportunity();
                newOpp.First_Name__c = newLead.FirstName;
                newOpp.Middle_Name__c = newLead.MiddleName;
                newOpp.Last_Name__c = newLead.LastName;
                newOpp.Mobile__c = newLead.MobilePhone;
                newOpp.Email__c = newLead.Email;
                newOpp.Title__c = newLead.Salutation;
                newOpp.Name = newLead.FirstName + newLead.LastName + '(Car)';
                newOpp.RecordTypeId = vehicleSalesRecordTypeId;
                newOpp.Line_Of_Business__c = newLead.Line_Of_Business__c;
                newOpp.Dealership_Channel__c = newLead.Dealership_Channel__c;
                newOpp.Ad_Details__c = newLead.AdEventName__c;
                newOpp.Buyer_Type__c = newLead.Buyer_Type__c;
                newOpp.Model_Code__c = newLead.Enq_Model__c;
                newOpp.Variant__c = newLead.Variant__c;
                newOpp.Color__c = newLead.Color__c;
                newOpp.Exchange_Color__c = newLead.Exchange_Color__c;
                newOpp.Exchange_Vehicle_x__c = newLead.Exchange_Vehicle__c;
                newOpp.Gender__c = newLead.Gender__c;
                newOpp.Customer_Type__c = newLead.Customer_Type__c ;
                newOpp.LeadSource  = newLead.LeadSource ;
                newOpp.Test_Drive_Given__c =newLead.Test_Drive_Given__c;
                newOpp.StageName = 'New';
                newOpp.CloseDate = System.today().addDays(90);
                oppsToCreate.add(newOpp);
            }
        }
        if(!oppsToCreate.isEmpty()){
            List<Database.SaveResult> saveResultList = Database.insert(oppsToCreate, false);
            for (Integer i = 0; i < saveResultList.size(); i++) {
                Database.SaveResult sr = saveResultList.get(i);
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted opporutnity. Account ID: ' + sr.getId());
                } else {
                    List<String> errors = new List<String>();
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {            
                        errors.add(err.getStatusCode() + ': ' + err.getMessage());
                    }
                    oppsToCreate.get(i).addError(String.join(errors, ';'));
                }
            }
        }
    }
    public void updateEnquiryNumber(){
        List<Lead> updateLeadList = new List<Lead>();
        for(Lead obj : newLeadList){
            Lead oldLeadRec = oldLeadMap.get(obj.Id);
            if(obj.Enq_External_Id__c != oldLeadRec.Enq_External_Id__c && String.isNotBlank(obj.aCRM__c)){
                updateLeadList.add(new Lead(Id = obj.aCRM__c, Enq_External_Id__c = obj.Enq_External_Id__c));
            }
        }
        if(updateLeadList.size() > 0){
            TriggerHandler.bypass('LeadTriggerHandler_Strategy');
            update updateLeadList;
            TriggerHandler.clearBypass('LeadTriggerHandler_Strategy');
        }else{
            System.debug('True values in else: '+updateLeadList.size());
        }
    }
    // Marketing Cloud's leads convert after 15 minutes
    /*public void convertLeadUsingSchedular(Set<Id> leadIds){
        DateTime currentTime = System.now();
        currentTime = currentTime.addMinutes(15);
        String hour = String.valueOf(currentTime.hour());
        String min = String.valueOf(currentTime.minute()); 
        String sec = String.valueOf(currentTime.second());
        
        LeadConvertScheduler leadConvertSchedulerObj = new LeadConvertScheduler(leadIds);
        String cronExp = sec + ' ' + min + ' ' + hour + ' * * ?';
        System.schedule('Execute apex job at '+ String.valueOf(Datetime.now()), cronExp, leadConvertSchedulerObj);
    }*/
}