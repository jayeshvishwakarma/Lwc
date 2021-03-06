/**
 * @description       : For an existing case, create a case comment record and save it. This will get copied over to Additional Info field on the case
 * @author            : Nitin
 * @group             : 
 * @last modified on  : 12-02-2020
 * @last modified by  : Nitin
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   12-02-2020   Nitin   Initial Version
**/
public class SysPerfAdditionalInfo implements HandlerInterface{
    public static void processData(){
        Performance_Logger__c pLog = new Performance_Logger__c();
        SavePoint sp = Database.setSavepoint();
        
        //create a Product Record
        List<Product2> prodRec = UtilityClass.createProduct(1);
        insert prodRec;
        List<Account> personAccList = UtilityClass.createPersonAccount(1);
        // creating person account for the Case
        insert personAccList;
        // defining list of Business account
        List<Account> businessList = UtilityClass.createBusinessAccount(1);
        // creating business account
        insert businessList;
        //create a Query case
        List<Case> caseList = UtilityClass.createQueryCase(personAccList[0].id, businessList[0].id, 1,prodRec[0].Id);
        caseList[0].Model__c='W';
        insert caseList;
        Integer maxLimit=integer.valueOf(System.Label.Maximum_Limit);
        //limit before
        UtilityClass.tempWrap lw =UtilityClass.LimitInitmthod();
        Decimal totTime =0; 
        for(Integer i=1; i<=maxLimit; i++){
            //ith Run
            decimal  timeBefore = Datetime.now().getTime();
            // defining the before time of case comment creation load time
            timeBefore = Datetime.now().getTime();
            
            List<CaseComment> commRec = UtilityClass.createCaseComments(1,caseList[0].Id);
            insert commRec;
            
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
        Performance__mdt prfm = UtilityClass.fetchMetadata('Create_Case_Comment');
        plog.Use_Case__c = prfm.MasterLabel;
        plog.Category__c= prfm.Category__c;
        Map<string,Integer> limitMap = UtilityClass.calculateLimit(lw,lw1,maxLimit);
        for(string ky : limitMap.keySet()){
            plog.put(ky+'__c',limitMap.get(ky));
        }
        insert pLog;
    }
}