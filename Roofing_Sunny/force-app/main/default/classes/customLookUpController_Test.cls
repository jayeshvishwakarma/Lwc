@isTest
public class customLookUpController_Test {
    @testSetup static void setupData() {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Indirect Accounts').getRecordTypeId();       
        List<Account> sold_To_Accts = new List<Account>();
        for(Integer i=0;i<100;i++) {
            Account act = new Account();
            act.Name = 'TestAcct'+i;
            act.ShippingStreet ='Test Address' + i;
            act.ShippingCity = 'Houston';
            act.ShippingState = 'TX';
            act.ShippingCountry ='United States';
            act.ShippingPostalCode = '77002';
            act.RecordTypeId = recordTypeId;
            act.SAP_ACCOUNT__c = 'TST' + i;
            act.Hierarchy_Level_BPCS__c = '4-Sold To';
            act.Status__c = 'Active';
            sold_To_Accts.add(act);
        }
        insert sold_To_Accts;
    }
    @isTest static void testfetchLookUpValues(){   
        customLookUpController.fetchLookUpValues('TST', 'SAP_ACCOUNT__c, Name', ',ShippingCity', 'SAP_ACCOUNT__c, Name', 'Hierarchy_Level_BPCS__c = \'4-Sold To\' AND Status__c = \'Active\'', 'Name', 'Account', false);
    }
    @isTest static void testfetchLookUpValues_Globalsearch(){    
        customLookUpController.fetchLookUpValues('TST', 'SAP_ACCOUNT__c, Name', ',ShippingCity', 'SAP_ACCOUNT__c, Name', 'Hierarchy_Level_BPCS__c = \'4-Sold To\' AND Status__c = \'Active\'', 'Name', 'Account', true);
    }
}