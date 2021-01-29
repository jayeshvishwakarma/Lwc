/**
* @File Name          : SysPerfSetFilterReport.cls
* @Description        : This class will create a performance log for change of filter report.
* @Author             : Ravi Gupta
* @Group              : 
* @Last Modified By   : 
* @Last Modified On   : 
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author      		      Modification
*==============================================================================
* 1.0    18/10/2019,       			Ravi Gupta    			  Initial Version
**/
Public class SysPerfSetFilterReport implements HandlerInterface{
    
    
    public static void ProcessData(){
        Performance_Logger__c pLog = new Performance_Logger__c();
        //Savepoint sp = Database.setSavepoint(); 
        // getting the report Id
        string reportId = UtilityClass.getReport();
        // defining metadata for the report
        List<Reports.ReportMetadata> metaReportList = UtilityClass.getReportMetadata(reportId);
        // storing the maximum limit for the loop to execute from custom label 
        integer maxLimit=integer.valueOf(System.Label.Maximum_Limit);
        //limit before
        UtilityClass.tempWrap lw =UtilityClass.LimitInitmthod();
        Decimal totTime =0; 
        for(Integer i=1; i<=maxLimit; i++){
            //ith Run
            decimal  timeBefore = Datetime.now().getTime();
            // defining the before time of opportunity Line item creation
            timeBefore = Datetime.now().getTime();
            // run the report by passing metadata and report Id
            UtilityClass.runReport(metaReportList[0],reportId);
            // defining the after time of opportunity Line item creation
            decimal timeAfter = Datetime.now().getTime();
            system.debug(timeBefore+'>>>'+timeAfter);
            // defining the actual time for the opportunity Line item  
            decimal tim= timeAfter - timeBefore;
            pLog.put('Run_'+i+'__c',tim);
            totTime+=tim;
        }
        //limit after
        UtilityClass.tempWrap lw1 =UtilityClass.LimitInitmthod();
        //Database.rollback(sp);
        //avg
        pLog.Average_Run_Time__c = (totTime)/maxLimit;
        Performance__mdt prfm = UtilityClass.fetchMetadata('Reports_Dashboard');
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