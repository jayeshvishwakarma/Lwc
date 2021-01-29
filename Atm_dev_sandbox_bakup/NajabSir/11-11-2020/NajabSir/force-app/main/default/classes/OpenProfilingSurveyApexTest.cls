/**
 * @File Name          : OpenProfilingSurveyApexTest.cls
 * @Description        : 
 * @Author             : Najab
 * @Group              : 
 * @Last Modified By   : Najab
 * @Last Modified On   : 21-12-2020
**/

@isTest
public class OpenProfilingSurveyApexTest {
    @testSetup
    public static void createRecord(){
        List<Survey_Taker_CTI__c> surveyTakerCTI = TestDataFactory.createSurveyTakerCTI();
        insert surveyTakerCTI;
    }
    @isTest
    public static void unitTest(){
        List<Survey_Taker_CTI__c> lstSurveyTakers = [SELECT id, DPS_ID__c FROM Survey_Taker_CTI__c];
        OpenProfilingSurveyApex.createProfiling(lstSurveyTakers[0].DPS_ID__c);
        //For negative testing
        OpenProfilingSurveyApex.createProfiling('1234');//custom dpsId
    }
}