/**
 * @description       : 
 * @author            : Rajesh Ramachandran
 * @group             : 
 * @last modified on  : 10-20-2020
 * @last modified by  : Rajesh Ramachandran
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   10-20-2020   Rajesh Ramachandran   Initial Version
**/
@isTest
public class NewCaseOverrideTest {
    @isTest
    static void testMethod1 (){
        CaseTriggerHandler nct = new CaseTriggerHandler();
        System.assertEquals('System Administrator', NewCaseOverrideController.getCurrentUserProfileName().split('#')[0]);
    }

}