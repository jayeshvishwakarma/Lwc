public class CreateComplaintCoordinatorClass {
    
    public static void createRecords() {
        List<StaticResource> categoryFile = new list<StaticResource>([SELECT Id, Body FROM StaticResource WHERE Name = 'ComplaintCoordinator']);
        if(categoryFile != NULL && categoryFile.size() > 0) {
            String[] filelines = new String[]{};
            Blob fileBody = categoryFile[0].Body;
            String nameFile = fileBody.toString();
            filelines = nameFile.split('\n'); 
            Set<String> setUserEmail = new Set<String>();
            Set<String> setContactEmail = new Set<String>();
            Map<String,List<String>> mapEmailToContactRecords= new Map<String,List<String>>();
            
            for(Integer i=1;i<filelines.size()-1;i++) {
                List<String> listValue = filelines[i].split(',');
                if(listValue[6] != NULL && listValue[6] == 'SF') {
                    setUserEmail.add(listValue[4]);    
                }
                else if(listValue[6] != NULL && listValue[6] == 'Non-SF' && String.isNotBlank(listValue[4])) {
                    setContactEmail.add(listValue[4]); 
                    mapEmailToContactRecords.put(listValue[4],listValue);
                }
            }
            
            Map<String,Id> mapEmailToUserId = new Map<String,Id>();
            if(setUserEmail.size() > 0) {
                for(User usr : [SELECT Id,Email FROM User WHERE Email IN :setUserEmail]) {
                    mapEmailToUserId.put(usr.Email,usr.Id);             
                }       
            }
            
            Map<String,Id> mapEmailToContactId = new Map<String,Id>();
            if(setContactEmail.size() > 0) {
                for(Contact con : [SELECT Id,Email FROM Contact WHERE Email IN :setContactEmail AND RecordType.Name = 'MSIL Stakeholder']) {
                    mapEmailToContactId.put(con.Email,con.Id);              
                }    
            }
            
            system.debug('mapEmailToContactId==>'+mapEmailToContactId.values().size());
            
            List<Contact> listContactToInsert = new List<Contact>();
            if(mapEmailToContactRecords.keySet().size() > 0) {
                for(String email : mapEmailToContactRecords.keySet()) {
                    if(!mapEmailToContactId.containsKey(email) && String.isNotBlank(email.split('@')[0])) {
                        String contactName = email.split('@')[0];
                        contactName = contactName.toUpperCase();
                        List<String> listValue = mapEmailToContactRecords.get(email);
                        Contact con = new Contact();
                        con.LastName = contactName;
                        con.Email = email;
                        con.Phone = listValue[5];
                        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('MSIL Stakeholder').getRecordTypeId();
                        con.AccountId = '0011s00000OHcOC';
                        setContactEmail.add(con.Email);
                        listContactToInsert.add(con);
                    }
                }
            }
            
            if(listContactToInsert.size() > 0) {
                insert listContactToInsert;
            }
            
            if(setContactEmail.size() > 0) {
                for(Contact con : [SELECT Id,Email FROM Contact WHERE Email IN :setContactEmail AND RecordType.Name = 'MSIL Stakeholder']) {
                    mapEmailToContactId.put(con.Email,con.Id);              
                }    
            }
            
            system.debug('mapEmailToContactId==>'+mapEmailToContactId.values().size());
            
            List<Complaint_Coordinator__c> listComplaintCordinatorToInsert = new List<Complaint_Coordinator__c>();
            for(Integer i=1;i<filelines.size()-1;i++) {
                List<String> listValue = filelines[i].split(',');
                Complaint_Coordinator__c complaintCordinator = new Complaint_Coordinator__c();
                system.debug('LOCK-1->'+listValue[4]);
                String temp = listValue[4];
                system.debug('LOCK-2->'+mapEmailToContactId.containsKey(temp.toLowerCase()));
                if(listValue[6] != NULL && listValue[6] == 'SF' && String.isNotBlank(listValue[4]) && mapEmailToUserId.containsKey(listValue[4])) {
                    complaintCordinator.User__c = mapEmailToUserId.get(listValue[4]);    
                    system.debug('Ok');      
                }
                
                else if(listValue[6] != NULL && listValue[6] == 'Non-SF' && String.isNotBlank(listValue[4]) && mapEmailToContactId.containsKey(listValue[4].toLowerCase())) {
                    complaintCordinator.Contact__c = mapEmailToContactId.get(listValue[4].toLowerCase());
                }
                complaintCordinator.Channel__c = listValue[0];
                complaintCordinator.Model__c = listValue[1];
                complaintCordinator.Type__c = listValue[2];
                complaintCordinator.Region__c = listValue[3];
                complaintCordinator.Zone__c = listValue[7];
                listComplaintCordinatorToInsert.add(complaintCordinator);
            }
           
           // if(listComplaintCordinatorToInsert.size() > 0) {
               // insert listComplaintCordinatorToInsert;
            //}// 
            
            //Insert Recipient List
        if (listComplaintCordinatorToInsert.size() > 0) { 
            Database.SaveResult[] srList = Database.insert(listComplaintCordinatorToInsert, false);
            // Iterate through each returned result
            Integer count = 1;
            for (Database.SaveResult sr : srList) {
               // System.debug(count);
                if (!sr.isSuccess()) {
                    System.debug(listComplaintCordinatorToInsert[count -1]);
                    // Operation failed, so get all errors
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }

                }
                count++;
            }
        }
        }
        
    }
}