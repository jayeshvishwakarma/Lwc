/**
 * @File Name          : MSIL_CdcCountOverMail.cls
 * @Description        : This utility class is to show the hourlypackage platform events for limits
 * @Author             : Satish Kumar
 * @Group              : Maruti
 * @Last Modified By   : 
 * @Last Modified On   : 
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 
 */ 

public class MSIL_CdcCountOverMail {
            public static final String environmentURL = URL.getSalesforceBaseUrl().toExternalForm() +System.Label.MSIL_HourlyPublishEvent;
            public Static Integer OverallCount =0;
            public static Integer max;
            public static Integer usage;
            public static Integer remaining;
            public static Integer reductionLimit;
            public static Integer OverAllSum=0;
            public static  HttpRequest request;
            public static  HttpResponse response;
            public static  Http http;
    
    @future(callout=true)
    public static void getCDCData(DateTime customTime){
            http = new Http();
            request = new HttpRequest();
            request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            request.setHeader('Content-Type', 'application/json');
            request.setEndpoint(environmentURL );
            request.setMethod('GET');
             System.debug('request:='+request);
            response = http.send(request);
            System.debug('response:='+response);
            parseJson(response,customTime);
            
    }
    
    public static void parseJson(HttpResponse response,DateTime customTime){
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody()); 
            Map<String,Object> responseObj= (Map<String,Object>)results.get(system.label.msil_eventname);
            max= (Integer) responseObj.get('Max');
            remaining= (Integer) responseObj.get('Remaining');
            reductionLimit=max-remaining;
            System.debug('reductionlimit:='+reductionLimit);
            insertCDCLimitField(reductionLimit,customTime,max);
    }
    /*public static void parseJson2(DateTime customTime){
            Map<String,System.OrgLimit> limitsMap = OrgLimits.getMap();
            System.OrgLimit aLimit = limitsMap.get(system.label.msil_eventname);
            usage = aLimit.getValue();
            insertCDCLimitField(usage,customTime);
    }*/
    

    public static void insertCDCLimitField(Integer usageTotal,DateTime customTime,Integer max){
         try{
            if(customTime!=null){
                List<CDC_Limit__c> cdcList=[SELECT Hourly_CDC_Consume_limit__c,Usage_Till_Now__c FROM CDC_Limit__c
                                            where BackupCustomDate__c =: customTime 
                                            order by CreatedDate desc limit 1];
                if(cdcList.IsEmpty())
                {
                    CDC_Limit__c cdc = new CDC_Limit__c(Hourly_CDC_Consume_limit__c = 0,Usage_Till_Now__c=usageTotal,BackupCustomDate__c=customTime);
                    insert cdc;
                    OveraAllCountALert(customTime,max);
                }
                else
                {
                    CDC_Limit__c cdc = new CDC_Limit__c();
                    cdc.Hourly_CDC_Consume_limit__c = usageTotal - cdcList[0].Usage_Till_Now__c;
                    cdc.Usage_Till_Now__c = usageTotal;
                    cdc.BackupCustomDate__c = customTime;
                    insert cdc;
                    OveraAllCountALert(customTime,max);
                }
               }
            }catch(Exception e){
                System.debug('cdcList fields that affected this error: ' + e);
            }
       
    }
    
    public static void OveraAllCountALert(DateTime customTime,Integer max ){
       
        List<CDC_Limit__c> cdcList=[SELECT Hourly_CDC_Consume_limit__c FROM CDC_Limit__c where BackupCustomDate__c =: customTime and Hourly_CDC_Consume_limit__c != null];
        for(CDC_Limit__c cdc:cdcList){
            OverallCount +=Integer.ValueOf(cdc.Hourly_CDC_Consume_limit__c) ;
        }
        sendEMailALert(OverallCount,max);
    }
    
     public static void sendEMailALert(Integer cdcCOunt,Integer max){
            Integer dailyUpperLimit=max/30;
            Messaging.SingleEmailMessage  email = new Messaging.SingleEmailMessage ();
            List<String> listofAddresses = Label.email_list != Null ? Label.email_list.split(',') : new List<string>();
            email.setToAddresses(listofAddresses);
            email.setSubject( 'CDC Consumption Alert');
            email.setPlainTextBody('Hi All, \n\n Out of Maximum CDC limit - '+dailyUpperLimit+', we have consumed:-'+cdcCOunt+' CDC limit \n\n Regards,\n SF Admin');    
            Messaging.SingleEmailMessage [] messages =   new List<Messaging.SingleEmailMessage > {email};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
}