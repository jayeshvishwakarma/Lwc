/**
Name           :   EmailUtilityTest
Author         :   iBirds Services
Date           :   16 July, 2019
Description    :   This is a test class of EmailUtility Class.
**/
@isTest
public class EmailUtilityTest {
	@isTest
    static void methodTest1(){
        List<OrgWideEmailAddress> orgWideObj = [SELECT Id,Address, DisplayName FROM OrgWideEmailAddress LIMIT 1];
        EmailUtility.sendEmail('service@cloud1.nl','service@cloud1.nl','test','<h1>HI</h1>Test',orgWideObj[0].Id);
    }
}