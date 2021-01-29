public class EscalationMatrix {
   /*
    Author : Gitika
    Company : Techmatrix Consulting
    Description : This helper method is used to fetch stakeholder mapping
    Return Type : list<stakeholderWrapper>
    */  
    @AuraEnabled
    public static list<stakeholderWrapper> getEscalationMatrix(String JSON , String businessArea){
       // map of recordId with Name 
       map<string,string> mapOfRecordIdWithName = new map<String,String>();
        // list of stakeholder wrapper
         list<stakeholderWrapper> wrapperList = new list<stakeholderWrapper>();
        // parsing JSON with help of parseStakeholderHierarchyJson method 
         List<StakeholderHierarchy.Sales> hierarchyList = StakeholderUtility.getSelectedHierarchyList(JSON,businessArea);
        // iterating to store Stakeholder Record Id 
        for (StakeholderHierarchy.Sales stakeholders : hierarchyList) {
           mapOfRecordIdWithName.put(stakeholders.recordId,null); 
        }
        // Querying to get Stakeholder Name 
        if(mapOfRecordIdWithName.size()>0){
            for(User us : [select FirstName,LastName,Id from User where id in :mapOfRecordIdWithName.keyset()]){
                String name = (us.FirstName != null ? us.FirstName:'')+' '+(us.LastName != null ? us.LastName:'');
                String Id = String.valueof(us.id).left(15);
                mapOfRecordIdWithName.put(Id,name);
            }
        }
        // iterating StakeholderHierarchy
        for (StakeholderHierarchy.Sales stakeholders : hierarchyList) {
            stakeholderWrapper wrapper = new stakeholderWrapper();
            
            wrapper.Level=stakeholders.stakeHolder;
            wrapper.Designation=stakeholders.refName;
            if(stakeholders.recordId.length()>15){
             stakeholders.recordId=String.valueof(stakeholders.recordId).left(15); 
            }
            if(mapOfRecordIdWithName.containskey(stakeholders.recordId)){
              wrapper.Name=mapOfRecordIdWithName.get(stakeholders.recordId);   
            }
            wrapper.Phone=stakeholders.phone;
            wrapper.Email=stakeholders.email;
            wrapperList.add(wrapper);
        }
        return wrapperList;
    }
    public class stakeholderWrapper{
        @AuraEnabled public string Level;
        @AuraEnabled public string Designation;
        @AuraEnabled public string Name;
        @AuraEnabled public string Phone;
        @AuraEnabled public string Email;
    }
}