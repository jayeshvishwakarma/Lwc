/**
 * @File Name          : dataDeleteBatchTest.cls
 * @Description        : 
 * @Author             : Rajesh Ramachandran
 * @Group              : 
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 12/19/2019, 7:12:24 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    12/19/2019   Rajesh Ramachandran     Initial Version
**/
@isTest
public class dataDeleteBatchTest {
    @testSetup
    static void createRecord(){
        list<Account> acclist = TestDataFactory.createBusinessAccount(1,'Dealer');
        insert acclist;
        
        List<Account> personAccountList = TestDataFactory.createPersonAccount(1);
        insert personAccountList;
        
        list<Opportunity> opplist = TestDataFactory.createTestOpportunity(200,'Vehicle Sales');
        for(Opportunity opp : opplist){
            opp.stageName = 'New';
            opp.Customer__c = personAccountList[0].Id;
            opp.Dealership__c = acclist[0].Id;
        }
        insert opplist;
    }
    @istest
    static  void SingleParameterTest(){
        Test.startTest();
        dataDeleteBatch deltest = new dataDeleteBatch('SELECT id From Opportunity');
        database.executeBatch(deltest);
        Test.stopTest();
    } 
    @istest
    static  void DoubleParameterTest(){
        Test.startTest();
        dataDeleteBatch deltest = new dataDeleteBatch('SELECT id From Opportunity',2);
        database.executeBatch(deltest);
        Test.stopTest();
    } 
}