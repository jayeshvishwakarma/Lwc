global class BatchKwtSettings implements Database.Batchable<sobject>,Database.AllowsCallouts {
    global Set<String> accIds;
     global Set<String> productIds;
    global BatchKwtSettings(Set<String> accIds, Set<String> productIds){
        this.accIds = accIds;
        this.productIds = productIds;
    }
    // Start Method
    global Database.Querylocator start (Database.BatchableContext BC) {
        String query = 'SELECT Id, KWT__c, Product__c, Account__c FROM Porteringen_mobiel__c where Product__c IN: productIds and Account__c IN: accIds';
                system.debug('@@@@ query ' + query);
        return Database.getQueryLocator(query);    
    }
    
    // Execute method
    global void execute (Database.BatchableContext BC, List<Porteringen_mobiel__c> scope) {
        Map<String, List<Porteringen_mobiel__c>> mapPorteringen = new Map<String, List<Porteringen_mobiel__c>>();
        for(Porteringen_mobiel__c objPorteringen : scope){
            String uniqueKey = objPorteringen.Account__c + '-' + objPorteringen.Product__c;
            if (!mapPorteringen.containsKey(uniqueKey)) {
                mapPorteringen.put(uniqueKey, new List<Porteringen_mobiel__c>());
            }
            mapPorteringen.get(uniqueKey).add(objPorteringen);                
        }    
        
        List<Porteringen_mobiel__c> lstUpdatePorteringen = new List<Porteringen_mobiel__c>();
        for(KWT__c objKWT : [SELECT Id, Korting_per_aansluiting_p_mnd__c, Product__c, Bedrijf__c
                             FROM KWT__c
                             where Product__c IN: productIds and Bedrijf__c IN: accIds]){  
                                 
                                 List<Porteringen_mobiel__c> lstPorteringenTemp = mapPorteringen.get(objKWT.Bedrijf__c + '-' + objKWT.Product__c );
                                 
                                 if(lstPorteringenTemp != null && lstPorteringenTemp.size() > 0){
                                     for(Porteringen_mobiel__c objPorteringen : lstPorteringenTemp){
                                         lstUpdatePorteringen.add(new Porteringen_mobiel__c(Id = objPorteringen.Id, KWT__c = objKWT.Korting_per_aansluiting_p_mnd__c));                                         
                                         
                                     }
                                 }
                             }
        if(lstUpdatePorteringen.size() > 0)
            update lstUpdatePorteringen;
        
    	}


// Finish Method
global void finish(Database.BatchableContext BC) {
    
}	
}