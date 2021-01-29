global class twod_policyUploadBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select Id,Claim_Type__c,Algae_Protection_YR__c,Maxiumum_Liability__c,Product_Type_Code__c,Reduction_Factor_MO__c,Second_Owner_IN_Surestart__c,Second_Owner_OUT_Surestart__c,Wind_Warranty_Term_Years__c,Workmanship_Coverage_Years__c,Building_Type_Application__c,Defect_Code__c,End_Date__c,Homeowner_s_Insurance_First_Y_N__c,Ignore_Defect_Code__c,Labor_Included_Y_N__c,Material_Included_Y_N__c,Ownership__c,PAT_Policy_ExternalId__c,Policy_Active_Y_N__c,Priority__c,Prorated_Y_N__c,Start_Date__c,SureStart_Period__c,Warranty_Period__c,WR_External_Id__c,Unique_Warranty_Registration__c,Warranty_Registration_Type__c,Wind_Speed__c from Policy_Dummy__c where CREATEDDATE = TODAY';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Policy_Dummy__c> scope) {
        twod_InsertPolicies ct=new twod_InsertPolicies();
        ct.insertPolicies(scope);
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}