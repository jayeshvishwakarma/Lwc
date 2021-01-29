/**
 * @description       : 
 * @author            : Rajesh Ramachandran
 * @group             : 
 * @last modified on  : 07-28-2020
 * @last modified by  : Rajesh Ramachandran
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   07-28-2020   Rajesh Ramachandran   Initial Version
**/
@isTest
public class feedbackListTest {
    @isTest
    static void testGetSurvey() {

        List<Account> accList=TestDataFactory.createPersonAccount(1);
        insert accList;
        List<Account> lsAcc = [select id from Account where recordtype.name = 'Customer' limit 1];
        test.startTest();
        FeedbacksRelatedList.getFeedbacks(lsAcc[0].id);
        test.stopTest();

    }
    @isTest
    static void testException(){
        test.startTest();
        FeedbacksRelatedList.getFeedbacks('abcd');
        test.stopTest();

    }

}