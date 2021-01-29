/**
 * @File Name          : TestDriveTrigger.trigger
 * @Description        : 
 * @Author             : Rajesh Ramachandran
 * @Group              : 
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 1/6/2020, 2:25:52 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    1/5/2020   Rajesh Ramachandran     Initial Version
**/
trigger TestDriveTrigger on Test_Drive__c (before insert) {
    new TestDriveTriggerHandler().run();
}