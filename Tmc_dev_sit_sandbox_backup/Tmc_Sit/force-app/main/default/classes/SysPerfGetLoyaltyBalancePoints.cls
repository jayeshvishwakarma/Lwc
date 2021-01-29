/*
@File Name :  SysPerfGetLoyaltyBalancePoints
@Description : This class will create a performance log for Point Redemption Check
@Author : Anas Yar Khan
@Group : 
@Last Modified By : 
@Last Modified On : 
*==============================================================================
* Ver         Date                     Author      		            Modification
*==============================================================================
* 1.0    21/07/2020,       			Anas Yar Khan    			  Initial Version
*/


public class SysPerfGetLoyaltyBalancePoints implements HandlerInterface{
    public static void processData() {
        Performance_Logger__c pLog = new Performance_Logger__c();
        Savepoint sp = Database.setSavepoint();  
        // defining list of person account
        List<Account> personAccList = UtilityClass.createPersonAccount(1);
        personAccList[0].Tier__c = 'Silver';
        personAccList[0].Loyalty_Card_Number__c = 'Test12345';
        personAccList[0].Points_Balance__c = 20;
        // creating person account for the Enquiry
        insert personAccList;
        // defining list of Business account
        List<Account> businessList = UtilityClass.createBusinessAccount(1);
        // creating business account
        insert businessList;
        //defining list of Vehicle Enqiry
        List<Opportunity> oppList = UtilityClass.createEnquiryVehicle(personAccList[0].Id,BusinessList[0].Id,1);
        // storing the maximum limit for the loop to execute from custom label 
        Integer maxLimit=integer.valueOf(System.Label.Maximum_Limit);
        //limit before
        UtilityClass.tempWrap lw =UtilityClass.LimitInitmthod();
        Decimal totTime =0; 
        for(Integer i=1; i<=maxLimit; i++){
            //ith Run
            decimal  timeBefore = Datetime.now().getTime();
            // defining the before time of enquiry creation
            timeBefore = Datetime.now().getTime();
            //fetching the Points details
            List<Account> listAccount = [SELECT Tier__c,Loyalty_Card_Number__c,Points_Balance__c FROM Account WHERE Id = :personAccList[0].Id];
            
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
        Performance__mdt prfm = UtilityClass.fetchMetadata('Point_Redemption_Check');
        plog.Use_Case__c = prfm.MasterLabel;
        plog.Category__c= prfm.Category__c;
        Map<string,Integer> limitMap = UtilityClass.calculateLimit(lw,lw1,maxLimit);
        for(string ky : limitMap.keySet()){
            plog.put(ky+'__c',limitMap.get(ky));
        }
        insert pLog;
    }
    }