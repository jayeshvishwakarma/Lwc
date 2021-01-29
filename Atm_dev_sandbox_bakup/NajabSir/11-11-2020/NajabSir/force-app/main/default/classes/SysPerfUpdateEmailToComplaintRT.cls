/**
 * @description       : Update an existing case of recordtype = Email with new recordtype = Complaint and few key field updates like channel, business area, 
 *                      primary category and save the case. Capture time taken to save
 * @author            : Nitin
 * @group             : 
 * @last modified on  : 12-03-2020
 * @last modified by  : Nitin
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   12-03-2020   Nitin   Initial Version
**/
public class SysPerfUpdateEmailToComplaintRT implements HandlerInterface{
    public static void processData(){
        Performance_Logger__c pLog = new Performance_Logger__c();
        SavePoint sp = Database.setSavepoint();
        
        List<Account> personAccList = UtilityClass.createPersonAccount(1);
        // creating person account for the Case
        insert personAccList;
        // defining list of Business account
        List<Account> businessList = UtilityClass.createBusinessAccount(1);
        // creating business account
        insert businessList;
        //create a Email case
        List<Case> caseList = UtilityClass.createEmailCase(personAccList[0].id, businessList[0].id, 1);
        insert caseList;
        system.debug('BefcaseList--->'+caseList[0]);
        String complaintId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();//Complaint record type
        List<Category__c> catList = [select id,name from Category__c where Case_Type__c = 'Complaint' and Channel__c = 'Arena' and Business_Area__c = 'Sales' and Case_Stage__c = 'Post Sales' and Active__c = true limit 1];
        //List<Case> csRc = [Select Id,RecordTypeId,Channel__c FROM CASE where Id IN: caseList];
        Integer maxLimit=integer.valueOf(System.Label.Maximum_Limit);
        //limit before
        UtilityClass.tempWrap lw =UtilityClass.LimitInitmthod();
        Decimal totTime =0; 
        for(Integer i=1; i<=maxLimit; i++){
            //ith Run
            decimal  timeBefore = Datetime.now().getTime();
            // defining the before time of case comment creation load time
            timeBefore = Datetime.now().getTime();
            
            //Update from Email to Complaint Case Record Type
            caseList[0].recordTypeId=complaintId;
            caseList[0].Channel__c='Arena';
            Update caseList;
            
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
        Performance__mdt prfm = UtilityClass.fetchMetadata('Update_Email_Complaint_Record_Type');
        plog.Use_Case__c = prfm.MasterLabel;
        plog.Category__c= prfm.Category__c;
        Map<string,Integer> limitMap = UtilityClass.calculateLimit(lw,lw1,maxLimit);
        for(string ky : limitMap.keySet()){
            plog.put(ky+'__c',limitMap.get(ky));
        }
        insert pLog;
    }
}