/**
 * @description       : For an existing case, create a case action record = Bulk Hold with fields filled on the UI by user on Bulk Hold chatter action on the UI. 
 *                      Save it. Capture time for the closure action to get saved
 * @author            : Nitin
 * @group             : 
 * @last modified on  : 12-09-2020
 * @last modified by  : Nitin
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   12-09-2020   Nitin   Initial Version
**/
public class SysPerfBulkHoldCases implements HandlerInterface{
    public static void ProcessData() {
        Performance_Logger__c pLog = new Performance_Logger__c();
        Savepoint sp = Database.setSavepoint();  
        //create a Product Record
        List<Product2> prodRec = UtilityClass.createProduct(1);
        insert prodRec;
        // storing the maximum limit for the loop to execute from custom label 
        // defining list of person account
        List<Account> personAccList = UtilityClass.createPersonAccount(1);
        // creating person account
        insert personAccList;
        // defining list of Business account
        List<Account> businessList = UtilityClass.createBusinessAccount(1);
        businessList[0].Stakeholder_Hierarchy__c=UtilityClass.createStakeHolderJSON('Account'); //Stakeholder Hierarchy
        // creating business account
        insert businessList;
        List<Category__c> primaryCategory = [SELECT Name,Id FROM Category__c WHERE Active__c = true AND External_ID_Query__c ='Arena_Complaint_Sales_Post Sales_Primary' Limit 1];
        String extrId= 'Arena_Complaint_Sales_Post Sales_Secondary_'+primaryCategory[0].Id;
        List<Category__c> secondaryategory =[SELECT Name FROM Category__c WHERE Active__c = true AND External_ID_Query__c =:extrId LIMIT 1];
        //create a case
        List<Case> caseList = UtilityClass.createCase(personAccList[0].id, businessList[0].id, 2);
        caseList[0].FCR_Conducted__c='Yes';caseList[1].FCR_Conducted__c='Yes';
        caseList[0].Primary_Category__c=primaryCategory[0].Name;caseList[0].Primary_Category_ID__c=primaryCategory[0].Id;
        caseList[0].Secondary_Category__c=secondaryategory[0].Name;caseList[0].Secondary_Category_ID__c=secondaryategory[0].Id;
        caseList[1].Primary_Category__c=primaryCategory[0].Name;caseList[1].Primary_Category_ID__c=primaryCategory[0].Id;
        caseList[1].Secondary_Category__c=secondaryategory[0].Name;caseList[1].Secondary_Category_ID__c=secondaryategory[0].Id;
        caseList[0].Model__c='AN';caseList[1].Model__c='AN';caseList[0].Variant__c=prodRec[0].id;caseList[1].Variant__c=prodRec[0].id;
        caseList[0].Selected_Hierarchy_Type__c='Sales';caseList[1].Selected_Hierarchy_Type__c='Sales';caseList[0].Model__c='W';
        caseList[0].Stakeholders_JSON__c='Test';caseList[1].Stakeholders_JSON__c='Test';caseList[1].Model__c='W';
        insert caseList;
        Integer maxLimit=integer.valueOf(System.Label.Maximum_Limit);
        //limit before
        UtilityClass.tempWrap lw =UtilityClass.LimitInitmthod();
        Decimal totTime =0; 
        for(Integer i=1; i<=maxLimit; i++){
            //ith Run
            decimal  timeBefore = Datetime.now().getTime();
            // defining the before time of case creation load time
            timeBefore = Datetime.now().getTime();
            
            caseList[0].Bulk_Hold_Till_Date__c=date.today().addDays(10);
            caseList[0].Comments='Test Bulk Hold';
            caseList[0].Bulk_Hold_Initiation_Time__c=System.now();
            caseList[0].Bulk_Hold_Start_Date__c=date.today();
            caseList[0].Bulk_Hold_Status__c='In Progress';
            caseList[1].Bulk_Hold_Till_Date__c=date.today().addDays(10);
            caseList[1].Comments='Test Bulk Hold';
            caseList[1].Bulk_Hold_Initiation_Time__c=System.now();
            caseList[1].Bulk_Hold_Start_Date__c=date.today();
            caseList[1].Bulk_Hold_Status__c='In Progress';
            update caseList;
            
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
        Performance__mdt prfm = UtilityClass.fetchMetadata('Create_Bulk_Hold_Case');
        plog.Use_Case__c = prfm.MasterLabel;
        plog.Category__c= prfm.Category__c;
        Map<string,Integer> limitMap = UtilityClass.calculateLimit(lw,lw1,maxLimit);
        for(string ky : limitMap.keySet()){
            plog.put(ky+'__c',limitMap.get(ky));
        }
        insert pLog;
    }   
}