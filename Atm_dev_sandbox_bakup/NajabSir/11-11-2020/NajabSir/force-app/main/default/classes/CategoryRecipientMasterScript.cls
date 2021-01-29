/**
* @File Name          : CategoryRecipientMasterScript.cls
* @Description        : Apex Class to create records for Category Master object, Recipient Master Object and their Recipient Lists
* @Author             : Prabhat Sharma
* @Group              : 
* @Last Modified By   : 
* @Last Modified On   : 06/05/2020, 11:29:29 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    06/05/2020, 11:29:29 PM                            Initial Version
**/
public class CategoryRecipientMasterScript {
    
  
    
     /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to create the Category Record From the CSV Files. The CSV files are uploaded in the static resources
        Inputs:
        Returns:
        History:
        ================
        1.2    27 May 2020      Sunit     Initial Version
    */
    public static void manageCategoryMasters() {
        
        List<StaticResource> categoryFile = new list<StaticResource>([SELECT Id, Body FROM StaticResource WHERE Name = 'CategoryFile']);
        String[] filelines = new String[]{};
        Blob fileBody = categoryFile[0].Body;
        String nameFile = fileBody.toString();
        filelines = nameFile.split('\n');

        List<Category__c> listToInsert2 = new list<Category__c>();
        List<Category__c> listToInsert3 = new list<Category__c>();
        List<Category__c> listToInsert4 = new list<Category__c>();

        map<String, Category__c> primaryMap = new map<String, Category__c>();


        map<String, String> secondaryPrimaryKeyMap = new map<String, String>();
        map<String, Category__c> secondaryMap = new map<String, Category__c>();

        map<String, String> tertiarySecondaryKeyMap = new map<String, String>();
        map<String, Category__c> tertiaryMap = new map<String, Category__c>();


        

        for (Integer i = 1; i < filelines.size() - 1; i++) {

            String query_external_Id = '';
            String external_Id = '';
            String tert_external_Id = '';


            String[] inputvalues = new String[]{
            };
            inputvalues = filelines[i].split(',');


            Category__c primary = new Category__c();
            primary.Name = inputvalues[4];
            query_external_Id += primary.Name;
            primary.Type__c = 'Primary';
            query_external_Id += '_' + primary.Type__c;
            primary.Channel__c = inputvalues[0];
            query_external_Id += '_' + primary.Channel__c;
            primary.Case_Type__c = inputvalues[1];
            query_external_Id += '_' + primary.Case_Type__c;
            primary.Business_Area__c = String.isNotBlank(inputvalues[2]) ? inputvalues[2] : null;
            if (primary.Business_Area__c != null)
                query_external_Id += '_' + primary.Business_Area__c;
            primary.Case_Stage__c = String.isNotBlank(inputvalues[3]) ? inputvalues[3] : null;
            if (primary.Case_Stage__c != null)
                query_external_Id += '_' + primary.Case_Stage__c;
            primary.Active__c = true;

            //Closure Files
            if (String.isNotBlank(inputvalues[7])) {
                primary.Closure_Files__c = inputvalues[7];
            }
            if (String.isNotBlank(inputvalues[8])) {
                primary.Closure_Files_Non_Mandatory__c = inputvalues[8];
            }
            //Region
            if (String.isNotBlank(inputvalues[9])) {
                primary.Region_Mandatory__c  = true;
            }
            primaryMap.put(query_external_Id, primary);


            if (String.isNotBlank(inputvalues[5])) {
                Category__c secondary = new Category__c();
                secondary.Name = inputvalues[5];
                external_Id += secondary.Name;

                secondary.Type__c = 'Secondary';
                external_Id += '_' + secondary.Type__c;

                secondary.Channel__c = inputvalues[0];
                external_Id += '_' + secondary.Channel__c;

                secondary.Case_Type__c = inputvalues[1];
                external_Id += '_' + secondary.Case_Type__c;

                secondary.Business_Area__c = inputvalues[2];
                external_Id += '_' + secondary.Business_Area__c;

                secondary.Case_Stage__c = String.isNotBlank(inputvalues[3]) ? inputvalues[3] : null;

                if (secondary.Case_Stage__c != null)
                    external_Id += '_' + secondary.Case_Stage__c;

                external_Id += '_' + primary.Name;
                secondary.Active__c = true;

                //Closure Files
                if (String.isNotBlank(inputvalues[7])) {
                    secondary.Closure_Files__c = inputvalues[7];
                }
                if (String.isNotBlank(inputvalues[8])) {
                    secondary.Closure_Files_Non_Mandatory__c = inputvalues[8];
                }
                //Region
                if (String.isNotBlank(inputvalues[9])) {
                    secondary.Region_Mandatory__c  = true;
                }

                secondaryPrimaryKeyMap.put(external_Id, query_external_Id);
                secondaryMap.put(external_Id, secondary);

                if (String.isNotBlank(inputvalues[6])) {
                    Category__c tertiary = new Category__c();
                    tertiary.Name = inputvalues[6];
                    tert_external_Id += '_' + tertiary.Name;

                    tertiary.Type__c = 'Tertiary';
                    tert_external_Id += '_' + tertiary.Type__c;

                    tertiary.Channel__c = inputvalues[0];
                    tert_external_Id += '_' + tertiary.Channel__c;

                    tertiary.Case_Type__c = inputvalues[1];
                    tert_external_Id += '_' + tertiary.Case_Type__c;

                    tertiary.Business_Area__c = inputvalues[2];
                    tert_external_Id += '_' + tertiary.Business_Area__c;

                    tertiary.Case_Stage__c = String.isNotBlank(inputvalues[3]) ? inputvalues[3] : null;
                    if (tertiary.Case_Stage__c != null)
                        tert_external_Id += '_' + tertiary.Case_Stage__c;

                    tert_external_Id += '_' + secondary.Name;
                    tert_external_Id += '_' + primary.Name;
                    tertiary.Active__c = true;

                    //Closure Files
                    if (String.isNotBlank(inputvalues[7])) {
                        tertiary.Closure_Files__c = inputvalues[7];
                    }
                    if (String.isNotBlank(inputvalues[8])) {
                        tertiary.Closure_Files_Non_Mandatory__c = inputvalues[8];
                    }
                    //Region
                    if (String.isNotBlank(inputvalues[9])) {
                        tertiary.Region_Mandatory__c  = true;
                    }

                    tertiarySecondaryKeyMap.put(tert_external_Id, external_Id);
                    tertiaryMap.put(tert_external_Id, tertiary);

                }
            }


        }

        insert primaryMap.values();


        //Secondary Cat Mappings
        map<String, String> secondaryIdMap = new map<String, String>();
        for (String str : secondaryPrimaryKeyMap.keySet()) {
            String key = secondaryPrimaryKeyMap.get(str);
            secondaryIdMap.put(str, String.valueOf(primaryMap.get(key).Id));
        }

        for (String cat2 : secondaryMap.keySet()) {
            secondaryMap.get(cat2).Primary_Category__c = Id.valueOf(secondaryIdMap.get(cat2));
        }
        insert secondaryMap.values();
        //Sec Map Ends

        //Tert maps
        map<String, Category__c> tertIdMap = new map<String, Category__c>();

        for (String str1 : tertiarySecondaryKeyMap.keySet()) {
            String key = tertiarySecondaryKeyMap.get(str1);
            tertIdMap.put(str1, secondaryMap.get(key));
        }

        for (String cat3 : tertiaryMap.keySet()) {
            tertiaryMap.get(cat3).Primary_Category__c = tertIdMap.get(cat3).Primary_Category__c;
            tertiaryMap.get(cat3).Secondary_Category__c = tertIdMap.get(cat3).Id;
        }

        insert tertiaryMap.values();
        //Tert maps Ends

    }

    
    /**
           Author: Prabhat Sharma
           Company: Techmatrix
           Description: Method to create the Recipient Master Record From the CSV File
           Inputs:
           Returns:
           History:
           ================
           1.2     27 May 2020      Sunit     Initial Version
    */
    public static void manageRecipientMaster() {
        try {


            List<StaticResource> recipientMasterFile = new list<StaticResource>([SELECT Id, Body FROM StaticResource WHERE Name = 'RecipientMasterFile']);
            String[] fileLines = new String[]{
            };
            Blob fileBody = recipientMasterFile[0].Body;
            String nameFile = fileBody.toString();
            fileLines = nameFile.split('\n');

            List<Recipient_Master__c> recipientMastersToInsert = new list<Recipient_Master__c>();
            
            for (Integer i = 1; i < fileLines.size() - 1; i++) {
                String[] inputValues = new String[]{
                };
                inputValues = fileLines[i].split(',');
                
                if (inputValues != null && inputValues.size() > 0) {
                    Schema.DescribeFieldResult regionFieldResult = Recipient_Master__c.Region__c.getDescribe();
                    List<Schema.PicklistEntry> regionList = regionFieldResult.getPicklistValues();
                    
                    String externalId = '';
                    if (String.isNotBlank(inputValues[0])) {
                        externalId = inputValues[0];
                    }
                    if (String.isNotBlank(inputValues[1])) {
                        externalId += '_' +inputValues[1];
                    }
                    if (String.isNotBlank(inputValues[2])) {
                        externalId += '_' +inputValues[2];
                    }
                    if (String.isNotBlank(inputValues[3])) {
                        externalId += '_' +inputValues[3];
                    }
                    if (String.isNotBlank(inputValues[4])) {
                        externalId += '_' +inputValues[4];
                    }
                    if (String.isNotBlank(inputValues[5])) {
                        externalId += '_' +inputValues[5];
                    }
                    if (String.isNotBlank(inputValues[6])) {
                        externalId += '_' +inputValues[6];
                    }
                    Recipient_Master__c recipientMaster = new Recipient_Master__c();

                    recipientMaster.Name = inputValues[0] + '_' +  inputValues[1] + '_' + inputValues[2];

                    if (inputValues[7] != null) {
                        recipientMaster.Case_Ownership__c = inputValues[7];
                    }
                    if (inputValues[8] != null) {
                        recipientMaster.Hierarchy_Type__c = inputValues[8];
                    }
                    if (inputValues[9] != null) {
                        recipientMaster.Owner_Type__c = inputValues[9];
                    }
                    if (inputValues[10] != null && recipientMaster.Owner_Type__c == ConstantsUtility.QUEUE) {
                        recipientMaster.Queue_Name__c = inputValues[10];
                    }
                    if (inputValues[11] != null) {
                        recipientMaster.Level_0_To__c = inputValues[11];
                    }
                    if (inputValues[12] != null) {
                        recipientMaster.Level_0_Cc__c = inputValues[12];
                    }
                    if (inputValues[13] != null) {
                        recipientMaster.Level_1_To__c = inputValues[13];
                    }
                    if (inputValues[14] != null) {
                        recipientMaster.Level_1_Cc__c = inputValues[14];
                    }
                    if (inputValues[15] != null) {
                        recipientMaster.Level_2_To__c = inputValues[15];
                    }
                    if (inputValues[16] != null) {
                        recipientMaster.Level_2_Cc__c = inputValues[16];
                    }
                    if (inputValues[17] != null) {
                        recipientMaster.Level_3_To__c = inputValues[17];
                    }
                    if (inputValues[18] != null) {
                        recipientMaster.Level_3_Cc__c = inputValues[18];
                    }
                    if (inputValues[19] != null) {
                        recipientMaster.Level_4_To__c = inputValues[19];
                    }
                    if (inputValues[20] != null) {
                        recipientMaster.Level_4_Cc__c = inputValues[20];
                    }
                    if (inputValues[21] != null) {
                        recipientMaster.Level_5_To__c = inputValues[21];
                    }
                    if (inputValues[22] != null) {
                        recipientMaster.Level_5_Cc__c = inputValues[22];
                    }
                    if (inputValues[23] != null) {
                        recipientMaster.Level_6_To__c = inputValues[23];
                    }
                    if (inputValues[24] != null) {
                        recipientMaster.Level_6_Cc__c = inputValues[24];
                    }
                    
                    recipientMaster.External_ID__c = externalId;                    
                    
                    //Region based segregation. The number of records will be added basis region. i.e. per region one record
                    if(String.isNotBlank(inputValues[25])){
                        //External ID for cloned records
                        String master_external_Id = externalId;
                        
                        recipientMaster.Region__c = regionList[0].getValue();
                        externalId+='_'+regionList[0].getValue();
                        recipientMaster.External_ID__c = externalId;
                        regionList.remove(0);
                        
                        for(Schema.PicklistEntry region : regionList){
                            String new_External_Id = master_external_Id;
                            Recipient_Master__c regionRM = new Recipient_Master__c();
                            regionRM = recipientMaster.clone(false,false,false,false);
                            regionRM.Region__c = region.getValue();
                            new_External_Id+='_'+regionRM.Region__c;
                            regionRM.External_ID__c = new_External_Id;
                            recipientMastersToInsert.add(regionRM);
                        }
                    }
                    recipientMastersToInsert.add(recipientMaster);
                }
            }
            
            
            
            if (recipientMastersToInsert.size() > 0) {
                // insert recipientMastersToInsert;
                Database.SaveResult[] srList = Database.insert(recipientMastersToInsert, false);
                // Iterate through each returned result
                Integer count = 1;
                for (Database.SaveResult sr : srList) {
                    
                    if (!sr.isSuccess()) {
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
        } catch (Exception exp) {
            System.debug('Exception Message :: ' + exp.getMessage() + ' StackTrace :: ' + exp.getStackTraceString());
        }
    }
         
    
    /**
           Author: Prabhat Sharma
           Company: Techmatrix
           Description: Method to create the Recipient List from Category and Recipient master Records
           Inputs:
           Returns:
           History:
           ================
           1.2    27 May 2020      Sunit     Initial Version
    */
    public static void manageRecipientList() {
        
        ID firstQueue = System.enqueueJob(new GenerateRecipientListFirst());

    }
    
    
    
    
    public static void createComplaintCORecords() {
        List<StaticResource> categoryFile = new list<StaticResource>([SELECT Id, Body FROM StaticResource WHERE Name = 'ComplaintCoordinator']);
        if(categoryFile != NULL && categoryFile.size() > 0) {
            String[] filelines = new String[]{};
            Blob fileBody = categoryFile[0].Body;
            String nameFile = fileBody.toString();
            filelines = nameFile.split('\n'); 
            Set<String> setUserNames = new Set<String>();
            Set<String> setContactEmail = new Set<String>();
            Map<String,List<String>> mapEmailToContactRecords= new Map<String,List<String>>();
            
            for(Integer i=1;i<filelines.size()-1;i++) {
                List<String> listValue = filelines[i].split(',');
                
                if(listValue[6] != NULL && listValue[6] == 'SF') {
                    setUserNames.add(listValue[4]);    
                }
                else if(listValue[6] != NULL && listValue[6] == 'Non-SF' && String.isNotBlank(listValue[4])) {
                    setContactEmail.add(listValue[4]); 
                    mapEmailToContactRecords.put(listValue[4],listValue);
                }
            }
            
            Map<String,Id> mapUserNameToUserId = new Map<String,Id>();
            if(setUserNames.size() > 0) {
                for(User usr : [SELECT Id,Email,Username FROM User WHERE Username IN :setUserNames]) {
                    mapUserNameToUserId.put(usr.Username,usr.Id);             
                }       
            }
            
            Map<String,Id> mapEmailToContactId = new Map<String,Id>();
            if(setContactEmail.size() > 0) {
                for(Contact con : [SELECT Id,Email FROM Contact WHERE Email IN :setContactEmail AND RecordType.Name = 'MSIL Stakeholder']) {
                    mapEmailToContactId.put(con.Email,con.Id);              
                }    
            }
            
              
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
                        con.AccountId = [SELECT id FROM Account WHERE Id=:Label.MSIL_Stakeholder_Account].Id;
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
             
            
            List<Complaint_Coordinator__c> listComplaintCordinatorToInsert = new List<Complaint_Coordinator__c>();
            for(Integer i=1;i<filelines.size()-1;i++) {
                List<String> listValue = filelines[i].split(',');
                Complaint_Coordinator__c complaintCordinator = new Complaint_Coordinator__c();
                 
                String tempStr = String.isNotBlank(listValue[4]) ? listValue[4] : '';
                 
                if(listValue[6] != NULL && listValue[6] == 'SF' && String.isNotBlank(tempStr) && mapUserNameToUserId.containsKey(tempStr.toLowerCase())) {
                    complaintCordinator.User__c = mapUserNameToUserId.get(tempStr.toLowerCase());    
                }
                
                else if(listValue[6] != NULL && listValue[6] == 'Non-SF' && String.isNotBlank(tempStr) && mapEmailToContactId.containsKey(tempStr.toLowerCase())) {
                    complaintCordinator.Contact__c = mapEmailToContactId.get(tempStr);
                }
                complaintCordinator.Channel__c = listValue[0];
                complaintCordinator.Model__c = listValue[1];
                complaintCordinator.Type__c = listValue[2];
                complaintCordinator.Region__c = listValue[3];
                complaintCordinator.Zone__c = listValue[7];
                listComplaintCordinatorToInsert.add(complaintCordinator);
            }
            
            //Insert Recipient List
            if (listComplaintCordinatorToInsert.size() > 0){ 
                Database.SaveResult[] srList = Database.insert(listComplaintCordinatorToInsert, false);
                // Iterate through each returned result
                Integer count = 1;
                for (Database.SaveResult sr : srList) {
                   
                    if (!sr.isSuccess()) {
                        
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