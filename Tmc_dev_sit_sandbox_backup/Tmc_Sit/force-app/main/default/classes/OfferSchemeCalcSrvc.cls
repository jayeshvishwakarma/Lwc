/**
 * @File Name          : OfferSchemeCalcSrvc.cls
 * @Description        : This class is used in AddLineItemCtrlHelper class.
 * @Author             : Anuj Kumar
 * @Group              : 
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 1/14/2020, 11:34:48 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    02/09/2019 11:17 AM          Anuj Kumar            Initial Version
**/

public with sharing class OfferSchemeCalcSrvc {
    
    @AuraEnabled(cacheable=true)
    public static String retiveOfferAndSchemes(String dataList){
    
        String enquiryId = '';
        String prcBkEntryId = '';
        String parentSobjectType = '';
        Sobject parentSObj;
        
        String selectedVariantId = '';
        String forCode = '';
        
        Map<String, Object> mainDataMap = (Map<String, Object>)JSON.deserializeUntyped(dataList);
        Map<String, Object> exShowRoomVariantMap = (Map<String, Object>) mainDataMap.get(ConstantsUtility.EX_SHOWROOM_VARIANT_KEY);
        Map<String, Object> addSchemesMap = (Map<String, Object>) mainDataMap.get(ConstantsUtility.ADD_SCHEMES_KEY);
        
        Boolean isCommercial = addSchemesMap.containsKey('isCommercial') ? Boolean.valueOf(addSchemesMap.get('isCommercial')) : false;
        Map<String, Object> selectedVariantMap = (Map<String, Object>) mainDataMap.get(ConstantsUtility.SELECTED_VARIANT_KEY);
        
        if(selectedVariantMap != null && selectedVariantMap.size() > 0){
            selectedVariantId = selectedVariantMap.containsKey(ConstantsUtility.ID_CONST) ? String.valueOf(selectedVariantMap.get(ConstantsUtility.ID_CONST)) : null;
        }
        
        Map<String, Object> opportunityInfoMap = (Map<String, Object>) mainDataMap.get(ConstantsUtility.OPPORTUNITY_INFO_KEY);
        if(opportunityInfoMap != null && opportunityInfoMap.size() > 0){
            forCode = opportunityInfoMap.containsKey(ConstantsUtility.Dealer_FORCODE_CONST) ? String.valueOf(opportunityInfoMap.get(ConstantsUtility.Dealer_FORCODE_CONST)) : '';
        }
        
        
        // Get Offer Fields Configuration details
        Offer_Fields_Configuration__c ofc = Offer_Fields_Configuration__c.getInstance();
        
        //Ex-showroom Variant
        if(exShowRoomVariantMap != null && exShowRoomVariantMap.size() > 0){
            enquiryId = exShowRoomVariantMap.containsKey(ConstantsUtility.OPPORTUNITY_ID_KEY) ? string.valueOf(exShowRoomVariantMap.get(ConstantsUtility.OPPORTUNITY_ID_KEY)) : null;
            if(enquiryId.startsWith(ConstantsUtility.OPPORTUNITY_KEY_PREFIX)){
                parentSobjectType = ConstantsUtility.OPPORTUNITY;
                parentSObj = Schema.getGlobalDescribe().get(ConstantsUtility.OPPORTUNITY).newSObject();
            }else if(enquiryId.startsWith(ConstantsUtility.QUOTE_KEY_PREFIX)){
                parentSobjectType = ConstantsUtility.QUOTE;
                parentSObj = Schema.getGlobalDescribe().get(ConstantsUtility.QUOTE).newSObject();
            }
            prcBkEntryId = exShowRoomVariantMap.containsKey(ConstantsUtility.PRICEBOOKENTRY_ID_CONST) ? string.valueOf(exShowRoomVariantMap.get(ConstantsUtility.PRICEBOOKENTRY_ID_CONST)) : null;
        }
        
        //Exchange Bonus
        if((Boolean)addSchemesMap.get(ConstantsUtility.EXCHANGE_BONUS_KEY)){
            Decimal bonusAmt = 0.0;
            if(ofc.Query_Exchange_Bonus__c){
                if(isCommercial){
                    bonusAmt = retriveExchangeBonusDiscount(enquiryId, parentSobjectType, selectedVariantId, forCode);
                }else{
                    bonusAmt = retriveExchangeBonus(enquiryId, parentSobjectType);
                }
            }
            Object oBonusAmt = bonusAmt;
            addSchemesMap.put(ConstantsUtility.EXCHANGE_BONUS_DATA_KEY, oBonusAmt);
        }
        
        //Corporate Discount
        if((Boolean)addSchemesMap.get(ConstantsUtility.CORPORATE_DIS_VALUE_KEY)){
            String corporateScheme = '';
            if(ofc.Query_Corporate_Offers__c){
                corporateScheme = retriveCorporateScheme(enquiryId, prcBkEntryId, parentSobjectType);
            }else{
                corporateScheme = ConstantsUtility.CORP_SCHEME;
            }
            
            if(corporateScheme != ''){
                List<String> lsCorporateScheme = corporateScheme.split(';');
                Decimal iDiscount = Decimal.valueOf(lsCorporateScheme[1]);
                Object oDiscount = iDiscount != null ? iDiscount : 0.0;
                Object oScheme = lsCorporateScheme[0];
                addSchemesMap.put(ConstantsUtility.CORPORATE_DIS_DATA_KEY, oDiscount);
                addSchemesMap.put(ConstantsUtility.SCHEME_CODE_KEY, oScheme);
            }
            
        //Rural Discount
        }else if((Boolean)addSchemesMap.get(ConstantsUtility.RURAL_OFFER_VALUE_KEY)){
            String ruralScheme = '';
            if(ofc.Query_Rural_Offers__c){
                ruralScheme = retriveRuralScheme(enquiryId, prcBkEntryId, parentSobjectType);
            }else{
                ruralScheme = ConstantsUtility.CORP_SCHEME;
            }
            
            if(ruralScheme != ''){
                List<String> lsRuralScheme = ruralScheme.split(';');
                Decimal iDiscount = Decimal.valueOf(lsRuralScheme[1]);
                Object oDiscount = iDiscount;
                Object oScheme = lsRuralScheme[0];
                addSchemesMap.put(ConstantsUtility.RURAL_DIS_DATA_KEY, oDiscount);
                addSchemesMap.put(ConstantsUtility.SCHEME_CODE_KEY, oScheme);
            }
        }
        
        //Acquisition Discount
        if(addSchemesMap.containskey(ConstantsUtility.ACQUISITION_DIS_VALUE_KEY) && (Boolean)addSchemesMap.get(ConstantsUtility.ACQUISITION_DIS_VALUE_KEY)){
            Decimal acquisitionDiscount = 0.0;
            
            system.debug('== Acq selectedVariantId '+selectedVariantId);
            system.debug('== Acq forCode '+forCode);
            
            acquisitionDiscount = retriveAcquisitionDiscount(enquiryId, parentSobjectType, selectedVariantId, forCode);
            if(acquisitionDiscount != null){
                addSchemesMap.put(ConstantsUtility.ACQUISITION_DIS_DATA_KEY, acquisitionDiscount);
            }
            
        //Loyalty Discount
        }else if(addSchemesMap.containskey(ConstantsUtility.LOYALTY_DIS_VALUE_KEY) && (Boolean)addSchemesMap.get(ConstantsUtility.LOYALTY_DIS_VALUE_KEY)){
            Decimal loyaltyDiscount = 0.0;
            
            system.debug('== Loy selectedVariantId '+selectedVariantId);
            system.debug('== Loy forCode '+forCode);
            
            loyaltyDiscount = retriveLoyaltyDiscount(enquiryId, parentSobjectType, selectedVariantId, forCode);
            if(loyaltyDiscount != null){
                addSchemesMap.put(ConstantsUtility.LOYALTY_DIS_DATA_KEY, loyaltyDiscount);
            }
        }
        
        
        mainDataMap.put(ConstantsUtility.ADD_SCHEMES_KEY, addSchemesMap);
        
        return JSON.serialize(mainDataMap);
    }
    
    /*
        @Author:                  Rajesh Ramachandran
        @Created Date :           18/08/2019
        @Discription:             Derive Exchange Bonus amount
        @Date Of Modification :   
    */
    @AuraEnabled(cacheable=true)
    public static Decimal retriveExchangeBonus(String enquiryId, String parentSobjectType){
        Decimal bonusAmt = 0.0;
        if (enquiryId == null || enquiryId == ''){
            return bonusAmt;
        }
        String model = '';
        String fuelType = '';
        String forCode = '';
        String billingState = '';
        String regionCode = '';
        String dealerShip = '';
        Decimal age = 0;
        
        //For Opportunity
        if(parentSobjectType == ConstantsUtility.OPPORTUNITY && isOpportunityAccessPermission()){
            Opportunity exchDetailsOpp = new Opportunity();
            List<Opportunity> oppList = [select id, Exchange_Model__c, Exchange_Fuel_Type__c, Exchange_Vehicle_Age__c, Dealership__c, Dealership__r.For_Code__c, dealership__r.billingstate,Dealership__r.Region_Code__c from Opportunity where id = :enquiryId];
            if(!oppList.isEmpty()){
                exchDetailsOpp = oppList[0];
            }
            model = exchDetailsOpp.Exchange_Model__c;
            dealerShip = exchDetailsOpp.Dealership__c;
            fuelType = exchDetailsOpp.Exchange_Fuel_Type__c;
            forCode = exchDetailsOpp.Dealership__c != Null ? exchDetailsOpp.Dealership__r.For_Code__c : null;
            billingState = exchDetailsOpp.Dealership__c != Null ? exchDetailsOpp.dealership__r.billingstate : null;
            regionCode = exchDetailsOpp.Dealership__c != Null ? exchDetailsOpp.Dealership__r.Region_Code__c : null;
            age = exchDetailsOpp.Exchange_Vehicle_Age__c != null ? exchDetailsOpp.Exchange_Vehicle_Age__c : null;
        }
        //For Quote
        else if(parentSobjectType == ConstantsUtility.QUOTE && isOpportunityAccessPermission() && isQuoteAccessPermission()){
            Quote exchDetailsOpp = new quote();
            List<Quote> quoteList = [select id, Opportunity.Exchange_Model__c, Opportunity.Exchange_Fuel_Type__c, Opportunity.Exchange_Vehicle_Age__c, Opportunity.Dealership__c,Opportunity.Dealership__r.For_Code__c, Opportunity.dealership__r.billingstate, Opportunity.Dealership__r.Region_Code__c from Quote where id = :enquiryId ];
            
            if(!quoteList.isEmpty()){
                exchDetailsOpp = quoteList[0];
            }
            model = exchDetailsOpp.Opportunity.Exchange_Model__c;
            dealerShip = exchDetailsOpp.Opportunity.Dealership__c;
            fuelType = exchDetailsOpp.Opportunity.Exchange_Fuel_Type__c;
            forCode = exchDetailsOpp.Opportunity.Dealership__r.For_Code__c;
            billingState = exchDetailsOpp.Opportunity.dealership__r.billingstate;
            regionCode = exchDetailsOpp.Opportunity.Dealership__r.Region_Code__c;
            age = exchDetailsOpp.Opportunity.Exchange_Vehicle_Age__c != null ? exchDetailsOpp.Opportunity.Exchange_Vehicle_Age__c : 2000;
        }
        String slab = '';
        List<Exchange_Discount_Slabs__c> eds = [select id,name,From_Age__c, To_Age__c from Exchange_Discount_Slabs__c where From_Age__c <= :age and To_Age__c > :age];
        if (eds != null && eds.size() > 0){
            slab = eds[0].name;
        }

        //Model / Get schema master                  
        if(model != null && dealerShip != null && isSchemeMasterAccessPermission()){
            List<Scheme_Master__c> exchScheme = [select id,discount_amount__c from Scheme_Master__c 
                                        where recordtype.developername = 'Exchange_Bonus' and Active__c = true AND 
                                        status__c = 'A' and (model__c =: model or model__c = null) AND 
                                        (Fuel_Type__c =: fuelType or fuel_type__c = null) AND 
                                        (For_Code__c =: forCode or For_Code__c = null) AND 
                                        (state__c =: billingState or state__c = null) AND 
                                        (region_code__c =: regionCode or region_code__c = null) AND 
                                        (Slab__c =: slab or Slab__c = null) AND
                                        (From_Date__c <=: System.today() AND To_Date__c >=: System.today()) limit 1];
                                        
            if(exchScheme != null && exchScheme.size() > 0){
                Scheme_Master__c excSch = exchScheme[0];
                bonusAmt = excSch.discount_amount__c;
            }
        }
        return bonusAmt;
    }

   /*
        @Author:                  Rajesh Ramachandran
        @Created Date :           18/08/2019
        @Discription:             Derive Corporate Scheme details
        @Date Of Modification :   
    */
    @AuraEnabled(cacheable=true)
    public static String retriveCorporateScheme(String enquiryId, String prcBkEntryId, String parentSobjectType){
        String corporateScheme = '';
        if (enquiryId == null || enquiryId == '' || prcBkEntryId == null){
            return corporateScheme;
        }
        PricebookEntry pbe;
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        if(isProductAccessPermission()){
            pricebookEntryList = [select id,Product2.family,Product2.model__c,product2.fuel_type__c from PricebookEntry where id = :prcBkEntryId limit 1];
        }
        
        //If PBE is not blank
        if(!pricebookEntryList.isEmpty()){
            pbe = pricebookEntryList[0];
        }
        //If PBE is null
        if(pbe == null){
            return corporateScheme;
        }
        
        String empName = '';
        String forCode = '';
        String billingState = '';
        String regionCode = '';
        String dealerShip = '';
        
        //For Opportunity
        if(parentSobjectType == ConstantsUtility.OPPORTUNITY && isOpportunityAccessPermission()){
            
            Opportunity corpDetailsOpp = new Opportunity();
            List<Opportunity> oppList = [select id, Employer_Name__c, Dealership__c, Dealership__r.For_Code__c, dealership__r.billingstate, Dealership__r.Region_Code__c from Opportunity where id =: enquiryId limit 1];
            if(!oppList.isEmpty()){
                corpDetailsOpp = oppList[0];
            }
            
            empName = corpDetailsOpp.Employer_Name__c;
            dealerShip = corpDetailsOpp.Dealership__c;
            forCode = corpDetailsOpp.Dealership__c != Null ? corpDetailsOpp.Dealership__r.For_Code__c : null;
            billingState = corpDetailsOpp.Dealership__c != Null ? corpDetailsOpp.dealership__r.billingstate : null;
            regionCode = corpDetailsOpp.Dealership__c != Null ? corpDetailsOpp.Dealership__r.Region_Code__c : null;
            
        }
        //For Quote
        else if(parentSobjectType == ConstantsUtility.QUOTE && isOpportunityAccessPermission() && isQuoteAccessPermission()){
            Quote corpDetailsOpp = new Quote();
            
            List<Quote> quoteList = [select id, Opportunity.Employer_Name__c, Opportunity.Dealership__c, Opportunity.Dealership__r.For_Code__c, Opportunity.dealership__r.billingstate, Opportunity.Dealership__r.Region_Code__c from Quote where id =: enquiryId limit 1];
            if(!quoteList.isEmpty()){
                corpDetailsOpp = quoteList[0];
            }
            empName = corpDetailsOpp.Opportunity.Employer_Name__c;
            dealerShip = corpDetailsOpp.Opportunity.Dealership__c;
            forCode = corpDetailsOpp.Opportunity.Dealership__c != Null ? corpDetailsOpp.Opportunity.Dealership__r.For_Code__c : null;
            billingState = corpDetailsOpp.Opportunity.Dealership__c != Null ? corpDetailsOpp.Opportunity.dealership__r.billingstate : null;
            regionCode = corpDetailsOpp.Opportunity.Dealership__c != Null ? corpDetailsOpp.Opportunity.Dealership__r.Region_Code__c : null;
        }
                            
        List<Corporate_Group_Line_Items__c> corpGrpItems = new List<Corporate_Group_Line_Items__c>();
        if(empName != null && isCorporateGroupAccessPermission()){
            corpGrpItems = [select id, Corporate_Group__c from Corporate_Group_Line_Items__c where Corporate__c =: empName];
        }
        List<Id> corpGrpIds = new List<Id>();
        for (Corporate_Group_Line_Items__c cgi : corpGrpItems){
            corpGrpIds.add(cgi.Corporate_Group__c);
        }
        //dummy logic to prevent this object from being for the soql query not to fail
        if (corpGrpIds == null){
            corpGrpIds.add(enquiryId);
        }
        if(empName != null && dealerShip != null && isSchemeMasterAccessPermission()){
            
            List<Scheme_Master__c> exchScheme = [select id, discount_amount__c, name from Scheme_Master__c 
                                    where recordtype.developername = 'Scheme' AND status__c = 'A' AND 
                                    (model__c =: pbe.Product2.Model__c or model__c = null) AND 
                                    (Fuel_Type__c =: pbe.Product2.Fuel_Type__c or fuel_type__c = null) AND 
                                    (For_Code__c =: forCode or For_Code__c = null) AND 
                                    (state__c =: billingState or state__c = null) AND 
                                    (region_code__c =: regionCode or region_code__c = null) AND 
                                    (From_Date__c <=: System.today() AND To_Date__c >=: System.today()) AND 
                                    (Corporate__c =: empName or Corporate_Group__c in :corpGrpIds) AND 
                                    scheme_cost_center__c in ('ISLP','COMC') limit 1];
                                    
            if(exchScheme != null && exchScheme.size() > 0){
                Scheme_Master__c corpSch = exchScheme[0];
                corporateScheme = corpSch.name + ';' + String.valueOf(corpSch.Discount_Amount__c);
            }
        }
        return corporateScheme;
    }

   /*
        @Author:                  Rajesh Ramachandran
        @Created Date :           18/08/2019
        @Discription:             Derive Rural Scheme details
        @Date Of Modification :   
    */
    @AuraEnabled(cacheable=true)
    public static String retriveRuralScheme(String enquiryId, String prcBkEntryId, String parentSobjectType){
        String ruralScheme = '';
        if (enquiryId == null || enquiryId == '' || prcBkEntryId == null){
            return ruralScheme;
        }
        List<PricebookEntry> pbe = new List<PricebookEntry>(
            [select id, Product2.family, Product2.model__c, product2.fuel_type__c from PricebookEntry where id = :prcBkEntryId limit 1]
        );
        if (pbe == null)
            return ruralScheme;
        
        String empName = '';
        String forCode = '';
        String billingState = '';
        String regionCode = '';
        
        String dealerShip = '';
        
        //For Opportunity
        if(parentSobjectType == ConstantsUtility.OPPORTUNITY && isOpportunityAccessPermission()){
            Opportunity ruralDetailsOpp = new Opportunity();
            
            List<Opportunity> oppList = [select id, Dealership__c, Dealership__r.For_Code__c, dealership__r.billingstate, Dealership__r.Region_Code__c from Opportunity where id = :enquiryId limit 1];
            if(!oppList.isEmpty()){
                ruralDetailsOpp = oppList[0];
            }
            
            dealerShip = ruralDetailsOpp.Dealership__c;
            forCode = ruralDetailsOpp.Dealership__c != Null ? ruralDetailsOpp.Dealership__r.For_Code__c : null;
            billingState = ruralDetailsOpp.Dealership__c != Null ? ruralDetailsOpp.dealership__r.billingstate : null;
            regionCode = ruralDetailsOpp.Dealership__c != Null ? ruralDetailsOpp.Dealership__r.Region_Code__c : null;
            
        }
        //For Quote
        else if(parentSobjectType == ConstantsUtility.QUOTE && isOpportunityAccessPermission() && isQuoteAccessPermission()){
            Quote ruralDetailsOpp = new Quote();
            List<Quote> quoteList = [select id, Opportunity.Dealership__c, Opportunity.Dealership__r.For_Code__c, Opportunity.dealership__r.billingstate, Opportunity.Dealership__r.Region_Code__c from Quote where id =: enquiryId limit 1];
            if(!quoteList.isEmpty()){
                ruralDetailsOpp = quoteList[0];
            }
            
            dealerShip = ruralDetailsOpp.Opportunity.Dealership__c;
            forCode = ruralDetailsOpp.Opportunity.Dealership__c != Null ? ruralDetailsOpp.Opportunity.Dealership__r.For_Code__c : null;
            billingState = ruralDetailsOpp.Opportunity.Dealership__c != Null ? ruralDetailsOpp.Opportunity.dealership__r.billingstate : null;
            regionCode = ruralDetailsOpp.Opportunity.Dealership__c != Null ? ruralDetailsOpp.Opportunity.Dealership__r.Region_Code__c : null;
        }
        if( dealerShip != null && pbe != null && pbe.size() > 0 && isSchemeMasterAccessPermission()){
        List<Scheme_Master__c> exchScheme = [select id, discount_amount__c,name from Scheme_Master__c 
                                where recordtype.developername = 'Scheme' AND Active__c = true and status__c = 'A' AND 
                                (model__c =: pbe[0].Product2.model__c or model__c = null) AND 
                                (Fuel_Type__c =: pbe[0].Product2.Fuel_Type__c or fuel_type__c = null) AND 
                                (For_Code__c =: forCode or For_Code__c = null) AND 
                                (state__c =: billingState or state__c = null) AND 
                                (region_code__c =: regionCode or region_code__c = null) AND 
                                (From_Date__c <=: System.today() AND To_Date__c >=: System.today()) AND 
                                scheme_cost_center__c in ('RMKP')  limit 1];
            
            if (exchScheme != null && exchScheme.size() > 0){
                Scheme_Master__c reSch = exchScheme[0];
                ruralScheme = reSch.name + ConstantsUtility.SEMI_COLON + String.valueOf(reSch.Discount_Amount__c);
            }
        }
        return ruralScheme;
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           06/05/2020
        @Discription:             Check Acquisition Discount
        @Date Of Modification :   
    */
    @AuraEnabled(cacheable=true)
    public static Decimal retriveAcquisitionDiscount(String enquiryId, String parentSobjectType, String selectedVariantId, string forCode){
        Decimal discountAmount = 0.0;
        List<Scheme_Master__c> schemeList = [select id, discount_amount__c from Scheme_Master__c 
                                        where recordtype.developername = 'Exchange_Bonus' and Active__c = true AND 
                                        Product__c =: selectedVariantId AND 
                                        For_Code__c =: forCode AND
                                        Bonus_Type__c = 'L' AND
                                        BONUS_LOY_ACQ_FLAG__c = 'A' AND
                                        (From_Date__c <=: System.today() AND To_Date__c >=: System.today()) limit 1];
        
        if(schemeList != Null && schemeList.size() > 0){
            discountAmount = schemeList[0].discount_amount__c;
        }
        
        return discountAmount;
    }
    
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           06/05/2020
        @Discription:             Check Loyalty Discount
        @Date Of Modification :   
    */
    @AuraEnabled(cacheable=true)
    public static Decimal retriveLoyaltyDiscount(String enquiryId, String parentSobjectType, String selectedVariantId, string forCode){
        Decimal discountAmount = 0.0;
        List<Scheme_Master__c> schemeList = [select id, discount_amount__c from Scheme_Master__c 
                                        where recordtype.developername = 'Exchange_Bonus' and Active__c = true AND 
                                        (Product__c =: selectedVariantId OR Product__c = null) AND
                                        Bonus_Type__c = 'L' AND
                                        BONUS_LOY_ACQ_FLAG__c = 'L' AND
                                        (From_Date__c <=: System.today() AND To_Date__c >=: System.today()) limit 1];
        
        if(schemeList != Null && schemeList.size() > 0){
            discountAmount = schemeList[0].discount_amount__c;
        }
        
        return discountAmount;
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           06/05/2020
        @Discription:             Check Exchange Bonus
        @Date Of Modification :   
    */
    @AuraEnabled(cacheable=true)
    public static Decimal retriveExchangeBonusDiscount(String enquiryId, String parentSobjectType, String selectedVariantId, string forCode){
        
        Decimal discountAmount = 0.0;
        List<Scheme_Master__c> schemeList = [select id, discount_amount__c from Scheme_Master__c 
                                        where recordtype.developername = 'Exchange_Bonus' AND 
                                        (Product__c =: selectedVariantId OR Product__c = null ) AND 
                                        Bonus_Type__c = 'E' AND
                                        (From_Date__c <=: System.today() AND To_Date__c >=: System.today()) limit 1];
        
        if(schemeList != Null && schemeList.size() > 0){
            discountAmount = schemeList[0].discount_amount__c;
        }
        
        return discountAmount;
    }
    
    
    /*******       TO Handle The Object And Field Permissions    ********/
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           30/07/2019
        @Discription:             To Check the create permissions for Opportunity.
        @Date Of Modification :   30/07/2019
    */
    public static Boolean isOpportunityAccessPermission(){
        if(CheckObjectAndField.objectCURDPermission(ConstantsUtility.OPPORTUNITY, ConstantsUtility.IsAccessible) &&
           CheckObjectAndField.objectCURDPermission(ConstantsUtility.ACCOUNT_OBJ, ConstantsUtility.IsAccessible) && 
           CheckObjectAndField.fieldCURDPermission(ConstantsUtility.OPPORTUNITY, ConstantsUtility.IsAccessible, ConstantsUtility.DEALER_FIELD) && 
           CheckObjectAndField.fieldCURDPermission(ConstantsUtility.OPPORTUNITY, ConstantsUtility.IsAccessible, ConstantsUtility.EXCH_MODEL) && 
           CheckObjectAndField.fieldCURDPermission(ConstantsUtility.OPPORTUNITY, ConstantsUtility.IsAccessible, ConstantsUtility.EXCH_FUEL_TYPE) && 
           CheckObjectAndField.fieldCURDPermission(ConstantsUtility.ACCOUNT_OBJ, ConstantsUtility.IsAccessible, ConstantsUtility.FOR_CODE) && 
           CheckObjectAndField.fieldCURDPermission(ConstantsUtility.ACCOUNT_OBJ, ConstantsUtility.IsAccessible, ConstantsUtility.REGION_CODE)){
            return True;
        }else{
            return false;
        }
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           30/07/2019
        @Discription:             To Check the create permissions for Quote.
        @Date Of Modification :   30/07/2019
    */
    public static Boolean isQuoteAccessPermission(){
        if(CheckObjectAndField.objectCURDPermission(ConstantsUtility.QUOTE, ConstantsUtility.IsAccessible)){
            return True;
        }else{
            return false;
        }
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           30/07/2019
        @Discription:             To Check the create permissions for Scheme Master.
        @Date Of Modification :   30/07/2019
    */
    public static Boolean isSchemeMasterAccessPermission(){
        if(CheckObjectAndField.objectCURDPermission(ConstantsUtility.SCHEME_MASTER, ConstantsUtility.IsAccessible) &&
           CheckObjectAndField.fieldCURDPermission(ConstantsUtility.SCHEME_MASTER, ConstantsUtility.IsAccessible, ConstantsUtility.DISCOUNT_AMT_FIELD)){
            return True;
        }else{
            return false;
        }
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           30/07/2019
        @Discription:             To Check the create permissions for Product.
        @Date Of Modification :   30/07/2019
    */
    public static Boolean isProductAccessPermission(){
        if(CheckObjectAndField.objectCURDPermission(ConstantsUtility.PRODUCT_OBJ, ConstantsUtility.IsAccessible) &&
           CheckObjectAndField.fieldCURDPermission(ConstantsUtility.PRODUCT_OBJ, ConstantsUtility.IsAccessible, ConstantsUtility.FUEL_TYPE_FIELD) && 
           CheckObjectAndField.fieldCURDPermission(ConstantsUtility.PRODUCT_OBJ, ConstantsUtility.IsAccessible, ConstantsUtility.FAMILY)){
            return True;
        }else{
            return false;
        }
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           30/07/2019
        @Discription:             To Check the create permissions for Corporate group.
        @Date Of Modification :   30/07/2019
    */
    public static Boolean isCorporateGroupAccessPermission(){
        if(CheckObjectAndField.objectCURDPermission(ConstantsUtility.CORP_GRP_LINE_ITEM_FIELD, ConstantsUtility.IsAccessible) &&
           CheckObjectAndField.fieldCURDPermission(ConstantsUtility.CORP_GRP_LINE_ITEM_FIELD, ConstantsUtility.IsAccessible, 'Corporate_Group__c')){
            return True;
        }else{
            return false;
        }
    }
    
}