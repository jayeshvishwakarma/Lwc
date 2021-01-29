public class GenerateRecipientListSecond implements Queueable {
    
    Map<String, Category__c> categoryMasterMap = new Map<String, Category__c>();
    Map<String, String> categoryMasterFinalMap = new Map<String, String>();
    
    public GenerateRecipientListSecond(Map<String, Category__c> catMap, Map<String, String> catFinMap){
        this.categoryMasterMap = catMap;
        this.categoryMasterFinalMap = catFinMap;
    }
    
    public void execute(QueueableContext context) {
        List<Recipient_List__c> relListToInsert = new list<Recipient_List__c>();
        
        for (Category__c catObjNew : categoryMasterMap.values()) {
            
            //REGION LIST EXTRACTION
            Schema.DescribeFieldResult regionFieldResult = Recipient_Master__c.Region__c.getDescribe();
            List<Schema.PicklistEntry> regionList = regionFieldResult.getPicklistValues();
            
            //Create Recipient List
            Recipient_List__c relObj = new Recipient_List__c();
            relObj.Category__c = catObjNew.Id;

            String external_Id = '';
            if (String.isNotBlank(catObjNew.Channel__c)) {
                external_Id = catObjNew.Channel__c;
            }
            if (String.isNotBlank(catObjNew.Case_Type__c)) {
                external_Id += '_' +catObjNew.Case_Type__c;
            }
            if (String.isNotBlank(catObjNew.Business_Area__c)) {
                external_Id += '_' +catObjNew.Business_Area__c;
            } 
            
            if (categoryMasterFinalMap.containsKey(external_Id)) { 
                relObj.Recipient_Master__c = categoryMasterFinalMap.get(external_Id);
            }
            
            //REGION BASED CHECK
            if(catObjNew.Region_Mandatory__c){
                external_Id+='_'+regionList[0].getValue();
                if (categoryMasterFinalMap.containsKey(external_Id)) { 
                    List<Schema.PicklistEntry> tempRegionList = regionList;
                    relObj.Recipient_Master__c = categoryMasterFinalMap.get(external_Id);
                    relObj.Region__c = tempRegionList[0].getValue();
                    tempRegionList.remove(0);
                    
                    //Call Remaining Region Wise Mapping
                    relListToInsert = (regionWiseRecipientList(external_Id,tempRegionList,categoryMasterFinalMap,relObj,relListToInsert));
                    
                }
                external_Id = external_Id.substring(0,external_Id.lastIndexOf('_'));
            }
            
            
            //If Case Stage is not blank - For Arena/Nexa/Com LOBs
            if (String.isNotBlank(catObjNew.Case_Stage__c)) {
                external_Id += '_' +catObjNew.Case_Stage__c;
                
                //categoryMasterFinalMap.put(external_Id, catObj.Id);
                if (categoryMasterFinalMap.containsKey(external_Id)) { 
                    relObj.Recipient_Master__c = categoryMasterFinalMap.get(external_Id);
                }
                
                //REGION BASED CHECK
                if(catObjNew.Region_Mandatory__c){
                    external_Id+='_'+regionList[0].getValue();
                    if (categoryMasterFinalMap.containsKey(external_Id)) { 
                        List<Schema.PicklistEntry> tempRegionList = regionList;
                        relObj.Recipient_Master__c = categoryMasterFinalMap.get(external_Id);
                        relObj.Region__c = tempRegionList[0].getValue();
                        tempRegionList.remove(0);
                        
                        //Call Remaining Region Wise Mapping
                        relListToInsert = (regionWiseRecipientList(external_Id,tempRegionList,categoryMasterFinalMap,relObj,relListToInsert));
                        
                    }
                    external_Id = external_Id.substring(0,external_Id.lastIndexOf('_'));
                }
            }
            
            
            if (String.isNotBlank(catObjNew.Name)) {
                external_Id += '_' +catObjNew.Name;
                
                //categoryMasterFinalMap.put(external_Id, catObj.Id);
                if (categoryMasterFinalMap.containsKey(external_Id)) { 
                    relObj.Recipient_Master__c = categoryMasterFinalMap.get(external_Id);
                }
                
                //REGION BASED CHECK
                if(catObjNew.Region_Mandatory__c){
                    external_Id+='_'+regionList[0].getValue();
                    if (categoryMasterFinalMap.containsKey(external_Id)) { 
                        List<Schema.PicklistEntry> tempRegionList = regionList;
                        relObj.Recipient_Master__c = categoryMasterFinalMap.get(external_Id);
                        relObj.Region__c = tempRegionList[0].getValue();
                        tempRegionList.remove(0);
                        
                        //Call Remaining Region Wise Mapping
                        relListToInsert = (regionWiseRecipientList(external_Id,tempRegionList,categoryMasterFinalMap,relObj,relListToInsert));
                        
                    }
                    external_Id = external_Id.substring(0,external_Id.lastIndexOf('_'));
                }
            }
            
            
            String new_External_Id = external_Id.substring(0,external_Id.lastIndexOf('_'));
            if(catObjNew.Type__c=='Secondary'){
                new_External_Id+='_'+catObjNew.Primary_Category__r.Name;
                
                //categoryMasterFinalMap.put(external_Id, catObj.Id);
                if (categoryMasterFinalMap.containsKey(new_External_Id)) { 
                    relObj.Recipient_Master__c = categoryMasterFinalMap.get(new_External_Id);
                }
                //REGION BASED CHECK
                if(catObjNew.Region_Mandatory__c){
                    new_External_Id+='_'+regionList[0].getValue();
                    if (categoryMasterFinalMap.containsKey(new_External_Id)) { 
                        List<Schema.PicklistEntry> tempRegionList = regionList;
                        relObj.Recipient_Master__c = categoryMasterFinalMap.get(new_External_Id);
                        relObj.Region__c = tempRegionList[0].getValue();
                        tempRegionList.remove(0);
                        
                        //Call Remaining Region Wise Mapping
                        relListToInsert = (regionWiseRecipientList(new_External_Id,tempRegionList,categoryMasterFinalMap,relObj,relListToInsert));
                        
                    }
                    new_External_Id = new_External_Id.substring(0,new_External_Id.lastIndexOf('_'));
                }
                
                //Deviation #2
                new_External_Id+='_'+catObjNew.Name;
                //categoryMasterFinalMap.put(external_Id, catObj.Id);
                if (categoryMasterFinalMap.containsKey(new_External_Id)) { 
                    relObj.Recipient_Master__c = categoryMasterFinalMap.get(new_External_Id);
                }
                //REGION BASED CHECK
                if(catObjNew.Region_Mandatory__c){
                    new_External_Id+='_'+regionList[0].getValue();
                    if (categoryMasterFinalMap.containsKey(new_External_Id)) { 
                        List<Schema.PicklistEntry> tempRegionList = regionList;
                        relObj.Recipient_Master__c = categoryMasterFinalMap.get(new_External_Id);
                        relObj.Region__c = tempRegionList[0].getValue();
                        tempRegionList.remove(0);
                        
                        //Call Remaining Region Wise Mapping
                        relListToInsert = (regionWiseRecipientList(new_External_Id,tempRegionList,categoryMasterFinalMap,relObj,relListToInsert));
                        
                    }
                    new_External_Id = new_External_Id.substring(0,new_External_Id.lastIndexOf('_'));
                }
            }
            
            relListToInsert.add(relObj);
        }
        
        
        
        
        
        Id batchId = Database.executeBatch(new GenerateRecipientListBatch(relListToInsert), 1000);
        
    }
    
    //Region Based Mapping
    private static List<Recipient_List__c> regionWiseRecipientList(String external_id_key,List<Schema.PicklistEntry> regionList, 
                                                                   Map<String,String> cmFinalMap,Recipient_List__c recListObj,
                                                                   List<Recipient_List__c> recList){
        
               
        String temp_key = external_id_key.substring(0,external_id_key.lastIndexOf('_'));
                
        for(Schema.PicklistEntry region : regionList){
            temp_key+='_'+region.getValue();
            
            if(cmFinalMap.containsKey(temp_key)){
                Recipient_List__c relList = new Recipient_List__c();
                relList = recListObj.clone(false,false,false,false);
                relList.Region__c = region.getValue(); 
                relList.Recipient_Master__c = cmFinalMap.get(temp_key);
                recList.add(relList);
            }
            temp_key = temp_key.substring(0,temp_key.lastIndexOf('_'));
        }
        return recList;
    }
    
    

}