/**
 * @description       : Save a case action record with recordtype = Duplicateand a parent case with Approval Status field = Approved. Capture time to save the update
 * @author            : Nitin
 * @group             : 
 * @last modified on  : 12-03-2020
 * @last modified by  : Nitin
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   12-03-2020   Nitin   Initial Version
**/
public class SysPerfDuplicateCaseActionApprove implements HandlerInterface{
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
        List<Case> caseList = UtilityClass.createQueryCase(personAccList[0].id, businessList[0].id, 2,prodRec[0].Id);
        caseList[0].FCR_Conducted__c='Yes';caseList[1].FCR_Conducted__c='Yes';
        insert caseList;
        List<Case> caseNumb = [Select Id,CaseNumber,Case_Type__c from Case where ID IN: caseList]; //Query to fetch Case Number
        String DuplicateRecTypeId=Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('Duplicate').getRecordTypeId();//Case Action Duplicate Record Type
        //Create Duplicate Case Action Record
        List<Case_Actions__c> caseAction = UtilityClass.createCaseActions(1,'Duplicate',caseList[0].Id,DuplicateRecTypeId);
        caseAction[0].Legal_Document__c='';
        caseAction[0].Raised_By__c='';
        caseAction[0].Date_of_Legal_Document__c=NULL;
        caseAction[0].Original_Complaint_No__c=caseList[1].Id;
        caseAction[0].Dealership_Remarks__c='Test Duplicate data';
        insert caseAction;
        Integer maxLimit=integer.valueOf(System.Label.Maximum_Limit);
        //limit before
        UtilityClass.tempWrap lw =UtilityClass.LimitInitmthod();
        Decimal totTime =0; 
        for(Integer i=1; i<=maxLimit; i++){
            //ith Run
            decimal  timeBefore = Datetime.now().getTime();
            // defining the before time of case comment creation load time
            timeBefore = Datetime.now().getTime();
            
            //Approve Duplicate Case Action Record
            List<Case_Actions__c> approveCaseAction = UtilityClass.createCaseActions(1,'Duplicate',caseList[0].Id,DuplicateRecTypeId);
            approveCaseAction[0].Approval_Status__c='Approved';approveCaseAction[0].Id=caseAction[0].Id;
            approveCaseAction[0].Approval_Chatter_Message__c=caseList[0].Case_Type__c +' ref. no. '+ caseNumb[0].CaseNumber +' is approved to be to mark as duplicate of ' + caseNumb[1].Case_Type__c + ' ref. no. ' + caseNumb[1].CaseNumber;
            update approveCaseAction;
            
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
        Performance__mdt prfm = UtilityClass.fetchMetadata('Create_Duplicate_Case_Action_Approved');
        plog.Use_Case__c = prfm.MasterLabel;
        plog.Category__c= prfm.Category__c;
        Map<string,Integer> limitMap = UtilityClass.calculateLimit(lw,lw1,maxLimit);
        for(string ky : limitMap.keySet()){
            plog.put(ky+'__c',limitMap.get(ky));
        }
        insert pLog;
    }
}