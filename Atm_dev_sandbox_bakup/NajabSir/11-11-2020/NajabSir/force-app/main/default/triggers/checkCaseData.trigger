trigger checkCaseData on CaseChangeEvent (after insert) {
    
    
    Set<Id> setCityId = new Set<Id>();
    Set<Id> setTechnicianId = new Set<Id>();
    
    Set<Id> setIntegrationUserId = CaseTriggerHelper.getIntegrationUserDetails();
    
    Map<Id,String> mapCityIdToCityCode = new Map<Id,String>();
    Map<Id,String> mapCityIdToName = new Map<Id,String>();
    Map<Id,String> mapIdToTechnicianId = new Map<Id,String>();
    Map<String,String> mapTechnicianIdToPhoneNumbers = new Map<String,String>();
    
    for(CaseChangeEvent cs : trigger.new) {
        Case newCase = new Case();
        Case oldCase = new Case();
        
        if(String.isNotBlank(cs.Case_NewMap__c)){
            newCase = (Case)JSON.deserialize(cs.Case_NewMap__c, Case.class);
        }
        if(String.isNotBlank(cs.Case_OldMap__c)){
            oldCase = (Case)JSON.deserialize(cs.Case_OldMap__c, Case.class);
        }
        
        system.debug('== newCase '+newCase);
        system.debug('== oldCase '+oldCase);
        
        if (newCase.recordTypeId == ConstantsUtility.MOS_COMPLAINT_CASE_RECORD_TYPE_ID) {
            if(newCase.City__c != NULL){
                setCityId.add(newCase.City__c);
            }
            if(newCase.Technician_Id__c != NULL) {
                setTechnicianId.add(newCase.Technician_Id__c);
            }
        }
        
        EventBus.ChangeEventHeader header = cs.ChangeEventHeader;
        if (header.changetype == 'UPDATE') {
            
        }
    }
    
    if(setCityId != NULL && setCityId.size() > 0) {
        for(City__c city : [SELECT Id,City_Code__c,Name FROM City__c WHERE Id IN :setCityId]) {
            mapCityIdToCityCode.put(city.Id,city.City_Code__c);
            mapCityIdToName.put(city.Id,city.Name);
        }
    }
    
    if(setTechnicianId != NULL && setTechnicianId.size() > 0) {
        for(Contact con : [SELECT Id,Phone,FE_Technician_ID__c FROM Contact WHERE Id IN :setTechnicianId]) {
            mapIdToTechnicianId.put(con.Id,con.FE_Technician_ID__c);
            if(con.Phone != NULL) {
                mapTechnicianIdToPhoneNumbers.put(con.Id,con.Phone);    
            }
        }    
    }
    
}