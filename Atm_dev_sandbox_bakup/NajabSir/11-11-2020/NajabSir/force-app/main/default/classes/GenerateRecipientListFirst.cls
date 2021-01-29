public class GenerateRecipientListFirst implements Queueable {
    
    public void execute(QueueableContext context) {
        set<String> applicableChannels = new set<String>();
        applicableChannels.add('Nexa');
        applicableChannels.add('Arena');
        applicableChannels.add('TrueValue');
        applicableChannels.add('Commercial');
        applicableChannels.add('MSDS');
        applicableChannels.add('MSGP');
        applicableChannels.add('MS Corporate');
        
        
        List<Category__c> categoryList = new List<Category__c>([
            SELECT Id,Name,Type__c,Channel__c,Case_Type__c,Business_Area__c,Case_Stage__c,Primary_Category__c,Primary_Category__r.Name,
            Secondary_Category__c,Region_Mandatory__c,External_ID__c 
            FROM Category__c WHERE Channel__c in: applicableChannels and Active__c=true
        ]);
        
        
        Map<String, String> recipientMasterKeyMap = new Map<String, String>();
        
        //Loop through all the Recipient master records to fill the map
        for (Recipient_Master__c recObj : [SELECT Id,External_ID__c FROM Recipient_Master__c]) {
            if (String.isNotBlank(recObj.External_ID__c)) {
                recipientMasterKeyMap.put(recObj.External_ID__c, recObj.Id);
            }
        }
        
        
        Map<String, Category__c> categoryMasterMap = new Map<String, Category__c>();
        set<Id> tertiaryRecordsSecondaryIds = new set<Id>();
        set<Id> tertiaryRecordsPrimaryIds = new set<Id>();
        set<Id> secondaryRecordsPrimaryIds = new set<Id>();
        
        //Loop through all the categories which are Tertiaries
        for (Category__c catObj : categoryList) {
            if (catObj.Type__c == 'Tertiary') {
                //These categories would require recipient list/masters
                categoryMasterMap.put(catObj.Id, catObj);
                //Set to filter out all the secondary categories which don't have any tertiary categories.
                tertiaryRecordsSecondaryIds.add(catObj.Secondary_Category__c);
                //Set to filter out all the Priamry categories which don't have any secondary categories.
                tertiaryRecordsPrimaryIds.add(catObj.Primary_Category__c);
            }
        }
        
        
        //Loop through all the categories which are Secondaries
        for (Category__c catObj : categoryList) {
            if (catObj.Type__c == 'Secondary' && !tertiaryRecordsSecondaryIds.contains(catObj.Id)) {
                //These categories would require recipient list/masters
                categoryMasterMap.put(catObj.Id, catObj);
                //Set to filter out all the Priamry categories which don't have any secondary categories.
                secondaryRecordsPrimaryIds.add(catObj.Primary_Category__c);
            }
        }
        
        
        //Loop through all the categories which are Primaries
        for (Category__c catObj : categoryList) {
            if (catObj.Type__c == 'Primary' && !tertiaryRecordsPrimaryIds.contains(catObj.Id) && !secondaryRecordsPrimaryIds.contains(catObj.Id)) {
                //These categories would require recipient list/masters
                categoryMasterMap.put(catObj.Id, catObj);
            }
        }
        
        
        Map<String, String> categoryMasterFinalMap = new Map<String, String>();
        List<Recipient_List__c> relListToInsert = new list<Recipient_List__c>();
        
        
        
        //Loop through the Category master map
        for (Category__c catObj : categoryMasterMap.values()) {
            
            String external_Id = '';
            if (String.isNotBlank(catObj.Channel__c)) {
                external_Id = catObj.Channel__c;
            }
            if (String.isNotBlank(catObj.Case_Type__c)) {
                external_Id += '_' +catObj.Case_Type__c;
            }
            if (String.isNotBlank(catObj.Business_Area__c)) {
                external_Id += '_' +catObj.Business_Area__c;
            }
            
            //Fill the map with first set of unique code
            //CHANNEL, CASE TYPE, BUSINESS AREA KEY
            if (recipientMasterKeyMap.containsKey(external_Id)) { 
                categoryMasterFinalMap.put(external_Id, recipientMasterKeyMap.get(external_Id));
            }
            //Call the region based method
            if(catObj.Region_Mandatory__c){
                categoryMasterFinalMap = regionWiseMapping(external_Id,recipientMasterKeyMap,categoryMasterFinalMap);
            }
            
            
            
            //WITH CASE STAGE KEY
            //If Case Stage is not blank - For Arena/Nexa/Com LOBs
            if (String.isNotBlank(catObj.Case_Stage__c)) {
                external_Id += '_' +catObj.Case_Stage__c;
                
                //categoryMasterFinalMap.put(external_Id, catObj.Id);
                if (recipientMasterKeyMap.containsKey(external_Id)) { 
                    categoryMasterFinalMap.put(external_Id, recipientMasterKeyMap.get(external_Id));
                }
                //Call the region based method
                if(catObj.Region_Mandatory__c){
                    categoryMasterFinalMap = regionWiseMapping(external_Id,recipientMasterKeyMap,categoryMasterFinalMap);
                }
            }
            
            
            
            //WITH CATEGORY NAME KEY
            if (String.isNotBlank(catObj.Name)) {
                external_Id += '_' +catObj.Name;
                
                //categoryMasterFinalMap.put(external_Id, catObj.Id);
                
                if (recipientMasterKeyMap.containsKey(external_Id)) { 
                    categoryMasterFinalMap.put(external_Id, recipientMasterKeyMap.get(external_Id));
                }
                //Call the region based method
                if(catObj.Region_Mandatory__c){
                    categoryMasterFinalMap = regionWiseMapping(external_Id,recipientMasterKeyMap,categoryMasterFinalMap); 
                }
            }
            
            
            //WITH CATEGORY NAME KEY AND PRIMARY CATEGOYR NAME KEY FOR DEVIATION USE CASES
            String new_External_Id = external_Id.substring(0,external_Id.lastIndexOf('_'));
            if(catObj.Type__c=='Secondary'){
                new_External_Id+='_'+catObj.Primary_Category__r.Name;
                
                if (recipientMasterKeyMap.containsKey(new_External_Id)) { 
                    categoryMasterFinalMap.put(new_External_Id, recipientMasterKeyMap.get(new_External_Id));
                }
                //Call the region based method
                if(catObj.Region_Mandatory__c){
                    categoryMasterFinalMap = regionWiseMapping(new_External_Id,recipientMasterKeyMap,categoryMasterFinalMap);
                }
                
                //Deviation #2
                new_External_Id+='_'+catObj.Name;
                if (recipientMasterKeyMap.containsKey(new_External_Id)) { 
                    categoryMasterFinalMap.put(new_External_Id, recipientMasterKeyMap.get(new_External_Id));
                }
                //Call the region based method
                if(catObj.Region_Mandatory__c){
                    categoryMasterFinalMap = regionWiseMapping(new_External_Id,recipientMasterKeyMap,categoryMasterFinalMap);
                }
            }
            
        }
        // Added By Tejendra on 5-01-2021
        if(!Test.isRunningTest()) 
            // Added By Tejendra on 5-01-2021    
            ID secondQueue = System.enqueueJob(new GenerateRecipientListSecond(categoryMasterMap,categoryMasterFinalMap));
        
    }
    
    //Region Based Mapping
    private static Map<String,String> regionWiseMapping(String external_id_key,Map<String,String> rmKeyMap, Map<String,String> cmFinalMap){
        Schema.DescribeFieldResult regionFieldResult = Recipient_Master__c.Region__c.getDescribe();
        List<Schema.PicklistEntry> regionList = regionFieldResult.getPicklistValues();
        String temp_key = external_id_key;
        for(Schema.PicklistEntry region : regionList){
            temp_key+='_'+region.getValue();
            
            if(rmKeyMap.containsKey(temp_key)){
                cmFinalMap.put(temp_key,rmKeyMap.get(temp_key));
            }
            temp_key = temp_key.substring(0,temp_key.lastIndexOf('_'));
        }
        return cmFinalMap;
    }
    
}