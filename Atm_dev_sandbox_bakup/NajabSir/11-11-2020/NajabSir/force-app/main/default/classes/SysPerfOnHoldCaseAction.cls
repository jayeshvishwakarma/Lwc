/**
 * @description       : For an existing case, create a case action record = On Hold with fields filled on the UI by user on Duplicate chatter 
 *                      action on the UI. Save it. Capture time for the closure action to get saved
 * @author            : Nitin
 * @group             : 
 * @last modified on  : 12-03-2020
 * @last modified by  : Nitin
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   12-03-2020   Nitin   Initial Version
**/
public class SysPerfOnHoldCaseAction implements HandlerInterface{
    public static void ProcessData(){
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
        List<Case> caseList = UtilityClass.createQueryCase(personAccList[0].id, businessList[0].id, 1,prodRec[0].id);
        caseList[0].FCR_Conducted__c='Yes';
        insert caseList;
        
        String OnHoldRecTypeId=Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('On_Hold').getRecordTypeId();//Case Action On Hold Record Type
        
        Integer maxLimit=1;
        //limit before
        UtilityClass.tempWrap lw =UtilityClass.LimitInitmthod();
        Decimal totTime =0; 
        //Loop will run only once because validation has been added That On Hold has already been initiated
        UtilityClass.skipInternalCaseActionValidation=true; // To Skip Case Action VR
        for(Integer i=1; i<=maxLimit; i++){
            //ith Run
            decimal  timeBefore = Datetime.now().getTime();
            // defining the before time of case comment creation load time
            timeBefore = Datetime.now().getTime();
            
            //Create On Hold Case Action Record
            List<Case_Actions__c> caseAction = UtilityClass.createCaseActions(1,'On Hold',caseList[0].Id,OnHoldRecTypeId);
            caseAction[0].Reason_For_Hold__c='Customer Unavailable';
            caseAction[0].Hold_Till_Date__c=Date.today().addDays(7);
            caseAction[0].POS_Indent_Date__c=Date.today().addDays(2);
            caseAction[0].POS_Indent_Number__c='Test Data';
            caseAction[0].Name_and_Position_of_Dealer_RO__c='Test Data';
            caseAction[0].Dealership_Remarks__c='Dealership_Remarks__c';
            caseAction[0].Estimated_Resolution_Date__c=Date.today().addDays(1);
            caseAction[0].Legal_Document__c='';
            caseAction[0].Raised_By__c='';
            caseAction[0].Date_of_Legal_Document__c=NULL;
            insert caseAction;
            //create Attachment
            List<Attachment> attRec = UtilityClass.createAttachments(1,caseList[0].Id);
            insert attRec;
            
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
        Performance__mdt prfm = UtilityClass.fetchMetadata('Create_On_Hold_Case_Action');
        plog.Use_Case__c = prfm.MasterLabel;
        plog.Category__c= prfm.Category__c;
        Map<string,Integer> limitMap = UtilityClass.calculateLimit(lw,lw1,maxLimit);
        for(string ky : limitMap.keySet()){
            plog.put(ky+'__c',limitMap.get(ky));
        }
        insert pLog;
    }
}