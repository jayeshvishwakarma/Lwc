/**
 * @File Name          : DMSSysncFailAlertAsMail.cls
 * @Description        : Send email containg all dms sysnc alert runs every 15 minutes
 * @Author             : Rahul Sharma
 * @Group              : MSIL
**/

public class DMSSysncFailAlertAsMail{
    //Method to extract the data 
    public static void extractFailEnquiryData(DateTime ActualStartDateTime, DateTime ActualEndDateTime){
        
        DateTime StartDateTime;
        DateTime EndDateTime;
        
        if(ActualStartDateTime == Null){
            Integer mins = label.Data_Extract_Min_Limit != null ? Integer.valueOf(label.Data_Extract_Min_Limit) : 10;
            StartDateTime = DateTime.Now().addMinutes(-mins);
        }else{
            StartDateTime = ActualStartDateTime;
        }
        
        if(ActualEndDateTime == Null){
            EndDateTime = DateTime.Now();
        }else{
            EndDateTime = ActualEndDateTime;
        }
        
        Date dt = date.newinstance(StartDateTime.year(), StartDateTime.month(), StartDateTime.day());
        Date dt1 = date.newinstance(EndDateTime.year(), EndDateTime.month(), EndDateTime.day());
                
        //Map to store the list of opportunity on the basis of defined Type
        map<string, list<opportunity>> oppMap = new map<string,list<opportunity>>();
        //Map to convert the opportunity list into CSV form 
        map<String,blob> csvConertingDataMapOpp ;
            list<Opportunity> syncFailEnquiry = new list<Opportunity>();
        //Condition check
        if(StartDateTime != null  && EndDateTime != null){
        
            list<Opportunity> syncFailEnquiryCreation = [select id,dealership__r.Channel__c, Dealership__r.Parent_Group__c, DMS_Enquiry_Name__c, StageName,DMS_Sync_Error__c,
                                                        DMS_Sync_Error_Details__c,Pre_Booking_Number__c
                                                         from opportunity 
                                                         where DMS_Sync_Error_Details__c != null
                                                         AND (NOT DMS_Sync_Error_Details__c Like '%DEALER DETAIL NOT AVAILABLE FOR USERID:%')
                                                         AND (NOT DMS_Sync_Error_Details__c Like '%EMPLOYEE APPROVAL STATUS IS PENDING FOR USERID:%')
                                                         AND Variant__c != null
                                                         AND StageName = 'New'
                                                         AND CreatedDate >=: StartDateTime 
                                                         AND CreatedDate <=: EndDateTime];
            if(syncFailEnquiryCreation.size() > 0)
            {
                for(Opportunity opp : syncFailEnquiryCreation)
                {
                    if(opp.DMS_Enquiry_Name__c == null && opp.StageName == 'New')
                        syncFailEnquiry.add(opp);
                }
            }
            list<Opportunity> syncFailEnquiryPreBooking = [select id,dealership__r.Channel__c, Dealership__r.Parent_Group__c, DMS_Enquiry_Name__c, StageName,DMS_Sync_Error__c,
                                                        DMS_Sync_Error_Details__c,Pre_Booking_Number__c,Pre_booking_Submission_Date__c 
                                                         from opportunity 
                                                         where DMS_Sync_Error_Details__c != null
                                                         AND StageName = 'Pre-Booking'
                                                         AND Pre_booking_Submission_Date__c >=: dt
                                                         AND Pre_booking_Submission_Date__c <=: dt1];
            if(syncFailEnquiryPreBooking.size() > 0)
            {
                for(Opportunity opp : syncFailEnquiryPreBooking)
                {
                    if(opp.Pre_Booking_Number__c == null && opp.Pre_booking_Submission_Date__c != null && opp.DMS_Enquiry_Name__c != null)
                        syncFailEnquiry.add(opp);
                }
            }
            
            //Condition check
            if(syncFailEnquiry != null && syncFailEnquiry.size()>0){
            //            oppmap.putAll('syncFail' , syncFailEnquiry);
            
             for(Opportunity opp : syncFailEnquiry){
                    //Fill map with defined Type
                    if(oppmap.containsKey('syncFail')){
                        list<Opportunity> templist =  oppmap.get('syncFail');
                        templist.add(opp);
                        oppmap.put('syncFail', templist);
                    }
                    else
                        oppmap.put('syncFail', new list<Opportunity>{opp});
                }
            }
            }
            //Size check 
            if(oppmap.size()>0)
                //Call class member function for convert data into .CSV format
                csvConertingDataMapOpp= convertListToCSVOpportunity(oppmap);
             
             //Condition check of Opportunity and Mc Communication
            if(oppMap.values().size()>0){
                map<String,blob> csvConertingDataMap = new map<String,blob>();
                //Condition check of Opportunity .CSV map
                if(csvConertingDataMapOpp != null && csvConertingDataMapOpp.size()>0)
                {
                    //Copies all the values of one map to another map 
                    csvConertingDataMap.putAll(csvConertingDataMapOpp);
                    if(csvConertingDataMap != null && csvConertingDataMap.size()>0){
                        sendSingleMail(csvConertingDataMap,StartDateTime,EndDateTime);
                    }
                }
            }   
       
    }
    
    //Method to convert the opportunity data into .CSV format
    public static Map<string,blob> convertListToCSVOpportunity(map<string,list<opportunity>> oppmap){
        //Variable to defined Column header for CSV
        String csvColumnHeader;
        //Map for storing the blob data for CSV
        map<string,blob> csvFiletoMail = new map<string,blob>();
        //Map to store column row values for CSV
        map<string,list<string>> csvRowValuesMap = new map <string,list<string>>(); 
        //Loop through keySet
        for(string key : oppmap.keyset()){
            //loop through List of map
           list<opportunity> lstOpp = oppmap.get(key);
           for(opportunity opp : oppmap.get(key)){
               //Create data for CSV
                string Id = opp.id;
                String Channel = opp.dealership__r.Channel__c != null ? opp.dealership__r.Channel__c : '' ;
                String ParentGroup = opp.Dealership__r.Parent_Group__c !=null ? opp.Dealership__r.Parent_Group__c : '';
                String DMSEnquiryNumber = opp.DMS_Enquiry_Name__c != null ? opp.DMS_Enquiry_Name__c : '';
                String StageName = opp.StageName != null ? opp.StageName : '';
                String DMSSyncError = String.valueOf(opp.DMS_Sync_Error__c) != null ? String.valueOf(opp.DMS_Sync_Error__c) : '';
                String DMSSyncErrorDetails = opp.DMS_Sync_Error_Details__c != null ? opp.DMS_Sync_Error_Details__c : '';
                String PreBookingNumber = opp.Pre_Booking_Number__c != null ? opp.Pre_Booking_Number__c : '';
                //Passing the data into single string variable
                String rowString = Id + ',' + Channel +','+ StageName + ','+ DMSEnquiryNumber +','+ ParentGroup +','+DMSSyncError + ',' +DMSSyncErrorDetails + ',' + PreBookingNumber;
                
                //Fill map with defined Type
                if(csvRowValuesMap.containsKey('syncFail')){
                    list<string> templist = csvRowValuesMap.get('syncFail');
                    templist.add(rowString);
                    csvRowValuesMap.put('syncFail',templist);
                }
                else
                    csvRowValuesMap.put('syncFail' , new list<string>{rowString}) ;
            }
        }
        //Condition check
        if(csvRowValuesMap.size()>0){
            //passing value to Column header
            csvColumnHeader = 'Id,Channel,StageName,DMSEnquiryName,ParentGroup, DMSSyncError, DMSSyncErrorDetails,PreBookingNumber , \n';
            //Loop through String map
            for(String keys : csvRowValuesMap.keySet()){
                if(csvRowValuesMap.containsKey(keys)){
                    //Create CSV file format 
                    String csvFile = csvColumnHeader + String.join(csvRowValuesMap.get(keys),'\n');
                    //Fill map with blob values for sending the mail
                    csvFiletoMail.put(keys, blob.valueOf(csvFile));
                }
            }
        }
        return csvFiletoMail;
    }
        
    //Method to send mail
    public static void sendSingleMail(map<string,blob> dataToSendMap, DateTime StartDateTime , DateTime EndDateTime){
        
        list<Messaging.EmailFileAttachment> csvAttachmentList = new list<Messaging.EmailFileAttachment>();
        for(string key : dataToSendMap.keySet()){
            if(dataToSendMap.containskey(key)){
                Messaging.EmailFileAttachment mailtoSend = new Messaging.EmailFileAttachment();
                String csvName = 'Alert - ' + 'syncFail'+'_Extract'+'-'+StartDateTime.format('HH:mm:ss') +'-'+EndDateTime.format('HH:mm:ss')+'.csv';
                mailtoSend.setFileName(csvName);
                system.debug('dataToSendMap.get(key) '+dataToSendMap.get(key));
                mailtoSend.setBody(dataToSendMap.get(key));
                csvAttachmentList.add(mailtoSend);
                
            }
        }
        
        if(csvAttachmentList.size()>0){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            List<String> toAddresses = Label.sync_Fail != Null ? Label.sync_Fail.split(',') : new List<string>();
            String subject = 'Enquiry Sync Fail Alert'+StartDateTime.format('HH:mm:ss')+'-'+EndDateTime.format('HH:mm:ss');
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            email.setPlainTextBody('Hi Sir/Mam, \n\nBelow is the attached document related to file extraction\n\n Regards,\n MSIL Admin Team');
            email.setFileAttachments(csvAttachmentList);
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        }   
}

}