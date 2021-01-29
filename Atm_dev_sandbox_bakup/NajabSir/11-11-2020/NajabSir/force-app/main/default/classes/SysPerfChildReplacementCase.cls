/**
 * @description       : Suzuki Connect  Replacement child case creation and related actions
 * @author            : Nitin
 * @group             : 
 * @last modified on  : 12-15-2020
 * @last modified by  : Nitin
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   12-15-2020   Nitin   Initial Version
**/
public class SysPerfChildReplacementCase implements HandlerInterface{
     public static void processData(){
        Performance_Logger__c pLog = new Performance_Logger__c();
        SavePoint sp = Database.setSavepoint();
        
        List<Account> personAccList = UtilityClass.createPersonAccount(1);
        // creating person account for the Case
        insert personAccList;
         List<Product2> crp = UtilityClass.createProduct(1);
         insert crp;
        // defining list of Business account
        List<Account> businessList = UtilityClass.createBusinessAccount(1);
        // creating business account
        insert businessList;
        //create a Suzuki Connect case
        List<Case> caseList = UtilityClass.createSuzukiConnectCase(personAccList[0].id, 1);
        caseList[0].Job_Status__c='Resolved by Stakeholder Replacement';
        insert caseList;
        List<Category__c> cpcatList = [select id,name from Category__c where Case_Type__c = 'Complaint' and Channel__c = 'Arena' and Business_Area__c = 'Accessories' and Case_Stage__c = 'Post Sales' and Active__c = true AND Name='Suzuki Connect Dealer Assistance' limit 1];
        String primaryId='Arena_Complaint_Accessories_Post Sales_Secondary_'+cpcatList[0].Id;
        List<Category__c> cscatList = [SELECT Name,id FROM Category__c WHERE Active__c = true AND External_ID_Query__c =:primaryId  AND Name='Device Connection To be checked' limit 1];
        Integer maxLimit=integer.valueOf(System.Label.Lower_Limit);
        //limit before
        UtilityClass.tempWrap lw =UtilityClass.LimitInitmthod();
        Decimal totTime =0; 
        for(Integer i=1; i<=maxLimit; i++){
            //ith Run
            decimal  timeBefore = Datetime.now().getTime();
            // defining the before time
            timeBefore = Datetime.now().getTime();
            
            //Create Complaint Case
            List<Case> compList = UtilityClass.createChildCase(personAccList[0].id,businessList[0].Id,1);
            compList[0].ParentId=caseList[0].Id;compList[0].Primary_Category_ID__c=cpcatList[0].Id;compList[0].Primary_Category__c=cpcatList[0].Name;
            compList[0].Secondary_Category_ID__c=cscatList[0].Id;compList[0].Secondary_Category__c=cscatList[0].name;compList[0].Model__c='W';compList[0].Variant__c=crp[0].Id;
            insert compList;
            
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
        Performance__mdt prfm = UtilityClass.fetchMetadata('Suzuki_Connect_Child_Replacement');
        plog.Use_Case__c = prfm.MasterLabel;
        plog.Category__c= prfm.Category__c;
        Map<string,Integer> limitMap = UtilityClass.calculateLimit(lw,lw1,maxLimit);
        for(string ky : limitMap.keySet()){
            plog.put(ky+'__c',limitMap.get(ky));
        }
        insert pLog;
    }
}