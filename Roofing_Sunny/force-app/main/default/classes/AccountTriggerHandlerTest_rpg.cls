@isTest
public class AccountTriggerHandlerTest_rpg { 
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
            act.SAP_SalesOrg_Account__c = act.SAP_ACCOUNT__c + '-' + '1501SP';
            act.LOB__c = '1501';
            sold_To_Accts.add(act);
        }
        insert sold_To_Accts;    
     }
    @isTest public static void createShiptoAccountsTest(){
        List<Account> sold_To_Accts = [SELECT Id, Name,ShippingStreet, ShippingState, ShippingCountry, ShippingPostalCode,SAP_ACCOUNT__c, 
                                       RecordTypeId,Hierarchy_Level_BPCS__c,LOB__c, SAP_SalesOrg_Account__c,Status__c FROM Account where Hierarchy_Level_BPCS__c = '4-Sold To'];
        //AccountTriggerHandler.createShiptoAccounts(sold_To_Accts);
        
        List<Account> ship_To_Accts = [SELECT Id, Name,ShippingStreet, ShippingState, ShippingCountry, ShippingPostalCode,SAP_ACCOUNT__c, 
                                       RecordTypeId,Hierarchy_Level_BPCS__c,LOB__c, SAP_SalesOrg_Account__c,Status__c FROM Account where Hierarchy_Level_BPCS__c = '3-Ship To'];        
        //List<Hierarchy_Ship_to_and_sold_to__c> HierarchyShipto_and_sold_to = [SELECT Id FROM Hierarchy_Ship_to_and_sold_to__c];
        system.assertEquals(sold_To_Accts.Size(), ship_To_Accts.size());
        system.assertEquals('TST0-1501', ship_To_Accts[0].SAP_SalesOrg_Account__c);
        //system.assertEquals(100, HierarchyShipto_and_sold_to.size()); 
    }
     @isTest public static void updateShiptoAccountsTest(){
         Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Indirect Accounts').getRecordTypeId();  
         List<Account> ship_To_Accts = new List<Account>();
       
         List<Account> sold_To_Accts = new List<Account>();
         for(Account soldTo : [SELECT Id, Name,ShippingStreet, ShippingState, ShippingCountry, ShippingPostalCode,SAP_ACCOUNT__c, 
                               RecordTypeId,Hierarchy_Level_BPCS__c,LOB__c, SAP_SalesOrg_Account__c,Status__c FROM Account where Hierarchy_Level_BPCS__c = '4-Sold To']){
                                   soldTo.Name = 'Update ' + soldTo.Name;
                                   sold_To_Accts.add(soldTo);           
                               }
        update sold_To_Accts;
        ship_To_Accts = [SELECT Id, Name,ShippingStreet, ShippingState, ShippingCountry, ShippingPostalCode,SAP_ACCOUNT__c, 
                                       RecordTypeId,Hierarchy_Level_BPCS__c,LOB__c, SAP_SalesOrg_Account__c,Status__c FROM Account where Hierarchy_Level_BPCS__c = '3-Ship To'];         
        //List<Hierarchy_Ship_to_and_sold_to__c> HierarchyShipto_and_sold_to = [SELECT Id FROM Hierarchy_Ship_to_and_sold_to__c];
        system.assertEquals(sold_To_Accts.Size(), ship_To_Accts.size());
        system.assertEquals('Update TestAcct0', ship_To_Accts[0].Name);
        //system.assertEquals(100, HierarchyShipto_and_sold_to.size()); 
     }
}