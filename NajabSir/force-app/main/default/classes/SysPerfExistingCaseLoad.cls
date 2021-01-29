/**
 * @description       : 
 * @author            : Rajesh Ramachandran
 * @group             : 
 * @last modified on  : 11-10-2020
 * @last modified by  : Rajesh Ramachandran
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   11-10-2020   Rajesh Ramachandran   Initial Version
**/
public with sharing class SysPerfExistingCaseLoad {

    public static void processData() {
        Performance_Logger__c pLog = new Performance_Logger__c();
        Savepoint sp = Database.setSavepoint();  
        // storing the maximum limit for the loop to execute from custom label 
        // defining list of person account
        List<Account> personAccList = UtilityClass.createPersonAccount(1);
        // creating person account for the Enquiry
        insert personAccList;
        // defining list of Business account
        List<Account> businessList = UtilityClass.createBusinessAccount(1);
        // creating business account
        insert businessList;
        //create a case
        List<Case> caseList = UtilityClass.createCase(personAccList[0].id, businessList[0].id, 4);

        Integer maxLimit=integer.valueOf(System.Label.Maximum_Limit);
        //limit before
        UtilityClass.tempWrap lw =UtilityClass.LimitInitmthod();
        Decimal totTime =0; 
        for(Integer i=1; i<maxLimit; i++){
            //ith Run
            decimal  timeBefore = Datetime.now().getTime();
            // defining the before time of case creation load time
            timeBefore = Datetime.now().getTime();
            //load data needed for new case when there is no parent case or case action
            CreateCaseController.getOnloadInfoForCaseAction(caseList[i].id, null, null);
            
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
        system.debug(lw+'>>>'+lw1);
        
        Database.rollback(sp);
        //avg
        pLog.Average_Run_Time__c = (totTime)/maxLimit;
        Performance__mdt prfm = UtilityClass.fetchMetadata('Existing_Case_Load');
        plog.Use_Case__c = prfm.MasterLabel;
        plog.Category__c= prfm.Category__c;
        Map<string,Integer> limitMap = UtilityClass.calculateLimit(lw,lw1,maxLimit);
        for(string ky : limitMap.keySet()){
            plog.put(ky+'__c',limitMap.get(ky));
        }
        insert pLog;
    }    

}