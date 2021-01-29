/**
* @File Name          : CorporateGroupTriggerTest.cls
* @Description        : This class will cover CorporateGroupTrigger
* @Author             : 
* @Group              : 
* @Last Modified By   : Brijesh Singh
* @Last Modified On   : 31st Aug 2020
* @Modification Log   : 

**/


@IsTest()  
       
public class CorporateGroupTriggerTest{
     @isTest
     private static void testUnit(){
         Corporate_Group__c cg = new Corporate_Group__c();
         cg.Corporate_Group_Code__c = 'AGFG216545CG';
         INSERT cg;
     }
}