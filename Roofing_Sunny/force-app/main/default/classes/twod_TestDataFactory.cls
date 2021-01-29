/**********************************************************************
Name:  twod_TestDataFactory
Copyright ? 2016  Tavant Technology Inc
==============================================================
===============================================================
Purpose: Test data set up class                                                                                                               
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Bikram           21/10/2016      INITIAL DEVELOPMENT            
***********************************************************************/
@isTest
public class twod_TestDataFactory{
    
    public static twod__Claim__c Create_Stnd_Claim(){
        RecordType RecID = [select Id, Name from RecordType where Name = 'International' and SobjectType = 'twod__Claim__c' limit 1];
        twod__Claim__c claim = new twod__Claim__c(First_Name__c='Abhishek',Last_Name__c='Singh',Address_1__c='Okaya 1',Address_2__c='Okaya 2',City__c='Noida',
                                                 Country__c='Canada',Custom_State__c='UP',Phone__c='9999999999',Zip_Code_Postal_Code__c='201308',Invoice_Number__c='INV_001',
                                                 twod__Date_of_Failure__c=system.today(),Defect_Details__c='N/A',material_quantity__c=100,twod__Claim_Type__c='Short_Term');
        insert claim;
        return claim;
    }
    
    public static Account createAccount(string accountName, string accountCategory, string accountType){
        Account acc = new Account();
        acc.name = accountName;
        acc.twod__Warranty_Account_Type__c = accountType;
        return acc;
    }
    
    public static Contact createContact(string firstName, string lastName, id accountId, boolean isPrimary){
        contact con = new contact();
        con.firstName = firstName;
        con.lastName = lastName;
        con.accountId = accountId;
        return con;
    }
    
    public static Group createGroup(string groupName, string groupType){
        Group gp = new Group();
        gp.Name = groupName;
        gp.type = groupType;
        return gp;
    }
    
    public static twod__Warranty_Product__c createWarrantyProduct(id productRecordTypeId, string productName, string productCode, boolean isActive, string trackType, string productType, string ItemType, string uom){
        twod__Warranty_Product__c product = new twod__Warranty_Product__c();
      
        product.twod__Product_Name__c = productName;
        product.twod__Track_Type__c = trackType;
        product.twod__Type__c = productType;
        product.twod__Item_Type__c = ItemType;
        product.twod__Units_of_Measure__c = uom;
        product.Name = productCode;
        return product;
    }
    
    public static twod__Inventory__c createInventory(id inventoryRecordTypeId, string inventoryName, string serialNumber, string assetType, id accountId ,id productId){
        twod__Inventory__c inv = new twod__Inventory__c();
        if(inventoryRecordTypeId != null) {
            inv.RecordTypeId = inventoryRecordTypeId;
        }
        inv.Name = inventoryName;
        inv.twod__Serial_Number__c = serialNumber;
        inv.twod__Asset_Type__c = assetType;
        inv.twod__Account__c = accountId;
        inv.twod__Item__c = productId;
        return inv;
    }
    
    public static twod__Warranty_Registration__c CreateWarrantyRegistration(string name, id accountId, string status, id inventoryId, date wrDate){
        twod__Warranty_Registration__c wr = new twod__Warranty_Registration__c();
        wr.name = name;
        wr.twod__Account__c = accountId;
        wr.twod__Status__c = status;
        wr.twod__Inventory__c = inventoryId;
        wr.twod__Registration_Date__c = wrDate;
        return wr;
    }
    
    public static twod__Payment_Definitions__c CreatePaymentDefination(string name){
        twod__Payment_Definitions__c paymentDf = new twod__Payment_Definitions__c();
        paymentDf.Name= name;
        return paymentDf;
    }
    
    public static twod__Payment_Definition_Items__c CreatePaymentDefinationItem(id paymentDefinationId,id paymentConfigurationId){
        twod__Payment_Definition_Items__c pmtDefItem = new twod__Payment_Definition_Items__c();
        pmtDefItem.twod__Payment_Configuration__c = paymentConfigurationId;
        pmtDefItem.twod__Payment_Definition__c = paymentDefinationId;
        return pmtDefItem;
    }
    
    public static twod__Payment_Configuration__c CreatePaymentConfiguration(string name, string claimFieldName){
        twod__Payment_Configuration__c pc =   new twod__Payment_Configuration__c();
        pc.Name = name;
        pc.twod__Claim_Field_Name__c = claimFieldName;
        return pc;
    }
    
    public static twod__Payment_Modifiers__c CreatePaymentModifier(string name,id paymentDefinationItemId, id paymtConfigurationId, date date_ActiveFrom, date date_ActiveUntil, integer paymentValue, integer priorityValue){
        twod__Payment_Modifiers__c pmtModifier = new twod__Payment_Modifiers__c();
        pmtModifier.Name = name;
        pmtModifier.twod__Payment_Definition__c = paymentDefinationItemId;
        pmtModifier.twod__Payment_Configuration__c = paymtConfigurationId;
        pmtModifier.twod__Active_From__c = date_ActiveFrom;
        pmtModifier.twod__Active_Until__c = date_ActiveUntil;
        pmtModifier.twod__Value__c = paymentValue;
        pmtModifier.twod__Priority__c = priorityValue;
        return pmtModifier;
    }
    
    public static twod__Policy_Definition__c CreatePolicyDefination(string name, id paymentDefinationId, date date_ActiveFrom, date date_ActiveUntil, integer priorityValue, integer monthsCovered, string policyDefType, string policyDefSubType, boolean isExtendable){
        twod__Policy_Definition__c policyDef =new twod__Policy_Definition__c();
        policyDef.Name = name;
        policyDef.twod__Active_From__c = date_ActiveFrom;
        policyDef.twod__Active_Until__c = date_ActiveUntil;
        policyDef.twod__Priority__c = priorityValue;
        policyDef.twod__Months_Covered__c = monthsCovered;
        policyDef.twod__Payment_Definition__c = paymentDefinationId;
        policyDef.twod__Type__c = policyDefType;
        policyDef.twod__Sub_Type__c = policyDefSubType;
        policyDef.twod__Status__c = 'Active';
        return policyDef;
    }
    
    public static twod__Policy_Applicability_Term__c CreatePAT(string name, id policyDefinationId, string referValue, string applicabilitySubType, string applicabilityValue){
        twod__Policy_Applicability_Term__c pat = new twod__Policy_Applicability_Term__c();
        pat.twod__Applicability_Term_Type__c = referValue;
        pat.twod__Applicability_SubType__c = applicabilitySubType;
        pat.twod__Applicability_Value__c = applicabilityValue;
        pat.twod__Policy_Definition__c = policyDefinationId;
        return pat;
    }
    
    public static twod__Warranty_Coverages__c CreateWarrantyCoverage(string name, id WRId, id policyDefinationId, boolean isActive, date warrantyEndDate, date warrantyStartDate, integer maximumUnit){
        twod__Warranty_Coverages__c warrantyCoverage = new twod__Warranty_Coverages__c();
        warrantyCoverage.twod__Warranty_Registration__c = WRId;
        warrantyCoverage.twod__Is_Active__c = isActive;
        warrantyCoverage.twod__Warranty_End_Date__c = warrantyEndDate;
        warrantyCoverage.twod__Warranty_Start_Date__c = warrantyStartDate;
        warrantyCoverage.twod__Maximum_Unit__c = maximumUnit;
        return warrantyCoverage;
    }
    
    public static twod__Claim__c createClaim(){
        twod__Claim__c claim = new twod__Claim__c();
        return claim;
    }
    
    public static twod__Claim_Financial__c createClaimFinancial(id claimId, string paymentType){
        twod__Claim_Financial__c cf = new twod__Claim_Financial__c();
        cf.twod__Claim__c = claimId;
        cf.twod__Payment_Type__c = paymentType;
        return cf;
    }
    
    public static twod__Claim_Part__c createClaimInstallPart(id inventoryId, id claimId){
        twod__Claim_Part__c installClaimPart = new twod__Claim_Part__c();
        installClaimPart.Name = 'Test001';
        //installClaimPart.recordtypeId = recordID;
        installClaimPart.twod__Claim__c = claimId;
        installClaimPart.twod__Custom_Part_Cost__c = 40;
        installClaimPart.twod__Final_Parts_Cost__c = 40;
        installClaimPart.twod__Inventory__c = inventoryId;
        installClaimPart.twod__Miscellaneous_Part_Name__c = 'test';
        //installClaimPart.twod__Warranty_Product__c = TestWarrantyProduct1.Id;
        installClaimPart.twod__Invoice_Date__c =  System.today()-7;
        installClaimPart.twod__Quantity__c = 500;
        //installClaimPart.twod__Warranty_Product_Pricebook__c = wp.Id;
        return installClaimPart;
    }
    
    public static twod__Removed_Claim_Part__c createRemovedClaimPart(id inventoryId, id claimId, integer quantity){
        twod__Removed_Claim_Part__c rc = new twod__Removed_Claim_Part__c();
        rc.twod__Inventory__c = inventoryId;
        rc.twod__Claim__c = claimId;
        rc.twod__Quantity__c = quantity;
        return rc;
    }
    
    public static twod__Warehouse__c createWarehouseLocation(){
        twod__Warehouse__c wh = new twod__Warehouse__c();
        wh.Name = 'Test_US';
        wh.twod__Address_Line_1__c = 'asd street';
        wh.twod__City__c = 'testCity';
        return wh;
    }
    
    public static twod__Shipment_Detail__c createShipmentDetail(id whLocationId){
        twod__Shipment_Detail__c sh = new twod__Shipment_Detail__c();
        sh.twod__Return_Location__c = whLocationId;
        return sh;
    }
    
    public static twod__Claim_Shipment__c createShipmentDetail(id removedClaimPartId, id shipmentDetailId, integer quantity){
        twod__Claim_Shipment__c cs = new twod__Claim_Shipment__c();
        cs.twod__Quantity__c = quantity;
        cs.twod__Removed_Claim_Part__c = removedClaimPartId;
        cs.twod__Shipment_Detail__c = shipmentDetailId;
        return cs;
    }
    
    public static twod__country__c createCountry(){
        twod__country__c c = new twod__country__c(Name = 'India',twod__Currency_Code__c = 'INR');
        return c;
    }
    
    public static twod__Warranty_Code__c createWarrantyCode(String wCodeName,Id wpID){
       twod__Warranty_Code__c warrantyCode = new twod__Warranty_Code__c();
       warrantyCode.Name                         = wCodeName;
       warrantyCode.twod__Warranty_Product__c            = wpID;
       warrantyCode.twod__Standard_Labor_Hour__c       =  10;
       return warrantyCode;      
   }
    
    public static twod__Claim_Service_Information__c createClaimService(Id jobCode, Integer quantity, Id claimId){
       twod__Claim_Service_Information__c claimService = new twod__Claim_Service_Information__c();
       claimService.Name  = 'Test Claim Service';
       claimService.twod__Service_Job_Code__c  = jobCode;  
       claimService.twod__Total_Labor_hours__c   = quantity;
       claimService.twod__claim__c  = claimId;
       return claimService;      
   }
    
    public static twod__Warranty_Product_Pricebook__c createtWarrantyProductPricebook(id countryId, id warrantyProductId){
        twod__Warranty_Product_Pricebook__c wp = new twod__Warranty_Product_Pricebook__c();
        wp.Name = 'test';
        wp.twod__Country__c = countryId;
        wp.twod__Warranty_Product__c = warrantyProductId;
        wp.twod__Valid_From__c = System.today()-35;
        wp.twod__Valid_Until__c = System.today()+365;
        wp.twod__Price__c = 400;
        return wp;
    }
    
    public static twod__Group__c createtGroup(){
        twod__Group__c grp =new twod__Group__c();
        grp.twod__Name__c='grp';
        grp.twod__Object_Name__c='Account';
        return grp;
    }
    
    public static twod__Group_Member__c createtGroupMember(Id groupId, Id accountId){
        twod__Group_Member__c member = new twod__Group_Member__c();
        member.twod__Group__c = groupId;
        member.twod__Record_Id__c = string.valueOf(accountId).substring(0, 15);
        member.twod__Account__c = accountId;
        return member;
    }
         
    
    public static User createCommunityUser(){
        string userName = UserInfo.getOrganizationId()+'_'+DateTime.now().millisecondGMT()+'testCommunityUser@test.com';
        User communityUser = new User(                
            Username = userName,
            Alias = 'test',
            Email = 'test100@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'xyz',
            CommunityNickname = UserInfo.getOrganizationId()+'_'+DateTime.now().millisecondGMT()+'abcd',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        return communityUser;
    }
    
    public static User createPartReceiverUser(){
        string userName = UserInfo.getOrganizationId()+'_'+DateTime.now().millisecondGMT()+'testPartReceiverUser@test.com';
        User partReceiverUser = new User(                
            Username = userName,
            Alias = 'test',
            Email = 'test100@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'xyz',
            CommunityNickname = UserInfo.getOrganizationId()+'_'+DateTime.now().millisecondGMT()+'abcd',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        return partReceiverUser;
    }
    
    public static twod__Service_Campaign__c createServiceCampaign(Id claimTemplateId,Id paymentDefId){
       twod__Service_Campaign__c servicecampaign = new twod__Service_Campaign__c();
       servicecampaign.Name                          = 'Test Service Campaign';
       servicecampaign.twod__Start_Date__c                   = date.today();
       servicecampaign.twod__End_Date__c                   =  date.today();
       servicecampaign.twod__Claim_Template__c           =  claimTemplateId; 
       servicecampaign.twod__Payment_Definitions__c        =  paymentDefId;        
       return servicecampaign;      
    }
    
    public static twod__Campaign_Members__c createCampaignMember(Id invId,Id serviceCampaignId){
       twod__Campaign_Members__c campaignMember = new twod__Campaign_Members__c();
       campaignMember.twod__Inventory__c                         = invId;
       campaignMember.twod__Service_Campaign__c              = serviceCampaignId;       
       return campaignMember;      
    }
    
    
    public static Attachment createAttachment(Id parentId){
        Attachment att = new Attachment();      
        att.Name = 'Test Attachment';
        Blob bodyBlob = Blob.valueOf('Test Attachment Body');
        att.body = bodyBlob;
        att.parentId = parentId;
        return att;
    }

    public static twod__WOD__c createWODCustomSetting_ForExecuteAccountTrigger(){
        return new twod__WOD__c(name='Execute Account Trigger',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForExecuteUserTrigger(){
        return new twod__WOD__c(name='Execute User Trigger',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForExecuteContactTrigger(){
        return new twod__WOD__c(name='Execute Contact Trigger',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForExecuteClaimTrigger(){
        return new twod__WOD__c(name='Execute Claim Trigger',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForExecuteClaimTriggerForPolicyChange(){
        return new twod__WOD__c(name='Enable OnPolicyChange',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_AllPaymentConfigurations(){
        return new twod__WOD__c(name='All Payment Configurations',twod__Trigger_Value__c = 'Labor,Meals,Parking,TravelByDistance,TravelByHours');
    }
    
    public static twod__WOD__c createWODCustomSetting_AllPrefixConfigurations(){
        return new twod__WOD__c(name='All Prefix Configurations',twod__Trigger_Value__c = 'Percent_,Final_,Total_,Approved_');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForExecuteClaimFinancialTrigger(){
        return new twod__WOD__c(name='Execute Claim Financial Trigger',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForExecuteClaimShipmentTrigger(){
        return new twod__WOD__c(name='Execute Claim Shipment Trigger',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForExecutePaymentDefinitionTrigger(){
        return new twod__WOD__c(name='Enable PaymentDefinitionTrigger',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForExecuteRemovedClaimPartTrigger(){
        return new twod__WOD__c(name='Enable RemovedClaimPartTrigger',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForInstalledClaimPart_AT(){
        return new twod__WOD__c(name='Enable InstalledClaimPart_AT',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForExecuteShipmentTrigger(){
        return new twod__WOD__c(name='Execute Shipment Trigger',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForAllowedIds(){
        return new twod__WOD__c(name='Allowed Ids',twod__Trigger_Value__c = '00e280000026uR8,00e280000026uR8');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForAllowedProfileForClaimDeletEdit(){
        return new twod__WOD__c(name='Allowed Profile For Claim DeletEdit',twod__Trigger_Value__c = 'System Administrator,Warranty Admin,Warranty Processor');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForEnableMasterRecoveryClaim(){
        return new twod__WOD__c(name='Enable MasterRecoveryClaim',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForEnableRemovedClaimPartSharing(){
        return new twod__WOD__c(name='Enable twod_RemovedClaimPartSharing',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForFieldModClaimPartsCompareFields1(){
        return new twod__WOD__c(name='FieldMod_ClaimParts_CompareFields1',twod__Trigger_Value__c = 'Quantity__c');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForFieldModClaimServiceCompareFields1(){
        return new twod__WOD__c(name='FieldMod_ClaimService_CompareFields1',twod__Trigger_Value__c = 'Total_Labor_hours__c');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForFieldModClaimCompareFields1(){
        return new twod__WOD__c(name='FieldMod_Claim_CompareFields1',twod__Trigger_Value__c = 'Total_Labor_Cost__c,Total_Meals_Cost__c,Total_Parking_Cost__c,Total_Parts_Cost__c');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForFieldModClaimCompareFields2(){
        return new twod__WOD__c(name='FieldMod_Claim_CompareFields2',twod__Trigger_Value__c = 'Total_TravelByDistance_Cost__c,Total_TravelByHours_Cost__c,Final_Labor_Cost__c,Final_Meals_Cost__c');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForFieldModClaimCompareFields3(){
        return new twod__WOD__c(name='FieldMod_Claim_CompareFields3',twod__Trigger_Value__c = 'Final_Parking_Cost__c,Final_Parts_Cost__c,Final_TravelByHours_Cost__c,Final_TravelByDistance_Cost__c');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForMultipleWarrantyRegistration(){
        return new twod__WOD__c(name='Multiple Warranty Registration',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForCreateUPSShipmentPreferences(){
        return new twod__WOD__c(name='UPS Shipment Preferences',twod__Trigger_Value__c = 'a1Q28000000zZPlEAM');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForExecuteTxnMemoHistoryTrigger(){
        return new twod__WOD__c(name='Execute Txn Memo History Trigger',twod__isTriggered__c = true);
    }

    public static twod__WOD__c createWODCustomSetting_ForEnablePaymentDefinitionItemsTrigger(){
        return new twod__WOD__c(name='Enable PaymentDefinitionItemsTrigger',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForAllowedProfileForClaimSubmit(){
        return new twod__WOD__c(name='Allowed Profile For Claim submit',twod__Trigger_Value__c = 'System Administrator,Warranty Admin,Warranty Processor');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForAutoAddNonSerializedRemovedPart(){
        return new twod__WOD__c(name='Auto Add Non-Serialized Removed Part',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForBatchUploadMember(){
        return new twod__WOD__c(name='Batch Upload Member',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForClaimDuplicateCheckPeriodInDays(){
        return new twod__WOD__c(name='Claim Duplicate Check Period In Days',twod__Trigger_Value__c = '180');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForCMAutonumber(){
        return new twod__WOD__c(name='CM Autonumber',twod__Trigger_Value__c = '100021');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForDefaultPolicy(){
        return new twod__WOD__c(name='Default Policy',twod__Trigger_Value__c = 'a0R28000004B9x3');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForDefaultPrice(){
        return new twod__WOD__c(name='Default Price',twod__Trigger_Value__c = 'a0o28000001A2AS');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForDefaultRate(){
        return new twod__WOD__c(name='Default Rate',twod__Trigger_Value__c = 'a0T28000008braf');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForEnableChangeCustomerName(){
        return new twod__WOD__c(name='Enable changeCustomerName',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForEnableUpdateMaximumUnit(){
        return new twod__WOD__c(name='Enable updateMaximumUnit',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForEnableWarrantyRegistrationTrigger(){
        return new twod__WOD__c(name='Enable WarrantyRegistrationTrigger',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForEnableWarrantyRuleAssociationTrigger(){
        return new twod__WOD__c(name='Enable WarrantyRuleAssociationTrigger',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForEnableWarrantyRuleCriteriaTrigger(){
        return new twod__WOD__c(name='Enable WarrantyRuleCriteriaTrigger',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForExecuteWarrantyCoverageTrigger(){
        return new twod__WOD__c(name='Execute Warranty Coverage Trigger',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForExtendedRegistrationMaxDays(){
        return new twod__WOD__c(name='Extended Registration Max Days',twod__isTriggered__c = true,twod__Trigger_Value__c = '10');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForFieldModObjects(){
        return new twod__WOD__c(name='FieldMod_Objects',twod__Trigger_Value__c = 'Claim__c,Claim_Part__c,Claim_Service_Information__c');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForInvBatchSize(){
        return new twod__WOD__c(name='InvBatchSize',twod__Trigger_Value__c = '5');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForInventoryEditProfileAccess(){
        return new twod__WOD__c(name='Inventory_Edit_Profile_Access',twod__Trigger_Value__c = 'Bigdog Dealer,Bigdog Distributor,Hustler Dealer,Hustler Distributor');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForLicenseReportFields(){
        return new twod__WOD__c(name='License Report Fields',twod__Trigger_Value__c = 'Name,Profile.Name,UserRole.Name,UserType,IsActive,LastLoginDate,Profile.UserLicense.Name');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForLicenseReportEmail(){
        return new twod__WOD__c(name='LicenseReportEmail',twod__Trigger_Value__c = 'anjani.rai@tavant.com');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForLookupMiniumCharacters(){
        return new twod__WOD__c(name='Lookup Minium Characters',twod__Trigger_Value__c = '2');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForMiscellaneousPartSettings(){
        return new twod__WOD__c(name='MiscellaneousPartSettings',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForNamespacePrefix(){
        return new twod__WOD__c(name='Namespace Prefix',twod__Trigger_Value__c = 'twod__');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForPartPriceClientCertificateName(){
        return new twod__WOD__c(name='PartPrice_ClientCertificate_Name',twod__Trigger_Value__c = 'tavantclient');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForPartPriceURNAddress(){
        return new twod__WOD__c(name='PartPrice_URN_Address',twod__Trigger_Value__c = 'urn:services-qad-com::prod');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForPartPricKeystorePassword(){
        return new twod__WOD__c(name='PartPric_Keystore_Password',twod__Trigger_Value__c = 'tavant');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForPartByPartSettings(){
        return new twod__WOD__c(name='Part_By_Part_Settings',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForPaymentType(){
        return new twod__WOD__c(name='Payment Type',twod__Trigger_Value__c = 'Labor,TravelByDistance,TravelByHours,Category1,Category2');
    }
    
    public static twod__WOD__c createWODCustomSetting_ForWRAutonumber(){
        return new twod__WOD__c(name='WR Autonumber',twod__Trigger_Value__c = '100798');
    }
    
     public static twod__WOD__c createWODCustomSetting_ForWarrantyProductTrigger(){
        return new twod__WOD__c(name='Enable WarrantyProductTrigger',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForRateDetailsTrigger(){
        return new twod__WOD__c(name='Enable RateDetailsTrigger',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForTransactionMemoHistoryTrigger(){
        return new twod__WOD__c(name='Enable TransactionMemoHistoryTrigger',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForTWoD_DealerTrainingTrigger(){
        return new twod__WOD__c(name='Enable TWoD_DealerTrainingTrigger',twod__isTriggered__c = true);
    }
    
    public static twod__WOD__c createWODCustomSetting_ForInstalledClaimPartTriggerActive(){
        return new twod__WOD__c(name='Enable InstalledClaimPartTriggerActive',twod__isTriggered__c = true);
    }  
    
    public static twod__WOD__c createWODCustomSetting_ForTwodClaimsTrigger(){
        return new twod__WOD__c(name='Enable TwodClaimsTrigger',twod__isTriggered__c = true);
    }  
    public static twod__WOD__c createWODCustomSetting_ForTwodRemovedClaimPartTrigger(){
        return new twod__WOD__c(name='Enable RemovedClaimPartTriggerActive',twod__isTriggered__c = true);
    }
   
    
    
    
    
    public static List<twod__WOD__c> createAllWODCustomSetting(){
        List<twod__WOD__c> wodCsList = new List<twod__WOD__c>();
        wodCsList.add(new twod__WOD__c(name='All Payment Configurations',twod__Trigger_Value__c = 'Labor,TravelByDistance,TravelByHours,Category1,Category2'));
        wodCsList.add(new twod__WOD__c(name='All Prefix Configurations',twod__Trigger_Value__c = 'Percent_,Final_,Total_,Approved_'));
        wodCsList.add(new twod__WOD__c(name='Allowed Ids',twod__Trigger_Value__c = '00e280000026uVj,00e28000001Sh6b'));
        wodCsList.add(new twod__WOD__c(name='Allowed Profile For Claim DeletEdit',twod__Trigger_Value__c = 'System Administrator,Warranty Admin,Warranty Processor'));
        wodCsList.add(new twod__WOD__c(name='Allowed Profile For Claim submit',twod__Trigger_Value__c = 'System Administrator,Warranty Admin,Warranty Processor'));
        wodCsList.add(new twod__WOD__c(name='Auto Add Non-Serialized Removed Part',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Batch Upload Member',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Claim Duplicate Check Period In Days',twod__Trigger_Value__c = '180'));
        wodCsList.add(new twod__WOD__c(name='CM Autonumber',twod__Trigger_Value__c = '100021'));
        wodCsList.add(new twod__WOD__c(name='Default Policy',twod__Trigger_Value__c = 'a0R28000004B9x3'));
        wodCsList.add(new twod__WOD__c(name='Default Price',twod__Trigger_Value__c = 'a0o28000001A2AS'));
        wodCsList.add(new twod__WOD__c(name='Default Rate',twod__Trigger_Value__c = 'a0T28000008braf'));
        wodCsList.add(new twod__WOD__c(name='Enable changeCustomerName',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Enable InstalledClaimPart_AT',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Enable MasterRecoveryClaim',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Enable OnPolicyChange',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Enable PaymentDefinitionItemsTrigger',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Enable PaymentDefinitionTrigger',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Enable RemovedClaimPartTrigger',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Enable twod_RemovedClaimPartSharing',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Enable WarrantyRegistrationTrigger',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Enable WarrantyRuleAssociationTrigger',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Enable WarrantyRuleCriteriaTrigger',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Execute Account Trigger',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Execute Claim Financial Trigger',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Execute Claim Shipment Trigger',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Execute Claim Trigger',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Execute Contact Trigger',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Execute Shipment Trigger',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Execute Txn Memo History Trigger',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Execute User Trigger',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Execute Warranty Coverage Trigger',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Extended Registration Max Days',twod__isTriggered__c = true,twod__Trigger_Value__c = '10'));
        wodCsList.add(new twod__WOD__c(name='FieldMod_ClaimParts_CompareFields1',twod__Trigger_Value__c = 'Quantity__c'));
        wodCsList.add(new twod__WOD__c(name='FieldMod_ClaimService_CompareFields1',twod__Trigger_Value__c = 'Total_Labor_hours__c'));
        wodCsList.add(new twod__WOD__c(name='FieldMod_Claim_CompareFields1',twod__Trigger_Value__c = 'Total_Labor_Cost__c,Total_Meals_Cost__c,Total_Parking_Cost__c,Total_Parts_Cost__c'));
        wodCsList.add(new twod__WOD__c(name='FieldMod_Claim_CompareFields2',twod__Trigger_Value__c = 'Total_TravelByDistance_Cost__c,Total_TravelByHours_Cost__c,Final_Labor_Cost__c,Final_Meals_Cost__c'));
        wodCsList.add(new twod__WOD__c(name='FieldMod_Claim_CompareFields3',twod__Trigger_Value__c = 'Final_Parking_Cost__c,Final_Parts_Cost__c,Final_TravelByHours_Cost__c,Final_TravelByDistance_Cost__c'));
        wodCsList.add(new twod__WOD__c(name='FieldMod_Objects',twod__Trigger_Value__c = 'Claim__c,Claim_Part__c,Claim_Service_Information__c'));
        wodCsList.add(new twod__WOD__c(name='InvBatchSize',twod__Trigger_Value__c = '5'));
        wodCsList.add(new twod__WOD__c(name='Inventory_Edit_Profile_Access',twod__Trigger_Value__c = 'Bigdog Dealer,Bigdog Distributor,Hustler Dealer,Hustler Distributor'));
        wodCsList.add(new twod__WOD__c(name='License Report Fields',twod__Trigger_Value__c = 'Name,Profile.Name,UserRole.Name,UserType,IsActive,LastLoginDate,Profile.UserLicense.Name'));
        wodCsList.add(new twod__WOD__c(name='LicenseReportEmail',twod__Trigger_Value__c = 'anjani.rai@tavant.com'));
        wodCsList.add(new twod__WOD__c(name='Lookup Minium Characters',twod__Trigger_Value__c = '2'));
        wodCsList.add(new twod__WOD__c(name='MiscellaneousPartSettings',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Multiple Warranty Registration',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Namespace Prefix',twod__Trigger_Value__c = 'twod__'));
        wodCsList.add(new twod__WOD__c(name='PartPrice_ClientCertificate_Name',twod__Trigger_Value__c = 'tavantclient'));
        wodCsList.add(new twod__WOD__c(name='PartPrice_URN_Address',twod__Trigger_Value__c = 'urn:services-qad-com::prod'));
        wodCsList.add(new twod__WOD__c(name='PartPric_Keystore_Password',twod__Trigger_Value__c = 'tavant'));
        wodCsList.add(new twod__WOD__c(name='Part_By_Part_Settings',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Payment Type',twod__Trigger_Value__c = 'Labor,TravelByDistance,TravelByHours,Category1,Category2'));
        wodCsList.add(new twod__WOD__c(name='UPS Shipment Preferences',twod__Trigger_Value__c = 'a1Q28000000zZPlEAM'));
        wodCsList.add(new twod__WOD__c(name='WR Autonumber',twod__Trigger_Value__c = '100798'));
        wodCsList.add(new twod__WOD__c(name='Enable TwodVRFStartupsTrigger',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Enable TwodWarrantyRegistrationTrigger',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Enable RemovedClaimPartTriggerActive',twod__isTriggered__c = true));
        wodCsList.add(new twod__WOD__c(name='Enable WarrantyProductTrigger',twod__isTriggered__c = true));
        //Commenting below line as it is already added in the list
        //wodCsList.add(new twod__WOD__c(name='Enable PaymentDefinitionTrigger',twod__isTriggered__c = true));
       
        return wodCsList;
    }
    
        public Static String getObjectRecordTypeId(String ovjAPIName, String recordTypeName) {
        system.debug('------2. getObjectRecordTypeId() called -----');
        if(!String.isBlank(ovjAPIName) && !String.isBlank(recordTypeName))
            return Schema.getGlobalDescribe().get(ovjAPIName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        return null;
    }
    
    
    
}