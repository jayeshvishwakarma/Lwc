/**
* @File Name          : CaseRedirectControllerTest.cls
* @Description        : It is utilized for CaseRedirectController Apex code coverage
* @Author             : Nitin Ghai
* @Group              : 
* Apex Class		  : CaseRedirectController
* @Last Modified By   : 
* @Last Modified On   : 18/06/2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author      		      Modification
*==============================================================================
* 1.0        18/06/2020               Nitin Ghai   		    	  Initial Version
**/
@isTest
public class CaseRedirectControllerTest {

    @isTest
    public static void method(){
        Test.startTest();
        String str = CaseRedirectController.getRedirectURL('Endorsement_Calculator','372372783');
        system.assertEquals(true,String.isNotBlank(str));
        Test.stopTest();    
    }
    @isTest
    public static void method1(){
        Test.startTest();
        String str = CaseRedirectController.getRedirectURL('','372372783');
        system.assertEquals(true,String.isBlank(str));
        Test.stopTest();    
    }
}