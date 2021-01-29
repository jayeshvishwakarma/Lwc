/**
 * @description       : For an existing case, create a case action record = Transfer with fields filled on the UI by user on Transfer chatter action on the UI. 
 *                      Save it. Capture time for the Transfer action to get saved
 * @author            : Nitin
 * @group             : 
 * @last modified on  : 12-04-2020
 * @last modified by  : Nitin
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   12-04-2020   Nitin   Initial Version
**/
public class SysPerfCaseActionTransfer implements HandlerInterface{
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
        List<Account> businessList = UtilityClass.createBusinessAccount(2);
        businessList[0].Stakeholder_Hierarchy__c=UtilityClass.createStakeHolderJSON('Account');
        businessList[1].Stakeholder_Hierarchy__c=UtilityClass.createStakeHolderJSON('Account');
        // creating business account
        insert businessList;
        //create a Query case
        List<Case> caseList = UtilityClass.createQueryCase(personAccList[0].id, businessList[0].id, 1,prodRec[0].Id);
        caseList[0].FCR_Conducted__c='Yes';
        insert caseList;
        String TransferRecTypeId=Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('Transfer').getRecordTypeId();//Case Action Transfer Record Type
        List<Category__c> catList = [select id,name from Category__c where Case_Type__c = 'Complaint' and Channel__c = 'Nexa' and Business_Area__c = 'Accessories' and Case_Stage__c = 'Post Sales' and Active__c = true limit 1];
        Integer maxLimit=integer.valueOf(System.Label.Maximum_Limit);
        //limit before
        UtilityClass.tempWrap lw =UtilityClass.LimitInitmthod();
        Decimal totTime =0; 
        //Loop will run only once because Transfer request cannot be initiated, as it has been done already
        UtilityClass.skipInternalCaseActionValidation=true; // To Skip Case Action VR
        for(Integer i=1; i<=maxLimit; i++){
            //ith Run
            decimal  timeBefore = Datetime.now().getTime();
            // defining the before time
            timeBefore = Datetime.now().getTime();
            
            //Create Transfer Case Action Record
            List<Case_Actions__c> caseAction = UtilityClass.createCaseActions(1,'Transfer',caseList[0].Id,TransferRecTypeId);
            caseAction[0].Channel__c='Nexa';
            caseAction[0].business_area__c = 'Accessories';
            caseAction[0].Case_Type__c = 'Complaint';
            caseAction[0].case_stage__c = 'Post Sales';
            caseAction[0].Dealer_Name__c=businessList[1].id;
            caseAction[0].Legal_Document__c='';
            caseAction[0].Raised_By__c='';
            caseAction[0].Date_of_Legal_Document__c=NULL;
            if(catList.size()>0){
                caseAction[0].Primary_Category_ID__c=catList[0].Id;
                caseAction[0].Primary_Category__c=catList[0].Name;
            }
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
        Performance__mdt prfm = UtilityClass.fetchMetadata('Create_Transfer_Case_Action');
        plog.Use_Case__c = prfm.MasterLabel;
        plog.Category__c= prfm.Category__c;
        Map<string,Integer> limitMap = UtilityClass.calculateLimit(lw,lw1,maxLimit);
        for(string ky : limitMap.keySet()){
            plog.put(ky+'__c',limitMap.get(ky));
        }
        insert pLog;
    }
}