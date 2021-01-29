global class CreateNewShipTo implements Database.Batchable<sObject>
{

global String query;
global CreateNewShipto(){}

global CreateNewShipto(String q)
{
query=q;
}
global Database.QueryLocator start(Database.BatchableContext BC)
{

String level = '4-Sold To';
String status = 'Active';
query = 'select Id, Name, Type, RecordTypeId, ParentId, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone, Fax, Account_Sub_Type__c, SAP_ACCOUNT__c, JDE_Hierarchy_Level__c, Com_Region_Name__c, Com_TM_Number__c, County__c, Currency__c, Customer_Channel_rpg__c, ENTERED__c, Default_Warehouse_Email__c, Default_Plant__c, FIPS__c, Hierarchy_Level_BPCS__c, Last_Order_Date__c, Order_For_Account__c, Phone_2__c, Phone_Type__c, RM_Number__c, RSM__c, Res_Region_Name__c, Res_TM_Number__c, SAP_Hierarchy_Level__c, Secondary_Fax__c, Secondary_Warehouse__c, Special_Instructions__c, Status__c, Transportation_Method__c, Sales_District_lookup__c, Finishing_Territory__c, Mechanical_Territory__c from Account where ';
//query += ' ID not in (select sold_to__c from Hierarchy_Ship_to_and_sold_to__c) and ';
query += ' Hierarchy_Level_BPCS__c = :level and Status__c = :status';
if(Test.isRunningTest()){
    query += ' Limit 10';

}
return Database.getQueryLocator(query);
}
global void execute(Database.BatchableContext BC, List<Account> scope)
{
list<account> acclist = new list<account>();
for(Account a : scope)
{

Account acc = new  Account();
//a.status__c= 'Inactive';
acc.Name = a.Name;
//acc.ParentId = a.Id;
acc.RecordTypeId = a.RecordTypeId;
acc.Type = a.Type;
acc.ShippingStreet = a.BillingStreet;
acc.ShippingCity = a.BillingCity;
acc.ShippingState = a.BillingState;
acc.ShippingPostalCode = a.BillingPostalCode;
acc.ShippingCountry = a.BillingCountry;
acc.Phone = a.Phone;
acc.Fax = a.Fax;
acc.Account_Sub_Type__c = a.Account_Sub_Type__c;
acc.SAP_ACCOUNT__c = a.SAP_ACCOUNT__c;
acc.JDE_Hierarchy_Level__c = a.JDE_Hierarchy_Level__c;
//acc.BPCS_Status_Code__c = a.BPCS_Status_Code__c;
acc.Com_Region_Name__c = a.Com_Region_Name__c;
//acc.Com_Special_Pricing__c = a.Com_Special_Pricing__c;
acc.Com_TM_Number__c = a.Com_TM_Number__c;
//acc.Com_TM__c = a.Com_TM__c;
acc.County__c = a.County__c;
acc.Currency__c = a.Currency__c;
acc.Customer_Channel_rpg__c = a.Customer_Channel_rpg__c;
acc.ENTERED__c = a.ENTERED__c;

acc.Default_Plant__c = a.Default_Plant__c;
acc.FIPS__c = a.FIPS__c;
acc.Hierarchy_Level_BPCS__c = '3-Ship To';
acc.Last_Order_Date__c = a.Last_Order_Date__c;
acc.Phone_2__c = a.Phone_2__c;
acc.Phone_Type__c = a.Phone_Type__c;
//acc.Primary_Contact__c = a.Primary_Contact__c;
//acc.//Product_Notes__c = a.Product_Notes__c;

acc.RSM__c = a.RSM__c;
//acc.Region__c = a.Region__c;
acc.Res_Region_Name__c = a.Res_Region_Name__c;
//acc.Res_Special_Pricing__c = a.Res_Special_Pricing__c;
acc.Res_TM_Number__c = a.Res_TM_Number__c;
//acc.Res_TM__c = a.Res_TM__c;
acc.Secondary_Warehouse__c = a.Secondary_Warehouse__c;
acc.Special_Instructions__c = a.Special_Instructions__c;
//acc.//Standard_Weight_Guidelines__c = a.Standard_Weight_Guidelines__c;
acc.Status__c = a.Status__c;
acc.Transportation_Method__c = a.Transportation_Method__c;
acc.Sales_District_lookup__c = a.Sales_District_lookup__c;
acc.Finishing_Territory__c = a.Finishing_Territory__c;
acc.Mechanical_Territory__c = a.Mechanical_Territory__c;
//acclist.add(acc);

insert acc;

/*Hierarchy_Ship_to_and_sold_to__c h = new Hierarchy_Ship_to_and_sold_to__c();
h.sold_to__c = a.Id;
h.ship_to__c = acc.Id;
h.ext_id__c = acc.SAP_ACCOUNT__c+'_'+a.SAP_ACCOUNT__c;
upsert h ext_id__c;*/

}

//insert acclist;

}

global void finish(Database.BatchableContext BC)

{

}

}