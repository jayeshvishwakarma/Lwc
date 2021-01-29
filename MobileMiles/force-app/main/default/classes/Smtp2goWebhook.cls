/*
    Name    : Smtp2goWebhook
*/
@RestResource(urlMapping='/Smtp2goWebhook')
global without sharing class Smtp2goWebhook{

    @HttpPost
    global static void receivePOST() {
        try{
            Map<String,String> requestParams = RestContext.request.params;
            String readSeconds = requestParams.get('read-secs');
            String subjectStr = requestParams.get('Subject');
            String description = '';
            
            String[] subjectParts = subjectStr.split(' ');
            System.debug('@@## params.subjectParts ' + subjectParts);
            
            String quoteNumber = subjectParts[subjectParts.size()-1];
            
            Quote quote = [Select id from Quote where QuoteNumber =: quoteNumber];
            
            Task tk = new Task(WhatId = quote.Id, 
                                Subject = subjectStr, 
                                description = description, 
                                Type = 'Email',
                                Status = 'Voltooid',
                                Open_DateTime__c = convertTimezoneToUserTimzone(requestParams.get('time')),
                                Sender__c = requestParams.get('sender'),
                                Recipient__c= requestParams.get('rcpt'),
                                Read_Seconds__c = requestParams.get('read-secs'));
            INSERT tk;
            
            
        }catch(Exception e){
            //Not a valid Quote Found.
        }
    }
    //This is used to convert another time zone to user time  zone
    public static Datetime convertTimezoneToUserTimzone(String dateTimezoneToConvert){
        String dateTimeZone = dateTimezoneToConvert;
        //String  convertedTime;
        if(dateTimeZone != null){
            String[] dt =  dateTimeZone.split('T');
            String[] dateToConvert  = dt[0].split('-');
            Integer year = integer.valueOf(dateToConvert[0]);
            Integer month = integer.valueOf(dateToConvert[1]);
            Integer day = integer.valueOf(dateToConvert[2]);
            String[] timeToConvert = dt[1].split(':');
        
            Integer hour =  integer.valueOf(timeToConvert[0]);
            Integer minute = integer.valueOf(timeToConvert[1]);
            Integer second = integer.valueOf(timeToConvert[2].removeEnd('Z'));
            
            Datetime newDate = Datetime.newInstance(year, month,day, hour, minute, second);
            //convertedTime = string.valueOfGmt(newDate);
            // return convertedTime;
            return newDate ;
            
        }
        return null;
    }
    
}