/* *********************************************************
 * Name: TWoD_RuleEngine_Test
 * Created By : Hampesh
 * Created Date: 06-04-2017
 *
********************************************************** */ 

@isTest
public class TWoD_RuleEngine_Test
{ 
   @testSetup static void setup() 
   {    
       twod__WOD__c csWOD_ExecutePaymentDefinitionTrigger = twod_TestDataFactory.createWODCustomSetting_ForExecutePaymentDefinitionTrigger();
       insert csWOD_ExecutePaymentDefinitionTrigger;
    
        twod__Payment_Definitions__c paymtDefinition = twod_TestDataFactory.CreatePaymentDefination('testPaymentDef');
        insert paymtDefinition;
       
        List<twod__Policy_Definition__c> plcyDefList = new List<twod__Policy_Definition__c>();
        twod__Policy_Definition__c plcyDef =new twod__Policy_Definition__c();
        plcyDef.Name = 'testplDf1';
        plcyDef.twod__Active_From__c = System.today().addDays(-30);
        plcyDef.twod__Active_Until__c = System.today().addDays(40);
        plcyDef.twod__Priority__c = 1;
        plcyDef.twod__Months_Covered__c = 15;
        plcyDef.twod__Payment_Definition__c = paymtDefinition.id;
        plcyDef.twod__Type__c = 'Standard';
        plcyDef.twod__Sub_Type__c = 'Marketing';
        plcyDef.twod__Status__c = 'Active';
        plcyDefList.add(plcyDef);
        
        twod__Policy_Definition__c plcyDef1 =new twod__Policy_Definition__c();
        plcyDef1.Name = 'testplDf2';
        plcyDef1.twod__Active_From__c = System.today().addDays(-20);
        plcyDef1.twod__Active_Until__c = System.today().addDays(30);
        plcyDef1.twod__Priority__c = 2;
        plcyDef1.twod__Months_Covered__c = 20;
        plcyDef1.twod__Payment_Definition__c = paymtDefinition.id;
        plcyDef1.twod__Type__c = 'Standard';
        plcyDef1.twod__Sub_Type__c = 'Marketing';
        plcyDef1.twod__Status__c = 'Active';
        plcyDefList.add(plcyDef1);
        
        twod__Policy_Definition__c plcyDef3 =new twod__Policy_Definition__c();
        plcyDef3.Name = 'testplDf3';
        plcyDef3.twod__Active_From__c = System.today().addDays(-20);
        plcyDef3.twod__Active_Until__c = System.today().addDays(20);
        plcyDef3.twod__Priority__c = 3;
        plcyDef3.twod__Months_Covered__c = 10;
        plcyDef3.twod__Payment_Definition__c = paymtDefinition.id;
        plcyDef3.twod__Type__c = 'Standard';
        plcyDef3.twod__Sub_Type__c = 'Marketing';
        plcyDef3.twod__Status__c = 'Active';
        plcyDefList.add(plcyDef3);
        
        insert plcyDefList;
              
        twod__WOD__c cs2 = twod_TestDataFactory.createWODCustomSetting_ForEnableWarrantyRuleCriteriaTrigger();
        insert cs2;
        
     List<twod__Warranty_Rule__c> wRuleList = new List<twod__Warranty_Rule__c>();
     twod__Warranty_Rule__c wRule = new twod__Warranty_Rule__c();
     wRule.name='W Rule1';
     wRule.twod__Object_Type__c='Claim'; //Account
     wRule.twod__Object_API_Name__c='twod__Claim__c';
     wRule.twod__Logical_Grouping__c='AND';
     wRule.twod__Rule_Type__c='Eligibility Rule';
     wRuleList.add(wRule);
     
      twod__Warranty_Rule__c wRule1 = new twod__Warranty_Rule__c();
     wRule1.name='W Rule2';
     wRule1.twod__Object_Type__c='Claim'; //Account
     wRule1.twod__Object_API_Name__c='twod__Claim__c';
     wRule1.twod__Logical_Grouping__c='AND';
     wRule1.twod__Rule_Type__c='Eligibility Rule';
     wRuleList.add(wRule1); 
     
     insert wRuleList;
     
     List<twod__Warranty_Rule_Criteria__c> wRuleCriteriaList = new List<twod__Warranty_Rule_Criteria__c>();
     
     twod__Warranty_Rule_Criteria__c wRuleCriteria1 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria1.twod__Warranty_Rule__c=wRule.id;
     wRuleCriteria1.twod__Field_Name__c='Travel ( By Distance)';
     wRuleCriteria1.twod__Sequence__c=1;
     wRuleCriteria1.twod__Criteria_Type__c='Not Equal To';
     wRuleCriteria1.twod__Criteria_Value__c='15';
     wRuleCriteria1.twod__Field_API_Name__c='twod__TravelByDistance__c'; 
     wRuleCriteria1.twod__Field_Type__c='NUMBER';
     wRuleCriteriaList.add(wRuleCriteria1); 
     twod__Warranty_Rule_Criteria__c wRuleCriteria2 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria2.twod__Warranty_Rule__c=wRule.id;
     wRuleCriteria2.twod__Field_Name__c='Travel ( By Distance)';
     wRuleCriteria2.twod__Sequence__c=2;
     wRuleCriteria2.twod__Criteria_Type__c='Greater Than';
     wRuleCriteria2.twod__Criteria_Value__c='8';
     wRuleCriteria2.twod__Field_API_Name__c='twod__TravelByDistance__c'; 
     wRuleCriteria2.twod__Field_Type__c='NUMBER';
     wRuleCriteriaList.add(wRuleCriteria2);
     
      twod__Warranty_Rule_Criteria__c wRuleCriteria3 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria3.twod__Warranty_Rule__c=wRule1.id;
     wRuleCriteria3.twod__Field_Name__c='Travel ( By Distance)';
     wRuleCriteria3.twod__Sequence__c=3;
     wRuleCriteria3.twod__Criteria_Type__c='Greater Than';
     wRuleCriteria3.twod__Criteria_Value__c='5';
     wRuleCriteria3.twod__Field_API_Name__c='twod__TravelByDistance__c'; 
     wRuleCriteria3.twod__Field_Type__c='NUMBER';
     wRuleCriteriaList.add(wRuleCriteria3);
     insert wRuleCriteriaList;
       
     wRule.twod__Enabled__c = true;
     update wRule;       
        
  }   
  
  public static testmethod void testMethod1()
  {
    Test.startTest();
    
    twod__WOD__c csWOD_ExecuteClaimTriggerForPolicyChange = twod_TestDataFactory.createWODCustomSetting_ForExecuteClaimTriggerForPolicyChange();
    insert csWOD_ExecuteClaimTriggerForPolicyChange;
    
    List<String> customSettingVal = new List<String>();
    twod__WOD__c  allPaymentConfig = twod_TestDataFactory.createWODCustomSetting_AllPaymentConfigurations();
    customSettingVal = allPaymentConfig.twod__Trigger_Value__c.split(',');
    customSettingVal.add('Parts');
    insert allPaymentConfig;
    
    twod__WOD__c  allprefixconfig = twod_TestDataFactory.createWODCustomSetting_AllPrefixConfigurations();
    insert allprefixconfig;
    
    //Custom setting data
    twod__WOD__c cs1 = new twod__WOD__c();
    cs1.name='Enable TwodClaimsTrigger';
    cs1.twod__isTriggered__c=True;
    insert cs1;
    
    twod__WOD__c cs3 = twod_TestDataFactory.createWODCustomSetting_ForEnableWarrantyRuleAssociationTrigger();
    insert cs3;
    
    Account acc1 = twod_TestDataFactory.createAccount('testAcc1','Testing1','Dealer'); 
    acc1.BillingCountry='United States';
    acc1.BillingState ='New York';  
    acc1.billingcity='test';
    acc1.billingstreet='test'; 
    acc1.BillingPostalCode = '12345'; 
    insert acc1;
    
    twod__WOD__c cs4 = new twod__WOD__c();
    cs4.name='Enable WarrantyProductTrigger';
    cs4.twod__isTriggered__c=True;
    insert cs4;
    
    twod__WOD__c cs5 = new twod__WOD__c();
    cs5.name='Enable RateDetailsTrigger';
    cs5.twod__isTriggered__c=True;
    insert cs5;
    
    twod__WOD__c csCustName = twod_TestDataFactory.createWODCustomSetting_ForEnableChangeCustomerName();
    insert csCustName;
            
    Account acc2 = twod_TestDataFactory.createAccount('testAcc2','Testing2','Dealer');
    acc2.ParentId = acc1.Id;
    acc2.ParentId = acc1.Id;
    acc2.BillingCountry='United States';
    acc2.BillingState ='New York';
    acc2.billingcity='test';
    acc2.billingstreet='test'; 
    acc2.BillingPostalCode = '12345';
    insert acc2;
    
    List<RecordType> recordTypeList_Product = [SELECT DeveloperName, SobjectType FROM RecordType WHERE DeveloperName = 'Item' AND SobjectType = 'twod__Warranty_Product__c'];
    Id productRecordTypeId;
    if(recordTypeList_Product != null && !recordTypeList_Product.isEmpty()){
        productRecordTypeId = recordTypeList_Product[0].id;
    }
  
    twod__Warranty_Product__c product = twod_TestDataFactory.createWarrantyProduct(productRecordTypeId,'test product','1',true,'Non-Serialized','Item','Machine','Hours');
   
    insert product;
    twod__Warranty_Product__c product1 = twod_TestDataFactory.createWarrantyProduct(productRecordTypeId,'test product','1',true,'Serialized','Item','Machine','Hours');
      
    insert product1;
    
    List<RecordType> recordTypeList_Inventory = [SELECT DeveloperName,SobjectType FROM RecordType WHERE DeveloperName = 'Warrantable' AND SobjectType = 'twod__Inventory__c'];
    Id inventoryRecordTypeId;
    if(recordTypeList_Inventory != null && !recordTypeList_Inventory.isEmpty()){
        inventoryRecordTypeId = recordTypeList_Inventory[0].id;
    }
    twod__Inventory__c inv = twod_TestDataFactory.createInventory(inventoryRecordTypeId,'test inventory','1','Warrantable',acc2.id, product1.id);
    insert inv;
    
    twod__Rates_Details__c RD = new twod__Rates_Details__c();
    RD.Name = 'RD001';
    RD.twod__Dealer__c = acc2.id;
    RD.twod__Status__c = 'Active';
    
    insert RD;
    
    twod__WOD__c csRD = new twod__WOD__c();
    csRD.Name = 'Default Rate';
    csRD.twod__isTriggered__c = true;
    csRD.twod__Trigger_Value__c=RD.Id;
    insert csRD;
      
    String RecTypeWC = Schema.SObjectType.twod__Warranty_Code__c.getRecordTypeInfosByName().get('Fault Code').getRecordTypeId();  
    twod__Warranty_Code__c wc = new twod__Warranty_Code__c();
    WC.Name = 'test WC';
    WC.twod__Warranty_Product__c = product.Id;
    WC.twod__Lang_Id__c = 'en_US';
    WC.RecordTypeId = RecTypeWC;
    WC.twod__Warranty_Code__c = 'WC_0050';
    insert WC;
     
     twod__Payment_Configuration__c paymentConfiguration = twod_TestDataFactory.CreatePaymentConfiguration('testpc','Test Parts');
     insert paymentConfiguration;
    
      List<twod__Policy_Definition__c> plcyDef = [Select id from twod__Policy_Definition__c];
      system.debug('list size'+plcyDef[1].id+'ids'+plcyDef[2]);
      id pdId=plcyDef[1].id;
     Set<Id> plcyDefSet = new Set<Id>{plcyDef[0].id}; 
     Set<Id> plcyDefSet2 = new Set<Id>{pdId}; //else logic
     
     List<twod__Warranty_Rule__c> wRule = [select id, name, twod__Warranty_Rule__c.twod__Enabled__c, twod__Rule_Type__c,
     twod__Object_API_Name__c, twod__Object_Type__c,twod__Logical_Grouping__c, twod__No_Of_Rule_Criteria__c
      from twod__Warranty_Rule__c];
    
     List<twod__Warranty_Rule_Criteria__c> wRuleCriteriaList = [select id, name, 
     twod__Warranty_Rule__c, twod__Field_Name__c, twod__Sequence__c, twod__Criteria_Type__c, twod__Criteria_Value__c, 
     twod__Field_API_Name__c , twod__Field_Type__c , twod__Warranty_Rule_Criteria__c.twod__Field_Relation__c,
     twod__Warranty_Rule_Criteria__c.twod__Maximum_Value__c, twod__Warranty_Rule_Criteria__c.twod__Minimum_Value__c,
     twod__Warranty_Rule_Criteria__c.twod__Related_Object__c, twod__Warranty_Rule_Criteria__c.twod__Rule_Object_Type__c
     from twod__Warranty_Rule_Criteria__c limit 3];    
     
    // Query the twod__Warranty_Rule__c again to get the updated rollup summary field.
    //twod__Warranty_Rule__c wRuleAfterInsert = [Select twod__No_Of_Rule_Criteria__c from twod__Warranty_Rule__c where Id= :wRule.Id];

    set<Id> RuleIdSet = new set<Id> {wRule[0].id};
     
     twod__Warranty_Rule_Association__c wRuleAssociation = new twod__Warranty_Rule_Association__c();
     wRuleAssociation.twod__Policy_Definition__c=plcyDef[0].id;
     wRuleAssociation.twod__Warranty_Rule__c=wRule[0].id;
     wRuleAssociation.twod__Is_Active__c=true;
     insert wRuleAssociation;
     
     twod__Warranty_Rule_Association__c wRuleAssociation1 = new twod__Warranty_Rule_Association__c();
     //wRuleAssociation1.twod__Policy_Definition__c=plcyDef.id;
     wRuleAssociation1.twod__Warranty_Rule__c=wRule[0].id;
     wRuleAssociation1.twod__Is_Active__c=true;
     insert wRuleAssociation1;
    insert new twod_TriggerControl__c(SetupOwnerId=UserInfo.getOrganizationId(), 
                                          twod_Payment_Trigger__c=true,
                                          twod_AccountCreationTrigger__c=true,
                                          twod_AccountCreationWarrantyTransferTrig__c=true,
                                          twod_AnswerTrigger__c=true,
                                          twod_ClaimInterestedPartiesTrigger__c=true,
                                          twod_ClaimTrigger__c=true,
                                          twod_RecordSharingTrigger__c=true
                                         );             
    TWoD_RuleEngine.getRulesList(RuleIdSet , 'twod__Claim__c'); 
    //system.debug('1234='+TWoD_RuleEngine.getRulesList(RuleIdSet , 'twod__Claim__c'));
       
    String ClaimRT1 = Schema.SObjectType.twod__Claim__c.getRecordTypeInfosByName().get('Serialized Part').getRecordTypeId();       
    twod__Claim__c claim = twod_TestDataFactory.createClaim();
    claim.Customer__c = acc1.id;
    claim.twod__Inventory__c = inv.id;
    claim.twod__Date_Of_Purchase__c = System.today().addDays(-30);
    claim.twod__Date_of_Failure__c = system.today().addDays(-20);
    claim.twod__Date_of_Repair__c = system.today().addDays(-10);
    claim.twod__Units_Run__c = 10;
    claim.twod__Claim_Status__c = 'Draft';
    claim.twod__In_Approval_Process__c = false;
    claim.twod__Approved_Labor_Cost__c = 200;
    claim.twod__Warranty_Product__c = product.Id;
    claim.twod__Causal_Part_Number__c = product.id;
    claim.twod__Fault_Code__c = WC.Id;
    claim.twod__CLAIM_TYPE__C = 'Machine';
    claim.twod__Rate__c = RD.Id;
    claim.twod__Applicable_Policy__c = plcyDef[0].id;
    claim.recordtypeId=ClaimRT1;
    claim.twod__TravelByDistance__c=11; 
    insert claim; 
        /* twod__Claim__c claim = new twod__Claim__c();
        claim.name = 'test';
        //claim.recordtypeId=claimrecordMap.get('Standard');
        claim.twod__Claim_Status__c= 'test';
        claim.Producing_Plant__c='avery';
        claim.Product_Group__c='Residential Roofing'; 
        claim.twod__Warranty_Product__c=product.id;
        //claim.Primary_Defect_Code__c =objdc.id;
        insert claim; */
    
    twod__Claim__c claim1 = twod_TestDataFactory.createClaim();
    claim1.twod__Account__c = acc2.id;
    //claim1.twod__Inventory__c = inv.id;
    claim1.twod__Date_Of_Purchase__c = System.today().addDays(-30);
    claim1.Install_Date__c = System.today().addDays(-5);
    claim1.twod__Date_of_Failure__c = system.today().addDays(-20);
    claim1.twod__Date_of_Repair__c = system.today().addDays(-10);
    claim1.twod__Units_Run__c = 10;
    claim1.twod__Claim_Status__c = 'Draft';
    claim1.twod__In_Approval_Process__c = false;
    claim1.twod__Approved_Labor_Cost__c = 200;
    claim1.twod__Warranty_Product__c = product.Id;
    claim1.twod__Causal_Part_Number__c = product.id;
    claim1.twod__Fault_Code__c = WC.Id;
    claim1.twod__CLAIM_TYPE__C = 'Machine';
    claim1.twod__Rate__c = RD.Id;
    claim1.twod__Applicable_Policy__c = plcyDef[1].id;
    claim1.recordtypeId=ClaimRT1;
    insert claim1;
        
     
      
    //2nd wrapper Rule Criteria
    twod.RuleCriteriaWrapper rcObj = new twod.RuleCriteriaWrapper(wRuleCriteriaList[0]);
    twod.RuleCriteriaWrapper rcObj2 = new twod.RuleCriteriaWrapper(wRuleCriteriaList[2]);
    
    //Wrapper logic    
    twod.RuleWrapper rwObj = new twod.RuleWrapper(wRule[0], wRuleCriteriaList);
    rwObj.RuleId=wRule[0].id;
    rwObj.RuleName=wRule[0].name;
    rwObj.Enabled=true;
    rwObj.RuleType=wRule[0].twod__Rule_Type__c;
    rwObj.ObjectType=wRule[0].twod__Object_Type__c;
    rwObj.isPassed=True;
    
    rwObj.RuleCriteriaMap.put(1, rcObj );
    
     twod.RuleWrapper rwObj1 = new twod.RuleWrapper(wRule[1], wRuleCriteriaList);
    rwObj1.RuleId=wRule[1].id;
    rwObj1.RuleName=wRule[1].name;
    rwObj1.Enabled=true;
    rwObj1.RuleType=wRule[1].twod__Rule_Type__c;
    rwObj1.ObjectType=wRule[1].twod__Object_Type__c;
    rwObj1.isPassed=True;
    
    rwObj1.RuleCriteriaMap.put(1, rcObj2 );
    
    List<twod.RuleWrapper> allRuleWrappers = new List<twod.RuleWrapper> {rwObj, rwObj1};
    //system.debug('Wrapper object=>'+rwObj);
    //TWoD_RuleEngine.RunEligibityRules(claim, plcyDefSet);
    TWoD_RuleEngine.RunEligibityRules(claim1, plcyDefSet);
    
    TWoD_RuleEngine.RunEligibityRules(claim1, plcyDefSet2);
   //TWoD_RuleEngine.RunEligibityRules(claim, plcyDefSet2);
    
    TWoD_RuleEngine.executeRule(claim, allRuleWrappers, 'twod__Claim__c');   
    
    Test.stopTest();
   } 
   
   // Validation logic
   public static testMethod void testMethod2()
   {
       insert new twod_TriggerControl__c(SetupOwnerId=UserInfo.getOrganizationId(), 
                                          twod_Payment_Trigger__c=true,
                                          twod_AccountCreationTrigger__c=true,
                                          twod_AccountCreationWarrantyTransferTrig__c=true,
                                          twod_AnswerTrigger__c=true,
                                          twod_ClaimInterestedPartiesTrigger__c=true,
                                          twod_ClaimTrigger__c=true,
                                          twod_RecordSharingTrigger__c=true
                                         );        
      Test.startTest();
      
    twod__WOD__c csWOD_ExecutePaymentDefinitionTrigger = twod_TestDataFactory.createWODCustomSetting_ForExecutePaymentDefinitionTrigger();
    insert csWOD_ExecutePaymentDefinitionTrigger;
    
    twod__WOD__c csWOD_ExecuteClaimTriggerForPolicyChange = twod_TestDataFactory.createWODCustomSetting_ForExecuteClaimTriggerForPolicyChange();
    insert csWOD_ExecuteClaimTriggerForPolicyChange;
    
    List<String> customSettingVal = new List<String>();
    twod__WOD__c  allPaymentConfig = twod_TestDataFactory.createWODCustomSetting_AllPaymentConfigurations();
    customSettingVal = allPaymentConfig.twod__Trigger_Value__c.split(',');
    customSettingVal.add('Parts');
    insert allPaymentConfig;
    
    twod__WOD__c  allprefixconfig = twod_TestDataFactory.createWODCustomSetting_AllPrefixConfigurations();
    insert allprefixconfig;
    
    twod__WOD__c csCustName = twod_TestDataFactory.createWODCustomSetting_ForEnableChangeCustomerName();
    insert csCustName;
    
    //Custom setting data
    twod__WOD__c cs1 = new twod__WOD__c();
    cs1.name='Enable TwodClaimsTrigger';
    cs1.twod__isTriggered__c=True;
    insert cs1;
    
    twod__WOD__c cs2 = twod_TestDataFactory.createWODCustomSetting_ForEnableWarrantyRuleCriteriaTrigger();
    insert cs2;
    
    twod__WOD__c cs3 = twod_TestDataFactory.createWODCustomSetting_ForEnableWarrantyRuleAssociationTrigger();
    insert cs3;
    
    Account acc1 = twod_TestDataFactory.createAccount('testAcc1','Testing1','Dealer'); 
    acc1.BillingCountry='United States';
    acc1.BillingState ='New York';  
    acc1.billingcity='test';
    acc1.billingstreet='test'; 
    acc1.BillingPostalCode = '12345';  
    insert acc1;
    
    twod__WOD__c cs4 = new twod__WOD__c();
    cs4.name='Enable WarrantyProductTrigger';
    cs4.twod__isTriggered__c=True;
    insert cs4;
    
    twod__WOD__c cs5 = new twod__WOD__c();
    cs5.name='Enable RateDetailsTrigger';
    cs5.twod__isTriggered__c=True;
    insert cs5;
            
    Account acc2 = twod_TestDataFactory.createAccount('testAcc2','Testing2','Dealer');
    acc2.ParentId = acc1.Id;
    acc2.ParentId = acc1.Id;
    acc2.BillingCountry='United States';
    acc2.BillingState ='New York';
    acc2.billingcity='test';
    acc2.billingstreet='test'; 
    acc2.BillingPostalCode = '12345';
    insert acc2;
    
    List<RecordType> recordTypeList_Product = [SELECT DeveloperName, SobjectType FROM RecordType WHERE DeveloperName = 'Item' AND SobjectType = 'twod__Warranty_Product__c'];
    Id productRecordTypeId;
    if(recordTypeList_Product != null && !recordTypeList_Product.isEmpty()){
        productRecordTypeId = recordTypeList_Product[0].id;
    }
  
 
    
    twod__Warranty_Product__c product = twod_TestDataFactory.createWarrantyProduct(productRecordTypeId,'test product','1',true,'Non-Serialized','Item','Machine','Hours');
    
  insert product;
    twod__Warranty_Product__c product1 = twod_TestDataFactory.createWarrantyProduct(productRecordTypeId,'test product','1',true,'Serialized','Item','Machine','Hours');
       
   insert product1;
    
    List<RecordType> recordTypeList_Inventory = [SELECT DeveloperName,SobjectType FROM RecordType WHERE DeveloperName = 'Warrantable' AND SobjectType = 'twod__Inventory__c'];
    Id inventoryRecordTypeId;
    if(recordTypeList_Inventory != null && !recordTypeList_Inventory.isEmpty()){
        inventoryRecordTypeId = recordTypeList_Inventory[0].id;
    }
    twod__Inventory__c inv = twod_TestDataFactory.createInventory(inventoryRecordTypeId,'test inventory','1','Warrantable',acc2.id, product1.id);
    insert inv;
    
     
    
    twod__Rates_Details__c RD = new twod__Rates_Details__c();
    RD.Name = 'RD001';
    RD.twod__Dealer__c = acc2.id;
    RD.twod__Status__c = 'Active';
    
    insert RD;
    
    twod__WOD__c csRD = new twod__WOD__c();
    csRD.Name = 'Default Rate';
    csRD.twod__isTriggered__c = true;
    csRD.twod__Trigger_Value__c=RD.Id;
    insert csRD;
    
    String RecTypeWC = Schema.SObjectType.twod__Warranty_Code__c.getRecordTypeInfosByName().get('Fault Code').getRecordTypeId();  
    twod__Warranty_Code__c wc = new twod__Warranty_Code__c();
    WC.Name = 'test WC';
    WC.twod__Warranty_Product__c = product.Id;
    WC.twod__Lang_Id__c = 'en_US';
    WC.RecordTypeId = RecTypeWC;
    WC.twod__Warranty_Code__c = 'WC_0050';
    insert WC;
    
     twod__Payment_Definitions__c paymtDefinition = twod_TestDataFactory.CreatePaymentDefination('testPaymentDef');
     insert paymtDefinition;
     
     twod__Payment_Configuration__c paymentConfiguration = twod_TestDataFactory.CreatePaymentConfiguration('testpc','Test Parts');
     insert paymentConfiguration;
    
    
    //twod__Policy_Definition__c plcyDef = twod_TestDataFactory.CreatePolicyDefination('testplDf',paymtDefinition.id,System.today().addDays(-30),System.today().addDays(50),1,20,'Standard','Marketing',true);
    //plcyDef.twod__Status__c = 'Active';
   // insert plcyDef;
    twod__Policy_Definition__c plcyDef = [Select id from twod__Policy_Definition__c limit 1];
        
     Set<Id> plcyDefSet = new Set<Id>{plcyDef.id};
     
     twod__Warranty_Rule__c wRule = new twod__Warranty_Rule__c();
     wRule.name='W Rule1';   
     wRule.twod__Object_Type__c='twod__Claim__c';
     //wRule.twod__No_Of_Rule_Criteria__c=2;
     wRule.twod__Rule_Type__c='Eligibility Rule';
     insert wRule;
    
         
    List<twod__Warranty_Rule_Criteria__c> wRuleCriteriaList = new List<twod__Warranty_Rule_Criteria__c>();   
     
     twod__Warranty_Rule_Criteria__c wRuleCriteria = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria.twod__Warranty_Rule__c=wRule.id;
     wRuleCriteria.twod__Field_Name__c='Travel ( By Distance)';
     wRuleCriteria.twod__Sequence__c=1;
     wRuleCriteria.twod__Criteria_Type__c='Equals';
     wRuleCriteria.twod__Criteria_Value__c='10';
     wRuleCriteria.twod__Field_API_Name__c='twod__TravelByDistance__c'; 
     wRuleCriteria.twod__Field_Type__c='NUMBER';
     wRuleCriteriaList.add(wRuleCriteria); 
     //List<twod__Warranty_Rule_Criteria__c> wRuleCriteriaList = new List<twod__Warranty_Rule_Criteria__c>{wRuleCriteria};
     
     twod__Warranty_Rule_Criteria__c wRuleCriteria1 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria1.twod__Warranty_Rule__c=wRule.id;
     wRuleCriteria1.twod__Field_Name__c='Travel ( By Distance)';
     wRuleCriteria1.twod__Sequence__c=2;
     wRuleCriteria1.twod__Criteria_Type__c='Not Equal To';
     wRuleCriteria1.twod__Criteria_Value__c='-10';
     wRuleCriteria1.twod__Field_API_Name__c='twod__TravelByDistance__c'; 
     wRuleCriteria1.twod__Field_Type__c='NUMBER';
     wRuleCriteriaList.add(wRuleCriteria1); 
       
       
     twod__Warranty_Rule_Criteria__c wRuleCriteria2 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria2.twod__Warranty_Rule__c=wRule.id;
     wRuleCriteria2.twod__Field_Name__c='Travel ( By Distance)';
     wRuleCriteria2.twod__Sequence__c=3;
     wRuleCriteria2.twod__Criteria_Type__c='Greater Than';
     wRuleCriteria2.twod__Criteria_Value__c='8';
     wRuleCriteria2.twod__Field_API_Name__c='twod__TravelByDistance__c'; 
     wRuleCriteria2.twod__Field_Type__c='NUMBER';
     wRuleCriteriaList.add(wRuleCriteria2);
       
      twod__Warranty_Rule_Criteria__c wRuleCriteria3 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria3.twod__Warranty_Rule__c=wRule.id;
     wRuleCriteria3.twod__Field_Name__c='Travel ( By Distance)';
     wRuleCriteria3.twod__Sequence__c=4;
     wRuleCriteria3.twod__Criteria_Type__c='Less Than';
     wRuleCriteria3.twod__Criteria_Value__c='15';
     wRuleCriteria3.twod__Field_API_Name__c='twod__TravelByDistance__c'; 
     wRuleCriteria3.twod__Field_Type__c='NUMBER';
     wRuleCriteriaList.add(wRuleCriteria3); 
       
      twod__Warranty_Rule_Criteria__c wRuleCriteria4 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria4.twod__Warranty_Rule__c=wRule.id;
     wRuleCriteria4.twod__Field_Name__c='Travel ( By Distance)';
     wRuleCriteria4.twod__Sequence__c=5;
     wRuleCriteria4.twod__Criteria_Type__c='Greater Or Equal';
     wRuleCriteria4.twod__Criteria_Value__c='12';
     wRuleCriteria4.twod__Field_API_Name__c='twod__TravelByDistance__c'; 
     wRuleCriteria4.twod__Field_Type__c='NUMBER';
     wRuleCriteriaList.add(wRuleCriteria4); 
     
       twod__Warranty_Rule_Criteria__c wRuleCriteria5 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria5.twod__Warranty_Rule__c=wRule.id;
     wRuleCriteria5.twod__Field_Name__c='Travel ( By Distance)';
     wRuleCriteria5.twod__Sequence__c=6;
     wRuleCriteria5.twod__Criteria_Type__c='Less Or Equal';
     wRuleCriteria5.twod__Criteria_Value__c='25';
     wRuleCriteria5.twod__Field_API_Name__c='twod__TravelByDistance__c'; 
     wRuleCriteria5.twod__Field_Type__c='NUMBER';
     wRuleCriteriaList.add(wRuleCriteria5); 
       
     twod__Warranty_Rule_Criteria__c wRuleCriteria6 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria6.twod__Warranty_Rule__c=wRule.id;
     wRuleCriteria6.twod__Field_Name__c='Travel ( By Distance)';
     wRuleCriteria6.twod__Sequence__c=7;
     wRuleCriteria6.twod__Criteria_Type__c='Between';
     wRuleCriteria6.twod__Criteria_Value__c='26';
     wRuleCriteria6.twod__Field_API_Name__c='twod__TravelByDistance__c'; 
     wRuleCriteria6.twod__Field_Type__c='NUMBER';
     wRuleCriteriaList.add(wRuleCriteria6);   
             
     insert wRuleCriteriaList;  
       
     wRule.twod__Enabled__c = true;
     update wRule; 
     
    // Query the twod__Warranty_Rule__c again to get the updated rollup summary field.
    twod__Warranty_Rule__c wRuleAfterInsert = [Select twod__No_Of_Rule_Criteria__c from twod__Warranty_Rule__c where Id= :wRule.Id];
    System.assertEquals(7, wRuleAfterInsert.twod__No_Of_Rule_Criteria__c);
    
    wRule.twod__Enabled__c=true;
    update wRule;
    set<Id> RuleIdSet = new set<Id> {wRule.id};
     
    twod__Warranty_Rule_Association__c wRuleAssociation = new twod__Warranty_Rule_Association__c();
    wRuleAssociation.twod__Policy_Definition__c=plcyDef.id;
    wRuleAssociation.twod__Warranty_Rule__c=wRule.id;
    wRuleAssociation.twod__Is_Active__c = true;
    insert wRuleAssociation;
  
     
    
    String ClaimRT1 = Schema.SObjectType.twod__Claim__c.getRecordTypeInfosByName().get('Serialized Part').getRecordTypeId();
        
    twod__Claim__c claim = twod_TestDataFactory.createClaim();
    claim.twod__Account__c = acc2.id;
    claim.twod__Inventory__c = inv.id;
    claim.twod__Date_Of_Purchase__c = System.today().addDays(-30);
    claim.twod__Date_of_Failure__c = system.today().addDays(-20);
    claim.twod__Date_of_Repair__c = system.today().addDays(-10);
    claim.twod__Units_Run__c = 10;
    claim.twod__Claim_Status__c = 'Draft';
    claim.twod__In_Approval_Process__c = false;
    claim.twod__Approved_Labor_Cost__c = 200;
    claim.twod__Warranty_Product__c = product.Id;
    claim.twod__Causal_Part_Number__c = product.id;
    claim.twod__Fault_Code__c = WC.Id;
    claim.twod__CLAIM_TYPE__C = 'Machine';
    claim.twod__Rate__c = RD.Id;
    claim.twod__Applicable_Policy__c = plcyDef.id;
    claim.recordtypeId=ClaimRT1;
    claim.twod__TravelByDistance__c=10;
    insert claim;
    
    twod.RuleCriteriaWrapper rcObj = new twod.RuleCriteriaWrapper(wRuleCriteria);
    rcObj.RCId=wRuleCriteria.id;
    rcObj.RCName=wRuleCriteria.name;
    rcObj.Sequence=  Integer.valueOf(wRuleCriteria.twod__Sequence__c);
    rcObj.FieldAPIName= wRuleCriteria.twod__Field_API_Name__c;
    rcObj.FieldName=wRuleCriteria.twod__Field_Name__c;    
    rcObj.FieldType=wRuleCriteria.twod__Field_Type__c;
    rcObj.CriteriaValue= wRuleCriteria.twod__Criteria_Value__c; 
       
    twod_RuleEngine.validateRule(claim, rcObj);
     
    twod.RuleCriteriaWrapper rcObj1 = new twod.RuleCriteriaWrapper(wRuleCriteria1);
    rcObj1.RCId=wRuleCriteria1.id;
    rcObj1.RCName=wRuleCriteria1.name;
    rcObj1.Sequence=  Integer.valueOf(wRuleCriteria1.twod__Sequence__c);
    rcObj1.FieldAPIName= wRuleCriteria1.twod__Field_API_Name__c;
    rcObj1.FieldName=wRuleCriteria1.twod__Field_Name__c;    
    rcObj1.FieldType=wRuleCriteria1.twod__Field_Type__c;
    rcObj1.CriteriaValue= wRuleCriteria1.twod__Criteria_Value__c;
       
    TWoD_RuleEngine.validateRule(claim, rcObj1);    
       
    twod.RuleCriteriaWrapper rcObj2 = new twod.RuleCriteriaWrapper(wRuleCriteria2);
    rcObj2.RCId=wRuleCriteria2.id;
    rcObj2.RCName=wRuleCriteria2.name;
    rcObj2.Sequence=  Integer.valueOf(wRuleCriteria2.twod__Sequence__c);
    rcObj2.FieldAPIName= wRuleCriteria2.twod__Field_API_Name__c;
    rcObj2.FieldName=wRuleCriteria2.twod__Field_Name__c;    
    rcObj2.FieldType=wRuleCriteria2.twod__Field_Type__c;
    rcObj2.CriteriaValue= wRuleCriteria2.twod__Criteria_Value__c;
       
     TWoD_RuleEngine.validateRule(claim, rcObj2); 
       
    twod.RuleCriteriaWrapper rcObj3 = new twod.RuleCriteriaWrapper(wRuleCriteria3);
    rcObj3.RCId=wRuleCriteria3.id;
    rcObj3.RCName=wRuleCriteria3.name;
    rcObj3.Sequence=  Integer.valueOf(wRuleCriteria3.twod__Sequence__c);
    rcObj3.FieldAPIName= wRuleCriteria3.twod__Field_API_Name__c;
    rcObj3.FieldName=wRuleCriteria3.twod__Field_Name__c;    
    rcObj3.FieldType=wRuleCriteria3.twod__Field_Type__c;
    rcObj3.CriteriaValue= wRuleCriteria3.twod__Criteria_Value__c; 
      
    TWoD_RuleEngine.validateRule(claim, rcObj3); 
       
    twod.RuleCriteriaWrapper rcObj4 = new twod.RuleCriteriaWrapper(wRuleCriteria4);
    rcObj4.RCId=wRuleCriteria4.id;
    rcObj4.RCName=wRuleCriteria4.name;
    rcObj4.Sequence=  Integer.valueOf(wRuleCriteria4.twod__Sequence__c);
    rcObj4.FieldAPIName= wRuleCriteria4.twod__Field_API_Name__c;
    rcObj4.FieldName=wRuleCriteria4.twod__Field_Name__c;    
    rcObj4.FieldType=wRuleCriteria4.twod__Field_Type__c;
    rcObj4.CriteriaValue= wRuleCriteria4.twod__Criteria_Value__c;
       
     TWoD_RuleEngine.validateRule(claim, rcObj4); 
      
    twod.RuleCriteriaWrapper rcObj5 = new twod.RuleCriteriaWrapper(wRuleCriteria5);
    rcObj5.RCId=wRuleCriteria5.id;
    rcObj5.RCName=wRuleCriteria5.name;
    rcObj5.Sequence=  Integer.valueOf(wRuleCriteria5.twod__Sequence__c);
    rcObj5.FieldAPIName= wRuleCriteria5.twod__Field_API_Name__c;
    rcObj5.FieldName=wRuleCriteria5.twod__Field_Name__c;    
    rcObj5.FieldType=wRuleCriteria5.twod__Field_Type__c;
    rcObj5.CriteriaValue= wRuleCriteria5.twod__Criteria_Value__c;
       
     TWoD_RuleEngine.validateRule(claim, rcObj5);         
       
    twod.RuleCriteriaWrapper rcObj6 = new twod.RuleCriteriaWrapper(wRuleCriteria6);
    rcObj6.RCId=wRuleCriteria6.id;
    rcObj6.RCName=wRuleCriteria6.name;
    rcObj6.Sequence=  Integer.valueOf(wRuleCriteria6.twod__Sequence__c);
    rcObj6.FieldAPIName= wRuleCriteria6.twod__Field_API_Name__c;
    rcObj6.FieldName=wRuleCriteria6.twod__Field_Name__c;    
    rcObj6.FieldType=wRuleCriteria6.twod__Field_Type__c;
    rcObj6.CriteriaValue= wRuleCriteria6.twod__Criteria_Value__c;
    rcObj6.MinimumValue='5';
    rcObj6.MaximumValue='30';
  
     TWoD_RuleEngine.validateRule(claim, rcObj6);
             
     Test.stopTest(); 
      
   }
   
  
   public static testMethod void testMethod3()
   {
      Test.startTest();
      insert new twod_TriggerControl__c(SetupOwnerId=UserInfo.getOrganizationId(), 
                                          twod_Payment_Trigger__c=true,
                                          twod_AccountCreationTrigger__c=true,
                                          twod_AccountCreationWarrantyTransferTrig__c=true,
                                          twod_AnswerTrigger__c=true,
                                          twod_ClaimInterestedPartiesTrigger__c=true,
                                          twod_ClaimTrigger__c=true,
                                          twod_RecordSharingTrigger__c=true
                                         );        
    twod__WOD__c csWOD_ExecutePaymentDefinitionTrigger = twod_TestDataFactory.createWODCustomSetting_ForExecutePaymentDefinitionTrigger();
    insert csWOD_ExecutePaymentDefinitionTrigger;
    
    twod__WOD__c csWOD_ExecuteClaimTriggerForPolicyChange = twod_TestDataFactory.createWODCustomSetting_ForExecuteClaimTriggerForPolicyChange();
    insert csWOD_ExecuteClaimTriggerForPolicyChange;
    
    List<String> customSettingVal = new List<String>();
    twod__WOD__c  allPaymentConfig = twod_TestDataFactory.createWODCustomSetting_AllPaymentConfigurations();
    customSettingVal = allPaymentConfig.twod__Trigger_Value__c.split(',');
    customSettingVal.add('Parts');
    insert allPaymentConfig;
    
    twod__WOD__c  allprefixconfig = twod_TestDataFactory.createWODCustomSetting_AllPrefixConfigurations();
    insert allprefixconfig;
    
    twod__WOD__c csCustName = twod_TestDataFactory.createWODCustomSetting_ForEnableChangeCustomerName();
    insert csCustName;
    
    //Custom setting data
    twod__WOD__c cs1 = new twod__WOD__c();
    cs1.name='Enable TwodClaimsTrigger';
    cs1.twod__isTriggered__c=True;
    insert cs1;
    
    twod__WOD__c cs2 = twod_TestDataFactory.createWODCustomSetting_ForEnableWarrantyRuleCriteriaTrigger();
    insert cs2;
    
    twod__WOD__c cs3 = twod_TestDataFactory.createWODCustomSetting_ForEnableWarrantyRuleAssociationTrigger();
    insert cs3;
    
    Account acc1 = twod_TestDataFactory.createAccount('testAcc1','Testing1','Dealer'); 
    acc1.BillingCountry='United States';
    acc1.BillingState ='New York'; 
    acc1.billingcity='test';
    acc1.billingstreet='test'; 
    acc1.BillingPostalCode = '12345';   
    insert acc1;
    
    twod__WOD__c cs4 = new twod__WOD__c();
    cs4.name='Enable WarrantyProductTrigger';
    cs4.twod__isTriggered__c=True;
    insert cs4;
    
    twod__WOD__c cs5 = new twod__WOD__c();
    cs5.name='Enable RateDetailsTrigger';
    cs5.twod__isTriggered__c=True;
    insert cs5;
            
    Account acc2 = twod_TestDataFactory.createAccount('testAcc2','Testing2','Dealer');
    acc2.ParentId = acc1.Id;
    acc2.ParentId = acc1.Id;
    acc2.BillingCountry='United States';
    acc2.BillingState ='New York';
    acc2.billingcity='test';
    acc2.billingstreet='test'; 
    acc2.BillingPostalCode = '12345';
    insert acc2;
    
    List<RecordType> recordTypeList_Product = [SELECT DeveloperName, SobjectType FROM RecordType WHERE DeveloperName = 'Item' AND SobjectType = 'twod__Warranty_Product__c'];
    Id productRecordTypeId;
    if(recordTypeList_Product != null && !recordTypeList_Product.isEmpty()){
        productRecordTypeId = recordTypeList_Product[0].id;
    }
    
    
    
    twod__Warranty_Product__c product = twod_TestDataFactory.createWarrantyProduct(productRecordTypeId,'test product','1',true,'Non-Serialized','Item','Machine','Hours');
   
  insert product;
    twod__Warranty_Product__c product1 = twod_TestDataFactory.createWarrantyProduct(productRecordTypeId,'test product','1',true,'Serialized','Item','Machine','Hours');
        
   insert product1;
    
    List<RecordType> recordTypeList_Inventory = [SELECT DeveloperName,SobjectType FROM RecordType WHERE DeveloperName = 'Warrantable' AND SobjectType = 'twod__Inventory__c'];
    Id inventoryRecordTypeId;
    if(recordTypeList_Inventory != null && !recordTypeList_Inventory.isEmpty()){
        inventoryRecordTypeId = recordTypeList_Inventory[0].id;
    }
    twod__Inventory__c inv = twod_TestDataFactory.createInventory(inventoryRecordTypeId,'test inventory','1','Warrantable',acc2.id, product1.id);
    insert inv;
    
     
    
    twod__Rates_Details__c RD = new twod__Rates_Details__c();
    RD.Name = 'RD001';
    RD.twod__Dealer__c = acc2.id;
    RD.twod__Status__c = 'Active';
    
    insert RD;
    
    twod__WOD__c csRD = new twod__WOD__c();
    csRD.Name = 'Default Rate';
    csRD.twod__isTriggered__c = true;
    csRD.twod__Trigger_Value__c=RD.Id;
    insert csRD;
    
    String RecTypeWC = Schema.SObjectType.twod__Warranty_Code__c.getRecordTypeInfosByName().get('Fault Code').getRecordTypeId();  
    twod__Warranty_Code__c wc = new twod__Warranty_Code__c();
    WC.Name = 'test WC';
    WC.twod__Warranty_Product__c = product.Id;
    WC.twod__Lang_Id__c = 'en_US';
    WC.RecordTypeId = RecTypeWC;
    WC.twod__Warranty_Code__c = 'WC_0050';
    insert WC;
    
     twod__Payment_Definitions__c paymtDefinition = twod_TestDataFactory.CreatePaymentDefination('testPaymentDef');
     insert paymtDefinition;
     
     twod__Payment_Configuration__c paymentConfiguration = twod_TestDataFactory.CreatePaymentConfiguration('testpc','Test Parts');
     insert paymentConfiguration;

     twod__Policy_Definition__c plcyDef = [Select id from twod__Policy_Definition__c limit 1];
   // twod__Policy_Definition__c plcyDef = twod_TestDataFactory.CreatePolicyDefination('testplDf',paymtDefinition.id,System.today().addDays(-30),System.today().addDays(50),1,20,'Standard','Marketing',true);
   // plcyDef.twod__Status__c = 'Active';
  //  insert plcyDef;
        
     Set<Id> plcyDefSet = new Set<Id>{plcyDef.id};
           
     twod__Warranty_Rule__c wRule1 = new twod__Warranty_Rule__c();
     wRule1.name='W Rule1';   
     wRule1.twod__Object_Type__c='twod__Claim__c';
     wRule1.twod__Rule_Type__c='Eligibility Rule';
     insert wRule1;
       
       List<twod__Warranty_Rule_Criteria__c> wRuleCriteriaList2 = new List<twod__Warranty_Rule_Criteria__c>(); 
       
      twod__Warranty_Rule_Criteria__c wRuleCriteria7 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria7.twod__Warranty_Rule__c=wRule1.id;
     wRuleCriteria7.twod__Field_Name__c='Date Of Purchase';
     wRuleCriteria7.twod__Sequence__c=8;
     wRuleCriteria7.twod__Criteria_Type__c='Equals';
     wRuleCriteria7.twod__Criteria_Value__c= Date.Today().addDays(-30).format(); //'3/25/2017';
     wRuleCriteria7.twod__Field_API_Name__c='twod__Date_Of_Purchase__c'; 
     wRuleCriteria7.twod__Field_Type__c='DATE';
     wRuleCriteriaList2.add(wRuleCriteria7); 
    
     twod__Warranty_Rule_Criteria__c wRuleCriteria8 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria8.twod__Warranty_Rule__c=wRule1.id;
     wRuleCriteria8.twod__Field_Name__c='Date Of Purchase';
     wRuleCriteria8.twod__Sequence__c=9;
     wRuleCriteria8.twod__Criteria_Type__c='Not Equal To';
     wRuleCriteria8.twod__Criteria_Value__c=Date.Today().addDays(-10).format(); //'5/25/2017';
     wRuleCriteria8.twod__Field_API_Name__c='twod__Date_Of_Purchase__c'; 
     wRuleCriteria8.twod__Field_Type__c='DATE';
     wRuleCriteriaList2.add(wRuleCriteria8); 
      
      twod__Warranty_Rule_Criteria__c wRuleCriteria9 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria9.twod__Warranty_Rule__c=wRule1.id;
     wRuleCriteria9.twod__Field_Name__c='Date Of Purchase';
     wRuleCriteria9.twod__Sequence__c=10;
     wRuleCriteria9.twod__Criteria_Type__c='Greater Than';
     wRuleCriteria9.twod__Criteria_Value__c=Date.Today().addDays(-40).format(); //'3/25/2016';
     wRuleCriteria9.twod__Field_API_Name__c='twod__Date_Of_Purchase__c'; 
     wRuleCriteria9.twod__Field_Type__c='DATE';
     wRuleCriteriaList2.add(wRuleCriteria9); 
   
    twod__Warranty_Rule_Criteria__c wRuleCriteria10 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria10.twod__Warranty_Rule__c=wRule1.id;
     wRuleCriteria10.twod__Field_Name__c='Date Of Purchase';
     wRuleCriteria10.twod__Sequence__c=11;
     wRuleCriteria10.twod__Criteria_Type__c='Greater Or Equal';
     wRuleCriteria10.twod__Criteria_Value__c=Date.Today().addDays(-35).format(); //'3/25/2016';
     wRuleCriteria10.twod__Field_API_Name__c='twod__Date_Of_Purchase__c'; 
     wRuleCriteria10.twod__Field_Type__c='DATE';
     wRuleCriteriaList2.add(wRuleCriteria10); 
   
     twod__Warranty_Rule_Criteria__c wRuleCriteria11 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria11.twod__Warranty_Rule__c=wRule1.id;
     wRuleCriteria11.twod__Field_Name__c='Date Of Purchase';
     wRuleCriteria11.twod__Sequence__c=12;
     wRuleCriteria11.twod__Criteria_Type__c='Less Than';
     wRuleCriteria11.twod__Criteria_Value__c=Date.Today().addDays(1).format(); //'5/25/2017';
     wRuleCriteria11.twod__Field_API_Name__c='twod__Date_Of_Purchase__c'; 
     wRuleCriteria11.twod__Field_Type__c='DATE';
     wRuleCriteriaList2.add(wRuleCriteria11); 
   
    twod__Warranty_Rule_Criteria__c wRuleCriteria12 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria12.twod__Warranty_Rule__c=wRule1.id;
     wRuleCriteria12.twod__Field_Name__c='Date Of Purchase';
     wRuleCriteria12.twod__Sequence__c=13;
     wRuleCriteria12.twod__Criteria_Type__c='Less Or Equal';
     wRuleCriteria12.twod__Criteria_Value__c=Date.Today().format(); //'3/25/2016';
     wRuleCriteria12.twod__Field_API_Name__c='twod__Date_Of_Purchase__c'; 
     wRuleCriteria12.twod__Field_Type__c='DATE';
     wRuleCriteriaList2.add(wRuleCriteria12);  
       
     twod__Warranty_Rule_Criteria__c wRuleCriteria13 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria13.twod__Warranty_Rule__c=wRule1.id;
     wRuleCriteria13.twod__Field_Name__c='Date Of Purchase';
     wRuleCriteria13.twod__Sequence__c=14;
     wRuleCriteria13.twod__Criteria_Type__c='Between';
     wRuleCriteria13.twod__Criteria_Value__c=Date.Today().addDays(5).format(); //'3/30/2017';
     wRuleCriteria13.twod__Field_API_Name__c='twod__Date_Of_Purchase__c'; 
     wRuleCriteria13.twod__Field_Type__c='DATE';
     wRuleCriteriaList2.add(wRuleCriteria13); 
     
     insert wRuleCriteriaList2;
       
     wRule1.twod__Enabled__c = true;
     update wRule1; 
     
    // Query the twod__Warranty_Rule__c again to get the updated rollup summary field.
    twod__Warranty_Rule__c wRuleAfterInsert = [Select twod__No_Of_Rule_Criteria__c from twod__Warranty_Rule__c where Id= :wRule1.Id];
    //System.assertEquals(7, wRuleAfterInsert.twod__No_Of_Rule_Criteria__c);
    
    wRule1.twod__Enabled__c=true;
    update wRule1;
    set<Id> RuleIdSet = new set<Id> {wRule1.id};
     
    twod__Warranty_Rule_Association__c wRuleAssociation = new twod__Warranty_Rule_Association__c();
    wRuleAssociation.twod__Policy_Definition__c=plcyDef.id;
    wRuleAssociation.twod__Warranty_Rule__c=wRule1.id;
    wRuleAssociation.twod__Is_Active__c = true;
    insert wRuleAssociation;   
    
    String ClaimRT1 = Schema.SObjectType.twod__Claim__c.getRecordTypeInfosByName().get('Serialized Part').getRecordTypeId();
        
    twod__Claim__c claim = twod_TestDataFactory.createClaim();
    claim.twod__Account__c = acc2.id;
    claim.twod__Inventory__c = inv.id;
    claim.twod__Date_Of_Purchase__c = System.today().addDays(-30);
    claim.twod__Date_of_Failure__c = system.today().addDays(-20);
    claim.twod__Date_of_Repair__c = system.today().addDays(-10);
    claim.twod__Units_Run__c = 10;
    claim.twod__Claim_Status__c = 'Draft';
    claim.twod__In_Approval_Process__c = false;
    claim.twod__Approved_Labor_Cost__c = 200;
    claim.twod__Warranty_Product__c = product.Id;
    claim.twod__Causal_Part_Number__c = product.id;
    claim.twod__Fault_Code__c = WC.Id;
    claim.twod__CLAIM_TYPE__C = 'Machine';
    claim.twod__Rate__c = RD.Id;
    claim.twod__Applicable_Policy__c = plcyDef.id;
    claim.recordtypeId=ClaimRT1;
    claim.twod__TravelByDistance__c=10;
    insert claim;
         
    //FiedType  = DATE
    twod.RuleCriteriaWrapper rcObj7 = new twod.RuleCriteriaWrapper(wRuleCriteria7);
    rcObj7.RCId=wRuleCriteria7.id;
    rcObj7.RCName=wRuleCriteria7.name;
    rcObj7.Sequence=  Integer.valueOf(wRuleCriteria7.twod__Sequence__c);
    rcObj7.FieldAPIName= wRuleCriteria7.twod__Field_API_Name__c;
    rcObj7.FieldName=wRuleCriteria7.twod__Field_Name__c;    
    rcObj7.FieldType=wRuleCriteria7.twod__Field_Type__c;
    rcObj7.CriteriaValue= wRuleCriteria7.twod__Criteria_Value__c;
        
     TWoD_RuleEngine.validateRule(claim, rcObj7); 
       
       
    twod.RuleCriteriaWrapper rcObj8 = new twod.RuleCriteriaWrapper(wRuleCriteria8);
    rcObj8.RCId=wRuleCriteria8.id;
    rcObj8.RCName=wRuleCriteria8.name;
    rcObj8.Sequence=  Integer.valueOf(wRuleCriteria8.twod__Sequence__c);
    rcObj8.FieldAPIName= wRuleCriteria8.twod__Field_API_Name__c;
    rcObj8.FieldName=wRuleCriteria8.twod__Field_Name__c;    
    rcObj8.FieldType=wRuleCriteria8.twod__Field_Type__c;
    rcObj8.CriteriaValue= wRuleCriteria8.twod__Criteria_Value__c;
        
     TWoD_RuleEngine.validateRule(claim, rcObj8);  
       
     twod.RuleCriteriaWrapper rcObj9 = new twod.RuleCriteriaWrapper(wRuleCriteria9);
    rcObj9.RCId=wRuleCriteria9.id;
    rcObj9.RCName=wRuleCriteria9.name;
    rcObj9.Sequence=  Integer.valueOf(wRuleCriteria9.twod__Sequence__c);
    rcObj9.FieldAPIName= wRuleCriteria9.twod__Field_API_Name__c;
    rcObj9.FieldName=wRuleCriteria9.twod__Field_Name__c;    
    rcObj9.FieldType=wRuleCriteria9.twod__Field_Type__c;
    rcObj9.CriteriaValue= wRuleCriteria9.twod__Criteria_Value__c;
        
     TWoD_RuleEngine.validateRule(claim, rcObj9); 
         
    twod.RuleCriteriaWrapper rcObj10 = new twod.RuleCriteriaWrapper(wRuleCriteria10);
    rcObj10.RCId=wRuleCriteria10.id;
    rcObj10.RCName=wRuleCriteria10.name;
    rcObj10.Sequence=  Integer.valueOf(wRuleCriteria10.twod__Sequence__c);
    rcObj10.FieldAPIName= wRuleCriteria10.twod__Field_API_Name__c;
    rcObj10.FieldName=wRuleCriteria10.twod__Field_Name__c;    
    rcObj10.FieldType=wRuleCriteria10.twod__Field_Type__c;
    rcObj10.CriteriaValue= wRuleCriteria10.twod__Criteria_Value__c;
        
     TWoD_RuleEngine.validateRule(claim, rcObj10); 
       
      twod.RuleCriteriaWrapper rcObj11 = new twod.RuleCriteriaWrapper(wRuleCriteria11);
    rcObj11.RCId=wRuleCriteria11.id;
    rcObj11.RCName=wRuleCriteria11.name;
    rcObj11.Sequence=  Integer.valueOf(wRuleCriteria11.twod__Sequence__c);
    rcObj11.FieldAPIName= wRuleCriteria11.twod__Field_API_Name__c;
    rcObj11.FieldName=wRuleCriteria11.twod__Field_Name__c;    
    rcObj11.FieldType=wRuleCriteria11.twod__Field_Type__c;
    rcObj11.CriteriaValue= wRuleCriteria11.twod__Criteria_Value__c;
        
     TWoD_RuleEngine.validateRule(claim, rcObj11); 
      
   
    twod.RuleCriteriaWrapper rcObj12 = new twod.RuleCriteriaWrapper(wRuleCriteria12);
    rcObj12.RCId=wRuleCriteria12.id;
    rcObj12.RCName=wRuleCriteria12.name;
    rcObj12.Sequence=  Integer.valueOf(wRuleCriteria12.twod__Sequence__c);
    rcObj12.FieldAPIName= wRuleCriteria12.twod__Field_API_Name__c;
    rcObj12.FieldName=wRuleCriteria12.twod__Field_Name__c;    
    rcObj12.FieldType=wRuleCriteria12.twod__Field_Type__c;
    rcObj12.CriteriaValue= wRuleCriteria12.twod__Criteria_Value__c;
        
    TWoD_RuleEngine.validateRule(claim, rcObj12); 
    
    twod.RuleCriteriaWrapper rcObj13 = new twod.RuleCriteriaWrapper(wRuleCriteria13);
    rcObj13.RCId=wRuleCriteria13.id;
    rcObj13.RCName=wRuleCriteria13.name;
    rcObj13.Sequence=  Integer.valueOf(wRuleCriteria13.twod__Sequence__c);
    rcObj13.FieldAPIName= wRuleCriteria13.twod__Field_API_Name__c;
    rcObj13.FieldName=wRuleCriteria13.twod__Field_Name__c;    
    rcObj13.FieldType=wRuleCriteria13.twod__Field_Type__c;
    rcObj13.CriteriaValue= wRuleCriteria13.twod__Criteria_Value__c;
    rcObj13.MinimumValue=Date.Today().addDays(-10).format(); //'3/26/2017';
    rcObj13.MaximumValue=Date.Today().addDays(25).format(); //'5/26/2017';      
   TWoD_RuleEngine.validateRule(claim, rcObj13); 
       
     Test.stopTest(); 
      
   } 
  
 
    //DateTime
   public static testMethod void testMethod4()
   {
      Test.startTest();
      insert new twod_TriggerControl__c(SetupOwnerId=UserInfo.getOrganizationId(), 
                                          twod_Payment_Trigger__c=true,
                                          twod_AccountCreationTrigger__c=true,
                                          twod_AccountCreationWarrantyTransferTrig__c=true,
                                          twod_AnswerTrigger__c=true,
                                          twod_ClaimInterestedPartiesTrigger__c=true,
                                          twod_ClaimTrigger__c=true,
                                          twod_RecordSharingTrigger__c=true
                                         );        
    twod__WOD__c csWOD_ExecutePaymentDefinitionTrigger = twod_TestDataFactory.createWODCustomSetting_ForExecutePaymentDefinitionTrigger();
    insert csWOD_ExecutePaymentDefinitionTrigger;
    
    twod__WOD__c csWOD_ExecuteClaimTriggerForPolicyChange = twod_TestDataFactory.createWODCustomSetting_ForExecuteClaimTriggerForPolicyChange();
    insert csWOD_ExecuteClaimTriggerForPolicyChange;
    
    List<String> customSettingVal = new List<String>();
    twod__WOD__c  allPaymentConfig = twod_TestDataFactory.createWODCustomSetting_AllPaymentConfigurations();
    customSettingVal = allPaymentConfig.twod__Trigger_Value__c.split(',');
    customSettingVal.add('Parts');
    insert allPaymentConfig;
    
    twod__WOD__c  allprefixconfig = twod_TestDataFactory.createWODCustomSetting_AllPrefixConfigurations();
    insert allprefixconfig;
    
    twod__WOD__c csCustName = twod_TestDataFactory.createWODCustomSetting_ForEnableChangeCustomerName();
    insert csCustName;
    
    //Custom setting data
    twod__WOD__c cs1 = new twod__WOD__c();
    cs1.name='Enable TwodClaimsTrigger';
    cs1.twod__isTriggered__c=True;
    insert cs1;
    
    twod__WOD__c cs2 = twod_TestDataFactory.createWODCustomSetting_ForEnableWarrantyRuleCriteriaTrigger();
    insert cs2;
    
    twod__WOD__c cs3 = twod_TestDataFactory.createWODCustomSetting_ForEnableWarrantyRuleAssociationTrigger();
    insert cs3;
    
    Account acc1 = twod_TestDataFactory.createAccount('testAcc1','Testing1','Dealer'); 
    acc1.BillingCountry='United States';
    acc1.BillingState ='New York';
    acc1.billingcity='test';
    acc1.billingstreet='test'; 
    acc1.BillingPostalCode = '12345';    
    insert acc1;
    
    twod__WOD__c cs4 = new twod__WOD__c();
    cs4.name='Enable WarrantyProductTrigger';
    cs4.twod__isTriggered__c=True;
    insert cs4;
    
    twod__WOD__c cs5 = new twod__WOD__c();
    cs5.name='Enable RateDetailsTrigger';
    cs5.twod__isTriggered__c=True;
    insert cs5;
            
    Account acc2 = twod_TestDataFactory.createAccount('testAcc2','Testing2','Dealer');
    acc2.ParentId = acc1.Id;
    acc2.ParentId = acc1.Id;
    acc2.BillingCountry='United States';
    acc2.BillingState ='New York';
    acc2.billingcity='test';
    acc2.billingstreet='test'; 
    acc2.BillingPostalCode = '12345';
    insert acc2;
    
    List<RecordType> recordTypeList_Product = [SELECT DeveloperName, SobjectType FROM RecordType WHERE DeveloperName = 'Item' AND SobjectType = 'twod__Warranty_Product__c'];
    Id productRecordTypeId;
    if(recordTypeList_Product != null && !recordTypeList_Product.isEmpty()){
        productRecordTypeId = recordTypeList_Product[0].id;
    }
    
   
    
    twod__Warranty_Product__c product = twod_TestDataFactory.createWarrantyProduct(productRecordTypeId,'test product','1',true,'Non-Serialized','Item','Machine','Hours');
    
  insert product;
    twod__Warranty_Product__c product1 = twod_TestDataFactory.createWarrantyProduct(productRecordTypeId,'test product','1',true,'Serialized','Item','Machine','Hours');
         
   insert product1;
    
    List<RecordType> recordTypeList_Inventory = [SELECT DeveloperName,SobjectType FROM RecordType WHERE DeveloperName = 'Warrantable' AND SobjectType = 'twod__Inventory__c'];
    Id inventoryRecordTypeId;
    if(recordTypeList_Inventory != null && !recordTypeList_Inventory.isEmpty()){
        inventoryRecordTypeId = recordTypeList_Inventory[0].id;
    }
    twod__Inventory__c inv = twod_TestDataFactory.createInventory(inventoryRecordTypeId,'test inventory','1','Warrantable',acc2.id, product1.id);
    insert inv;
    
     
    
    twod__Rates_Details__c RD = new twod__Rates_Details__c();
    RD.Name = 'RD001';
    RD.twod__Dealer__c = acc2.id;
    RD.twod__Status__c = 'Active';
   
    insert RD;
       
    twod__WOD__c csRD = new twod__WOD__c();
    csRD.Name = 'Default Rate';
    csRD.twod__isTriggered__c = true;
    csRD.twod__Trigger_Value__c=RD.Id;
    insert csRD;
    
    String RecTypeWC = Schema.SObjectType.twod__Warranty_Code__c.getRecordTypeInfosByName().get('Fault Code').getRecordTypeId();  
    twod__Warranty_Code__c wc = new twod__Warranty_Code__c();
    WC.Name = 'test WC';
    WC.twod__Warranty_Product__c = product.Id;
    WC.twod__Lang_Id__c = 'en_US';
    WC.RecordTypeId = RecTypeWC;
    WC.twod__Warranty_Code__c = 'WC_0050';
    insert WC;
        
    twod__Payment_Definitions__c paymtDefinition = twod_TestDataFactory.CreatePaymentDefination('testPaymentDef');
    insert paymtDefinition;
     
    twod__Payment_Configuration__c paymentConfiguration = twod_TestDataFactory.CreatePaymentConfiguration('testpc','Test Parts');
    insert paymentConfiguration;
    
    twod__Policy_Definition__c plcyDef = [Select id from twod__Policy_Definition__c limit 1];
    //twod__Policy_Definition__c plcyDef = twod_TestDataFactory.CreatePolicyDefination('testplDf',paymtDefinition.id,System.today().addDays(-30),System.today().addDays(50),1,20,'Standard','Marketing',true);
    //plcyDef.twod__Status__c = 'Active';
    //insert plcyDef;
        
     Set<Id> plcyDefSet = new Set<Id>{plcyDef.id};    
       
     twod__Warranty_Rule__c wRule1 = new twod__Warranty_Rule__c();
     wRule1.name='W Rule1';   
     wRule1.twod__Object_Type__c='twod__Claim__c';
     wRule1.twod__Rule_Type__c='Eligibility Rule';
     insert wRule1;
       
     List<twod__Warranty_Rule_Criteria__c> wRuleCriteriaList2 = new List<twod__Warranty_Rule_Criteria__c>(); 
       
     twod__Warranty_Rule_Criteria__c wRuleCriteria7 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria7.twod__Warranty_Rule__c=wRule1.id;
     wRuleCriteria7.twod__Field_Name__c='Created Date';
     wRuleCriteria7.twod__Sequence__c=8;
     wRuleCriteria7.twod__Criteria_Type__c='Equals';
     wRuleCriteria7.twod__Criteria_Value__c=DateTime.now().format();
     wRuleCriteria7.twod__Field_API_Name__c='CreatedDate'; 
     wRuleCriteria7.twod__Field_Type__c='DATETIME';
     wRuleCriteriaList2.add(wRuleCriteria7); 
     
     twod__Warranty_Rule_Criteria__c wRuleCriteria8 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria8.twod__Warranty_Rule__c=wRule1.id;
     wRuleCriteria8.twod__Field_Name__c='Created Date';
     wRuleCriteria8.twod__Sequence__c=9;
     wRuleCriteria8.twod__Criteria_Type__c='Not Equal To';
     wRuleCriteria8.twod__Criteria_Value__c=DateTime.now().addDays(-30).format();
     wRuleCriteria8.twod__Field_API_Name__c='CreatedDate'; 
     wRuleCriteria8.twod__Field_Type__c='DATETIME';
     wRuleCriteriaList2.add(wRuleCriteria8); 
      
      twod__Warranty_Rule_Criteria__c wRuleCriteria9 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria9.twod__Warranty_Rule__c=wRule1.id;
     wRuleCriteria9.twod__Field_Name__c='Created Date';
     wRuleCriteria9.twod__Sequence__c=10;
     wRuleCriteria9.twod__Criteria_Type__c='Greater Than';
     wRuleCriteria9.twod__Criteria_Value__c=DateTime.now().addDays(-5).format();
     wRuleCriteria9.twod__Field_API_Name__c='CreatedDate'; 
     wRuleCriteria9.twod__Field_Type__c='DATETIME';
     wRuleCriteriaList2.add(wRuleCriteria9); 
   
    twod__Warranty_Rule_Criteria__c wRuleCriteria10 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria10.twod__Warranty_Rule__c=wRule1.id;
     wRuleCriteria10.twod__Field_Name__c='Created Date';
     wRuleCriteria10.twod__Sequence__c=11;
     wRuleCriteria10.twod__Criteria_Type__c='Greater Or Equal';
     wRuleCriteria10.twod__Criteria_Value__c=DateTime.now().format();
     wRuleCriteria10.twod__Field_API_Name__c='CreatedDate'; 
     wRuleCriteria10.twod__Field_Type__c='DATETIME';
     wRuleCriteriaList2.add(wRuleCriteria10); 
   
     twod__Warranty_Rule_Criteria__c wRuleCriteria11 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria11.twod__Warranty_Rule__c=wRule1.id;
     wRuleCriteria11.twod__Field_Name__c='Created Date';
     wRuleCriteria11.twod__Sequence__c=12;
     wRuleCriteria11.twod__Criteria_Type__c='Less Than';
     wRuleCriteria11.twod__Criteria_Value__c=DateTime.now().addDays(-6).format();
     wRuleCriteria11.twod__Field_API_Name__c='CreatedDate'; 
     wRuleCriteria11.twod__Field_Type__c='DATETIME';
     wRuleCriteriaList2.add(wRuleCriteria11); 
   
    twod__Warranty_Rule_Criteria__c wRuleCriteria12 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria12.twod__Warranty_Rule__c=wRule1.id;
     wRuleCriteria12.twod__Field_Name__c='Created Date';
     wRuleCriteria12.twod__Sequence__c=13;
     wRuleCriteria12.twod__Criteria_Type__c='Less Or Equal';
     wRuleCriteria12.twod__Criteria_Value__c=DateTime.now().format();
     wRuleCriteria12.twod__Field_API_Name__c='CreatedDate'; 
     wRuleCriteria12.twod__Field_Type__c='DATETIME';
     wRuleCriteriaList2.add(wRuleCriteria12);  
       
     twod__Warranty_Rule_Criteria__c wRuleCriteria13 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria13.twod__Warranty_Rule__c=wRule1.id;
     wRuleCriteria13.twod__Field_Name__c='Created Date';
     wRuleCriteria13.twod__Sequence__c=14;
     wRuleCriteria13.twod__Criteria_Type__c='Between';
     wRuleCriteria13.twod__Criteria_Value__c=DateTime.now().addDays(10).format();
     wRuleCriteria13.twod__Field_API_Name__c='CreatedDate'; 
     wRuleCriteria13.twod__Field_Type__c='DATETIME';
     wRuleCriteriaList2.add(wRuleCriteria13); 
     
     insert wRuleCriteriaList2;
       
     wRule1.twod__Enabled__c = true;
     update wRule1; 
     
    // Query the twod__Warranty_Rule__c again to get the updated rollup summary field.
    twod__Warranty_Rule__c wRuleAfterInsert = [Select twod__No_Of_Rule_Criteria__c from twod__Warranty_Rule__c where Id= :wRule1.Id];
    //System.assertEquals(7, wRuleAfterInsert.twod__No_Of_Rule_Criteria__c);
      
    wRule1.twod__Enabled__c=true;
    update wRule1;
    set<Id> RuleIdSet = new set<Id> {wRule1.id};
     
    twod__Warranty_Rule_Association__c wRuleAssociation = new twod__Warranty_Rule_Association__c();
    wRuleAssociation.twod__Policy_Definition__c=plcyDef.id;
    wRuleAssociation.twod__Warranty_Rule__c=wRule1.id;
    wRuleAssociation.twod__Is_Active__c = true;
    insert wRuleAssociation;
      
    
    String ClaimRT1 = Schema.SObjectType.twod__Claim__c.getRecordTypeInfosByName().get('Serialized Part').getRecordTypeId();       
    twod__Claim__c claim = twod_TestDataFactory.createClaim();
    claim.twod__Account__c = acc2.id;
    claim.twod__Inventory__c = inv.id;
    claim.twod__Date_Of_Purchase__c = System.today().addDays(-30);
    claim.twod__Date_of_Failure__c = system.today().addDays(-20);
    claim.twod__Date_of_Repair__c = system.today().addDays(-10);
    claim.twod__Units_Run__c = 10;
    claim.twod__Claim_Status__c = 'Draft';
    claim.twod__In_Approval_Process__c = false;
    claim.twod__Approved_Labor_Cost__c = 200;
    claim.twod__Warranty_Product__c = product.Id;
    claim.twod__Causal_Part_Number__c = product.id;
    claim.twod__Fault_Code__c = WC.Id;
    claim.twod__CLAIM_TYPE__C = 'Machine';
    claim.twod__Rate__c = RD.Id;
    claim.twod__Applicable_Policy__c = plcyDef.id;
    claim.recordtypeId=ClaimRT1;
    claim.twod__TravelByDistance__c=10;
    insert claim;
   
    twod__Claim__c claim2 = [SELECT Id, twod__Account__c, createddate,  twod__Inventory__c, twod__Date_Of_Purchase__c,
                                twod__Date_of_Failure__c, twod__Date_of_Repair__c, twod__Units_Run__c,
                            twod__Claim_Status__c, twod__In_Approval_Process__c, twod__Approved_Labor_Cost__c,
                             twod__Warranty_Product__c, twod__Causal_Part_Number__c, twod__Fault_Code__c,
                             twod__CLAIM_TYPE__C, twod__Rate__c, twod__Applicable_Policy__c, twod__TravelByDistance__c
                            from twod__Claim__c where id=:claim.Id];
          
      //FiedType  = DATE
    twod.RuleCriteriaWrapper rcObj7 = new twod.RuleCriteriaWrapper(wRuleCriteria7);
    rcObj7.RCId=wRuleCriteria7.id;
    rcObj7.RCName=wRuleCriteria7.name;
    rcObj7.Sequence=  Integer.valueOf(wRuleCriteria7.twod__Sequence__c);
    rcObj7.FieldAPIName= wRuleCriteria7.twod__Field_API_Name__c;
    rcObj7.FieldName=wRuleCriteria7.twod__Field_Name__c;    
    rcObj7.FieldType=wRuleCriteria7.twod__Field_Type__c;
    rcObj7.CriteriaValue= wRuleCriteria7.twod__Criteria_Value__c;
    //System.debug('*** Date77 '+rcObj7);
     TWoD_RuleEngine.validateRule(claim2, rcObj7); 
       
       
    twod.RuleCriteriaWrapper rcObj8 = new twod.RuleCriteriaWrapper(wRuleCriteria8);
    rcObj8.RCId=wRuleCriteria8.id;
    rcObj8.RCName=wRuleCriteria8.name;
    rcObj8.Sequence=  Integer.valueOf(wRuleCriteria8.twod__Sequence__c);
    rcObj8.FieldAPIName= wRuleCriteria8.twod__Field_API_Name__c;
    rcObj8.FieldName=wRuleCriteria8.twod__Field_Name__c;    
    rcObj8.FieldType=wRuleCriteria8.twod__Field_Type__c;
    rcObj8.CriteriaValue= wRuleCriteria8.twod__Criteria_Value__c;
        
     TWoD_RuleEngine.validateRule(claim2, rcObj8);  
       
     twod.RuleCriteriaWrapper rcObj9 = new twod.RuleCriteriaWrapper(wRuleCriteria9);
    rcObj9.RCId=wRuleCriteria9.id;
    rcObj9.RCName=wRuleCriteria9.name;
    rcObj9.Sequence=  Integer.valueOf(wRuleCriteria9.twod__Sequence__c);
    rcObj9.FieldAPIName= wRuleCriteria9.twod__Field_API_Name__c;
    rcObj9.FieldName=wRuleCriteria9.twod__Field_Name__c;    
    rcObj9.FieldType=wRuleCriteria9.twod__Field_Type__c;
    rcObj9.CriteriaValue= wRuleCriteria9.twod__Criteria_Value__c;
        
     TWoD_RuleEngine.validateRule(claim2, rcObj9); 
         
    twod.RuleCriteriaWrapper rcObj10 = new twod.RuleCriteriaWrapper(wRuleCriteria10);
    rcObj10.RCId=wRuleCriteria10.id;
    rcObj10.RCName=wRuleCriteria10.name;
    rcObj10.Sequence=  Integer.valueOf(wRuleCriteria10.twod__Sequence__c);
    rcObj10.FieldAPIName= wRuleCriteria10.twod__Field_API_Name__c;
    rcObj10.FieldName=wRuleCriteria10.twod__Field_Name__c;    
    rcObj10.FieldType=wRuleCriteria10.twod__Field_Type__c;
    rcObj10.CriteriaValue= wRuleCriteria10.twod__Criteria_Value__c;
        
     TWoD_RuleEngine.validateRule(claim2, rcObj10); 
       
      twod.RuleCriteriaWrapper rcObj11 = new twod.RuleCriteriaWrapper(wRuleCriteria11);
    rcObj11.RCId=wRuleCriteria11.id;
    rcObj11.RCName=wRuleCriteria11.name;
    rcObj11.Sequence=  Integer.valueOf(wRuleCriteria11.twod__Sequence__c);
    rcObj11.FieldAPIName= wRuleCriteria11.twod__Field_API_Name__c;
    rcObj11.FieldName=wRuleCriteria11.twod__Field_Name__c;    
    rcObj11.FieldType=wRuleCriteria11.twod__Field_Type__c;
    rcObj11.CriteriaValue= wRuleCriteria11.twod__Criteria_Value__c;
        
     TWoD_RuleEngine.validateRule(claim2, rcObj11);      
   
    twod.RuleCriteriaWrapper rcObj12 = new twod.RuleCriteriaWrapper(wRuleCriteria12);
    rcObj12.RCId=wRuleCriteria12.id;
    rcObj12.RCName=wRuleCriteria12.name;
    rcObj12.Sequence=  Integer.valueOf(wRuleCriteria12.twod__Sequence__c);
    rcObj12.FieldAPIName= wRuleCriteria12.twod__Field_API_Name__c;
    rcObj12.FieldName=wRuleCriteria12.twod__Field_Name__c;    
    rcObj12.FieldType=wRuleCriteria12.twod__Field_Type__c;
    rcObj12.CriteriaValue= wRuleCriteria12.twod__Criteria_Value__c;
        
     TWoD_RuleEngine.validateRule(claim2, rcObj12); 
    
    twod.RuleCriteriaWrapper rcObj13 = new twod.RuleCriteriaWrapper(wRuleCriteria13);
    rcObj13.RCId=wRuleCriteria13.id;
    rcObj13.RCName=wRuleCriteria13.name;
    rcObj13.Sequence=  Integer.valueOf(wRuleCriteria13.twod__Sequence__c);
    rcObj13.FieldAPIName= wRuleCriteria13.twod__Field_API_Name__c;
    rcObj13.FieldName=wRuleCriteria13.twod__Field_Name__c;    
    rcObj13.FieldType=wRuleCriteria13.twod__Field_Type__c;
    rcObj13.CriteriaValue= wRuleCriteria13.twod__Criteria_Value__c;
    rcObj13.MinimumValue=DateTime.now().addDays(-5).format();
    rcObj13.MaximumValue=DateTime.now().addDays(20).format();      
    TWoD_RuleEngine.validateRule(claim2, rcObj13); 
       
     Test.stopTest(); 
      
   } 
    
    //Picklist dataTYpe
   public static testMethod void testMethod5()
   {
      Test.startTest();
      insert new twod_TriggerControl__c(SetupOwnerId=UserInfo.getOrganizationId(), 
                                          twod_Payment_Trigger__c=true,
                                          twod_AccountCreationTrigger__c=true,
                                          twod_AccountCreationWarrantyTransferTrig__c=true,
                                          twod_AnswerTrigger__c=true,
                                          twod_ClaimInterestedPartiesTrigger__c=true,
                                          twod_ClaimTrigger__c=true,
                                          twod_RecordSharingTrigger__c=true
                                         );        
    twod__WOD__c csWOD_ExecutePaymentDefinitionTrigger = twod_TestDataFactory.createWODCustomSetting_ForExecutePaymentDefinitionTrigger();
    insert csWOD_ExecutePaymentDefinitionTrigger;
    
    twod__WOD__c csWOD_ExecuteClaimTriggerForPolicyChange = twod_TestDataFactory.createWODCustomSetting_ForExecuteClaimTriggerForPolicyChange();
    insert csWOD_ExecuteClaimTriggerForPolicyChange;
    
    List<String> customSettingVal = new List<String>();
    twod__WOD__c  allPaymentConfig = twod_TestDataFactory.createWODCustomSetting_AllPaymentConfigurations();
    customSettingVal = allPaymentConfig.twod__Trigger_Value__c.split(',');
    customSettingVal.add('Parts');
    insert allPaymentConfig;
    
    twod__WOD__c  allprefixconfig = twod_TestDataFactory.createWODCustomSetting_AllPrefixConfigurations();
    insert allprefixconfig;
    
    twod__WOD__c csCustName = twod_TestDataFactory.createWODCustomSetting_ForEnableChangeCustomerName();
    insert csCustName;
    
    //Custom setting data
    twod__WOD__c cs1 = new twod__WOD__c();
    cs1.name='Enable TwodClaimsTrigger';
    cs1.twod__isTriggered__c=True;
    insert cs1;
    
    twod__WOD__c cs2 = twod_TestDataFactory.createWODCustomSetting_ForEnableWarrantyRuleCriteriaTrigger();
    insert cs2;
    
    twod__WOD__c cs3 = twod_TestDataFactory.createWODCustomSetting_ForEnableWarrantyRuleAssociationTrigger();
    insert cs3;
    
    Account acc1 = twod_TestDataFactory.createAccount('testAcc1','Testing1','Dealer'); 
    acc1.BillingCountry='United States';
    acc1.BillingState ='New York';
    acc1.billingcity='test';
    acc1.billingstreet='test'; 
    acc1.BillingPostalCode = '12345';    
    insert acc1;
    
    twod__WOD__c cs4 = new twod__WOD__c();
    cs4.name='Enable WarrantyProductTrigger';
    cs4.twod__isTriggered__c=True;
    insert cs4;
    
    twod__WOD__c cs5 = new twod__WOD__c();
    cs5.name='Enable RateDetailsTrigger';
    cs5.twod__isTriggered__c=True;
    insert cs5;
            
    Account acc2 = twod_TestDataFactory.createAccount('testAcc2','Testing2','Dealer');
    acc2.ParentId = acc1.Id;
    acc2.ParentId = acc1.Id;
    acc2.BillingCountry='United States';
    acc2.BillingState ='New York';
    acc2.billingcity='test';
    acc2.billingstreet='test'; 
    acc2.BillingPostalCode = '12345';
    insert acc2;
    
    List<RecordType> recordTypeList_Product = [SELECT DeveloperName, SobjectType FROM RecordType WHERE DeveloperName = 'Item' AND SobjectType = 'twod__Warranty_Product__c'];
    Id productRecordTypeId;
    if(recordTypeList_Product != null && !recordTypeList_Product.isEmpty()){
        productRecordTypeId = recordTypeList_Product[0].id;
    }
    
    
    
    twod__Warranty_Product__c product = twod_TestDataFactory.createWarrantyProduct(productRecordTypeId,'test product','1',true,'Non-Serialized','Item','Machine','Hours');
    
    insert product;
    twod__Warranty_Product__c product1 = twod_TestDataFactory.createWarrantyProduct(productRecordTypeId,'test product','1',true,'Serialized','Item','Machine','Hours');
       
    insert product1;
    
    List<RecordType> recordTypeList_Inventory = [SELECT DeveloperName,SobjectType FROM RecordType WHERE DeveloperName = 'Warrantable' AND SobjectType = 'twod__Inventory__c'];
    Id inventoryRecordTypeId;
    if(recordTypeList_Inventory != null && !recordTypeList_Inventory.isEmpty()){
        inventoryRecordTypeId = recordTypeList_Inventory[0].id;
    }
    twod__Inventory__c inv = twod_TestDataFactory.createInventory(inventoryRecordTypeId,'test inventory','1','Warrantable',acc2.id, product1.id);
    insert inv;
    
    
    
    twod__Rates_Details__c RD = new twod__Rates_Details__c();
    RD.Name = 'RD001';
    RD.twod__Dealer__c = acc2.id;
    RD.twod__Status__c = 'Active';
    
    insert RD;
    
    twod__WOD__c csRD = new twod__WOD__c();
    csRD.Name = 'Default Rate';
    csRD.twod__isTriggered__c = true;
    csRD.twod__Trigger_Value__c=RD.Id;
    insert csRD;
    
    String RecTypeWC = Schema.SObjectType.twod__Warranty_Code__c.getRecordTypeInfosByName().get('Fault Code').getRecordTypeId();  
    twod__Warranty_Code__c wc = new twod__Warranty_Code__c();
    WC.Name = 'test WC';
    WC.twod__Warranty_Product__c = product.Id;
    WC.twod__Lang_Id__c = 'en_US';
    WC.RecordTypeId = RecTypeWC;
    WC.twod__Warranty_Code__c = 'WC_0050';
    insert WC;
    
     twod__Payment_Definitions__c paymtDefinition = twod_TestDataFactory.CreatePaymentDefination('testPaymentDef');
     insert paymtDefinition;
     
     twod__Payment_Configuration__c paymentConfiguration = twod_TestDataFactory.CreatePaymentConfiguration('testpc','Test Parts');
     insert paymentConfiguration;
    
     twod__Policy_Definition__c plcyDef = [Select id from twod__Policy_Definition__c limit 1]; 
       
     Set<Id> plcyDefSet = new Set<Id>{plcyDef.id};    
       
     twod__Warranty_Rule__c wRule1 = new twod__Warranty_Rule__c();
     wRule1.name='W Rule1';   
     wRule1.twod__Object_Type__c='twod__Claim__c';
     wRule1.twod__Rule_Type__c='Eligibility Rule';
     insert wRule1;
       
     List<twod__Warranty_Rule_Criteria__c> wRuleCriteriaList2 = new List<twod__Warranty_Rule_Criteria__c>(); 
       
     twod__Warranty_Rule_Criteria__c wRuleCriteria7 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria7.twod__Warranty_Rule__c=wRule1.id;
     wRuleCriteria7.twod__Field_Name__c='Claim Status';
     wRuleCriteria7.twod__Sequence__c=8;
     wRuleCriteria7.twod__Criteria_Type__c='Equals';
     wRuleCriteria7.twod__Criteria_Value__c='Draft';
     wRuleCriteria7.twod__Field_API_Name__c='twod__Claim_Status__c'; 
     wRuleCriteria7.twod__Field_Type__c='Picklist';
     wRuleCriteriaList2.add(wRuleCriteria7); 
    
     twod__Warranty_Rule_Criteria__c wRuleCriteria8 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria8.twod__Warranty_Rule__c=wRule1.id;
     wRuleCriteria8.twod__Field_Name__c='Claim Status';
     wRuleCriteria8.twod__Sequence__c=9;
     wRuleCriteria8.twod__Criteria_Type__c='Not Equal To';
     wRuleCriteria8.twod__Criteria_Value__c='In Progress';
     wRuleCriteria8.twod__Field_API_Name__c='twod__Claim_Status__c'; 
     wRuleCriteria8.twod__Field_Type__c='Picklist';
     wRuleCriteriaList2.add(wRuleCriteria8); 
      
     twod__Warranty_Rule_Criteria__c wRuleCriteria9 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria9.twod__Warranty_Rule__c=wRule1.id;
     wRuleCriteria9.twod__Field_Name__c='Claim Status';
     wRuleCriteria9.twod__Sequence__c=10;
     wRuleCriteria9.twod__Criteria_Type__c='Contains';
     wRuleCriteria9.twod__Criteria_Value__c='Draf';
     wRuleCriteria9.twod__Field_API_Name__c='twod__Claim_Status__c'; 
     wRuleCriteria9.twod__Field_Type__c='Picklist';
     wRuleCriteriaList2.add(wRuleCriteria9); 
   
     twod__Warranty_Rule_Criteria__c wRuleCriteria10 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria10.twod__Warranty_Rule__c=wRule1.id;
     wRuleCriteria10.twod__Field_Name__c='Claim Status';
     wRuleCriteria10.twod__Sequence__c=11;
     wRuleCriteria10.twod__Criteria_Type__c='Does not Contain';
     wRuleCriteria10.twod__Criteria_Value__c='App';
     wRuleCriteria10.twod__Field_API_Name__c='twod__Claim_Status__c'; 
     wRuleCriteria10.twod__Field_Type__c='Picklist';
     wRuleCriteriaList2.add(wRuleCriteria10); 
   
     twod__Warranty_Rule_Criteria__c wRuleCriteria11 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria11.twod__Warranty_Rule__c=wRule1.id;
     wRuleCriteria11.twod__Field_Name__c='Claim Status';
     wRuleCriteria11.twod__Sequence__c=12;
     wRuleCriteria11.twod__Criteria_Type__c='Starts With';
     wRuleCriteria11.twod__Criteria_Value__c='Dra';
     wRuleCriteria11.twod__Field_API_Name__c='twod__Claim_Status__c'; 
     wRuleCriteria11.twod__Field_Type__c='Picklist';
     wRuleCriteriaList2.add(wRuleCriteria11); 
   
     twod__Warranty_Rule_Criteria__c wRuleCriteria12 = new twod__Warranty_Rule_Criteria__c();  
     wRuleCriteria12.twod__Warranty_Rule__c=wRule1.id;
     wRuleCriteria12.twod__Field_Name__c='Claim Status';
     wRuleCriteria12.twod__Sequence__c=13;
     wRuleCriteria12.twod__Criteria_Type__c='Ends With';
     wRuleCriteria12.twod__Criteria_Value__c='ft';
     wRuleCriteria12.twod__Field_API_Name__c='twod__Claim_Status__c'; 
     wRuleCriteria12.twod__Field_Type__c='Picklist';
     wRuleCriteriaList2.add(wRuleCriteria12);  
            
     insert wRuleCriteriaList2;
       
     wRule1.twod__Enabled__c = true;
     update wRule1; 
     
    // Query the twod__Warranty_Rule__c again to get the updated rollup summary field.
    twod__Warranty_Rule__c wRuleAfterInsert = [Select twod__No_Of_Rule_Criteria__c from twod__Warranty_Rule__c where Id= :wRule1.Id];
    //System.assertEquals(7, wRuleAfterInsert.twod__No_Of_Rule_Criteria__c);
        
    wRule1.twod__Enabled__c=true;
    update wRule1;
    set<Id> RuleIdSet = new set<Id> {wRule1.id};
     
    twod__Warranty_Rule_Association__c wRuleAssociation = new twod__Warranty_Rule_Association__c();
    wRuleAssociation.twod__Policy_Definition__c=plcyDef.id;
    wRuleAssociation.twod__Warranty_Rule__c=wRule1.id;
    wRuleAssociation.twod__Is_Active__c = true;
    insert wRuleAssociation;
      
    String ClaimRT1 = Schema.SObjectType.twod__Claim__c.getRecordTypeInfosByName().get('Serialized Part').getRecordTypeId();
        
    twod__Claim__c claim = twod_TestDataFactory.createClaim();
    claim.twod__Account__c = acc2.id;
    claim.twod__Inventory__c = inv.id;
    claim.twod__Date_Of_Purchase__c = System.today().addDays(-30);
    claim.twod__Date_of_Failure__c = system.today().addDays(-20);
    claim.twod__Date_of_Repair__c = system.today().addDays(-10);
    claim.twod__Units_Run__c = 10;
    claim.twod__Claim_Status__c = 'Draft';
    claim.twod__In_Approval_Process__c = false;
    claim.twod__Approved_Labor_Cost__c = 200;
    claim.twod__Warranty_Product__c = product.Id;
    claim.twod__Causal_Part_Number__c = product.id;
    claim.twod__Fault_Code__c = WC.Id;
    claim.twod__CLAIM_TYPE__C = 'Machine';
    claim.twod__Rate__c = RD.Id;
    claim.twod__Applicable_Policy__c = plcyDef.id;
    claim.recordtypeId=ClaimRT1;
    claim.twod__TravelByDistance__c=10;
    insert claim;   
         
    //FiedType  = Picklist
    twod.RuleCriteriaWrapper rcObj7 = new twod.RuleCriteriaWrapper(wRuleCriteria7);
    rcObj7.RCId=wRuleCriteria7.id;
    rcObj7.RCName=wRuleCriteria7.name;
    rcObj7.Sequence=  Integer.valueOf(wRuleCriteria7.twod__Sequence__c);
    rcObj7.FieldAPIName= wRuleCriteria7.twod__Field_API_Name__c;
    rcObj7.FieldName=wRuleCriteria7.twod__Field_Name__c;    
    rcObj7.FieldType=wRuleCriteria7.twod__Field_Type__c;
    rcObj7.CriteriaValue= wRuleCriteria7.twod__Criteria_Value__c;
        
    TWoD_RuleEngine.validateRule(claim, rcObj7);        
       
    twod.RuleCriteriaWrapper rcObj8 = new twod.RuleCriteriaWrapper(wRuleCriteria8);
    rcObj8.RCId=wRuleCriteria8.id;
    rcObj8.RCName=wRuleCriteria8.name;
    rcObj8.Sequence=  Integer.valueOf(wRuleCriteria8.twod__Sequence__c);
    rcObj8.FieldAPIName= wRuleCriteria8.twod__Field_API_Name__c;
    rcObj8.FieldName=wRuleCriteria8.twod__Field_Name__c;    
    rcObj8.FieldType=wRuleCriteria8.twod__Field_Type__c;
    rcObj8.CriteriaValue= wRuleCriteria8.twod__Criteria_Value__c;
        
    TWoD_RuleEngine.validateRule(claim, rcObj8);  
       
    twod.RuleCriteriaWrapper rcObj9 = new twod.RuleCriteriaWrapper(wRuleCriteria9);
    rcObj9.RCId=wRuleCriteria9.id;
    rcObj9.RCName=wRuleCriteria9.name;
    rcObj9.Sequence=  Integer.valueOf(wRuleCriteria9.twod__Sequence__c);
    rcObj9.FieldAPIName= wRuleCriteria9.twod__Field_API_Name__c;
    rcObj9.FieldName=wRuleCriteria9.twod__Field_Name__c;    
    rcObj9.FieldType=wRuleCriteria9.twod__Field_Type__c;
    rcObj9.CriteriaValue= wRuleCriteria9.twod__Criteria_Value__c;
        
    TWoD_RuleEngine.validateRule(claim, rcObj9); 
         
    twod.RuleCriteriaWrapper rcObj10 = new twod.RuleCriteriaWrapper(wRuleCriteria10);
    rcObj10.RCId=wRuleCriteria10.id;
    rcObj10.RCName=wRuleCriteria10.name;
    rcObj10.Sequence=  Integer.valueOf(wRuleCriteria10.twod__Sequence__c);
    rcObj10.FieldAPIName= wRuleCriteria10.twod__Field_API_Name__c;
    rcObj10.FieldName=wRuleCriteria10.twod__Field_Name__c;    
    rcObj10.FieldType=wRuleCriteria10.twod__Field_Type__c;
    rcObj10.CriteriaValue= wRuleCriteria10.twod__Criteria_Value__c;
        
    TWoD_RuleEngine.validateRule(claim, rcObj10); 
       
    twod.RuleCriteriaWrapper rcObj11 = new twod.RuleCriteriaWrapper(wRuleCriteria11);
    rcObj11.RCId=wRuleCriteria11.id;
    rcObj11.RCName=wRuleCriteria11.name;
    rcObj11.Sequence=  Integer.valueOf(wRuleCriteria11.twod__Sequence__c);
    rcObj11.FieldAPIName= wRuleCriteria11.twod__Field_API_Name__c;
    rcObj11.FieldName=wRuleCriteria11.twod__Field_Name__c;    
    rcObj11.FieldType=wRuleCriteria11.twod__Field_Type__c;
    rcObj11.CriteriaValue= wRuleCriteria11.twod__Criteria_Value__c;
        
     TWoD_RuleEngine.validateRule(claim, rcObj11); 
         
    twod.RuleCriteriaWrapper rcObj12 = new twod.RuleCriteriaWrapper(wRuleCriteria12);
    rcObj12.RCId=wRuleCriteria12.id;
    rcObj12.RCName=wRuleCriteria12.name;
    rcObj12.Sequence=  Integer.valueOf(wRuleCriteria12.twod__Sequence__c);
    rcObj12.FieldAPIName= wRuleCriteria12.twod__Field_API_Name__c;
    rcObj12.FieldName=wRuleCriteria12.twod__Field_Name__c;    
    rcObj12.FieldType=wRuleCriteria12.twod__Field_Type__c;
    rcObj12.CriteriaValue= wRuleCriteria12.twod__Criteria_Value__c;
        
    TWoD_RuleEngine.validateRule(claim, rcObj12); 
       
    Test.stopTest(); 
      
   } 
   
   
   
   
  }