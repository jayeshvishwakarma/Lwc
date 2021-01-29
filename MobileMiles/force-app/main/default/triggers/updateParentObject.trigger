trigger updateParentObject on EZSign__Signature__c (before update) {  
    //Bulkify the trigger
    for (EZSign__Signature__c s : Trigger.new){
        if (s.EZSign__Parent_Id__c!=null){                       
            //if (s.EZSign__Signature__c!=null){
                //Update Parent Record
                Id objId = s.EZSign__Parent_Id__c;
                if (objId!=null){    
                    String theObjId = (String)objId;
                    //Protect from SOQL injection attacks
                    theObjId = String.escapeSingleQuotes(theObjId);
                    //Populate map that links sObject key prefix values to their API names
                    Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
                    Set<String> keyPrefixSet = gd.keySet();
                    Map<String, String> keyPrefixMap = new Map<String, String>{};
                    for(String sObj : keyPrefixSet){
                        Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe(); 
                        String tempName = r.getName();
                        String tempPrefix = r.getKeyPrefix();
                        keyPrefixMap.put(tempPrefix, tempName);
                    }
                    String tPrefix = theObjId.substring(0,3);
                    //Determine sObject type from record id by using the map
                    String objectType = keyPrefixMap.get(tPrefix);
                    //Protect from SOQL injection attacks
                    objectType = String.escapeSingleQuotes(objectType); 
                    //Query database for the record's signature field values
                    String theQuery = 'SELECT Id, Signature__c, Signature_Date__c, Signature_Name__c, Signature_URL__c, Signature_Key__c, Geboortedatum__c, Legitimatienummer__c, Handtekening_IP__c';
                    if (tPrefix=='001')
                        theQuery += ', Bankrekeningnummer__c, Looptijd_contract_Telfort_Zakelijk_vt__c';
                    list<sObject> theObject = Database.Query(theQuery + ' FROM '+objectType+' WHERE Id = \''+theObjId+'\' LIMIT 1');
                    if (!theObject.isEmpty()){
                        if (s.Geboortedatum__c!=null){
                            theObject[0].put('Geboortedatum__c',s.Geboortedatum__c);
                        }
                        if (s.Legitimatienummer__c!=null){
                            theObject[0].put('Legitimatienummer__c',s.Legitimatienummer__c); 
                        }
                        if (s.Handtekening_IP__c!=null){
                            theObject[0].put('Handtekening_IP__c',s.Handtekening_IP__c);
                        }
                        if (tPrefix=='001' && s.Bankrekeningnummer__c!=null){
                            theObject[0].put('Bankrekeningnummer__c',s.Bankrekeningnummer__c);
                        }
                        if (tPrefix=='001' && s.Looptijd_contract_Telfort_Zakelijk_vt__c!=null){
                            theObject[0].put('Looptijd_contract_Telfort_Zakelijk_vt__c',s.Looptijd_contract_Telfort_Zakelijk_vt__c);      
                        }    
                        update theObject;                        
                    }            
                }
           //}
        }                   
    }    
}