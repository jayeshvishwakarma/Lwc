/**
 * @Description        : Test Class for System Performance Classes in ATM Dev
 * @Author             : Nitin
**/
@isTest(seeAlldata=false)
private class SysPerformanceTest {
    
    @testSetup static void createTestData() {
        Test.startTest();
        insert new Custom_Validation_Exception_Setting__c(SetupOwnerId=UserInfo.getUserId(), Bypass_Validation_Rules__c=true);
        List<Implementation_Strategy__c> impList =  new List<Implementation_Strategy__c>();
        Implementation_Strategy__c imS = TestDataFactory.createImplementation('CaseMOSCaseTriggerServiceImpl','MOS_Complaints');
        Implementation_Strategy__c imS1 = TestDataFactory.createImplementation('CaseComplaintTriggerServiceImpl','Complaint');
        Implementation_Strategy__c imS2 = TestDataFactory.createImplementation('CaseQueryFeedbackTriggerServiceImpl','Query_Feedback');
        Implementation_Strategy__c imS3 = TestDataFactory.createImplementation('CaseEmailTriggerServiceImpl','Email_Cases');
        Implementation_Strategy__c imS4 = TestDataFactory.createImplementation('CaseSuzukiConnectTriggerServiceImpl','Suzuki_Connect');
        impList.add(imS);impList.add(imS1);impList.add(imS2);impList.add(imS3);impList.add(imS4);
        insert impList;
        //Primary Category
        List<Category__c> crt  = TestDataFactory.createCategories(4,'');
        crt[0].Case_Type__c = 'Dealer Query';crt[0].Channel__c = 'Arena';crt[0].Business_Area__c = 'Sales';crt[0].Case_Stage__c = 'Post Sales';crt[0].Active__c=true;crt[0].Type__c='Primary';
        crt[1].Case_Type__c = 'Complaint';crt[1].Channel__c = 'Arena';crt[1].Business_Area__c = 'Sales';crt[1].Case_Stage__c = 'Post Sales';crt[1].Active__c=true;crt[1].Type__c='Primary';
        crt[2].Case_Type__c = 'Complaint';crt[2].Channel__c = 'Arena';crt[2].Business_Area__c = 'Accessories';crt[2].Case_Stage__c = 'Post Sales';crt[2].Active__c=true;crt[2].Type__c='Primary';
        crt[2].Name='Suzuki Connect Product Complaint';
        crt[3].Case_Type__c = 'Complaint';crt[3].Channel__c = 'Arena';crt[3].Business_Area__c = 'Accessories';crt[3].Case_Stage__c = 'Post Sales';crt[3].Active__c=true;crt[3].Type__c='Primary';
        crt[3].Name='Suzuki Connect Dealer Assistance';
        insert crt;
        //Secondary Category
        List<Category__c> seccrt  = TestDataFactory.createCategories(3,'');
        seccrt[0].Case_Type__c = 'Complaint';seccrt[0].Channel__c = 'Arena';seccrt[0].Business_Area__c = 'Sales';seccrt[0].Case_Stage__c = 'Post Sales';seccrt[0].Active__c=true;seccrt[0].Type__c='Secondary';
        seccrt[0].Primary_Category__c=crt[1].Id;
        seccrt[1].Case_Type__c = 'Complaint';seccrt[1].Channel__c = 'Arena';seccrt[1].Business_Area__c = 'Accessories';seccrt[1].Case_Stage__c = 'Post Sales';seccrt[1].Active__c=true;seccrt[1].Type__c='Secondary';
        seccrt[1].Primary_Category__c=crt[2].Id;
        seccrt[1].Name='Server Error';
        seccrt[2].Case_Type__c = 'Complaint';seccrt[2].Channel__c = 'Arena';seccrt[2].Business_Area__c = 'Accessories';seccrt[2].Case_Stage__c = 'Post Sales';seccrt[2].Active__c=true;seccrt[2].Type__c='Secondary';
        seccrt[2].Primary_Category__c=crt[3].Id;
        seccrt[2].Name='Device Connection To be checked';
        insert seccrt;
        Test.stopTest();
    }
    
    static testMethod void CreateMOSCase(){
        Test.startTest();
        SysPerfCreateMOSCase.processData();
        Test.stopTest();
    }
    static testMethod void UpdateMOSCase(){
        Test.startTest();
        SysPerfUpdateMOSCase.processData();
        Test.stopTest();
    }
    static testMethod void CreateCustomActivity(){
        Test.startTest();
        SysPerfCreateCustomActivity.processData();
        Test.stopTest();
    }
    static testMethod void UpdateCustomActivity(){
        Test.startTest();
        SysPerfUpdateCustomActivity.processData();
        Test.stopTest();
    }
    static testMethod void CreateMCcommunication(){
        Test.startTest();
        SysPerfCreateMCcommunication.processData();
        Test.stopTest();
    }
    static testMethod void CreateMCcommunicationEmail(){
        Test.startTest();
        SysPerfCreateMCcommunicationEmail.processData();
        Test.stopTest();
    }
    static testMethod void CreateFCRYesCase(){
        Test.startTest();
        SysPerfCreateFCRYesCase.processData();
        Test.stopTest();
    }
    static testMethod void AdditionalInfo(){
        Test.startTest();
        SysPerfAdditionalInfo.processData();
        Test.stopTest();
    }
    static testMethod void LegalCaseAction(){
        Test.startTest();
        SysPerfLegalCaseAction.processData();
        Test.stopTest();
    }
    static testMethod void LegalCaseActionApprove(){
        Test.startTest();
        SysPerfLegalCaseActionApprove.processData();
        Test.stopTest();
    }
    static testMethod void CaseActionClosure(){
        Test.startTest();
        SysPerfCaseActionClosure.processData();
        Test.stopTest();
    }
    static testMethod void CaseActionApproveClosure(){
        Test.startTest();
        SysPerfCaseActionApproveClosure.processData();
        Test.stopTest();
    }
    static testMethod void NCHCaseAction(){
        Test.startTest();
        SysPerfNCHCaseAction.processData();
        Test.stopTest();
    }
    static testMethod void DNECaseAction(){
        Test.startTest();
        SysPerfDNECaseAction.processData();
        Test.stopTest();
    }
    static testMethod void DNECaseActionApprove(){
        Test.startTest();
        SysPerfDNECaseActionApprove.processData();
        Test.stopTest();
    }
    static testMethod void DuplicateCaseAction(){
        Test.startTest();
        SysPerfDuplicateCaseAction.processData();
        Test.stopTest();
    }
    static testMethod void DuplicateCaseActionApprove(){
        Test.startTest();
        SysPerfDuplicateCaseActionApprove.processData();
        Test.stopTest();
    }
    static testMethod void UpdateEmailToComplaintRT(){
        Test.startTest();
        SysPerfUpdateEmailToComplaintRT.processData();
        Test.stopTest();
    }
    static testMethod void OnHoldCaseAction(){
        Test.startTest();
        SysPerfOnHoldCaseAction.processData();
        Test.stopTest();
    }
    static testMethod void OnHoldCaseActionApprove(){
        Test.startTest();
        SysPerfOnHoldCaseActionApprove.processData();
        Test.stopTest();
    }
    static testMethod void CaseActionTransfer(){
        Test.startTest();
        SysPerfCaseActionTransfer.processData();
        Test.stopTest();
    }
    static testMethod void SendOTP(){
        Test.startTest();
        SysPerfSendOTP.processData();
        Test.stopTest();
    }
    static testMethod void VerifyOTP(){
        Test.startTest();
        SysPerfVerifyOTP.processData();
        Test.stopTest();
    }
    static testMethod void CampaignDatasetRequest(){
        Test.startTest();
        SysPerfCampaignDatasetRequest.processData();
        Test.stopTest();
    }
    static testMethod void CampaignDatasetStatusUpdate(){
        Test.startTest();
        SysPerfCampaignDatasetStatusUpdate.processData();
        Test.stopTest();
    }
    static testMethod void CampaignDatasetPending(){
        Test.startTest();
        SysPerfCampaignDatasetPending.processData();
        Test.stopTest();
    }
    static testMethod void CampaignDatasetMKT3App(){
        Test.startTest();
        SysPerfCampaignDatasetMKT3App.processData();
        Test.stopTest();
    }
    static testMethod void CampaignDatasetCRM2App(){
        Test.startTest();
        SysPerfCampaignDatasetCRM2App.processData();
        Test.stopTest();
    }
    static testMethod void CampaignDatasetCRM1App(){
        Test.startTest();
        SysPerfCampaignDatasetCRM1App.processData();
        Test.stopTest();
    }
    static testMethod void LeadConversion(){
        Test.startTest();
        SysPerfLeadConversion.processData();
        Test.stopTest();
    }
    static testMethod void CloseDateCmpDataset(){
        Test.startTest();
        SysPerfCloseDateCmpDataset.processData();
        Test.stopTest();
    }
    static testMethod void BulkHoldCases(){
        Test.startTest();
        SysPerfBulkHoldCases.processData();
        Test.stopTest();
    }
    static testMethod void BulkHoldStatusUpdate(){
        Test.startTest();
        SysPerfBulkHoldStatusUpdate.processData();
        Test.stopTest();
    }
    static testMethod void HotLeadConversion(){
        Test.startTest();
        SysPerfHotLeadConversion.processData();
        Test.stopTest();
    }
    static testMethod void CreateComplaintCase(){
        Test.startTest();
        SysPerfCreateComplaintCase.processData();
        Test.stopTest();
    }
    static testMethod void ExistingCaseLoad(){
        Test.startTest();
        SysPerfExistingCaseLoad.processData();
        Test.stopTest();
    }
    static testMethod void GetCaseCategories(){
        Test.startTest();
        SysPerfGetCaseCategories.processData();
        Test.stopTest();
    }
    static testMethod void NewCaseLoad(){
        Test.startTest();
        SysPerfNewCaseLoad.processData();
        Test.stopTest();
    }
    static testMethod void ChildInspectionCase(){
        Test.startTest();
        SysPerfChildInspectionCase.processData();
        Test.stopTest();
    }
    static testMethod void ChildReplacementCase(){
        Test.startTest();
        SysPerfChildReplacementCase.processData();
        Test.stopTest();
    }
    static testMethod void SuzukiManualOnHold(){
        Test.startTest();
        SysPerfSuzukiManualOnHold.processData();
        Test.stopTest();
    }
    static testMethod void UpdateClarifications(){
        Test.startTest();
        SysPerfUpdateClarifications.processData();
        Test.stopTest();
    }
    static testMethod void SuzukiConnectCaseClosure(){
        Test.startTest();
        SysPerfSuzukiConnectCaseClosure.processData();
        Test.stopTest();
    }
}