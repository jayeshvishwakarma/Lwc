/**
 * @description       : Update MOS Case
 * @author            : Nitin
 * @group             : 
 * @last modified on  : 12-01-2020
 * @last modified by  : Nitin
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   12-01-2020   Nitin   Initial Version
**/
public class SysPerfUpdateMOSCase implements HandlerInterface{
    public static void processData(){
        Performance_Logger__c pLog = new Performance_Logger__c();
        SavePoint sp = Database.setSavepoint();
        
        // defining list of Business account
        List<Account> businessList = UtilityClass.createBusinessAccount(1);
        businessList[0].MOS_Category__c='MOS';
        // creating business account
        insert businessList;
        
        //create a Problem Category Record
        List<Problem_Category__c> createProb = UtilityClass.createProblemCategory(1);
        insert createProb;
        
        //create a Product Record
        List<Product2> prodRec = UtilityClass.createProduct(1);
        insert prodRec;
        
        //create Color Record
        List<Color_Variant_Master__c> colorRec = UtilityClass.createColorVariant(1,prodRec[0].Id);
        insert colorRec;
        
        //create a MOS case
        List<Case> caseList = UtilityClass.createMOSCase(1);
        caseList[0].Variant__c=prodRec[0].Id;
        caseList[0].Color__c=colorRec[0].Id;
        caseList[0].Problem_Category__c=createProb[0].Id;
        caseList[0].Allocated_Dealer__c=businessList[0].Id;
        caseList[0].Model__c='W';
        insert caseList;
        Integer maxLimit=integer.valueOf(System.Label.Performance_Mid_Limit);
        //limit before
        UtilityClass.tempWrap lw =UtilityClass.LimitInitmthod();
        Decimal totTime =0; 
        for(Integer i=1; i<=maxLimit; i++){
            //ith Run
            decimal  timeBefore = Datetime.now().getTime();
            // defining the before time of case creation load time
            timeBefore = Datetime.now().getTime();
            
            List<Case> caseListRec = UtilityClass.createMOSCase(1);
            caseListRec[0].FE_CaseNumber__c = '102XNXSHS2'+i;
            caseListRec[0].Id=caseList[0].Id;
            caseListRec[0].MOS_Case_Stage__c='Pending for Out for Service';
            update caseList;
            
            // defining the after time of MOS Case creation
            decimal timeAfter = Datetime.now().getTime();
            system.debug(timeBefore+'>>>'+timeAfter);
            // defining the actual time for the MOS Case creation  
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
        Performance__mdt prfm = UtilityClass.fetchMetadata('Update_MOS_Case');
        plog.Use_Case__c = prfm.MasterLabel;
        plog.Category__c= prfm.Category__c;
        Map<string,Integer> limitMap = UtilityClass.calculateLimit(lw,lw1,maxLimit);
        for(string ky : limitMap.keySet()){
            plog.put(ky+'__c',limitMap.get(ky));
        }
        insert pLog;
    }
}