/**
* @File Name          : SysPerfTestDriveCreate.cls
* @Description        : This class will create a performance log for Vehicle Enquiry.
* @Author             : 
* @Group              :  
* @Last Modified By   : Saifullah Saifi
* @Last Modified On   : 08th Oct 2019
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    04/09/2019,                Ravi Gupta                Initial Version
**/
Public class SysPerfTestDriveCreate implements HandlerInterface{
    
    
    public static void ProcessData(){
    
        
        Performance_Logger__c pLog = new Performance_Logger__c(); 
        // storing the maximum limit for the loop to execute from custom label 
        integer maxLimit=integer.valueOf(System.Label.Maximum_Limit);
        // defining map to store time 
        Map<integer,Decimal> mapToTime = new Map<integer,decimal>();
        
        
        /*
* fetchDateTime method calls Api and fetch time slot 
* is written here to avoid savepoint issue coming due API call
*
*/
        // defining booking Id
        string BookId;
        List<UtilityClass.wrapperDateTime> wrpDate = new List<UtilityClass.wrapperDateTime>();
        for(Integer i=1; i<=maxLimit; i++){
            
             
            // before time
            decimal  timeBeforeFetchSlot = Datetime.now().getTime();
          wrpDate=UtilityClass.fetchDateTime(); 
            BookId=string.valueOf(Datetime.now().getTime());//UtilityClass.saveTimeSlot();
            // after time 
            decimal timeAfterFetchSlot = Datetime.now().getTime();
            decimal timeFetcSlot= timeAfterFetchSlot - timeBeforeFetchSlot;
            mapToTime.put(i,timeFetcSlot);
        }
        Savepoint sp = Database.setSavepoint();
        // defining list of person account
        List<Account> personAccList = UtilityClass.createPersonAccount(1);
        // creating person account for the Enquiry
        insert personAccList;
        // defining list of Business account
        List<Account> BusinessList = UtilityClass.createBusinessAccount(1);
        // creating business account
        insert BusinessList;
        // creating the Vehicle enquiry
        List<Opportunity> oppList = UtilityClass.createEnquiryVehicle(personAccList[0].Id,BusinessList[0].Id,1);
        insert oppList; 
        // creating the Asset record
        List<Asset> astList = UtilityClass.createAssets(personAccList[0].Id,1);
        insert astList;
        
        
        //limit before
        UtilityClass.tempWrap lw =UtilityClass.LimitInitmthod();
        Decimal totTime =0; 
        for(Integer i=1; i<=maxLimit; i++){
            //ith Run
            decimal  timeBefore = Datetime.now().getTime();
            // defining the before time of enquiry creation
            List<Test_Drive__c> testDriveList = UtilityClass.createTestDrive(i,oppList[0].Id,astList[0].Id,1,BookId,wrpDate[0].StartbookDate,wrpDate[0].EndbookDate);
            // Creating  the test drive
            insert testDriveList; 
            // defining the after time of enquiry creation
            decimal timeAfter = Datetime.now().getTime();
            system.debug(timeBefore+'>>>'+timeAfter);
            // defining the actual time for the Enquiry creation  
            decimal tim= timeAfter - timeBefore;
            pLog.put('Run_'+i+'__c',tim += mapToTime.get(i));
            totTime+=tim;
        }
        //limit after
        UtilityClass.tempWrap lw1 =UtilityClass.LimitInitmthod();
        Database.rollback(sp);
        //avg
        pLog.Average_Run_Time__c = (totTime)/maxLimit;
        Performance__mdt prfm = UtilityClass.fetchMetadata('Test_Drive_Create');
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