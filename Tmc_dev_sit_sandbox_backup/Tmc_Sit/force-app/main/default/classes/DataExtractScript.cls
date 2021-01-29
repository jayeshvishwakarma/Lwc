/**
 * @File Name          : DataExtractScript.cls
 * @Description        : 
 * @Author             : Rajesh Ramachandran
 * @Group              : 
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 1/10/2020, 2:23:49 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    1/10/2020   Rajesh Ramachandran     Initial Version
**/
//Class to Extract data from Opportunity and MC_Communication__c from giving StartDate and EndDate and mail the records in .CSV
//
Public class DataExtractScript {
    //Method to extract the data 
    public static void extractData(DateTime ActualStartDateTime, DateTime ActualEndDateTime){
        
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
        
        //Map to store the list of MC_Communication__c on the basis of Type
        map<string,list<MC_Communication__c>> mapList = new map<string,list<MC_Communication__c>>();
        //Map to store the list of opportunity on the basis of defined Type
        map<string, list<opportunity>> oppMap = new map<string,list<opportunity>>();
        //Map to convert the opportunity list into CSV form 
        map<String,blob> csvConertingDataMapOpp ;
        
        //Condition check
        if(StartDateTime != null  && EndDateTime != null){
            //Query through MC_Communication__c
            list<MC_Communication__c> quoteList = [Select id,Channel__c, Enquiry_MD__r.Dealership__r.Parent_Group__c, Enquiry_MD__r.Dealership__r.Dealer_Map_Code__c,
                                                   Enquiry_MD__r.Dealership__r.Dealer_Location__c, Enquiry_MD__r.DMS_Enquiry_Name__c, Enquiry_MD__r.Booking_Number__c,
                                                   type__c, Enquiry_MD__r.Mobile__c, Enquiry_MD__r.First_Name__c, Enquiry_MD__r.Middle_Name__c, Enquiry_MD__r.Last_Name__c,
                                                   URL_1__c, CreatedDate 
                                                   from MC_Communication__c 
                                                   where Type__c = 'Quote' 
                                                   and CreatedDate >=: StartDateTime 
                                                   AND CreatedDate <=: EndDateTime];
            //Condition check
            if(quoteList != null && quoteList.size()>0){
                //Loop through list
                for(MC_Communication__c Quote : quoteList){
                    //Fill map with defined Type
                    if(mapList.containsKey(Quote.Type__c)){
                        list<MC_Communication__c> templist =  mapList.get(Quote.Type__c);
                        templist.add(Quote);
                        mapList.put(Quote.Type__c , templist);
                    }
                    else
                        mapList.put(Quote.Type__c , new list<MC_Communication__c>{Quote});
                }
            }
            
            //Query through MC_Communication__c
            list<MC_Communication__c> bcrList = [SELECT id,Channel__c, Enquiry_MD__r.Dealership__r.Parent_Group__c, Enquiry_MD__r.Dealership__r.Dealer_Map_Code__c,
                                                 Enquiry_MD__r.Dealership__r.Dealer_Location__c, Enquiry_MD__r.DMS_Enquiry_Name__c, 
                                                 Enquiry_MD__r.Booking_Number__c, type__c, Enquiry_MD__r.Mobile__c, Enquiry_MD__r.First_Name__c,
                                                 Enquiry_MD__r.Middle_Name__c, Enquiry_MD__r.Last_Name__c, URL_1__c, CreatedDate 
                                                 from MC_Communication__c 
                                                 where Type__c = 'BCR' 
                                                 and CreatedDate >=: StartDateTime 
                                                 AND CreatedDate <=: EndDateTime];
            
            //Condition check
            if(bcrList != null && bcrList.size()>0){
                //Loop through list 
                for(MC_Communication__c bcr : bcrList){
                    //Fill map with defined type
                    if(mapList.containsKey(bcr.Type__c)){
                        list<MC_Communication__c> templist =  mapList.get(bcr.Type__c);
                        templist.add(bcr);
                        mapList.put(bcr.Type__c , templist);
                    }
                    else
                        mapList.put(bcr.Type__c , new list<MC_Communication__c>{bcr});
                }
            }
            
            //Query through opportunity
            list<Opportunity> postBookingFeedbackList = [select id,dealership__r.Channel__c, Dealership__r.Parent_Group__c,dealership__r.Dealer_Map_Code__c,
                                                         dealership__r.Dealer_Location__c, DMS_Enquiry_Name__c, Booking_Number__c, StageName, Mobile__c,
                                                         First_Name__c, Middle_Name__c, Last_Name__c, Post_Booking_Feedback__c, Booking_Date__c
                                                         from opportunity 
                                                         where Booking_Number__c != null
                                                         and Booking_Date__c = TODAY
                                                         AND LastModifiedDate >=: StartDateTime 
                                                         AND LastModifiedDate <=: EndDateTime];
            
            //Condition check
            if(postBookingFeedbackList != null && postBookingFeedbackList.size()>0){
                //Loop through list
                for(Opportunity opp : postBookingFeedbackList){
                    //Fill map with defined Type
                    if(oppmap.containsKey(ConstantsUtility.Post_Booking_Feedback)){
                        list<Opportunity> templist =  oppmap.get(ConstantsUtility.Post_Booking_Feedback);
                        templist.add(opp);
                        oppmap.put(ConstantsUtility.Post_Booking_Feedback , templist);
                    }
                    else
                        oppmap.put(ConstantsUtility.Post_Booking_Feedback , new list<Opportunity>{opp});
                }
            }
            //Size check 
            if(oppmap.size()>0)
                //Call class member function for convert data into .CSV format
                csvConertingDataMapOpp= convertListToCSVOpportunity(oppmap);
            
            
            //Query through MC_Communication__c
            list<MC_Communication__c> sendBrochureList = [select id,Channel__c, Enquiry_MD__r.Dealership__r.Parent_Group__c, Enquiry_MD__r.Dealership__r.Dealer_Map_Code__c,
                                                          Enquiry_MD__r.Dealership__r.Dealer_Location__c, Enquiry_MD__r.DMS_Enquiry_Name__c, Enquiry_MD__r.Booking_Number__c,
                                                          type__c, Enquiry_MD__r.Mobile__c, Enquiry_MD__r.First_Name__c, Enquiry_MD__r.Middle_Name__c, Enquiry_MD__r.Last_Name__c,
                                                          URL_1__c, CreatedDate
                                                          from MC_Communication__c 
                                                          where Type__c = 'Send Brochure' 
                                                          and General_Field_3__c = 'SMS' 
                                                          and CreatedDate >=: StartDateTime 
                                                          AND CreatedDate <=: EndDateTime];
            
            //Condition check
            if(sendBrochureList != null && sendBrochureList.size()>0){
                //Loop through list 
                for(MC_Communication__c brochure : sendBrochureList){
                    //Fill map with defined Type
                    if(mapList.containsKey(brochure.Type__c)){
                        list<MC_Communication__c> templist =  mapList.get(brochure.Type__c);
                        templist.add(brochure);
                        mapList.put(brochure.Type__c , templist);
                    }
                    else
                        mapList.put(brochure.Type__c , new list<MC_Communication__c>{brochure});
                }  
            }
        }
        
        //Condition check of Opportunity and Mc Communication
        if(mapList.size()>0 || oppMap.size()>0){
            //Map to convert Mc Communication records into .CSV
            map<String,blob> csvConertingDataMap = ConvertListToCSV(mapList); 
            //Condition check of Opportunity .CSV map
            if(csvConertingDataMapOpp != null && csvConertingDataMapOpp.size()>0)
            //Copies all the values of one map to another map 
            csvConertingDataMap.putAll(csvConertingDataMapOpp);
            //Condition check 
            if(csvConertingDataMap != null && csvConertingDataMap.size()>0){
                //Call another class for sending mail
                SendEmail.sendSingleMail(csvConertingDataMap,StartDateTime,EndDateTime);
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
           for(opportunity opp : oppmap.get(key)){
               //Create data for CSV
                string Id = opp.id;
                String Channel = opp.dealership__r.Channel__c != null ? opp.dealership__r.Channel__c : '' ;
                String ParentGroup = opp.Dealership__r.Parent_Group__c !=null ? opp.Dealership__r.Parent_Group__c : '';
                String DealerMapCode = opp.dealership__r.Dealer_Map_Code__c !=null ? opp.dealership__r.Dealer_Map_Code__c : '';
                String DealerLocation = opp.dealership__r.Dealer_Location__c !=null ? opp.dealership__r.Dealer_Location__c : '';
                String DMSEnquiryName = opp.DMS_Enquiry_Name__c != null ? opp.DMS_Enquiry_Name__c : '';
                String BookingNumber = opp.Booking_Number__c != null ? opp.Booking_Number__c : '';
                String Mobile = opp.Mobile__c != null ? opp.Mobile__c : '';
                String FirstName = opp.First_Name__c != null ? opp.First_Name__c :'';
                String MiddleName = opp.Middle_Name__c != null ? opp.Middle_Name__c : '';
                String LastName = opp.Last_Name__c != null ? opp.Last_Name__c : '';
                String PostBookingFeedback = opp.Post_Booking_Feedback__c != null ? opp.Post_Booking_Feedback__c : '';
                String BookingDate = opp.Booking_Date__c != null ? String.ValueOf(opp.Booking_Date__c) : '';
                String StageName = opp.StageName != null ? opp.StageName : '';
                
                //Passing the data into single string variable
                String rowString = Id + ',' + Channel +','+ StageName +','+ PostBookingFeedback +','+ BookingDate +','+ DMSEnquiryName +','+ BookingNumber +','+ Mobile +','+ FirstName +','+ MiddleName +','+ LastName +','+ ParentGroup +','+DealerMapCode + ',' +DealerLocation;
                
                //Fill map with defined Type
                if(csvRowValuesMap.containsKey(ConstantsUtility.Post_Booking_Feedback)){
                    list<string> templist = csvRowValuesMap.get(ConstantsUtility.Post_Booking_Feedback);
                    templist.add(rowString);
                    csvRowValuesMap.put(ConstantsUtility.Post_Booking_Feedback,templist);
                }
                else
                    csvRowValuesMap.put(ConstantsUtility.Post_Booking_Feedback , new list<string>{rowString}) ;
            }
        }
        //Condition check
        if(csvRowValuesMap.size()>0){
            //passing value to Column header
            csvColumnHeader = 'Id,Channel,StageName,PostBookingFeedback,BookingDate,DMSEnquiryName,BookingNumber,Mobile,FirstName,MiddleName,LastName,ParentGroup, DealerMapCode, DealerLocation\n';
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
    
    ////Method to convert the MC Communication data into .CSV format
    public static Map<string,blob> ConvertListToCSV(map<string,list<MC_Communication__c>> mapList){
        //Variable to defined Column header for CSV
        String csvColumnHeader;
        //Variable to defined URL_1__c if type is 'Send Brochure'
        String URL1 ;
        //Variable to defined URL if type is other than 'Send Brochure'
        String URL = '';
        //Map to store column row values for CSV
        map<string,list<string>> csvRowValuesMap = new map <string,list<string>>();
        //Map for storing the blob data for CSV
        map<string,blob> csvFiletoMail = new map<string,blob>();
        
        //Loop through keySet
        for(String Keys : mapList.Keyset()){
            if(mapList.containsKey(keys)){
               //loop through List of map
                for(MC_Communication__c forquote : mapList.get(keys)){
                    //Create data for CSV
                    string Id = forquote.id;
                    String Channel = forquote.Channel__c != null ? forquote.Channel__c : '' ;
                    String ParentGroup = forquote.Enquiry_MD__r.Dealership__r.Parent_Group__c !=null ? forquote.Enquiry_MD__r.Dealership__r.Parent_Group__c : '';
                    String DealerMapCode = forquote.Enquiry_MD__r.Dealership__r.Dealer_Map_Code__c !=null ? forquote.Enquiry_MD__r.Dealership__r.Dealer_Map_Code__c  : '';
                    String DealerLocation = forquote.Enquiry_MD__r.Dealership__r.Dealer_Location__c !=null ? forquote.Enquiry_MD__r.Dealership__r.Dealer_Location__c : '';
                    String DMSEnquiryName = forquote.Enquiry_MD__r.DMS_Enquiry_Name__c != null ? forquote.Enquiry_MD__r.DMS_Enquiry_Name__c : '';
                    String BookingNumber = forquote.Enquiry_MD__r.Booking_Number__c != null ? forquote.Enquiry_MD__r.Booking_Number__c : '';
                    String Typee = forquote.Type__c != null ? forquote.Type__c : '';
                    String Mobile = forquote.Enquiry_MD__r.Mobile__c != null ? forquote.Enquiry_MD__r.Mobile__c : '';
                    String FirstName = forquote.Enquiry_MD__r.First_Name__c != null ? forquote.Enquiry_MD__r.First_Name__c :'';
                    String MiddleName = forquote.Enquiry_MD__r.Middle_Name__c != null ? forquote.Enquiry_MD__r.Middle_Name__c : '';
                    String LastName = forquote.Enquiry_MD__r.Last_Name__c != null ? forquote.Enquiry_MD__r.Last_Name__c : '';
                    String CreatedDate = forquote.CreatedDate.format('M/d/yyyy h:mm:ss a z');
                    
                    String rowString = '';
                    //Check type if other than 'Send Brochure'
                    if(keys != ConstantsUtility.SEND_BROCHURE_METADATA){
                         URL = forquote.URL_1__c !=null ? forquote.URL_1__c : '';
                         //Passing the data into single string variable
                        rowString = Id + ',' + Channel +','+ Typee +','+ URL +','+ CreatedDate +','+ DMSEnquiryName +','+ BookingNumber +','+ Mobile +','+ FirstName +','+ MiddleName +','+ LastName +','+ ParentGroup +','+ DealerMapCode +','+ DealerLocation;
                    }
                    
                    
                    //Check type if 'Send Brochure'
                    if(keys == ConstantsUtility.SEND_BROCHURE_METADATA){
                        //Passing the data into single string variable
                        URL1 = forquote.URL_1__c != null ? forquote.URL_1__c : '';
                        rowString = Id + ',' + Channel +','+ Typee +','+ URL1 +','+ CreatedDate +','+ DMSEnquiryName +','+ BookingNumber +','+ Mobile +','+ FirstName +','+ MiddleName +','+ LastName +','+ ParentGroup +','+ DealerMapCode +','+ DealerLocation;
                        
                    }
                    
                    
                    //Condition check 
                    if(Typee != null){
                        //Fill map with defined Type
                        if(csvRowValuesMap.containsKey(Typee)){
                            list<string> templist = csvRowValuesMap.get(Typee);
                            templist.add(rowString);
                            csvRowValuesMap.put(Typee,templist);
                        }
                        else
                            csvRowValuesMap.put(Typee , new list<string>{rowString}) ;
                    }
                }
            }
        }
        
        //Condition check
        if(csvRowValuesMap.size()>0){
            //Variable to change column header if type is other than 'Send Brochure'
            String target = 'URL';
            //Varibale to change column header if type is 'Send Brochure'
            String replacement = 'General Field 2';
            //Define Column Header
            csvColumnHeader = 'Id, Channel,Type,URL,CreatedDate,DMSEnquiryName,BookingNumber,Mobile,FirstName,MiddleName,LastName, ParentGroup, DealerMapCode, DealerLocation\n';
            //Loop through String map
            for(String key : csvRowValuesMap.keySet()){
                //Check if type is 'Send Brouchure'
                if(key == ConstantsUtility.SEND_BROCHURE_METADATA)
                    //Replace Column header
                    csvColumnHeader = csvColumnHeader.replace(target, replacement);
                //Condition check
                if(csvRowValuesMap.containsKey(key)){
                    //Create CSV file format 
                    String csvFile = csvColumnHeader + String.join(csvRowValuesMap.get(key),'\n');
                    //Fill map with blob values for sending the mail
                    csvFiletoMail.put(key, blob.valueOf(csvFile));
                }
            }
        }
        return csvFiletoMail;
    }
}