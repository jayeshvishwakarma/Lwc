/**
* @File Name          : SysPerfUpdateQuote.cls
* @Description        : This class will create a performance log for Vehicle Enquiry.
* @Author             : 
* @Group              : 
* @Last Modified By   : Saifullah Saifi
* @Last Modified On   : 08th Oct 2019
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author      		      Modification
*==============================================================================
* 1.0    04/09/2019,       			Ravi Gupta    			  Initial Version
**/
Public class SysPerfUpdateQuote implements HandlerInterface{
    
    
    public static void ProcessData(){
        Performance_Logger__c pLog = new Performance_Logger__c();
        Savepoint sp = Database.setSavepoint();  
        // defining list of Product
        List<Product2> ProList = UtilityClass.createProduct(1);
        // creating Product
        insert ProList;
        // defining list of standard PriceBook 
        List<Pricebook2> StdPriceList = UtilityClass.createPriceBook();
        // defining list of person account
        List<Account> personAccList = UtilityClass.createPersonAccount(1);
        // creating person account for the Enquiry
        insert personAccList;
        // defining list of Business account
        List<Account> BusinessList = UtilityClass.createBusinessAccount(1);
        // creating business account
        insert BusinessList;
        // getting Id of the enquiry vehicle
        List<Opportunity> oppList = UtilityClass.createEnquiryVehicle(personAccList[0].Id,BusinessList[0].Id,1);
        oppList[0].Description='SysPerfUpdateQuote';
        insert oppList; 
        // creating the pricebook entry record
        List<PriceBookEntry> priceEntryList = UtilityClass.createPriceBookEntry(ProList[0].Id,StdPriceList[0].Id,1);
        insert priceEntryList;
        //string value='01s7F00000BI0N7QAL';
        
        system.debug('===='+priceEntryList[0].Id);
        // creating the Opp LIne Item
        List<OpportunityLineItem> oppLineList = UtilityClass.createOppLineItem(ProList[0].Id,oppList[0].Id,priceEntryList[0].Id,1);
        insert oppLineList;
        
        // CReating the quote
        List<Quote> QuoteList = UtilityClass.createQuote(oppList[0].Id,1);
        insert QuoteList;
        // storing the maximum limit for the loop to execute from custom label 
        integer maxLimit=integer.valueOf(System.Label.Maximum_Limit);
        //limit before
        UtilityClass.tempWrap lw =UtilityClass.LimitInitmthod();
        Decimal totTime =0; 
        for(Integer i=1; i<=maxLimit; i++){
            //ith Run
            decimal  timeBefore = Datetime.now().getTime();
            // defining the before time of enquiry creation
            timeBefore = Datetime.now().getTime();
            List<Opportunity> UpdateQuoteList = UtilityClass.synchQuote(oppList[0].Id,QuoteList[0].Id);
            // Update the Quote
            Update UpdateQuoteList;  
            // defining the after time of enquiry creation
            decimal timeAfter = Datetime.now().getTime();
            system.debug(timeBefore+'>>>'+timeAfter);
            // defining the actual time for the Enquiry creation  
            decimal tim= timeAfter - timeBefore;
            pLog.put('Run_'+i+'__c',tim);
            totTime+=tim;
        }
        //limit after
        UtilityClass.tempWrap lw1 =UtilityClass.LimitInitmthod();
        Database.rollback(sp);
        //avg
        pLog.Average_Run_Time__c = (totTime)/maxLimit;
        Performance__mdt prfm = UtilityClass.fetchMetadata('Vehicle_Enquiry_Sync_quote_to_opportun');
        plog.Use_Case__c = prfm.MasterLabel;
        plog.Category__c= prfm.Category__c;
        Map<string,Integer> limitMap = UtilityClass.calculateLimit(lw,lw1,maxLimit);
        system.debug('>>>'+limitMap);
        for(string ky : limitMap.keySet()){
            plog.put(ky+'__c',limitMap.get(ky));
        }
        insert pLog;	
    }
    
}