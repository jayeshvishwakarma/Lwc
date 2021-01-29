/**
Author: Gitika
Company: Techmatrix
Description: Class Used for Case Closure document upload functionality. 
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0        19/06/2020                Gitika            Initial Version
**/

public without sharing class dynamicFileUploadController {
    /**
Author: Gitika
Company: Techmatrix
Description: Method to send OTP to Customer
Returns: String
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/
    @AuraEnabled
    public static string sendOtp(String recordId) {
        try {
            Case cse = [select id,OTP_Base_Value__c,mobile_number__c,Status,Email__c,Channel__c from case where id = :recordId];
            String otp = String.valueOf(Math.round((Math.random() * (900000) + 100000)));

            if (String.isBlank(cse.OTP_Base_Value__c)) {
                createMcCommunication(cse.mobile_number__c,otp,cse,ConstantsUtility.RESOLUTION_CODE,cse.Email__c);
                cse.OTP_Base_Value__c = otp;
                cse.OTP_Generated_Time__c = System.now();
                update cse;
            }else{
                createMcCommunication(cse.mobile_number__c,cse.OTP_Base_Value__c,cse,ConstantsUtility.RESOLUTION_CODE,cse.Email__c);
                cse.OTP_Generated_Time__c = System.now();
                update cse;
            }
            return 'SUCCESS';
        } catch (exception e) {
            return e.getMessage();
        }
    }
    /**
Author: Gitika
Company: Techmatrix
Description: Method to verify OTP
Returns: String
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/
    @AuraEnabled
    public static string verifyOtp(String recordId, String otpentered, String closuremode) {
        try {
            Case cse = [select id,OTP_Base_Value__c,Status,closure_Mode__c,Channel__c,Email__c from case where id = :recordId];
            if (cse.OTP_Base_Value__c == otpentered) {
                cse.OTP_Entered__c = otpentered;
                cse.closure_Mode__c = closuremode;
                createMcCommunication(cse.mobile_number__c,cse.OTP_Base_Value__c,cse,'OTP - Verification Confirmed',cse.Email__c);
                update cse;
                return 'SUCCESS';
            }
            return 'ERROR';
        } catch (exception e) {
            return e.getMessage();
        }
    }
    /**
Author: Gitika
Company: Techmatrix
Description: method called on load of dynamicFileUpload LWC
Returns: masterWrapper
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/
    @AuraEnabled
    public static masterWrapper fetchDocumentUploadList(Id recordId, String processName) {
        //main wrapper class used to store case detail, parentwrapper
        masterWrapper masterwrap = new masterWrapper();
        // list used to store mandatory document
        list<string> documentlistmadatory = new list<string>();
        // list used to store non mandatory document
        list<string> documentlistnonmadatory = new list<string>();
        documentlistnonmadatory.add(ConstantsUtility.Others);
        string categoryid;
        // list used to store Case Actions
        list<Case_Actions__c> caseActioninfo = new list<Case_Actions__c>();
        // Stirng to store processName
        string processNameApex = '';
        // Stirng to store CaseNumber
        string CaseNumber = '';
        if (processName != null) {
            processNameApex = processName;
        }
        try {
            Map<string, FileUtility__c> FileUtilityName = FileUtility__c.getAll();

            list<Case_Actions__c> caseAcc = [
                    Select Id,MSIL_Remarks__c,OwnerId,Case_Number__c,Approval_Status__c,RecordType.DeveloperName
                    from case_actions__c
                    where (Case_Number__c = :recordId OR Id = :recordId )
                    and RecordType.DeveloperName = :processNameApex
                    order by createddate desc
                    limit 1
            ];

            if (caseAcc.size() > 0) {
                recordid = caseacc[0].Case_Number__c;
                masterWrap.caseAcObj = caseAcc[0];
                if (processName == null) {
                    processNameApex = caseacc[0].RecordType.DeveloperName;
                }
            }
            if (FileUtilityName.containskey(processNameApex)) {

                list<case> caseobj = [select id,OTP_Entered__c,Closure_Mode__c,Clarification_Note_reason__c,Status,OTP_Generated_Time__c,No_of_Outbound_Emails__c,MSIL_Remarks__c,MSIL_Query_Response__c,Recordtype.DeveloperName,casenumber,Primary_Category_ID__c,Secondary_Category_ID__c,Tertiary_Category_ID__c from case where id = :recordId];

                if (caseobj.size() > 0) {

                    CaseNumber = caseobj[0].casenumber;

                    masterwrap.caseobj = caseobj[0];

                    if (String.isBlank(string.valueof(caseobj[0].OTP_Generated_Time__c))) {
                        masterwrap.disableSentOtp = false;
                    } else if (String.isNotBlank(string.valueof(caseobj[0].OTP_Generated_Time__c)) && ((system.now().getTime() - caseobj[0].OTP_Generated_Time__c.getTime()) / 60000) > 5) {
                        masterwrap.disableSentOtp = false;
                    }

                    if (ConstantsUtility.COMPLAINT_DEALER_Closure.contains(processNameApex)) {
                        categoryid = String.isnotblank(caseobj[0].Tertiary_Category_ID__c) ? caseobj[0].Tertiary_Category_ID__c :
                                (String.isnotblank(caseobj[0].Secondary_Category_ID__c) ? caseobj[0].Secondary_Category_ID__c :
                                        (String.isnotblank(caseobj[0].Primary_Category_ID__c) ? caseobj[0].Primary_Category_ID__c : null));

                    } else {
                        documentlistmadatory = String.isnotblank(FileUtilityName.get(processNameApex).Mandatory_Document__c) ? FileUtilityName.get(processNameApex).Mandatory_Document__c.split(';') : documentlistmadatory;
                        documentlistnonmadatory = String.isnotblank(FileUtilityName.get(processNameApex).Non_Mandatory_Documents__c) ? FileUtilityName.get(processNameApex).Non_Mandatory_Documents__c.split(';') : new list<string>();
                    }

                }

                if (categoryid != null) {
                    Category__c catgry = [SELECT Closure_Files__c,Closure_Files_Non_Mandatory__c FROM Category__c where Active__c = true and id = :categoryid];
                    documentlistmadatory = String.isnotblank(catgry.Closure_Files__c) ? catgry.Closure_Files__c.split(';') : documentlistmadatory;
                    documentlistnonmadatory = String.isnotblank(catgry.Closure_Files_Non_Mandatory__c) ? catgry.Closure_Files_Non_Mandatory__c.split(';') : documentlistnonmadatory;


                }
                masterwrap.parentwrapper.addall(dynamicFileUploadController.documentList(documentlistmadatory, CaseNumber, true, recordId, FileUtilityName.get(processNameApex)));
                masterwrap.parentwrapper.addall(dynamicFileUploadController.documentList(documentlistnonmadatory, CaseNumber, false, recordId, FileUtilityName.get(processNameApex)));

                masterwrap.message = 'SUCCESS';
                return masterwrap;
            }
            masterwrap.message = 'No Process Found';
            return masterwrap;
        } catch (exception e) {
            masterwrap.message = e.getMessage();
            return masterwrap;
        }
    }
    /**
Author: Gitika
Company: Techmatrix
Description: Method to return list of uploaded documents with Master Document Name
Returns: ParentWrapper
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/
    public static list<ParentWrapper> documentList(list<string> documentList, String CaseNumber, boolean IsRequired, String CaseId, FileUtility__c processName) {
        // map to get Document uploaded with respect to Documentlist
        map<string, list<ChildWrapper>> mapOfUploadedDoc = new map<string, list<ChildWrapper>>();
        list<ParentWrapper> pWrapList = new list<ParentWrapper>();
        mapOfUploadedDoc = dynamicFileUploadController.UploadedDocList(CaseId);
        set<string> documentset = new set<String>();
        documentset.addAll(documentList);
        for (string str : documentset) {
            ParentWrapper pWrap = new ParentWrapper();
            pWrap.MasterDocName = str;
            pWrap.required = IsRequired;
            if (str == processName.Pick_List_Doc_Name__c) {
                pWrap.isPickList = true;
            }
            ChildWrapper childrecord = new ChildWrapper();
            list<ChildWrapper> childlist = new list<ChildWrapper>();
            childlist.add(childrecord);
            integer i = 1;
            if (mapOfUploadedDoc.containskey(str + ';' + processName.Name)) {
                for (ChildWrapper child : mapOfUploadedDoc.get(str + ';' + processName.Name)) {
                    pWrap.isuploaded = true;
                    string[] filenameWithExtension = child.fileuniquename.split('\\.');
                    child.fileuniquename = CaseNumber + ' ' + str + '(' + i + ').' + filenameWithExtension[1];
                    i++;
                }
                childlist.addall(mapOfUploadedDoc.get(str + ';' + processName.Name));
            }
            pWrap.childRecordList = childlist;
            pWrapList.add(pWrap);
        }
        return pWrapList;
    }
    /**
Author: Gitika
Company: Techmatrix
Description: Method is called when file is Uploaded successfully
Returns: String
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/
    @AuraEnabled
    public static string OnUploadFinish(String recordId, String filedata, String fileUniquename, String processName, String caseDetail, boolean isResolved) {
        try {
            list<FileWrapper> fileDetail = (list<FileWrapper>) JSON.deserialize(filedata, list<FileWrapper>.class);
            ContentVersion conVer = [SELECT Id,ContentDocumentId,FileUniqueName__c,ContentUrl,title FROM ContentVersion Where ContentDocumentId = :fileDetail[0].documentid];
            conVer.FileUniqueName__c = fileUniquename + ';' + processName;
            update conVer;
            Case cs = new Case();
            cs = (Case) JSON.deserialize(caseDetail, Case.class);
            // Updating Closure Mode Once File is uploaded first time
            if (fileUniquename.contains(ConstantsUtility.Closure) && isResolved == false) {
                update cs;
            }
            // Updating MSIL_Query_Response__c Once File is uploaded first time
            if (fileUniquename.contains(ConstantsUtility.MSIL)) {
                update cs;
                // INSERT FEED
                CaseActionCreation.insertFeedItem(recordId, NULL, ConstantsUtility.CONTENT_POST, conVer.Id);
            }

            return 'SUCCESS';
        } catch (exception e) {
            return e.getMessage();
        }

    }
    /**
Author: Gitika
Company: Techmatrix
Description: Method called to delete doc
Returns: String
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/
    @AuraEnabled
    public static string deleteDocList(String docId) {
        try {
            ContentDocument conDocLink = new ContentDocument();
            conDocLink.Id = docId;
            delete conDocLink;
            return 'SUCCESS';
        } catch (exception e) {
            return e.getMessage();
        }
    }
    /**
Author: Gitika
Company: Techmatrix
Description: method to return child files uploaded with respect to each File Name Category
Returns: String
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0                                                           Initial Version
**/
    public static map<string, list<ChildWrapper>> UploadedDocList(String recordId) {
        // map to store File upload category Name with Uploaded Files
        map<string, list<ChildWrapper>> mapOfUploadedDoc = new map<string, list<ChildWrapper>>();
        // map of documentid with public URL.
        map<string, string> mapOfveiwlink = new map<string, string>();
        // set to store documentids
        set<String> docIds = new set<string>();

        for (ContentDocumentLink conLink : [Select ContentDocumentId from ContentDocumentLink where LinkedEntityid = :recordId]) {
            docIds.add(conLink.ContentDocumentId);
        }

        for (ContentVersion conVer : [SELECT Id,ContentDocumentId,FileUniqueName__c,title,FileExtension FROM ContentVersion Where ContentDocumentId in :docIds]) {

            if (string.isnotblank(conVer.FileUniqueName__c)) {
                if (!mapOfUploadedDoc.containskey(conVer.FileUniqueName__c)) {
                    list<ChildWrapper> childlist = new list<ChildWrapper>();
                    ChildWrapper childrecord = new ChildWrapper();
                    childrecord.fileuniquename = conVer.title + '.' + conVer.FileExtension;
                    childrecord.documentid = conVer.ContentDocumentId;
                    childrecord.isDownloded = true;


                    childlist.add(childrecord);

                    mapOfUploadedDoc.put(conVer.FileUniqueName__c, childlist);
                } else {
                    list<ChildWrapper> childlist = mapOfUploadedDoc.get(conVer.FileUniqueName__c);
                    ChildWrapper childrecord = new ChildWrapper();
                    childrecord.fileuniquename = conVer.title + '.' + conVer.FileExtension;
                    childrecord.documentid = conVer.ContentDocumentId;
                    childrecord.isDownloded = true;


                    childlist.add(childrecord);

                    mapOfUploadedDoc.put(conVer.FileUniqueName__c, childlist);
                }
            }
        }

        return mapOfUploadedDoc;

    }
    public class masterWrapper {
        @AuraEnabled public list<ParentWrapper> parentwrapper = new list<ParentWrapper>();
        @AuraEnabled public Case caseObj = new Case();
        @AuraEnabled public Case_Actions__c caseAcObj = new Case_Actions__c();
        @AuraEnabled public boolean disableSentOtp = true;
        @AuraEnabled public string message ;
    }
    public class ParentWrapper {
        @AuraEnabled public string MasterDocName;
        @AuraEnabled public boolean required = false;
        @AuraEnabled public boolean isuploaded = false;
        @AuraEnabled public boolean isPickList = false;
        @AuraEnabled public list<ChildWrapper> childRecordList;
    }
    public class ChildWrapper {
        @AuraEnabled public string fileuniquename;
        @AuraEnabled public string documentid;
        @AuraEnabled public boolean isDownloded = false;

    }
    public class FileWrapper {
        public string name;
        public string documentid;
    }

    /**
    Author: Gitika
    Company: Techmatrix
    Description: Method to create MC Communition record
    Returns: String
    History:
    * Ver         Date                     Author                    Modification
    *===========================================================================
    * 1.0                                                           Initial Version
    **/
    public static void createMcCommunication(String mobileNo, String otp, Case caseObj, String type, String emailString) {
        MC_Communication__c mc = new MC_Communication__c();
        mc.Recipient_Phone_Numbers__c = String.isNotBlank(mobileNo) ? mobileNo : '';
        mc.General_Field_4__c = otp;
        mc.Case__c = caseObj.Id;
        mc.Type__C = type;
        mc.Status__c = 'Queued';
        mc.Email_1__c = String.isNotBlank(emailString) ? emailString : null;
        if (caseObj != null && caseObj.Channel__c == ConstantsUtility.NEXA_CASE_CHANNEL) {
            mc.General_Field_5__c = String.valueOf(System.Label.Nexa_Toll_Free_Numbers);
        } else {
            mc.General_Field_5__c = String.valueOf(System.Label.Arena_Toll_Free_Numbers);
        }
        insert mc;
    }


}