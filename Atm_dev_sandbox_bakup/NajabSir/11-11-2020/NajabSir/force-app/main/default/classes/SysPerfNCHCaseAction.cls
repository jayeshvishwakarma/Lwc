/**
 * @description       : For an existing case, create a case action record = NCH with fields filled on the UI by user on NCH chatter action on the UI. 
 *                      Save it. Capture time for the NCH action to get saved
 * @author            : Nitin
 * @group             : 
 * @last modified on  : 12-03-2020
 * @last modified by  : Nitin
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   12-03-2020   Nitin   Initial Version
**/
public class SysPerfNCHCaseAction implements HandlerInterface{
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
        caseList[0].NCH_Flag__c=true;caseList[0].Model__c='W';
        insert caseList;
        String NCHRecTypeId=Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('NCH').getRecordTypeId();//Case Action NCH Record Type
        Integer maxLimit=integer.valueOf(System.Label.Maximum_Limit);
        //limit before
        UtilityClass.tempWrap lw =UtilityClass.LimitInitmthod();
        Decimal totTime =0;
        UtilityClass.skipInternalCaseActionValidation=true; // To Skip Case Action VR
        for(Integer i=1; i<=maxLimit; i++){
            //ith Run
            decimal  timeBefore = Datetime.now().getTime();
            // defining the before time of case comment creation load time
            timeBefore = Datetime.now().getTime();
            
            //Create NCH Case Action Record
            List<Case_Actions__c> caseAction = UtilityClass.createCaseActions(1,'NCH Legal',caseList[0].Id,NCHRecTypeId);
            caseAction[0].Legal_Document__c='';
            caseAction[0].Raised_By__c='';
            caseAction[0].Date_of_Legal_Document__c=NULL;
            caseAction[0].NCH_Response__c='NCH Test Data';
            caseAction[0].NCH_Response_Type__c='Interim';
            insert caseAction;
            
            // defining the after time
            decimal timeAfter = Datetime.now().getTime();
            system.debug(timeBefore+'>>>'+timeAfter);
            // defining the actual time  
            decimal tim= timeAfter - timeBefore;
            pLog.put('Run_'+i+'__c',tim);
            totTime+=tim;
        }
        UtilityClass.skipInternalCaseActionValidation=false;
        //limit after
        UtilityClass.tempWrap lw1 =UtilityClass.LimitInitmthod();
        system.debug(lw+'>>>'+lw1);
        
        Database.rollback(sp);
        //avg
        pLog.Average_Run_Time__c = (totTime)/maxLimit;
        Performance__mdt prfm = UtilityClass.fetchMetadata('Create_NCH_Case_Action');
        plog.Use_Case__c = prfm.MasterLabel;
        plog.Category__c= prfm.Category__c;
        Map<string,Integer> limitMap = UtilityClass.calculateLimit(lw,lw1,maxLimit);
        for(string ky : limitMap.keySet()){
            plog.put(ky+'__c',limitMap.get(ky));
        }
        insert pLog;
    }
}