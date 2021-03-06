/* 
* @File Name          : GenerateFilePublicURL.cls
* @Description        : This class generates public links for files and creates a record in Marketing communication 
                        object storing the public links
* @Author             : 
* @Group              : 
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 1/16/2020, 10:26:29 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0     9/26/2019, 01:05:33 PM      Prabhat Sharma             Initial Version
**/

//CODE REVIEW DONE: By Prabhat Sharma
public without sharing class GenerateFilePublicURL {
    
    public static Map<Id, List<String>> enquiryIdWithNotifierIdMap;
    public static Map<String, String> userIdWithEmailMap;
    public static Map<String, String> enquiryIdWithLevelMap;
    //Added 8th Dec 2020
    public static List<Quote> quotes;
    public static map<String,String> modelPicklistMap = EmailQuotePDFCtrl.modelCodeLabelMap();
    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: This method will generate public links for files. 
        Inputs: Content Version ID
        Returns: public link url as string
        History:
        ================
        1.0     26 Sept 2019      Prabhat     Initial Version
    **/
    public static string CreateAttachmentPublicLink(string contentVersionId) {
        //Declaring return variable 
        string returnCdistobj;
        //null check for contentVersionId
        if (string.isNotBlank(contentVersionId)) {
            //Creating contentDistribution obj for generating the URL
            contentDistribution cdistObj = new contentDistribution();
            cdistObj.Name = 'File Public URL';
            cdistObj.ContentVersionId = contentVersionId;
            cdistObj.PreferencesAllowPDFDownload = true;
            cdistObj.PreferencesAllowViewInBrowser = true;
            insert cdistObj;
            //Query to fetch the PdfDownloadUrl from ContentDistribution
            returnCdistobj = [SELECT PdfDownloadUrl FROM ContentDistribution WHERE Id = :cdistObj.Id].PdfDownloadUrl;
        }
        //return the URL 
        return returnCdistobj;
    }


    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: This method will generate public links for files.
        Inputs: CommunicationType,
        Returns: void
        History:
        ================
        1.0     26 Sept 2019      Prabhat     Initial Version  9008893146
    **/
    public static List<MC_Communication__c> CreateMCRecord(String communicationType, set<Id> objectRecIds, String objectType, string pdfURL) {
        try {

            //For Escalation of enquiries get the below map from Trigger Helper class
            map<Id, set<String>> esclationUsers = new map<Id, set<String>>(OpportunityTriggerHelper.esclationUsers);
            //For Escalation Level Mapping
            map<Id, String> esclationLevel = new map<Id, String>(OpportunityTriggerHelper.esclationLevels);

            //For Brochure Mapping
            map<String, Task> brochureLevelMap = new map<String, Task>(OpportunityTriggerHelper.sendBrochurePhone);

            List<MC_Communication__c> mcRecordsToCreate = new list<MC_Communication__c>();

            //Create the mapping of MC Communication fields with Enquiry fields

            map<String, String> fieldMap = new map<String, String>(fetchObjectFields(communicationType));
            //Query details from Opportunity/Test Drive based on the details 
            String query = fetchSOQLQuery(communicationType);

            //Add record Ids based on object type received
            query = String.format(query, new List<String> { objectType }); 
			 //Added 9th Dec 2020 get most recent Quote record 
            quotes = [SELECT id,Name,Variant__c,Variant__r.name FROM Quote WHERE OpportunityId IN:objectRecIds ORDER BY CreatedDate DESC LIMIT 1]; 
                
                
             List<String> userIdList;
            //Loop through all the records of Opp/Test Drive
            for (sObject obj : Database.query(query)) {
                Record rec = new Record(obj);

                //For escalation enquiries, get the list of users
                if (communicationType == ConstantsUtility.ESCALATION_MC_TYPE && esclationUsers.containsKey(obj.Id)) {
                    userIdList = new List<String>(esclationUsers.get(obj.Id));
                }
                //For case escalation, get the list of users
                if (communicationType == ConstantsUtility.TRANSFER_ESCALATION_MC_TYPE && esclationUsers.containsKey(obj.Id)) {
                    userIdList = new List<String>(esclationUsers.get(obj.Id));
                }

                //Add the MC Communication Instance to the list
                mcRecordsToCreate.addAll(createMCrecordInstance(communicationType, pdfUrl, fieldMap, rec, userIdList, esclationLevel, brochureLevelMap));
            }

            //Check If bypass is enabled for the user/profile
            Bypass_Setting__c bypass = Bypass_Setting__c.getInstance();
            //Create MC COmmunications Records
            if (Schema.sObjectType.MC_Communication__c.isCreateable() && !bypass.Skip_MC_Record_Creation__c) {
                insert mcRecordsToCreate;
                //Prabhat to check the feasiblity of calling Exception handler class for bulk of records
            }

            return mcRecordsToCreate;
        }
        catch(Exception e){ExceptionHandler.LogError('GenerateFilePublicURL',e.getMessage(),objectType,null,null); return null;
        }
    }


    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: This method will create MC Communication record instances.
        Inputs: List of test Drive, Communicatio Type , public url for pdf file
        Returns: List of MC COmmunication record
        History:
        ================
        1.0     04 Oct 2019     Prabhat     Initial Version
        1.1    11 JUN 2020     Deepak       Added Case escalation checks
    **/
    public static List<MC_Communication__c> createMCrecordInstance(String communicationType,
            String pdfUrl,
            map<String, String> fieldMap,
            Record rec,
            list<String> esclationUsers,
            map<Id, String> escaltionLevels,
            map<String, Task> brochureMap) {

        List<MC_Communication__c> mcList = new list<MC_Communication__c>();
        Integer loopCount = 1;
        if(communicationType == ConstantsUtility.ESCALATION_MC_TYPE || communicationType == ConstantsUtility.TRANSFER_ESCALATION_MC_TYPE){
            loopCount = esclationUsers.size();
        }

        for (Integer i = 0; i < loopCount; i++) {
            MC_Communication__c mcRecordObj = new MC_Communication__c();
            mcRecordObj.Type__c = communicationType;
            mcRecordObj.URL_1__c = String.isNotBlank(pdfURL) ? pdfURL : '';

            for (String field : fieldMap.keySet()) {
                String fname = fieldMap.get(field);
                String fieldValue = String.valueOf(rec.get(fname));

                //Escalation DateTime field mapping
                if (fname == ConstantsUtility.ESCALATION_TIME && fieldValue != null) {
                    mcRecordObj.put(field, DateTime.valueOfGmt(fieldValue));
                } else if (fname == ConstantsUtility.SCHEDULE_START && fieldValue != null) {
                    DateTime dt = DateTime.valueOfGmt(fieldValue);
                    mcRecordObj.put(field, dt.format(label.Date_Time_Format));
                } else if (fname == ConstantsUtility.SCHEDULE_END && fieldValue != null) {
                    DateTime dt = DateTime.valueOfGmt(fieldValue);
                    mcRecordObj.put(field, dt.format(label.Date_Time_Format));
                } else if (fname == ConstantsUtility.INVOICE_DATE && fieldValue != null) {
                    mcRecordObj.put(field, Date.valueOf(fieldValue));
                } else if (field == ConstantsUtility.ESCALATION_DATE_TIME && fieldValue != null) { // Added By Deepak For transfer Escalation
                    mcRecordObj.put(field, DateTime.valueOfGmt(fieldValue));
                } else {
                    // Added the if part to conver the DateTime on the basis of user locale(03/03/2020)
                    if(fname=='Appointment_Datetime__c' && fieldValue!=NULL){
                            DateTime dt = DateTime.valueOfGmt(fieldValue);
                            mcRecordObj.put(field,dt.format(label.Date_Time_Format));
                    }
                    else{
                        mcRecordObj.put(field,fieldValue); 
                    } 
                }
            } 
            
             //Map the escalation user
            if(communicationType == 'Parts Escalation' && !enquiryIdWithNotifierIdMap.isEmpty() && enquiryIdWithNotifierIdMap.containsKey(mcRecordObj.Enquiry_MD__c)){
                
                if(enquiryIdWithLevelMap.containsKey(mcRecordObj.Enquiry_MD__c)){
                    String level_Val = enquiryIdWithLevelMap.get(mcRecordObj.Enquiry_MD__c);
                    if(String.isNotBlank(level_Val) && (level_Val == ConstantsUtility.level_1 || level_Val == ConstantsUtility.level_2)){
                        mcRecordObj.URL_1__c  = label.Base_Community_URL + '/' + mcRecordObj.Enquiry_MD__c;
                    }else{
                        mcRecordObj.URL_1__c  = baseURL() + '/' + mcRecordObj.Enquiry_MD__c;
                    }
                }
                
                List<String> userIdList = enquiryIdWithNotifierIdMap.get(mcRecordObj.Enquiry_MD__c);
                if(!userIdList.isEmpty() && userIdList.size() > 0){
                    mcRecordObj.Internal_User__c = userIdList[0];
                    mcRecordObj.Email_1__c = userIdWithEmailMap.containsKey(mcRecordObj.Internal_User__c) ? userIdWithEmailMap.get(mcRecordObj.Internal_User__c) : null;
                }
                if(!userIdList.isEmpty() && userIdList.size() == 2){
                    MC_Communication__c mcCloneRecordObj = new MC_Communication__c();
                    mcCloneRecordObj = mcRecordObj.clone(false, false, false, false);
                    mcCloneRecordObj.Internal_User__c = userIdList[1];
                    mcCloneRecordObj.Email_1__c = userIdWithEmailMap.containsKey(mcCloneRecordObj.Internal_User__c) ? userIdWithEmailMap.get(mcCloneRecordObj.Internal_User__c) : null;
                    mcList.add(mcCloneRecordObj);
                }
            }
            //Map the escalation user
            if (communicationType == ConstantsUtility.ESCALATION_MC_TYPE) {
                mcRecordObj.Internal_User__c = esclationUsers[i];
                mcRecordObj.General_Field_2__c = escaltionLevels.containsKey(mcRecordObj.Enquiry_MD__c) ? escaltionLevels.get(mcRecordObj.Enquiry_MD__c) : null;
                if (String.isNotBlank(mcRecordObj.General_Field_9__c)) {
                    mcRecordObj.General_Field_4__c = mcRecordObj.General_Field_9__c;
                }
            }
            // FOR ESCALATION USER CASE ESCALATION ADDED BY DEEPAK
            if (communicationType == ConstantsUtility.TRANSFER_ESCALATION_MC_TYPE) {
                mcRecordObj.Internal_User__c = esclationUsers[i];
            }
            if (communicationType == ConstantsUtility.SEND_BROCHURE_METADATA) {
                mcRecordObj.General_Field_2__c = escaltionLevels.containsKey(mcRecordObj.Enquiry_MD__c) ? modelPicklistMap.get(escaltionLevels.get(mcRecordObj.Enquiry_MD__c)) : null;
                mcRecordObj.Phone_2__c = brochureMap.containsKey(mcRecordObj.Enquiry_MD__c)  ? brochureMap.get(mcRecordObj.Enquiry_MD__c).Customer_Mobile__c  : null;
                mcRecordObj.Brochure_Type__c  = brochureMap.containsKey(mcRecordObj.Enquiry_MD__c)  ? brochureMap.get(mcRecordObj.Enquiry_MD__c).Brochure_Type__c : null;
                mcRecordObj.Loyalty_Program_Type__c  = brochureMap.containsKey(mcRecordObj.Enquiry_MD__c)  ? brochureMap.get(mcRecordObj.Enquiry_MD__c).Loyalty_Program_Type__c : null;
                //to default 91 for mobile number in case of brochure requests
                //if (mcRecordObj.Phone_2__c != null && mcRecordObj.Phone_2__c.length() == 10){
                  //  mcRecordObj.Phone_2__c = ConstantsUtility.COUNTRY_CODE + mcRecordObj.Phone_2__c;
                //}                  
                mcRecordObj.Email_2__c = brochureMap.containsKey(mcRecordObj.Enquiry_MD__c)   ? brochureMap.get(mcRecordObj.Enquiry_MD__c).Customer_Email_ID__c : null;
                mcRecordObj.General_Field_3__c = brochureMap.containsKey(mcRecordObj.Enquiry_MD__c) ? brochureMap.get(mcRecordObj.Enquiry_MD__c).Sending_Option__c  : null;
                
                // R1.2 Commercial development changes
                mcRecordObj.General_Field_9__c = brochureMap.containsKey(mcRecordObj.Enquiry_MD__c) ? brochureMap.get(mcRecordObj.Enquiry_MD__c).Language__c : null;
                string modelVariant = brochureMap.get(mcRecordObj.Enquiry_MD__c).Model_Variant__c;

                mcRecordObj.General_Field_2__c = string.isNotBlank(modelVariant) ? modelVariant : mcRecordObj.General_Field_2__c;
                
            }
            //Added by Nitin Ghai(31/03/2020)
            //This part is added to append +91 on Phone number fields, these records will be used by SFMC to send SMS
            if(communicationType==ConstantsUtility.updateAppointment){
                if (mcRecordObj.Phone_1__c != null && mcRecordObj.Phone_1__c.length() == 10){
                    mcRecordObj.Phone_1__c = ConstantsUtility.COUNTRY_CODE + mcRecordObj.Phone_1__c;
                }
                if (mcRecordObj.Phone_2__c != null && mcRecordObj.Phone_2__c.length() == 10){
                    mcRecordObj.Phone_2__c = ConstantsUtility.COUNTRY_CODE + mcRecordObj.Phone_2__c;
                }
                if (mcRecordObj.Phone_3__c != null && mcRecordObj.Phone_3__c.length() == 10){
                    mcRecordObj.Phone_3__c = ConstantsUtility.COUNTRY_CODE + mcRecordObj.Phone_3__c;
                }
                if (mcRecordObj.Phone_4__c != null && mcRecordObj.Phone_4__c.length() == 10){
                    mcRecordObj.Phone_4__c = ConstantsUtility.COUNTRY_CODE + mcRecordObj.Phone_4__c;
                }
            }
			 //Added 9th Dec 2020 If Communication Type is Quote then we will assign quote's variant
            if(communicationType == 'Quote'){
                mcRecordObj.General_Field_2__c = quotes[0].variant__r.name;
            }
            mcList.add(mcRecordObj);
        }
        return mcList;

    }


    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: This method will fetch the SOQL
        Inputs: Communication Type (BCR, TD Rescedule etc)
        Returns: String of query
        History:
        ================
        1.0     04 Oct 2019     Prabhat     Initial Version  
    **/
    public static String fetchSOQLQuery(String communicationType) {

        String query = '';
        //Get the Query details from Metadata
        List<MC_Communication_SOQLs__mdt> mcomList = new list<MC_Communication_SOQLs__mdt>([
                SELECT MasterLabel,Source_SOQL__c
                FROM MC_Communication_SOQLs__mdt
                WHERE MasterLabel = :communicationType
        ]);
        if (mcomList.size() > 0) {
            query = mcomList[0].Source_SOQL__c;
        }
        return query;

    }

    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: This method will fetch the field mapping of Opporutnity and MC Communication object
        Inputs: Communication Type (BCR, TD Rescedule etc)
        Returns: map of MC field as key and Opportunity field as value
        History:
        ================
        1.0     04 Oct 2019     Prabhat     Initial Version  
    **/
    public static map<String, String> fetchObjectFields(String communicationType) {

        List<String> sourceObjectFieldList = new list<String>();
        List<String> mcObjectFieldList = new list<String>();
        Map<String, String> sourceTargteFieldMap = new Map<String, String>();

        //Get the field details from Metadata based on communication type
        for (MC_Communication_SOQLs__mdt mcCom : [SELECT MC_Communication_Fields__c,Source_Fields__c FROM MC_Communication_SOQLs__mdt WHERE MasterLabel = :communicationType]) {
            sourceObjectFieldList = mcCom.Source_Fields__c.split(',');
            mcObjectFieldList = mcCom.MC_Communication_Fields__c.split(',');
        }

        if (sourceObjectFieldList.size() > 0 && mcObjectFieldList.size() > 0) {
            //Loop through all fields and create a map with key as MC Comm fields and value as Source object fields
            for (Integer i = 0; i < mcObjectFieldList.size(); i++) {
                sourceTargteFieldMap.put(mcObjectFieldList[i].trim(), sourceObjectFieldList[i].trim());
            }
        }
        return sourceTargteFieldMap;
    }


    /**
        Author: Anuj Kumar
        Company: Techmatrix
        Description: This method will generate Base URl.
        Returns: Base URl
        ================
        1.0     12 Oct 2019     Anuj     Initial Version  
    **/
    public Static String baseURL() {
        String baseURL = '';
        Boolean isPortalUser;

        List<User> currentUserData = new List<User>([Select id, Name, Title, IsPortalEnabled from User where Id = :UserInfo.getUserId() Limit 1]);
        if (currentUserData != null && currentUserData.size() > 0) {
            isPortalUser = currentUserData[0].IsPortalEnabled;
        }

        if (isPortalUser) {
            String currentCommunityId = Network.getNetworkId();
            if (currentCommunityId != null) {
                string communityURL = Network.getLoginUrl(currentCommunityId);
                if (communityURL.endsWith('login')) {
                    communityURL = communityURL.replace('/login', '');
                }
                baseURL = communityURL;
            }
        } else {
            baseURL = Url.getSalesforceBaseUrl().toExternalForm();
        }

        return baseURL;

    }


    /**
        Author: Sumit Gupta
        Description: Wrapper class to work with dynamic sobject records
    **/
    public class Record {
        SObject rec;
        Map<String, Object> recMap;

        public Record(SObject rec) {
            if (rec != null) {
                this.rec = rec;
                recMap = this.rec.getPopulatedFieldsAsMap();
            }
        }

        //Get the record detail in a wrapper
        public Object get(String fname) {
            if (fname.startsWith('Child.')) {
                List<String> keys = fname.replace('Child.', '').split('\\.');
                return get(keys.get(0), keys.get(1));
            } 
            else if(fname.contains('.')){
                List<String> keys = fname.split('\\.');

                Record tmpRecord = this;
                Integer index = 0;

                while (tmpRecord != null && index < keys.size() - 1) {
                    String key = keys.get(index);
                    if (tmpRecord.get(key) != null && tmpRecord.get(key) != '') {
                        tmpRecord = new Record((SObject) tmpRecord.get(key));
                    }
                    index++;
                }
                return tmpRecord.get(keys.get(index));
            } else if (String.isNotBlank(fname) && recMap != null) {
                return recMap.get(fname);
            }
            else{
                return '';
            }
        }

        public Object get(String rname, String fname) {
            List<SObject> children = (List<SObject>) rec.getSObjects(rname);
            if (children != null) {
                return new Record(children.get(0)).get(fname);
            }
            return '';
        }
    }
}