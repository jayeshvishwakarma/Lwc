/**
* @File Name          : SysPerfTestDriveSubmitFeedback.cls
* @Description        : This class will create a performance log for Vehicle Enquiry.
* @Author             : 
* @Group              : 
* @Last Modified By   : Saifullah Saifi

* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    17/09/2019,                Ravi Gupta                Initial Version
**/
Public class SysPerfTestDriveSubmitFeedback implements HandlerInterface{
    
    
    public static void ProcessData(){
        
        Performance_Logger__c pLog = new Performance_Logger__c();
        Savepoint sp = Database.setSavepoint();  
        // defining list of person account
        List<Account> personAccList = UtilityClass.createPersonAccount(1);
        // creating person account for the Enquiry
        insert personAccList;
        // defining list of Business account
        List<Account> BusinessList = new List<Account>();
        List<Account> BusinessLi = UtilityClass.createBusinessAccount(1);
        for(Account acc:BusinessLi){
            acc.TSM_MGA__c=UserInfo.getUserId();
            acc.TSM_ISL__c=UserInfo.getUserId();
            acc.TSM_Rural__c=UserInfo.getUserId();
            BusinessList.add(acc);
        }
        // creating business account
        insert BusinessList;
        // creating the Vehicle enquiry
        List<Opportunity> oppList = UtilityClass.createEnquiryVehicle(personAccList[0].Id,BusinessList[0].Id,1);
        insert oppList; 
        // creating the Survey record
        List<Survey__c> surveyList = UtilityClass.fetchSurvey();
        
        List<SurveyTaker__c> surveyTakenList = UtilityClass.CreateSurveyTaken(oppList[0].Id,surveyList[0].Id,personAccList[0].Id,BusinessList[0].Id,1);
        //inserting  the Survey Taken
        insert surveyTakenList;
        // fetching the list of Survey Questions
        List<Survey_Question__c> surveyQuestionList = UtilityClass.fetchSurveyQuestion();
        //fetching the list of Survey Response
        List<SurveyQuestionResponse__c> surveyResponse = UtilityClass.CreateSurveyRespnse(surveyTakenList[0].Id,surveyQuestionList); 
        // inserting the Record Of Survey Response
        insert surveyResponse;
        
        
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
            //fetching the list of Survey Response
            List<SurveyQuestionResponse__c> newsurveyResponse = UtilityClass.updateSurveyRespnse(surveyTakenList[0].Id,surveyResponse); 
            // Updating the ssurvey Response
            update newsurveyResponse;
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
        Performance__mdt prfm = UtilityClass.fetchMetadata('Test_Drive_Submit_Feedback');
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