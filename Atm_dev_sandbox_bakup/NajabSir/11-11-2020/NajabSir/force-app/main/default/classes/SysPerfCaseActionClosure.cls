/**
 * @description       : For an existing case, create a case action record = Case Closure with fields filled on the UI by user on Case closure chatter action on the UI. 
 *                      Save it. Capture time for the closure action to get saved
 * @author            : Nitin
 * @group             : 
 * @last modified on  : 12-02-2020
 * @last modified by  : Nitin
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   12-02-2020   Nitin   Initial Version
**/
public class SysPerfCaseActionClosure implements HandlerInterface{
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
        String closureRecTypeId=Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('Case_Closure').getRecordTypeId();//Case Action Closure Record Type
        //limit before
        UtilityClass.tempWrap lw =UtilityClass.LimitInitmthod();
        Decimal totTime =0; 
        Integer maxLimit=integer.valueOf(System.Label.Lower_Limit);
        //Loop will run only Twice
        UtilityClass.skipInternalCaseActionValidation=true; // To Skip Case Action VR
        for(Integer i=1; i<=maxLimit; i++){
            //ith Run
            decimal  timeBefore = Datetime.now().getTime();
            // defining the before time
            timeBefore = Datetime.now().getTime();
            
            List<Case_Actions__c> caseAction = UtilityClass.createCaseActions(1,'Closure',caseList[0].Id,closureRecTypeId);//Create Closure Case Action Record
            caseAction[0].Issue_Description__c='Test Rec';
            caseAction[0].Gaps_Identified__c='Test data';
            caseAction[0].Action_Taken__c='Test';
            caseAction[0].Legal_Document__c='';
            caseAction[0].Raised_By__c='';
            caseAction[0].Date_of_Legal_Document__c=NULL;
            insert caseAction;
            //create Attachment
            List<Attachment> attRec = UtilityClass.createAttachments(1,caseList[0].Id);
            insert attRec;
            
            caseList[0].Closure_Mode__c='Clarification Note';
            update caseList;
            
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
        Performance__mdt prfm = UtilityClass.fetchMetadata('Create_Closure_Case_Action');
        plog.Use_Case__c = prfm.MasterLabel;
        plog.Category__c= prfm.Category__c;
        Map<string,Integer> limitMap = UtilityClass.calculateLimit(lw,lw1,maxLimit);
        for(string ky : limitMap.keySet()){
            plog.put(ky+'__c',limitMap.get(ky));
        }
        insert pLog;
    }
}