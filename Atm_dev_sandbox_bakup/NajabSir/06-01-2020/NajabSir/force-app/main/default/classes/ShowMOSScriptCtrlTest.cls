/**
* @File Name          : ShowMOSScriptCtrlTest.cls
* @Description        :
* @Author             : Najab Maghribi
* @Group              :
* @Last Modified By   : Najab Maghribi
* @Last Modified On   : 23/10/2020 10:45 AM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    23/10/2020 10:45 AM         Najab Maghribi            Initial Version
**/
@isTest
private class ShowMOSScriptCtrlTest {
    @testsetup
    static void testRecordCreate(){
        //Create Case record for testing
        String caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MOS Case').getRecordTypeId(); 
        List<Case> caseList = TestDataFactory.createCase(1, caseRecTypeId);
        INSERT caseList;
    }
    @isTest
    private static void unitTest(){
        List<Case> caseList = [Select id 
                               From Case 
                               LIMIT 1 ];
        ShowMOSScriptCtrl.getCaseDetail(caseList[0].id);
    }
}