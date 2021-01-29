public with sharing class twod_PaymentSummaryCtl {

    public PageReference cancel() {
        PageReference returnPage = new PageReference(ApexPages.currentPage().getParameters().get('retURL')); 
        return returnPage;
    }
    
    public List<paymentWrapper> PaymentList {get; set;}
    public String claimId {get;set;}
    public Integer summaryLength {get;set;}
    public String claimStatus {get;set;}
    public boolean isCAD {get;set;}    
    
    public twod_PaymentSummaryCtl() {
        twod__Claim__c cli = new twod__Claim__c();
        claimId = apexPages.currentPage().getParameters().get('retURL');
        if(claimId != null && claimId !='/a06/o' ){
            
            claimId = claimId.substring(1,16);
            
        }
        claimStatus = [Select twod__Claim_Status__c from twod__Claim__c where Id=:claimId].twod__Claim_Status__c ;   
        //paymentList = new List<Payment__c>();
   
    }
   
    public List<paymentWrapper> getPaymentInfo() {
        if(PaymentList == null) {
            PaymentList = new List<paymentWrapper>();
            //CT Multi currency changes
            for(Payment__c c: [SELECT Sent_To_SAP__c, Approval_Status__c, Approved__c, Order_Type__c, Check_Date__c,Check_Number__c,Claim__c,Division_Code__c,Id,Name,Order_Number__c,Order_Reason__c,Paid_Y_N__c,Payment_Type__c,Plant_Code__c,
                  RecordTypeId,Released_To_SAP__c,SAP_Accounts__c,Sequence_Number__c,Settlement_Type__c,Shipping_Condition__c,Ship_Credit_Debit_Date__c,Ship_To__c,
                  Sold_To__c,Total_Cost__c,Total_Amount__C,Total_Amount_Converted__c,Void_Payment__c,Sales_Org__c,Currency__c FROM Payment__c Where Claim__c =: claimId ORDER BY CreatedDate DESC]) {
                
                PaymentList.add(new paymentWrapper(c));
                
            }
            summaryLength=PaymentList.size();
            
            if((PaymentList[0].pay.Currency__c == 'CAD') && (PaymentList[0].pay.Sales_Org__c == '1102')) {
                isCAD = true;
            } else {
                isCAD = false;
            }
        }
        return PaymentList;
    }


    public class customException extends Exception{} 
    
   @RemoteAction
   
    public static String processSelected(List<String> realeaseToSapIds){
        String returnMsg ='';
        List<Payment__c> PaymentSapList = new List<Payment__c>();
        Map<Id,Payment__c> selectedonHold = new map<Id,Payment__c>();
        List<SAP_Log__c> logs = new List<SAP_Log__c>();
        
        for(Payment__c c: [SELECT Sent_To_SAP__c,  Approved__c,Check_Date__c,Check_Number__c,Claim__c,Division_Code__c,Id,Name,Order_Number__c,Order_Reason__c,Paid_Y_N__c,Payment_Type__c,Plant_Code__c,
                  RecordTypeId,Released_To_SAP__c,SAP_Accounts__c,Sequence_Number__c,Settlement_Type__c,Shipping_Condition__c,Ship_Credit_Debit_Date__c,Ship_To__c,
                  Sold_To__c,Total_Cost__c,Total_Amount__C,Void_Payment__c, Claim__r.isClassAction__c, Claim__r.Country_BL__c, Currency__c, Sales_Org__c, Total_Amount_Converted__c
                           FROM Payment__c Where Id =: realeaseToSapIds And Released_To_SAP__c =false AND Payment_Type__c != 'Gelco']) {
                  
            PaymentSapList.add(c);
       }
        /*if(PaymentSapList[0].Claim__r.Country_BL__c =='Canada'){
            throw new customException('Cannot release Canadian payment to SAP until further notice.');  
        }*/
        
        //Allowing only 10 packages to be relased to SAP 
        if(PaymentSapList.size()> 10){
            throw new customException('Maximum of 10 packages can be released to SAP');
        }
        if(PaymentSapList.size()> 10){
            throw new customException('Maximum of 10 packages can be released to SAP');
        }
                   
        for(Payment__c pPay :PaymentSapList){
            
            
            if(pPay.Approved__c == true) {
                //Added check to ensure that if Country = CA and currency!= CAD, then dont process further
                if(pPay.Claim__r.Country_BL__c == 'Canada' && pPay.Currency__c != 'CAD' && pPay.Claim__r.isClassAction__c == false){
                    throw new customException('Currency for all Canadian payment needs to be CAD to be released to SAP');
                }
                if((pPay.Payment_Type__c == 'Free Material' || pPay.Payment_Type__c == 'Credit/Debit') && pPay.Released_To_SAP__c == false){
                    if(pPay.Payment_Type__c == 'Credit/Debit' && ValidateCreditDebitReleaseDays()){
                        //if(pPay.Payment_Type__c == 'Credit/Debit' && ((String.valueof(system.today())>='2017-08-01') && (String.valueof(system.today())<'2017-08-03'))){
                        throw new customException('Credit and Debit payments cannot be released to SAP during the first 2 business days of the month');
                    }else{
                        
                        try{
                            SAP_Log__c log = twod_PaymentManager.SendOrderToSAP(pPay.Id);
                            if(!log.Has_Error__c){
                                pPay.Released_To_SAP__c = true;
                                pPay.Order_Number__c = log.Response__c;
                                pPay.Ship_Credit_Debit_Date__c = string.valueof(date.today().format());
                                pPay.Sent_To_SAP__C = 'Success';                            
                            }else{
                                pPay.Sent_To_SAP__C = 'Failed ';
                            }
                            logs.add(log);
                            returnMsg = 'Processed';
                        }catch(Exception e){
                            system.debug('Error'+e.getStackTraceString());
                            pPay.Sent_To_SAP__c = 'Failed ';
                        }
                    }
                    //selectedonHold.add(pPay.pay);
                    selectedonHold.put(pPay.Id, pPay);
                }else if(pPay.Released_To_SAP__c == false && pPay.Payment_Type__c != 'Gelco'){
                    if(pPay.Payment_Type__c == 'Check' && pPay.SAP_Accounts__c == null){
                        throw new customException('Ensure that all check payments have associated GL Account/Profit Center details');
                    }
                    //Added condition to ensure all check payments have currency, sales org, total amount(USD/CAD) populated
                    else if(pPay.Payment_Type__c == 'Check' && 
                            (pPay.Currency__c == null || pPay.Sales_Org__c == null || pPay.Total_Amount_Converted__c == null)){
                                throw new customException('Ensure that all check payments have Currency, Sales Org and Total Amount (USD/CAD) populated');
                            }
                    else{
                        pPay.Released_To_SAP__c = true;
                        pPay.Sent_To_SAP__C = 'Success';
                        //selectedonHold.add(pPay.pay);
                        selectedonHold.put(pPay.Id, pPay);
                        returnMsg = 'Processed';
                    }
                }
                
            }
        
        }   
        insert logs;
       
        FOR(SAP_Log__c log: logs){
            Payment__c wrapper = selectedonHold.get(log.payment_id__c);
            if(wrapper != null){
                system.debug('PPP'+wrapper.Sent_To_SAP__c + log.Id);
                wrapper.Sent_To_SAP__c =wrapper.Sent_To_SAP__c + log.Id;
            }
        }
        update selectedonHold.values();
        
        PaymentSapList=null;
        return returnMsg;
    }

    public static Boolean ValidateCreditDebitReleaseDays(){  
     Boolean inValidReleaseDate = false;
        string todaysmonth = String.valueof(System.today().month());
        if(todaysmonth.length() == 1){
            todaysmonth = '0' + todaysmonth;
        }
        string todaysyear = String.valueof(System.today().year());
        system.debug('todaysmonth is ' + todaysmonth);
        system.debug('todaysyear is ' + todaysyear);
        Integer firstdate;
        List<CreditDebit_Release_Day__c> alldates = [select Id,Date__c from CreditDebit_Release_Day__c where Year__c= :todaysyear and Month__c =:todaysmonth ORDER by Date__c desc];
        if(alldates.size() > 0){
            firstdate = Integer.valueOf(alldates[0].Date__c);
        }
        else{
             throw new customException('Credit and Debit business days not defined. Please contact Warranty Admin team');
        }
        if((System.today().day()) < firstdate){
            inValidReleaseDate = true;
        }
     return inValidReleaseDate;
    }
  
     
   
 @RemoteAction
   
  public static String queueForApprovalSelected(Id claimId,List<String> queueApprovalIds){
    
    String retMsg ='';
    List<twod__Claim__c> tempList = new List<twod__Claim__c>();
    List<Payment__c> toUpdate = new List<Payment__c>();
    tempList = [SELECT Id,Approval_Status__c FROM twod__Claim__c Where Id =: claimId AND Approval_Status__c = 'Initiated']; 
        if(tempList.size()==0){
        for(Payment__c pay:[Select name,Id,Approval_Status__c,Payment_Type__c FROM Payment__c where Id =:queueApprovalIds]){
                List<Payment_Line__c> payList= [select Id,name from Payment_Line__c where payment__c =:pay.id];  
                if(pay.Approval_Status__c!='Approved' && payList.size()>0 && pay.Payment_Type__c !='Gelco'){
                pay.Approval_Status__c ='Queued For Approval';
                toUpdate.add(pay);
            }
            else{
              if(pay.Approval_Status__c!='Approved' && pay.Payment_Type__c !='Gelco'){
                  retMsg +=pay.name+'\n';
                }
                
             }
             if(pay.Payment_Type__c =='Gelco'){
                   pay.Approval_Status__c ='Queued For Approval';
                   toUpdate.add(pay);
             }
          }
        }
        else{
          retMsg ='Initiated';
        }
        
        if(retMsg =='' || retMsg==null){
           update toUpdate;
           retMsg ='Success';
        }
     
     return retMsg;
    }

  
    public class paymentWrapper {
        public Payment__c pay {get; set;}
        public Boolean selected {get; set;}

        //This is the contructor method.
        public paymentWrapper(Payment__c p) {
            pay = p;
            selected = false;
        }
    }
}