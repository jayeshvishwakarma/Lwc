/**
* @File Name          : SysPerfVehicleEnquiryDeliveryChecklist.cls
* @Description        : This class will create a performance log Vehicle Enquiry  DeliveryChecklist Process.
* @Author             : 
* @Group              :  
* @Last Modified By   : Ravi Gupta
* @Last Modified On   : 28th Nov 2019
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author      		      Modification
*==============================================================================
* 1.0    28/11/2019,       			Ravi Gupta    			  Initial Version
**/
Public class SysPerfVehicleEnquiryDeliveryChecklist implements HandlerInterface{
    
    public static void ProcessData(){
        Performance_Logger__c pLog = new Performance_Logger__c();
        Savepoint sp = Database.setSavepoint();
        // defining list of person account
        List<Account> personAccList = UtilityClass.createPersonAccount(1);
        // creating person account for the Enquiry
        insert personAccList;
        // defining list of Business account
        List<Account> BusinessList = UtilityClass.createBusinessAccount(1);
        // creating business account
        insert BusinessList;
        // getting Id of the enquiry vehicle
        List<Opportunity> oppList = UtilityClass.createEnquiryAccessories(personAccList[0].Id,BusinessList[0].Id,1);
        insert oppList;
        // fetching the JSON string to pass
        string Data = UtilityClass.getJsonString();
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
            String response = GenerateDeliveryChecklistController.saveSurveyResponse(oppList[0].Id,Data,ConstantsUtility.BTN_LABEL_CONST);
            
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
        Performance__mdt prfm = UtilityClass.fetchMetadata('Vehicle_Enquiry_Delivery_Checklist');
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