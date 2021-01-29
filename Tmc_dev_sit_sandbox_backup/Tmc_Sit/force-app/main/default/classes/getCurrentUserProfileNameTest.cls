/**
* @File Name          : getCurrentUserProfileNameTest.cls
* @Description        : It is utilized for getCurrentUserProfileName Apex code coverage
* @Author             :
* @Group              :
* Apex Class		   : getCurrentUserProfileName
* @Last Modified By   :
* @Last Modified On   : 08/06/2020
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author      		      Modification
*==============================================================================
* 1.0        17/06/2020               Nitin Ghai   		    	  Initial Version
**/
@isTest
public class getCurrentUserProfileNameTest {

    @isTest
    public static void method1(){
        test.startTest();
        getCurrentUserProfileName.DataWrapper wrap =  getCurrentUserProfileName.getMetadataRecords('General','','EXC');
        //system.assertEquals(wrap.lstmdtRecord.size()>0,wrap.lstmdtRecord.size()>0);
        test.stopTest();
    }
    @isTest
    public static void method2(){
        test.startTest();
        getCurrentUserProfileName.DataWrapper wrap =  getCurrentUserProfileName.getMetadataRecords('First Free Service','','EXC');
        //system.assertEquals(1,wrap.lstmdtRecord.size());
        test.stopTest();
    }
}