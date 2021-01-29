/**
 * @File Name          : GenerateJSONFromLineItems.cls
 * @Description        : This class is used to Create JSON String used in creating Line Item Records.
 * @Author             : Anuj Kumar
 * @Group              : 
 * @Last Modified By   : Anuj Kumar
 * @Last Modified On   : 06/10/2019 10:15 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    06/10/2019 10:15 AM          Anuj Kumar            Initial Version
**/

Public With Sharing Class GenerateJSONFromLineItems{
    
    Public Static String ENQUIRY_RECORDTYPE;
    Public Static Decimal ACCESSORIES_DISCOUNT_AMOUNT;
    Public Static Decimal OFFER_DISCOUNT_AMOUNT;
    
    Public Static List<String> headerValueDataList = new List<String>();
    
    Public Static List<OpportunityLineItems_JSON_STRUCTURE.AddComponent> addComponentList = new List<OpportunityLineItems_JSON_STRUCTURE.AddComponent>();
    
    Public Static List<OpportunityLineItems_JSON_STRUCTURE.AddAccessories> addAccessoriesList = new List<OpportunityLineItems_JSON_STRUCTURE.AddAccessories>();
    
    Public Static List<OpportunityLineItem> oppLineItemList;
    
    Public Static OpportunityLineItems_JSON_STRUCTURE jsonObject = new OpportunityLineItems_JSON_STRUCTURE();
    
    Public Static OpportunityLineItems_JSON_STRUCTURE.AddSchemes addSchemeData = new OpportunityLineItems_JSON_STRUCTURE.AddSchemes();
    
    Public Static Map<String, OpportunityLineItem> productIdWithOpportunityLineItemMap = new Map<String, OpportunityLineItem>();
    
    
    /*------------------------------------------------------------------------------------
        Description     To Generate JSON String from Line Item Records
        params          recordId - Selected Opportunity Id
    ------------------------------------------------------------------------------------*/
    @AuraEnabled
    Public Static String generateJSONForEnquiry(String recordId){
        
        List<Opportunity> opportunityRecord = new List<Opportunity>();
        
        OpportunityLineItems_JSON_STRUCTURE.OpportunityInfo oppInfo = new OpportunityLineItems_JSON_STRUCTURE.OpportunityInfo();
        
        OpportunityLineItems_JSON_STRUCTURE.Variant_toReplace_R colorRelatedVariant = new OpportunityLineItems_JSON_STRUCTURE.Variant_toReplace_R();
        
        OpportunityLineItems_JSON_STRUCTURE.SelectedColorVariant colorVariant = new OpportunityLineItems_JSON_STRUCTURE.SelectedColorVariant();
        
        if(!String.isEmpty(recordId)){
            opportunityRecord = [Select id, Name, RecordType.Name, SVOC_Customer_Name__c, DMS_Enquiry_Name__c, Amount, 
                                StageName, Mobile__c, Email__c, Pricebook2Id, Color__c, Color__r.Color_Type__c, Color__r.Variant__c,
                                Color__r.Color_Code__c, Color__r.Name, Color__r.Variant__r.ProductCode, Cash_Payment__c, 
                                Finance_Amount__c, Employer_Name__c, Employer_Name__r.Name
                                from Opportunity 
                                where Id =: recordId];
            
            queryLineItemRecords(recordId);
        }
        
        if(opportunityRecord != Null && opportunityRecord.size() > 0 && opportunityRecord[0].RecordTypeId != Null){
            
            oppInfo.Amount = opportunityRecord[0].Amount;
            oppInfo.StageName = opportunityRecord[0].StageName;
            oppInfo.Mobile_toReplace = opportunityRecord[0].Mobile__c;
            oppInfo.Email_toReplace = opportunityRecord[0].Email__c;
            oppInfo.Pricebook2Id = opportunityRecord[0].Pricebook2Id;
            oppInfo.Name = opportunityRecord[0].Name;
            
            
            addSchemeData.cashPaymentData = opportunityRecord[0].Cash_Payment__c;
            addSchemeData.financeAmountData = string.valueOf(opportunityRecord[0].Finance_Amount__c);
            
            addSchemeData.employerName = opportunityRecord[0].Employer_Name__c != Null ? opportunityRecord[0].Employer_Name__r.Name : Null;
            addSchemeData.offersText = null;
            addSchemeData.OfferData = 0.0;
            
            /*------------------------------------------------------------------------------------
                STORE ENQUIRY RECORD TYPE INFO
            ------------------------------------------------------------------------------------*/
            jsonObject.enquiryRecordType = opportunityRecord[0].RecordType.Name;
            
            /*------------------------------------------------------------------------------------
                FOR SELECTED COLOR VARIANT RECORD
            ------------------------------------------------------------------------------------*/
            
            colorRelatedVariant.Id = opportunityRecord[0].Color__c != Null ? opportunityRecord[0].Color__r.Variant__c : Null;
            colorRelatedVariant.ProductCode = opportunityRecord[0].Color__r.Variant__c != Null ? opportunityRecord[0].Color__r.Variant__r.ProductCode : Null;
            
            colorVariant.Variant_toReplace_R = colorRelatedVariant;
            colorVariant.Color_Type_toReplace = opportunityRecord[0].Color__c != Null ? opportunityRecord[0].Color__r.Color_Type__c : Null;
            colorVariant.Variant_toReplace = opportunityRecord[0].Color__c != Null ? opportunityRecord[0].Color__r.Variant__c : Null;
            colorVariant.Color_Code_toReplace = opportunityRecord[0].Color__c != Null ? opportunityRecord[0].Color__r.Color_Code__c : Null;
            colorVariant.Name = opportunityRecord[0].Color__c != Null ? opportunityRecord[0].Color__r.Name : Null;
            colorVariant.Id = opportunityRecord[0].Color__c;
            
            /*------------------------------------------------------------------------------------
                STORE SELECTED COLOR VARIANT INFO
            ------------------------------------------------------------------------------------*/
            jsonObject.selectedColorVariant = colorVariant;
            
        }
        
        if(opportunityRecord != Null && opportunityRecord.size() > 0 && opportunityRecord[0].SVOC_Customer_Name__c != Null){
            headerValueDataList.add('Customer Name : ' + opportunityRecord[0].SVOC_Customer_Name__c);            
        }
        
        if(opportunityRecord != Null && opportunityRecord.size() > 0 && opportunityRecord[0].DMS_Enquiry_Name__c != Null){
            headerValueDataList.add('DMS Enquiry Number : ' + opportunityRecord[0].DMS_Enquiry_Name__c);            
        }
        
        
        
        // RETRIVE DISCOUNT CUSTOM SETTING INFO
        OtherAmountValidation__c otherDiscount = OtherAmountValidation__c.getOrgDefaults();
        
        ACCESSORIES_DISCOUNT_AMOUNT = otherDiscount.Accessories_Discount_Amount__c != null ? otherDiscount.Accessories_Discount_Amount__c : 0;
        OFFER_DISCOUNT_AMOUNT = otherDiscount.Offer_Discount_Amount__c != null ? otherDiscount.Offer_Discount_Amount__c : 0;
        
        /*------------------------------------------------------------------------------------
            STORE ACCESSORIES DISCOUNT VALIDATION AMOUNT 
        ------------------------------------------------------------------------------------*/
        jsonObject.accessoriesValidAmount = ACCESSORIES_DISCOUNT_AMOUNT;
        
        /*------------------------------------------------------------------------------------
            STORE OTHER DISCOUNT VALIDATION AMOUNT
        ------------------------------------------------------------------------------------*/
        jsonObject.otherValidAmount = OFFER_DISCOUNT_AMOUNT;
        
        // RETRIVE ENQUIRY RECORDTYPE INFO
        if(opportunityRecord != Null && opportunityRecord.size() > 0){
            ENQUIRY_RECORDTYPE = opportunityRecord[0].Recordtype.Name;
        }
        
        for(string productId : productIdWithOpportunityLineItemMap.keySet()){
            system.debug('== Product RecordType Name '+productIdWithOpportunityLineItemMap.get(productId).priceBookEntry.product2.RecordType.Name);
            
            if(!string.isEmpty(productIdWithOpportunityLineItemMap.get(productId).priceBookEntry.product2.RecordTypeId)){
                generateJSONData(productIdWithOpportunityLineItemMap.get(productId));
            }
        }
        
        /*------------------------------------------------------------------------------------
            STORE HEADER VALUE INFO
        ------------------------------------------------------------------------------------*/
        jsonObject.headerValue = headerValueDataList;
        
        /*------------------------------------------------------------------------------------
            STORE ADD COMPONENT INFO
        ------------------------------------------------------------------------------------*/
        jsonObject.addComponent = addComponentList;
        
        /*------------------------------------------------------------------------------------
            STORE ADD COMPONENT INFO
        ------------------------------------------------------------------------------------*/
        jsonObject.addAccessories = addAccessoriesList;
        
        /*------------------------------------------------------------------------------------
            STORE OPPORTUNITY INFO
        ------------------------------------------------------------------------------------*/
        jsonObject.opportunityInfo = oppInfo;
        
        if(jsonObject.addSchemes == null){
            
            /*------------------------------------------------------------------------------------
            STORE OTHER ACCESSORIES DISCOUNT INFO (If there is no product with offer Record Type.)
            ------------------------------------------------------------------------------------*/
            jsonObject.addSchemes = addSchemeData;
            
        }
        
        if(jsonObject.otherAccessoriesDiscount == null){
            OpportunityLineItems_JSON_STRUCTURE.otherAccessoriesDiscount otherAcc = new OpportunityLineItems_JSON_STRUCTURE.otherAccessoriesDiscount();
            /*------------------------------------------------------------------------------------
                STORE OTHER ACCESSORIES DISCOUNT INFO
            ------------------------------------------------------------------------------------*/
            jsonObject.otherAccessoriesDiscount = otherAcc;
        }
        
        if(jsonObject.otherCharge == null){
            
            OpportunityLineItems_JSON_STRUCTURE.OtherCharge otherChange = new OpportunityLineItems_JSON_STRUCTURE.OtherCharge();
            
            /*------------------------------------------------------------------------------------
                STORE OTHER CHARGE INFO
            ------------------------------------------------------------------------------------*/
            jsonObject.otherCharge = otherChange;
            
        }
        
        string jsonString = '';
        if(jsonObject != null){
            
            jsonString = JSON.Serialize(jsonObject);
            
            if(jsonString.contains('_toReplace_R')){
               jsonString = jsonString.replace('_toReplace_R', '__r');
            }
            if(jsonString.contains('_toReplace')){
                jsonString = jsonString.replace('_toReplace', '__c');
            }
            
            system.debug('== Final jsonString '+jsonString);
        }
        return jsonString;
    }
    
    /*------------------------------------------------------------------------------------
        Description     Query Opportunity Line Item Records
        params          recordId - Selected Opportunity Id
    ------------------------------------------------------------------------------------*/
    Public Static void queryLineItemRecords(String opportunityId){
        oppLineItemList = new List<OpportunityLineItem>([ Select id, Name, UnitPrice, Quantity, priceBookEntryId, 
                            priceBookEntry.product2Id, priceBookEntry.product2.Name, priceBookEntry.product2.RecordType.Name,
                            priceBookEntry.product2.RecordTypeId, TotalPrice,
                            priceBookEntry.product2.Family, priceBookEntry.product2.Applicable_Model__c, priceBookEntry.product2.IsActive,
                            priceBookEntry.product2.Extended_Warranty_1_year__c, priceBookEntry.product2.Extended_Warranty_2_year__c,
                            priceBookEntry.product2.Extended_Warranty_3_year__c, priceBookEntry.product2.Loyalty_Amount__c,
                            priceBookEntry.product2.Minimum_Quantity__c, priceBookEntry.product2.Maximum_Quantity__c, 
                            priceBookEntry.product2.Model__c, priceBookEntry.product2.Fuel_Type__c, 
                            opportunityId,
                            MCP_Package__c, MCP_Validity__c
                            From OpportunityLineItem Where opportunityId =: opportunityId]);
                            
        for(OpportunityLineItem oli : oppLineItemList){
            productIdWithOpportunityLineItemMap.put(oli.priceBookEntry.product2Id, oli);
        }
    }
    
    /*------------------------------------------------------------------------------------
        Description     Generate JSON object from Line Item Records
        params          record - OpportunityLineItem record data.
    ------------------------------------------------------------------------------------*/
    Public Static void generateJSONData(OpportunityLineItem record){
        
        
        /*------------------------------------------------------------------------------------
            FOR COMPONENT RECORD TYPE PRODUCT ONLY
        ------------------------------------------------------------------------------------*/
        if((record.priceBookEntry.product2.RecordType.Name).equalsIgnoreCase(ConstantsUtility.COMPONENT_CONST)){
            
            generateADDComponentData(record);
        }
        
        /*------------------------------------------------------------------------------------
            FOR ACCESSORIES RECORD TYPE PRODUCT ONLY
        ------------------------------------------------------------------------------------*/
        if((record.priceBookEntry.product2.RecordType.Name).equalsIgnoreCase(ConstantsUtility.ACCESSORIES_CONST)){
            generateADDAccessoriesData(record);    
        }
        
        /*------------------------------------------------------------------------------------
            FOR OFFER RECORD TYPE PRODUCT ONLY
        ------------------------------------------------------------------------------------*/
        if((record.priceBookEntry.product2.RecordType.Name).equalsIgnoreCase(ConstantsUtility.OFFER_CONST)){
            generateAddSchemesData(record);    
        }
        
        /*------------------------------------------------------------------------------------
            FOR VARIANT RECORD TYPE PRODUCT ONLY
        ------------------------------------------------------------------------------------*/
        if((record.priceBookEntry.product2.RecordType.Name).equalsIgnoreCase(ConstantsUtility.VARIANT_CONST)){
            OpportunityLineItems_JSON_STRUCTURE.SelectedVariant variant = new OpportunityLineItems_JSON_STRUCTURE.SelectedVariant();
            
            variant.Family = record.priceBookEntry.product2.Family;
            variant.Fuel_Type_toReplace = record.priceBookEntry.product2.Fuel_Type__c;
            variant.Loyalty_Amount_toReplace = record.priceBookEntry.product2.Loyalty_Amount__c;
            variant.Extended_Warranty_3_year_toReplace = record.priceBookEntry.product2.Extended_Warranty_3_year__c;
            variant.Extended_Warranty_2_year_toReplace = record.priceBookEntry.product2.Extended_Warranty_2_year__c;
            variant.Extended_Warranty_1_year_toReplace = record.priceBookEntry.product2.Extended_Warranty_1_year__c;
            variant.Name = record.priceBookEntry.product2.Name;
            variant.Id = record.priceBookEntry.product2Id;
            
            /*------------------------------------------------------------------------------------
                STORE SELECTED VARIANT INFO
            ------------------------------------------------------------------------------------*/
            jsonObject.selectedVariant = variant;
            
            
            OpportunityLineItems_JSON_STRUCTURE.ExShowRoomVariant exShowRoomVariant = new OpportunityLineItems_JSON_STRUCTURE.ExShowRoomVariant();
            
            exShowRoomVariant.priceBookEntryId = record.priceBookEntryId;
            exShowRoomVariant.UnitPrice = string.valueOf(record.UnitPrice);
            exShowRoomVariant.Quantity = record.Quantity;
            exShowRoomVariant.opporrtunityId = record.opportunityId;
            
            /*------------------------------------------------------------------------------------
                STORE SELECTED VARIANT INFO
            ------------------------------------------------------------------------------------*/
            jsonObject.exShowRoomVariant = exShowRoomVariant;
            
        }
    }
    
    /*------------------------------------------------------------------------------------
        STORE ADD COMPONENT INFO
    ------------------------------------------------------------------------------------*/
    Public Static void generateADDComponentData(OpportunityLineItem record){
    
        if((record.priceBookEntry.product2.Name).equalsIgnoreCase(ConstantsUtility.EX_WARRANTY_CONST)){
            
            OpportunityLineItems_JSON_STRUCTURE.AddComponent addCom = new OpportunityLineItems_JSON_STRUCTURE.AddComponent();
            addCom.showCheckBox = false;
            
            if(record.priceBookEntry.product2.Extended_Warranty_1_year__c != Null){
                addCom.year = '1 year';
            }else if(record.priceBookEntry.product2.Extended_Warranty_2_year__c != Null){
                addCom.year = '2 year';
            }else if(record.priceBookEntry.product2.Extended_Warranty_3_year__c != Null){
                addCom.year = '3 year';
            }
            
            addCom.isDisabled = true;
            addCom.showLabel = false;
            addCom.isExchangedWarrenty = true;
            addCom.isChecked = true;
            addCom.value = record.UnitPrice;
            addCom.label = ConstantsUtility.EX_WARRANTY_CONST;
            
            addComponentList.add(addCom);
            
        }else if((record.priceBookEntry.product2.Name).equalsIgnoreCase(ConstantsUtility.LOYALTY_CONST)){
            
            OpportunityLineItems_JSON_STRUCTURE.AddComponent addCom = new OpportunityLineItems_JSON_STRUCTURE.AddComponent();
            addCom.showCheckBox = true;
            
            addCom.isDisabled = true;
            addCom.showLabel = true;
            addCom.isChecked = true;
            addCom.value = record.UnitPrice;
            addCom.label = ConstantsUtility.LOYALTY_CONST;
            
            addComponentList.add(addCom);
            
        }else if((record.priceBookEntry.product2.Name).equalsIgnoreCase(ConstantsUtility.INSURANCE_CONT)){
            
            OpportunityLineItems_JSON_STRUCTURE.AddComponent addCom = new OpportunityLineItems_JSON_STRUCTURE.AddComponent();
            addCom.showCheckBox = true;
            
            addCom.isDisabled = false;
            addCom.showLabel = true;
            addCom.isChecked = true;
            addCom.value = record.UnitPrice;
            addCom.label = ConstantsUtility.INSURANCE_CONT;
            
            addComponentList.add(addCom);
            
        }else if((record.priceBookEntry.product2.Name).equalsIgnoreCase(ConstantsUtility.MUNICIPAL_CH_CONST)){
            
            OpportunityLineItems_JSON_STRUCTURE.AddComponent addCom = new OpportunityLineItems_JSON_STRUCTURE.AddComponent();
            addCom.showCheckBox = true;
            
            addCom.isDisabled = false;
            addCom.showLabel = true;
            addCom.isChecked = true;
            addCom.value = record.UnitPrice;
            addCom.label = ConstantsUtility.MUNICIPAL_CH_CONST;
            
            addComponentList.add(addCom);
            
        }else if((record.priceBookEntry.product2.Name).equalsIgnoreCase(ConstantsUtility.NUM_PLATE_CONST)){
            
            OpportunityLineItems_JSON_STRUCTURE.AddComponent addCom = new OpportunityLineItems_JSON_STRUCTURE.AddComponent();
            addCom.showCheckBox = true;
            
            addCom.isDisabled = false;
            addCom.showLabel = true;
            addCom.isChecked = true;
            addCom.value = record.UnitPrice;
            addCom.label = ConstantsUtility.NUM_PLATE_CONST;
            
            addComponentList.add(addCom);
            
        }else if((record.priceBookEntry.product2.Name).equalsIgnoreCase(ConstantsUtility.ROAD_TAX_CONST)){
            
            OpportunityLineItems_JSON_STRUCTURE.AddComponent addCom = new OpportunityLineItems_JSON_STRUCTURE.AddComponent();
            addCom.showCheckBox = true;
            
            addCom.isDisabled = false;
            addCom.showLabel = true;
            addCom.isChecked = true;
            addCom.value = record.UnitPrice;
            addCom.label = ConstantsUtility.ROAD_TAX_CONST;
            
            addComponentList.add(addCom);
            
        }else if((record.priceBookEntry.product2.Name).equalsIgnoreCase(ConstantsUtility.MCP_CONST)){
            
            OpportunityLineItems_JSON_STRUCTURE.AddComponent addCom = new OpportunityLineItems_JSON_STRUCTURE.AddComponent();
            
            addCom.amount = 0;
            addCom.showCheckBox = false;
            addCom.validityValue = record.MCP_Validity__c;
            addCom.packageValue = record.MCP_Package__c;
            addCom.isDisabled = true;
            addCom.showLabel = false;
            addCOm.isMCP = true;
            addCom.isChecked = true;
            addCom.value = record.UnitPrice;
            addCom.label = ConstantsUtility.MCP_CONST;
            
            addComponentList.add(addCom);
        }else if((record.priceBookEntry.product2.Name).equalsIgnoreCase(ConstantsUtility.OTHER_CHARGES_CONST)){
            
            OpportunityLineItems_JSON_STRUCTURE.OtherCharge otherChange = new OpportunityLineItems_JSON_STRUCTURE.OtherCharge();
            
            otherChange.priceBookEntryId = record.priceBookEntryId;
            otherChange.UnitPrice = record.UnitPrice;
            otherChange.Quantity = record.Quantity;
            otherChange.opporrtunityId = record.opportunityId;
            
            /*------------------------------------------------------------------------------------
                STORE OTHER CHARGE INFO
            ------------------------------------------------------------------------------------*/
            jsonObject.otherCharge = otherChange;
            
        }else if((record.priceBookEntry.product2.Name).equalsIgnoreCase(ConstantsUtility.REGISTRATION_AMOUNT_CONST)){
            
            OpportunityLineItems_JSON_STRUCTURE.RegistrationAmountVariant registrationAmount = new OpportunityLineItems_JSON_STRUCTURE.RegistrationAmountVariant();
            
            registrationAmount.priceBookEntryId = record.priceBookEntryId;
            registrationAmount.UnitPrice = string.valueOf(record.UnitPrice);
            registrationAmount.Quantity = record.Quantity;
            registrationAmount.opporrtunityId = record.opportunityId;
            
            /*------------------------------------------------------------------------------------
                STORE OTHER CHARGE INFO
            ------------------------------------------------------------------------------------*/
            jsonObject.registrationAmountVariant = registrationAmount;
        }
        
    }
    
    
    /*------------------------------------------------------------------------------------
        STORE ADD ACCESSORIES INFO
    ------------------------------------------------------------------------------------*/
    Public Static void generateADDAccessoriesData(OpportunityLineItem record){
        
        if((record.priceBookEntry.product2.Name).equalsIgnoreCase(ConstantsUtility.ACCESSORIES_DISCOUNT_CONST)){
            
            OpportunityLineItems_JSON_STRUCTURE.otherAccessoriesDiscount otherAcc = new OpportunityLineItems_JSON_STRUCTURE.otherAccessoriesDiscount();
            
            otherAcc.priceBookEntryId = record.priceBookEntryId;
            otherAcc.UnitPrice = string.valueOf(math.abs(record.UnitPrice));
            otherAcc.Quantity = record.Quantity;
            otherAcc.opporrtunityId = record.opportunityId;
            
            /*------------------------------------------------------------------------------------
                STORE OTHER ACCESSORIES DISCOUNT INFO
            ------------------------------------------------------------------------------------*/
            jsonObject.otherAccessoriesDiscount = otherAcc;
            
            
        }else{
            
            OpportunityLineItems_JSON_STRUCTURE.AddAccessories addAcc = new OpportunityLineItems_JSON_STRUCTURE.AddAccessories();
            
            addAcc.priceBookEntryId = record.priceBookEntryId;
            addAcc.unitPrice = record.unitPrice;
            addAcc.price = record.TotalPrice;
            addAcc.Maximum_Quantity_toReplace = record.priceBookEntry.product2.Maximum_Quantity__c;
            addAcc.Minimum_Quantity_toReplace = record.priceBookEntry.product2.Minimum_Quantity__c;
            addAcc.quantity = string.valueOf(record.Quantity);
            addAcc.Name = record.priceBookEntry.product2.Name;
            addAcc.Id = record.priceBookEntry.product2Id;
            
            
            addAccessoriesList.add(addAcc);
            
        }
    }
    
    
    
    /*------------------------------------------------------------------------------------
        STORE ADD SCHEMES INFO
    ------------------------------------------------------------------------------------*/
    Public Static void generateAddSchemesData(OpportunityLineItem record){
        
        
        
        if((record.priceBookEntry.product2.Name).equalsIgnoreCase(ConstantsUtility.CORPORATE_DISCOUNT_CONST)){
            
            addSchemeData.corporateDiscountValue = true;
            addSchemeData.corporateDiscountData =  math.abs(record.unitPrice);
        }else if((record.priceBookEntry.product2.Name).equalsIgnoreCase(ConstantsUtility.EXCH_BONUS_CONST)){
            
            addSchemeData.exchangeBonusValue = true;
            addSchemeData.exchangeBonusData = math.abs(record.unitPrice);
        }else if((record.priceBookEntry.product2.Name).equalsIgnoreCase(ConstantsUtility.EXCH_VALUE_CONST)){
            
            addSchemeData.exchangeValue = true;
            addSchemeData.exchangeData = math.abs(record.unitPrice);
        }else if((record.priceBookEntry.product2.Name).equalsIgnoreCase(ConstantsUtility.OTHER_DISCOUNT_CONST)){
            
            addSchemeData.otherDiscountValue = true;
            addSchemeData.otherDiscountData = math.abs(record.unitPrice);
        }else if((record.priceBookEntry.product2.Name).equalsIgnoreCase(ConstantsUtility.RURAL_OFFER_CONST)){
            
            addSchemeData.ruralOffersValue = true;
            addSchemeData.ruralDiscountData = math.abs(record.unitPrice);
        }
        
        /*------------------------------------------------------------------------------------
            STORE OTHER ACCESSORIES DISCOUNT INFO
        ------------------------------------------------------------------------------------*/
        jsonObject.addSchemes = addSchemeData;
        
    }
        
    
}