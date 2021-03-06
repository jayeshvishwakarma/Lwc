/**
 * @description       : Campaign/ Dataset record approval by CRM 2 DPM
 * @author            : Nitin
 * @group             : 
 * @last modified on  : 12-07-2020
 * @last modified by  : Nitin
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   12-07-2020   Nitin   Initial Version
**/
public class SysPerfCampaignDatasetCRM2App implements HandlerInterface{
    public static void ProcessData(){
        Performance_Logger__c pLog = new Performance_Logger__c();
        SavePoint sp = Database.setSavepoint();
        List<User> us = [Select Id from User where isActive=true LIMIT 2];//Query to pull users
        List<Adhoc_Campaign_Request__c> adhc = UtilityClass.createCampaignDatasetRequest(us[0].Id,1,us[1].Id,'Pending Data Preparation');
        insert adhc;
        adhc[0].Status__c='Pending Data Approval CRM 2 Dept. Head';
        update adhc;
        Integer maxLimit=integer.valueOf(System.Label.Maximum_Limit);
        //limit before
        UtilityClass.tempWrap lw =UtilityClass.LimitInitmthod();
        Decimal totTime =0; 
        for(Integer i=1; i<=maxLimit; i++){
            //ith Run
            decimal  timeBefore = Datetime.now().getTime();
            // defining the before time
            timeBefore = Datetime.now().getTime();
            adhc[0].Status__c='Pending Data Approval CRM 1 Dept. Head';
            update adhc;
            // defining the after time
            decimal timeAfter = Datetime.now().getTime();
            system.debug(timeBefore+'>>>'+timeAfter);
            // defining the actual time  
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
        Performance__mdt prfm = UtilityClass.fetchMetadata('Create_Campaign_Dataset_CRM2_DPM');
        plog.Use_Case__c = prfm.MasterLabel;
        plog.Category__c= prfm.Category__c;
        Map<string,Integer> limitMap = UtilityClass.calculateLimit(lw,lw1,maxLimit);
        for(string ky : limitMap.keySet()){
            plog.put(ky+'__c',limitMap.get(ky));
        }
        insert pLog;
    }
}