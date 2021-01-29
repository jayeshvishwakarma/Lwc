/**
 * @description       : Enquiry conversion in Salesforce for the leads updated from MC
 * @author            : Nitin
 * @group             : 
 * @last modified on  : 12-09-2020
 * @last modified by  : Nitin
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   12-09-2020   Nitin   Initial Version
**/
public class SysPerfHotLeadConversion implements HandlerInterface{
    public static void ProcessData(){
        Performance_Logger__c pLog = new Performance_Logger__c();
        SavePoint sp = Database.setSavepoint();
        
        list<City__c> cityRec = UtilityClass.createCityAddressMasterData(1);
        cityRec[0].City_Code__c='sbdasdsdsdadsdsadsdsds';
        insert cityRec;
        // defining list of Business account
        List<Account> businessList = UtilityClass.createBusinessAccount(1);
        // creating business account
        insert businessList;
        Integer maxLimit=integer.valueOf(System.Label.Maximum_Limit);
        list<Campaign> cmp = UtilityClass.createCampaign(1); //CREATE CAMPAIGNS
        insert cmp;
        List<Lead> leadRec = UtilityClass.createLead(1,'aCRM',cmp[0].Id,businessList[0].Id,cityRec[0].Id); // Create Lead
        leadRec[0].Expected_Drive_Km__c=2344;leadRec[0].Ownership_Age__c=45;
        insert leadRec;
        leadRec[0].Interested_in_New_Car__c='Yes';
        leadRec[0].Purchase_Interest__c  = 'H';
        leadRec[0].Is_Completed__c=true;leadRec[0].Ownership_Age__c=45; 
        update leadRec;
        List<Survey_Question_CTI__c> crtQues = UtilityClass.createQuestion(null,cmp[0].Id,1);
        insert crtQues;
        List<Survey_Response_CTI__c> crtRes = UtilityClass.createResponse(leadRec[0].Id,crtQues[0].Id,1);
        insert crtRes;
        List<Survey_Response_CTI__c> response = [SELECT Id, Response__c, Survey_Question__c, Unique_ID__c, Lead__c, ResponseText__c 
                                           FROM Survey_Response_CTI__c WHERE ID IN: crtRes];
        String responseData = '['+JSON.serialize(response[0])+']';
        //limit before
        UtilityClass.tempWrap lw =UtilityClass.LimitInitmthod();
        Decimal totTime =0; 
        for(Integer i=1; i<=maxLimit; i++){
            //ith Run
            decimal  timeBefore = Datetime.now().getTime();
            // defining the before time
            timeBefore = Datetime.now().getTime();
            if(!Test.isRunningTest()) {
                FetchLeadSurveyDetail.submitSurveyResponse(responseData, true, leadRec[0].Id);
            }
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
        Performance__mdt prfm = UtilityClass.fetchMetadata('Hot_Lead_Enquiry_Conversion');
        plog.Use_Case__c = prfm.MasterLabel;
        plog.Category__c= prfm.Category__c;
        Map<string,Integer> limitMap = UtilityClass.calculateLimit(lw,lw1,maxLimit);
        for(string ky : limitMap.keySet()){
            plog.put(ky+'__c',limitMap.get(ky));
        }
        insert pLog;
    }
}