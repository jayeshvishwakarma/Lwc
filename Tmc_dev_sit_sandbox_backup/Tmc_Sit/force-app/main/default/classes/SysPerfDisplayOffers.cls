/**
* @File Name          : SysPerfDisplayOffers.cls
* @Description        : This class will create a performance log for Load Offer in quotaion.
* @Author             : 
* @Group              : 
* @Last Modified By   : Ravi Gupta
* @Last Modified On   : 21th Oct 2019
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    21/09/2019,                Ravi Gupta                Initial Version
**/
Public class SysPerfDisplayOffers implements HandlerInterface{
    public static void ProcessData(){
        Performance_Logger__c pLog = new Performance_Logger__c();
        Savepoint sp = Database.setSavepoint(); 
        // defining list of standard PriceBook 
        List<Pricebook2> StdPriceList = UtilityClass.createPriceBook();
        // defining list of person account
        List<Account> personAccList = UtilityClass.createPersonAccount(1);
        // creating person account for the Enquiry
        insert personAccList;
        // defining list of for code
        List<For_Code__c> forCodeList = UtilityClass.createforCode(1);
        // creating for code
        insert forCodeList;
        // defining list of Business account
        List<Account> BusinessList = UtilityClass.createBusinessAccountForCode(1,forCodeList[0].Id);
        // creating business account
        insert BusinessList;
        //Contacts Creation 
        List<Contact> conList = TestDataFactory.createTestContact(1, BusinessList[0].Id);
        conList[0].FirstName = 'abc';
        conList[0].LastName = 'abc';
        conList[0].MiddleName = 'abc';
        conList[0].Title = 'Mr.';
        conList[0].IsEvaluator__c = true;
		conList[0].Is_eval_contact__c = true;
        conList[0].MobilePhone = '9747453765';
        insert conList;
        // creating the variant record type 
        List<Product2> proVariantList = UtilityClass.createProduct(1);
        insert proVariantList;
         // defining list of Product
        List<Product2> ProList = UtilityClass.createOfferProduct(1);
        // creating Product
        insert ProList;
         // creating the record of color variant
        List<Color_Variant_Master__c> colorVariantList = UtilityClass.createColorVariant(1,proVariantList[0].Id);
        insert colorVariantList;
        // getting Id of the enquiry vehicle
        List<Opportunity> oppList = UtilityClass.createEnquiryOffer(personAccList[0].Id,BusinessList[0].Id,colorVariantList[0].Id,proVariantList[0].Id,1,conList[0].id);
        insert oppList;
        // creating the Price master
        List<Price_Master__c> priceList = UtilityClass.createPriceMaster(proVariantList[0].Id,1);
        insert priceList;
        // creating the pricebook entry record
        List<PriceBookEntry> priceEntryList = UtilityClass.createPriceBookEntry(ProList[0].Id,StdPriceList[0].Id,1);
        insert priceEntryList;
        // creating the opportunity Line item
       // List<OpportunityLineItem> oppLineList = UtilityClass.createOppLineItem(ProList[0].Id,oppList[0].Id,priceEntryList[0].Id,1);
        //insert oppLineList;
        
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
           
            
            // defining the after time of enquiry creation
            decimal timeAfter = Datetime.now().getTime();
            OfferSchemeCalcSrvc.retriveExchangeBonus(oppList[0].Id,'Opportunity');
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
        Performance__mdt prfm = UtilityClass.fetchMetadata('Vehicle_Enquiry_Display_Offers');
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