/**
 * @File Name          : Msil_FpmIntegration.cls
 * @Author             : Rahul Sharma
 * @Group              : MSIL COE
 * @Discription        : Posting information to loan Status Portal.
**/
public with sharing class Msil_FpmIntegration{

    
@AuraEnabled
    public static enquiryWithLoanStatusWrapper getLoanStatusFromFMP(String oppId){
        string Status;
        if(oppId != null)
        {
            DateTime dt = system.now();
            String timenow = dt.format('HH:mm:ss'); 
            String dayOfWeek = dt.format('EEEE');
            List<FMP_Integration__c> fmpValues = FMP_Integration__c.getAll().values();
            String weekDays = fmpValues[0].Weekdays__c;
            List<String> Days = weekDays.split(',');    
            system.debug('dayOfWeek'+dayOfWeek+Days);
            if(Days.contains(dayOfWeek))
            {
                system.debug('timenow'+timenow+fmpValues[0].Start_Time__c+fmpValues[0].End_Time__c);
                if(timenow >= fmpValues[0].Start_Time__c && timenow <= fmpValues[0].End_Time__c)
                {
                    Opportunity opp = [SELECT id,DMS_Enquiry_Name__c,Dealership__r.Dealer_Code__c,Dealership__r.For_Code__r.For_Code__c,Owner.Channel__c
                                        from Opportunity where id=:oppId];
                    system.debug('opp details' +opp.DMS_Enquiry_Name__c + opp.Dealership__r.Dealer_Code__c + opp.Dealership__r.For_Code__r.For_Code__c+opp.Owner.Channel__c);
                    if(opp.Owner.Channel__c == 'Nexa')
                    {
                        if(opp.DMS_Enquiry_Name__c != null && opp.Dealership__r.Dealer_Code__c != null && opp.Dealership__r.For_Code__r.For_Code__c != null)        
                        {
                            JSONGenerator gen = JSON.createGenerator(true);
                            gen.writeStartObject();
                            //Enquiry Number
                            gen.writeStringField('dms_lead_id',opp.DMS_Enquiry_Name__c);
                            //Dealer Code
                            gen.writeStringField('dealer',opp.Dealership__r.Dealer_Code__c);
                            //Dealer Code
                            gen.writeStringField('dealer_for_code',opp.Dealership__r.For_Code__r.For_Code__c);
                            gen.writeEndObject();
                            String strBody = gen.getAsString();  
                            system.debug('janrain strBody '+ strBody);  
                            
                            Http http = new Http();
                            HttpRequest request = new HttpRequest();
                            request.setEndpoint('callout:FMPIntegrate');
                            request.setMethod('POST');
                            request.setHeader('Content-Type', 'application/json');
                            request.setBody(strBody);
                            HttpResponse response = http.send(request); 
                            String strResponse = response.getBody();
                            system.debug('***strResponse :'+strResponse );
                            System.debug('Received the following response : '+response );
                            
                            fmpResponseWrapper authCodeResponse = (fmpResponseWrapper)JSON.deserialize(strResponse ,fmpResponseWrapper.class);      
                            System.debug('Received the following response : '+authCodeResponse );
                            List<loanStatusWrapper> loanWrap = authCodeResponse.loan_status;
                            if(authCodeResponse.status == 'Success')
                            {
                                if(loanWrap != null)
                                {
                                   status = (loanWrap.get(loanWrap.size() - 1)).status;
                                   string actionTime1 = (loanWrap.get(loanWrap.size() - 1)).last_updated_status_at;                                        
                                   enquiryWithLoanStatusWrapper wrap = new enquiryWithLoanStatusWrapper(opp.DMS_Enquiry_Name__c,opp.Dealership__r.Dealer_Code__c,opp.Dealership__r.For_Code__r.For_Code__c,status,actionTime1);
                                    system.debug('wrappper '+wrap);
                                    return wrap;
                                }
                                else
                                {
                                    status = authCodeResponse.message;
                                    enquiryWithLoanStatusWrapper wrap = new enquiryWithLoanStatusWrapper(opp.DMS_Enquiry_Name__c,opp.Dealership__r.Dealer_Code__c,opp.Dealership__r.For_Code__r.For_Code__c,status,null);
                                    system.debug('wrappper '+wrap);
                                    return wrap;
                                }
                            }
                            else
                            {
                                status = ConstantsUtility.fmpError1;
                                enquiryWithLoanStatusWrapper wrap = new enquiryWithLoanStatusWrapper(opp.DMS_Enquiry_Name__c,opp.Dealership__r.Dealer_Code__c,opp.Dealership__r.For_Code__r.For_Code__c,status,null);
                                return wrap;
                            }
                            
                        }                       
                        else
                        {
                            status = ConstantsUtility.fmpError3;
                            enquiryWithLoanStatusWrapper wrap = new enquiryWithLoanStatusWrapper(null,null,null,status,null);
                            return wrap;
                        }
                    }
                    else
                    {
                        status = ConstantsUtility.fmpError2;
                        enquiryWithLoanStatusWrapper wrap = new enquiryWithLoanStatusWrapper(null,null,null,status,null);
                        return wrap;
                    }  
                }
                else
                {
                    status = ConstantsUtility.fmpError4;
                    enquiryWithLoanStatusWrapper wrap = new enquiryWithLoanStatusWrapper(null,null,null,status,null);
                    return wrap;
                }
            }
            else
            {
                status = ConstantsUtility.fmpError4;
                enquiryWithLoanStatusWrapper wrap = new enquiryWithLoanStatusWrapper(null,null,null,status,null);
                return wrap;
            }
        
        }
        else{
        status = ConstantsUtility.fmpError1;
        enquiryWithLoanStatusWrapper wrap = new enquiryWithLoanStatusWrapper(null,null,null,status,null);
        return wrap;
        }
    }
  
    //Wrapper for returning values to LWC of loan status @Rahul Sharma
    public class enquiryWithLoanStatusWrapper{
        @AuraEnabled
        public string enqNo;
        
        @AuraEnabled
        public string dealerCode;
        
        @AuraEnabled
        public string dealerForCode;
        
        @AuraEnabled
        public string loanStatus;
        
        @AuraEnabled
        public string actionTime;
        
        public enquiryWithLoanStatusWrapper(String enqNumber,String dealerCode,String dealerForCode,String loanStatus,string actionTime){
            this.enqNo = enqNumber;
            this.dealerCode = dealerCode;
            this.dealerForCode = dealerForCode;
            this.loanStatus = loanStatus;
            this.actionTime = actionTime;
        }
        
    }
    
    //Wrapper to deserialize values recived from FMP server @Rahul Sharma
    public class fmpResponseWrapper{
        
        public string status;
        
        public string message;
        
        public List<loanStatusWrapper> loan_status;
        
        public fmpResponseWrapper(String status,String message,List<loanStatusWrapper> loan_status){
            this.status = status;
            this.message = message;
            this.loan_status= loan_status;
            
        }
        
    }
    
    //Wrapper to deserialize values recived from FMP server @Rahul Sharma
    public class loanStatusWrapper{
        
        public string status;
        
        public string financier;
        
        public string last_updated_status_at;
               
        
        public loanStatusWrapper(String status,String financier,string last_updated_status_at){
            this.status = status;
            this.financier = financier;
            this.last_updated_status_at= last_updated_status_at;
            
        }
        
    }
}