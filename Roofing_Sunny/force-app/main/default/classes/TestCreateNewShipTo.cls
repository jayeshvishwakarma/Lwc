/*******************************************************************************
Name          : TestCreateNewshipTo
Date  : 27th Mar 2015
Descriprion   : Test Class for CreateNewShipTo.cs
*******************************************************************************/
@isTest(SeeAllData=false)
private class TestCreateNewShipTo {

    static testMethod void methodA()
    {
        String level = '4-Sold To';
        String status = 'Active';
        
        Region__c region = TestClassUtility.createRegion('testname', 'tst', true);
        Territory__c territory = TestClassUtility.createTerritory('testname', '100', 'Commercial', region.id, true);
        Account acc = TestClassUtility.createAccount('Test Account',null, 'All_Other_Accounts', 'Other', 'Other', territory.Id, false);
        acc.SAP_ACCOUNT__c = 'Test001';
        acc.Hierarchy_Level_BPCS__c = level;
        acc.Status__c = status;
        insert acc;
        
        String query = 'select Id, Name, Type, RecordTypeId, ParentId, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone, Fax, Account_SubType__c, SAP_ACCOUNT__c, BPCS_Hierarchy_Level__c, BPCS_Status_Code__c,Com_Region_Name__c, Com_Special_Pricing__c, Com_TM_Number__c, Com_TM__c, County__c, Currency__c, Customer_Channel__c, Customer_Since__c, Default_Warehouse_Email__c, Default_Warehouse__c, FIPS_Code__c, Hierarchy_Level_BPCS__c, Last_Order_Date__c, Order_For_Account__c, Phone_2__c, Phone_Type__c, Primary_Contact__c, Product_Notes__c, RM_Number__c, RM__c, Region__c, Res_Region_Name__c, Res_Special_Pricing__c, Res_TM_Number__c, Res_TM__c, SAP_Hierarchy_Level__c, Secondary_Fax__c, Secondary_Warehouse__c, Special_Instructions__c, Standard_Weight_Guidelines__c, Status__c, Transportation_Method__c, Price_Area__c, Territory_Commercial__c, Territory__c from Account where ID not in (select sold_to__c from Hierarchy_Ship_to_and_sold_to__c) and Hierarchy_Level_BPCS__c = :level and Status__c = :status';
        
        Test.startTest();
        CreateNewShipTo bulkupdate=  new CreateNewShipTo(query);
        
        bulkupdate.start(null);
        bulkupdate.query = 'select Id, Name, Type, RecordTypeId, ParentId, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone, Fax, Account_SubType__c, SAP_ACCOUNT__c, BPCS_Hierarchy_Level__c, BPCS_Status_Code__c,Com_Region_Name__c, Com_Special_Pricing__c, Com_TM_Number__c, Com_TM__c, County__c, Currency__c, Customer_Channel__c, Customer_Since__c, Default_Warehouse_Email__c, Default_Warehouse__c, FIPS_Code__c, Hierarchy_Level_BPCS__c, Last_Order_Date__c, Order_For_Account__c, Phone_2__c, Phone_Type__c, Primary_Contact__c, Product_Notes__c, RM_Number__c, RM__c, Region__c, Res_Region_Name__c, Res_Special_Pricing__c, Res_TM_Number__c, Res_TM__c, SAP_Hierarchy_Level__c, Secondary_Fax__c, Secondary_Warehouse__c, Special_Instructions__c, Standard_Weight_Guidelines__c, Status__c, Transportation_Method__c, Price_Area__c, Territory_Commercial__c, Territory__c from Account where ID not in (select sold_to__c from Hierarchy_Ship_to_and_sold_to__c) and Hierarchy_Level_BPCS__c = :level and Status__c = :status';
        
        ID batchprocessid = Database.executeBatch(bulkupdate);
        
        System.assert(true);
        Test.stopTest();
    }

}