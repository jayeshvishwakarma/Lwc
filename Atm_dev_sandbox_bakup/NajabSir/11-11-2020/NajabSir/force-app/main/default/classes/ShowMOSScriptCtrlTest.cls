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
        Implementation_Strategy__c imS = TestDataFactory.createImplementation('CaseMOSCaseTriggerServiceImpl','MOS_Complaints');
        insert imS;
        
        String caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MOS Case').getRecordTypeId(); 
        List<Product2> product = TestDataFactory.createProducts('Variants',1);
        insert product;
        List<Color_Variant_Master__c> colorVariantMaster = TestDataFactory.createColorVarientRealetdToProduct(1,product[0].id);
        insert colorVariantMaster;
        
        List<Case> caseList = TestDataFactory.createCase(1, caseRecTypeId);
        caseList[0].Color__c = colorVariantMaster[0].id;
        caseList[0].Vehicle_Model__c = 'CI';
        caseList[0].Model__c = 'CI';
        caseList[0].Variant__c = product[0].id;
        caseList[0].MOS_Case_Source__c = 'M-Call';
        caseList[0].Job_Type__c = 'Accidental';
        caseList[0].MOS_Case_Stage__c = 'Reached';
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