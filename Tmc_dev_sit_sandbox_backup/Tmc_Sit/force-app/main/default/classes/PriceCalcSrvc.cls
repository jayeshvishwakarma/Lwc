/**
* @File Name : PriceCalcSrvc.cls
* @Description : This class is used in AddLineItemCtrlHelper class.
* @Author : Anuj Kumar
* @Group :
* @Last Modified By : Anuj Kumar
* @Last Modified On : 02/09/2019 10:15 AM
* @Modification Log :
*==============================================================================
* Ver Date Author Modification
*==============================================================================
* 1.0 02/09/2019 11:17 AM Anuj Kumar Initial Version
**/

public with sharing class PriceCalcSrvc {

    Public Static String parentSobjectType = '';
    Public Static String childSobjectType = '';

    Public Static sObject parentSObj;

    Public Static String cashPayment = '';
    Public Static String financeAmount = '';
    //#DE622 Start
    public Static String firstName = '';
    public Static String lastName = '';
    public Static String middleName = '';
    public Static String phoneNumber = '';
    //#DE622 End

    Public Static String parentField = '';
    Public Static String parentRecordId = '';

    Public Static String enquiryRecordType = '';

    // To check if we need to create MC communication record or not.
    Public Static Boolean generateMCRecord = false;

    Public Static Map < String, String > existingPriceBookEntryIdMap = new Map < String, String > ();
    Public Static Map < string, SObject > productIdWithLineItemMap = new Map < String, SObject > ();

    Public Static Map < String, String > allProductNameWithIdMap = new Map < String, String > ();
    Public Static Map < string, String > allproductIdWithPriceBookEntryIdMap = new Map < String, String > ();

    @AuraEnabled
    public static SObject createChildSObjectInstance(String SObjectName) {
        return Schema.getGlobalDescribe().get(SObjectName).newSObject();
    }

    public static Boolean createDefaultProductRecords() {

        Set < String > componentProductNameSet = new Set < String >{
            'Extended Warranty',
                'Loyalty',
                'Insurance',
                'MGA',
                'Municipal Charges',
                'Number Plate Charges',
                'Road Tax',
                'MCP',
                'Other Charges',
                'FASTag charges',
                'Registration Amount'
                };
                    allProductNameWithIdMap = getAllProductIdFromName(componentProductNameSet, 'Component', allProductNameWithIdMap);

        Set < String > accProductNameSet = new Set < String >{
            'Accessory Discount'
                };
                    allProductNameWithIdMap = getAllProductIdFromName(accProductNameSet, 'Accessories', allProductNameWithIdMap);

        Set<String> offerProductNameSet = new Set<String> {'Corporate Discount', 'Exchange Bonus', 'Exchange Value', 'Loyalty Bonus',
                                                      'Other Discount', 'Rural Offers', 'Acquisition Discount', 'Loyalty Discount', 'Bulk Discount', 'Special Discount', 'Offer'};
        allProductNameWithIdMap = getAllProductIdFromName(offerProductNameSet, 'Offer', allProductNameWithIdMap);

        if(allProductNameWithIdMap.size() > 0){
            Set<String> componentNotExistProductNameSet = new Set<String>();
            Set<String> accNotExistProductNameSet = new Set<String>();
            Set<String> offerNotExistProductNameSet = new Set<String>();

            for(String productName : componentProductNameSet){
                if(!allProductNameWithIdMap.containsKey(productName.toLowerCase())){
                    componentNotexistProductNameSet.add(productName);
                }
            }

            for (String productName : accProductNameSet) {
                if (!allProductNameWithIdMap.containsKey(productName.toLowerCase())) {
                    accNotExistProductNameSet.add(productName);
                }
            }

            for (String productName : offerProductNameSet) {
                if (!allProductNameWithIdMap.containsKey(productName.toLowerCase())) {
                    offerNotExistProductNameSet.add(productName);
                }
            }

            if (componentNotExistProductNameSet.size() > 0) {
                allProductNameWithIdMap = createProductIdFromName(componentNotExistProductNameSet, 'Component', allProductNameWithIdMap);
            }

            if (accNotExistProductNameSet.size() > 0) {
                allProductNameWithIdMap = createProductIdFromName(accNotExistProductNameSet, 'Accessories', allProductNameWithIdMap);
            }

            if (offerNotExistProductNameSet.size() > 0) {
                allProductNameWithIdMap = createProductIdFromName(offerNotExistProductNameSet, 'Offer', allProductNameWithIdMap);
            }

            Set < String > productNotExistPriceEntrySet = new Set < String > ();

            Set < String > productIdSet = new Set < String > (allProductNameWithIdMap.values());
            allproductIdWithPriceBookEntryIdMap = getPriceBookEntryIds(productIdSet);

            for (string proId : productIdSet) {
                if (!allproductIdWithPriceBookEntryIdMap.containsKey(proId)) {
                    productNotExistPriceEntrySet.add(proId);
                }
            }

            if (productNotExistPriceEntrySet.size() > 0) {
                allproductIdWithPriceBookEntryIdMap = createPriceBookEntryIds(productIdSet, allproductIdWithPriceBookEntryIdMap);
            }

            system.debug('== allProductNameWithIdMap ' + json.serialize(allProductNameWithIdMap));
            system.debug('== allproductIdWithPriceBookEntryIdMap ' + json.serialize(allproductIdWithPriceBookEntryIdMap));

            return true;
        }
        return false;
    }

    @AuraEnabled
    public static string calculateLineItemInfo(String dataList, string parentSobjectId) {
        string result = '';
        Boolean productDataAvailable = createDefaultProductRecords();
        if (productDataAvailable) {
            result = generateLineItemInfo(dataList, parentSobjectId);
        }
        return result;
    }

    public static string generateLineItemInfo(String dataList, string parentSobjectId) {
        system.debug('== dataList ' + dataList);
        system.debug('== parentSobjectId '+parentSobjectId);

        String errorData = '';
        // ALL DATA MAP
        Map < String, Object > mainDataMap = (Map < String, Object >) JSON.deserializeUntyped(dataList);
        Map < String, Object > exShowRoomVariantMap = (Map < String, Object >) mainDataMap.get('exShowRoomVariant');

        if (parentSobjectId != null && parentSobjectId != '' && parentSobjectId.startsWith('006')) {
            parentField = 'opportunityId';
            parentSobjectType = 'Opportunity';
            childSobjectType = 'OpportunityLineItem';

            parentSObj = Schema.getGlobalDescribe().get('Opportunity').newSObject();
        } else if (parentSobjectId != null && parentSobjectId != '' && parentSobjectId.startsWith('0Q0')) {

            parentRecordId = parentSobjectId;
            parentField = 'quoteId';
            parentSobjectType = 'Quote';
            childSobjectType = 'QuoteLineItem';

            parentSObj = Schema.getGlobalDescribe().get('Quote').newSObject();
        } else {
            if (exShowRoomVariantMap != Null && exShowRoomVariantMap.size() > 0) {
                parentRecordId = exShowRoomVariantMap.containsKey('opporrtunityId') ? string.valueOf(exShowRoomVariantMap.get('opporrtunityId')) : null;
                if (parentRecordId != null && parentRecordId.startsWith('006')) {
                    parentField = 'opportunityId';
                    parentSobjectType = 'Opportunity';
                    childSobjectType = 'OpportunityLineItem';

                    parentSObj = Schema.getGlobalDescribe().get('Opportunity').newSObject();

                } else if (parentRecordId != null && parentRecordId.startsWith('0Q0')) {
                    parentField = 'quoteId';
                    parentSobjectType = 'Quote';
                    childSobjectType = 'QuoteLineItem';

                    parentSObj = Schema.getGlobalDescribe().get('Quote').newSObject();
                }

                String parentQuery = 'SELECT Id, PriceBookEntryId FROM ' + childSobjectType;
                parentQuery += ' WHERE ' + parentField + ' =: parentRecordId';
                List < sObject > existingLineItemsList = (List < sObject >) Database.query(parentQuery);

                if (existingLineItemsList != Null && existingLineItemsList.size() > 0) {
                    for (sObject obj : existingLineItemsList) {
                        existingPriceBookEntryIdMap.put(string.valueOf(obj.get('PriceBookEntryId')), string.valueOf(obj.get('Id')));
                    }
                }
            }
        }
        enquiryRecordType = mainDataMap.containsKey('enquiryRecordType') ? string.valueOf(mainDataMap.get('enquiryRecordType')) : null;

        if (enquiryRecordType == 'Accessories Sales') {
            generateMCRecord = true;
            // AddAccessories LineItem
            accessoriesLineItem(mainDataMap);

            // To Add Accessories Discount Amount
            otherAccessoryDiscountLineItem(mainDataMap);
        } else {

            // ExShowRoom LineItem
            exShowRoomLineItem(mainDataMap);

            // AddAccessories LineItem
            accessoriesLineItem(mainDataMap);

            // To Add Accessories Discount Amount
            otherAccessoryDiscountLineItem(mainDataMap);

            // Registration LineItem
            registrationLineItem(mainDataMap);

            // Component LineItem
            componentLineItem(mainDataMap);

            // OtherCharge LineItem
            otherChargeLineItem(mainDataMap);

            // SchemesAndOffer LineItem
            schemesAndOfferLineItem(mainDataMap);

            // For Consumer Offer LineItem
            consumerOfferLineItem(mainDataMap);

            // For Loyalty Bonus Deduction duing qoute generation
            if (parentSobjectType == 'Quote') {
                LoyaltyBonusLineItem(mainDataMap);
            }

        }

        if (productIdWithLineItemMap != null && productIdWithLineItemMap.size() > 0 && productIdWithLineItemMap.values().size() > 0) {

            List < sObject > oliInsertList = new List < sObject > ();
            List < sObject > oliUpdateList = new List < sObject > ();

            Boolean variant = false;
            Boolean mga = false;

            for (sObject obj : productIdWithLineItemMap.values()) {
                String priceBookEntryId = '';
                if (obj.get('priceBookEntryId') != null && obj.get('priceBookEntryId') != '')
                    priceBookEntryId = String.valueOf(obj.get('priceBookEntryId'));

                if (priceBookEntryId != null && priceBookEntryId != '' && existingPriceBookEntryIdMap.containsKey(priceBookEntryId)) {
                    obj.put('id', existingPriceBookEntryIdMap.get(priceBookEntryId));
                }
                if (obj.get('UnitPrice') != null && obj.get('UnitPrice') != '') {
                    if (obj.get('id') != Null) {
                        oliUpdateList.add(obj);
                    } else {
                        oliInsertList.add(obj);

                        string type = (obj.get('Type__c') != null && obj.get('Type__c') != '') ? string.valueOf(obj.get('Type__c')) : Null;

                        if (type != Null && type == 'Variants') {
                            variant = True;
                        }
                        if (type != Null && type == 'MGA') {
                            mga = True;
                        }
                    }
                }
            }

            // Variable used to create the MC Communication Record
            generateMCRecord = (!variant && mga) ? True : False;


            Map < String, String > afterDMLPBEWithLineItemIdMap = new Map < String, String > ();
            Set < String > newLineItemIdSet = new Set < String > ();
            if (oliInsertList != Null && oliInsertList.size() > 0) {
                try {
                    Database.SaveResult[] oliSR = Database.Insert(oliInsertList, false);
                    for (integer i = 0; i < oliInsertList.size(); i++) {
                        if (oliSR.get(i).isSuccess()) {
                            newLineItemIdSet.add(oliSR.get(i).getId());
                            afterDMLPBEWithLineItemIdMap.put(string.valueOf(oliInsertList.get(i).get('priceBookEntryId')), oliSR.get(i).getId());
                        } else {
                            for (Database.Error err : oliSR.get(i).getErrors()) {
                                errorData += err.getMessage();
                            }
                        }
                    }
                } catch (Exception ex) {
                    errorData += ex.getMessage();
                }
            }

            if (oliUpdateList != Null && oliUpdateList.size() > 0) {
                try {
                    Database.SaveResult[] oliUR = Database.Update(oliUpdateList, false);
                    for (integer i = 0; i < oliUpdateList.size(); i++) {
                        if (oliUR.get(i).isSuccess()) {
                            newLineItemIdSet.add(oliUR.get(i).getId());
                            afterDMLPBEWithLineItemIdMap.put(string.valueOf(oliUpdateList.get(i).get('priceBookEntryId')), oliUR.get(i).getId());
                        } else {
                            for (Database.Error err : oliUR.get(i).getErrors()) {
                                errorData += err.getMessage();
                            }
                        }
                    }

                } catch (Exception ex) {
                    errorData += ex.getMessage();
                }
                system.debug('== First errorData ' + errorData);
            }
            string lineItemSummary = JSON.serialize(mainDataMap);

            if (parentRecordId != Null && parentRecordId != '') {
                String oldVariantId = '';
                Integer oldVariantChangeCount;
                Map < String, Object > opportunityInfoDataMap;
                opportunityInfoDataMap = (Map < String, Object >) mainDataMap.get('opportunityInfo');
                if (parentSobjectType == 'Opportunity' && enquiryRecordType == 'Vehicle Sales') {
                    //#DE622 Start
                    parentSObj.put('First_Name__c', firstName != null ? String.valueOf(firstName) : null);
                    parentSObj.put('Last_Name__c', lastName != null ? String.valueOf(lastName) : null);
                    parentSObj.put('Middle_Name__c', middleName != null ? String.valueOf(middleName) : null);
                    parentSObj.put('Mobile__c', phoneNumber != null ? String.valueOf(phoneNumber) : null);

                    String optyName = '';
                    if (firstName != null)
                        optyName = firstName + ConstantsUtility.BLANK_SPACE;
                    if (middleName != null)
                        optyName += middleName + ConstantsUtility.BLANK_SPACE;
                    if (lastName != null)
                        optyName += lastName + ConstantsUtility.BLANK_SPACE;

                    if (string.isNotEmpty(optyName) && enquiryRecordType == 'Vehicle Sales') {
                        optyName += ConstantsUtility.OPEN_BRACKET + ConstantsUtility.NEWCAR_ENQ + ConstantsUtility.CLOSE_BRACKET;
                    } else {
                        optyName += ConstantsUtility.OPEN_BRACKET + ConstantsUtility.ACCESSORIES_ENQ + ConstantsUtility.CLOSE_BRACKET;
                    }
                    if (optyName != '') {
                        parentSObj.put('Name', optyName);
                    }
                    //#DE622 End
                }

                parentSObj.put('Id', parentRecordId);

                if (enquiryRecordType != 'Accessories Sales') {
                    parentSObj.put('Cash_Payment__c', cashPayment != null ? decimal.valueOf(cashPayment) : null);
                    parentSObj.put('Finance_Amount__c', financeAmount != null ? decimal.valueOf(financeAmount) : null);
                }

                if (parentSobjectType == 'Opportunity' && opportunityInfoDataMap != Null && opportunityInfoDataMap.size() > 0) {
                        Boolean mgaSelected = opportunityInfoDataMap.containsKey('MGASelected') ? Boolean.valueOf(opportunityInfoDataMap.get('MGASelected')) : false;

                        if (enquiryRecordType == 'Accessories Sales' && mgaSelected) {
                            parentSObj.put('StageName', 'MGA Selected');
                        }
                    }

                if (opportunityInfoDataMap != Null && opportunityInfoDataMap.size() > 0) {
                    if (parentSobjectType == 'Opportunity') {
                        parentSObj.put('Model_Code__c', opportunityInfoDataMap.containsKey('Model_Code__c') ? String.valueOf(opportunityInfoDataMap.get('Model_Code__c')) : null);
                    }
                    oldVariantId = opportunityInfoDataMap.containsKey('Old_Variant__c') ? String.valueOf(opportunityInfoDataMap.get('Old_Variant__c')) : '';
                    oldVariantChangeCount = opportunityInfoDataMap.containsKey('Variant_Modified_Count__c') ? Integer.valueOf(opportunityInfoDataMap.get('Variant_Modified_Count__c')) : 0;
                }

                if (lineItemSummary != Null && lineItemSummary != '') {
                    parentSObj.put('Line_Item_Summary__c', lineItemSummary);
                }

                Map < String, Object > colorAndVariantObjMap = (Map < String, Object >) mainDataMap.get('selectedColorVariant');
                string variantId = '';
                if (colorAndVariantObjMap != null && colorAndVariantObjMap.size() > 0) {
                    variantId = string.valueOf(colorAndVariantObjMap.get('Variant__c')) != null ? string.valueOf(colorAndVariantObjMap.get('Variant__c')) : null;
                    string colorVariantId = string.valueOf(colorAndVariantObjMap.get('Id')) != null ? string.valueOf(colorAndVariantObjMap.get('Id')) : null;
                    if (variantId != null && variantId != '') {
                        parentSObj.put('Variant__c', variantId);
                        parentSObj.put('Color__c', colorVariantId);
                    }
                }


                if (parentSobjectType == 'Opportunity' && variantId != null && variantId != '' && oldVariantChangeCount == 0) {
                    parentSObj.put('Variant_Modified_Count__c', 1);
                } else if (parentSobjectType == 'Opportunity' && variantId != null && variantId != '' && oldVariantId != '' && variantId != oldVariantId) {
                    parentSObj.put('Variant_Modified_Count__c', 2);
                } else if (parentSobjectType == 'Opportunity' && variantId != null && variantId != '' && oldVariantId == '' && oldVariantChangeCount == 1) {
                    parentSObj.put('Variant_Modified_Count__c', 2);
                }

                //Added  By Deepak
                if (parentSobjectType == 'Opportunity') {
                    // Loyalty Enrollment
                    if (opportunityInfoDataMap != null && opportunityInfoDataMap.containsKey('Interested_In_Loyalty') && opportunityInfoDataMap.get('Interested_In_Loyalty') != null) {
                        parentSObj.put('Interested_In_Loyalty__c', opportunityInfoDataMap.get('Interested_In_Loyalty'));
                        parentSObj.put('Reason_not_Interested_in_Loyalty__c', null);
                    }
                    if (opportunityInfoDataMap != null && opportunityInfoDataMap.containsKey('Reason_not_Interested_in_Loyalty') && opportunityInfoDataMap.get('Reason_not_Interested_in_Loyalty') != null) {
                        parentSObj.put('Reason_not_Interested_in_Loyalty__c', opportunityInfoDataMap.get('Reason_not_Interested_in_Loyalty'));
                    }
                    if (opportunityInfoDataMap != null && opportunityInfoDataMap.containsKey('Points_To_Be_Redeemed__c') && opportunityInfoDataMap.get('Points_To_Be_Redeemed__c') != null) {
                        String points = string.valueOf(opportunityInfoDataMap.get('Points_To_Be_Redeemed__c'));
                        Decimal reedemPoint = Decimal.valueof(points);
                        if (reedemPoint > 0) {
                            parentSObj.put('Points_To_Be_Redeemed__c', reedemPoint);
                        }
                    }
                }

                Set < String > existingLineItemIdSet = new Set < String > (existingPriceBookEntryIdMap.values());
                List < String > deleteLineItemIdList = new List < String > ();

                if (existingLineItemIdSet != Null && existingLineItemIdSet.size() > 0) {
                    for (string str : existingLineItemIdSet) {
                        if (!newLineItemIdSet.contains(str)) {
                            deleteLineItemIdList.add(str);
                        }
                    }
                }
                if (deleteLineItemIdList != Null && deleteLineItemIdList.size() > 0 && errorData == '' && enquiryRecordType == 'Vehicle Sales') {
                    DataBase.delete(deleteLineItemIdList, false);
                }

                if (enquiryRecordType == 'Accessories Sales' && childSobjectType == 'OpportunityLineItem') {
                    String YES = 'y';
                    String parentQuery = 'SELECT Id, DMS_Acc_Cust_Serv__c FROM ' + childSobjectType;
                    parentQuery += ' WHERE Id IN: deleteLineItemIdList AND DMS_Acc_Cust_Serv__c =: YES And ' + parentField + ' =: parentRecordId';
                    List < sObject > existingAccLineItemsList = (List < sObject >) Database.query(parentQuery);

                    List < sObject > notInUseAccList = new List < sObject > ();
                    if (existingAccLineItemsList != null && existingAccLineItemsList.size() > 0) {
                        for (sObject obj : existingAccLineItemsList) {
                            obj.put('DMS_Acc_Cust_Serv__c', 'n');
                            notInUseAccList.add(obj);
                        }

                        if (notInUseAccList != null && notInUseAccList.size() > 0) {
                            TriggerHandler.bypass('OpportunityTriggerHandler_Strategy');
                            Database.update(notInUseAccList, false);
                            TriggerHandler.clearBypass('OpportunityTriggerHandler_Strategy');
                        }

                    }
                }

                try {
                    update parentSObj;
                } catch (DmlException de) {
                    system.debug('== Before opp update errorData ' + errorData);
                    for (Integer i = 0; i < de.getNumDml(); i++) {
                        errorData += de.getDmlMessage(i);
                    }
                }
            }

            try {
                if (generateMCRecord) {
                    // Create MC Communication record for accessories type only
                    GenerateFilePublicURL.CreateMCRecord(ConstantsUtility.ACCESSORIES_CREATION_CONST, new Set < Id >{
                        parentRecordId
                            }, ConstantsUtility.OPPORTUNITY, '');
                }
            } catch (Exception ex) {
                system.debug('== ex Message ' + ex.getMessage());
                errorData += ex.getMessage();
            }

            if (errorData == '') {
                return 'success';
            } else {
                system.debug('== Last errorData ' + errorData);
                ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();
                ehst.componentName = 'Add Line Item';
                ehst.userId = UserInfo.getUserId();
                ExceptionHandler.LogError('AddLineItemCtrl', errorData, 'AddLineItemCtrl', '', ehst);
                return errorData;
            }
        }
        return null;
    }


    Public Static void exShowRoomLineItem(Map < String, Object > mainDataMap) {

        Map < String, Object > exShowRoomVariantDataMap = (Map < String, Object >) mainDataMap.get('exShowRoomVariant');

        Map < String, Object > colorAndVariantObjMap = (Map < String, Object >) mainDataMap.get('selectedColorVariant');
        if (childSobjectType != null && childSobjectType != '' && parentField != '' && parentRecordId != '') {

            sobject objEx = createChildSObjectInstance(childSobjectType);
            objEx.put(parentField, parentRecordId);
            objEx.put('Quantity', exShowRoomVariantDataMap.containsKey('Quantity') ? Integer.valueOf(exShowRoomVariantDataMap.get('Quantity')) : null);

            string unitPriceExStr = exShowRoomVariantDataMap.containsKey('UnitPrice') ? string.valueOf(exShowRoomVariantDataMap.get('UnitPrice')) : null;
            objEx.put('UnitPrice', unitPriceExStr != null ? decimal.valueOf(unitPriceExStr) : null);
            objEx.put('priceBookEntryId', exShowRoomVariantDataMap.containsKey('priceBookEntryId') ? string.valueOf(exShowRoomVariantDataMap.get('priceBookEntryId')) : null);
            objEx.put('Type__c', 'Variants');

            if (colorAndVariantObjMap != null && colorAndVariantObjMap.size() > 0) {
                objEx.put('Color__c', string.valueOf(colorAndVariantObjMap.get('Id')) != null ? string.valueOf(colorAndVariantObjMap.get('Id')) : null);
            }

            objEx.put('SortOrder', 1);
            if (unitPriceExStr != null && unitPriceExStr != '' && decimal.valueOf(unitPriceExStr) > 0) {
                productIdWithLineItemMap.put(string.valueOf(objEx.get('priceBookEntryId')), objEx);
            }
        }
    }

    Public Static void accessoriesLineItem(Map < String, Object > mainDataMap) {

        List < object > addAccessoriesDataList = (List < object >) mainDataMap.get('addAccessories');
        if (addAccessoriesDataList != Null && addAccessoriesDataList.size() > 0) {
            for (Object obj : addAccessoriesDataList) {
                Map < String, Object > accessoriesObjMap = (Map < String, Object >) obj;

                sobject objAcc = createChildSObjectInstance(childSobjectType);
                objAcc.put(parentField, parentRecordId);
                objAcc.put('Quantity', accessoriesObjMap.containsKey('quantity') ? Integer.valueOf(accessoriesObjMap.get('quantity')) : null);

                string unitPrice = accessoriesObjMap.containsKey('unitPrice') ? String.valueOf(accessoriesObjMap.get('unitPrice')) : null;
                objAcc.put('UnitPrice', unitPrice != null ? decimal.valueOf(unitPrice) : null);
                objAcc.put('priceBookEntryId', accessoriesObjMap.containsKey('priceBookEntryId') ? String.valueOf(accessoriesObjMap.get('priceBookEntryId')) : null);
                objAcc.put('ServiceDate', system.today());

                if (parentSobjectType == 'Opportunity' && enquiryRecordType == 'Accessories Sales'){
                    objAcc.put('DMS_Acc_Cust_Serv__c', 'y');
                }

                objAcc.put('Type__c', 'MGA');
                objAcc.put('SortOrder', 10);

                if (unitPrice != null && unitPrice != '' && decimal.valueOf(unitPrice) > 0) {
                    productIdWithLineItemMap.put(string.valueOf(objAcc.get('priceBookEntryId')), objAcc);
                }
            }
        }
    }

    Public Static void registrationLineItem(Map < String, Object > mainDataMap) {

        Map < String, Object > registrationAmountVariantMap = (Map < String, Object >) mainDataMap.get('registrationAmountVariant');
        if (registrationAmountVariantMap != Null && registrationAmountVariantMap.size() > 0) {

            sobject objReg = createChildSObjectInstance(childSobjectType);
            objReg.put(parentField, parentRecordId);
            objReg.put('Quantity', registrationAmountVariantMap.containsKey('Quantity') ? Integer.valueOf(registrationAmountVariantMap.get('Quantity')) : null);

            string unitPrice = registrationAmountVariantMap.containsKey('UnitPrice') ? string.valueOf(registrationAmountVariantMap.get('UnitPrice')) : null;
            objReg.put('UnitPrice', unitPrice != null ? decimal.valueOf(unitPrice) : null);
            objReg.put('SortOrder', 20);

            String priceEntryBookId = getPriceBookEntryId('Registration Amount');
            system.debug('== Registartion Amount priceEntryBookId ' + priceEntryBookId);

            if (priceEntryBookId != Null && priceEntryBookId != '') {
                objReg.put('priceBookEntryId', priceEntryBookId);
            } else {
                objReg.put('priceBookEntryId', registrationAmountVariantMap.containsKey('priceBookEntryId') ? string.valueOf(registrationAmountVariantMap.get('priceBookEntryId')) : null);
            }

            objReg.put('Type__c', 'Registration');

            if (unitPrice != null && unitPrice != '' && decimal.valueOf(unitPrice) > 0) {
                productIdWithLineItemMap.put(string.valueOf(objReg.get('priceBookEntryId')), objReg);
            }
        }
    }

    Public Static void componentLineItem(Map < String, Object > mainDataMap) {

        List < object > addComponentDataList = (List < object >) mainDataMap.get('addComponent');
        system.debug('== addComponentDataList ' + addComponentDataList);
        Map < String, Object > opportunityInfoDataMap = (Map < String, Object >) mainDataMap.get('opportunityInfo');
        string loyaltyProgramType = '';
        if (opportunityInfoDataMap != null && opportunityInfoDataMap.containsKey('Loyalty_Program_Type__c') && opportunityInfoDataMap.get('Loyalty_Program_Type__c') != null) {
            loyaltyProgramType = string.valueOf(opportunityInfoDataMap.get('Loyalty_Program_Type__c'));
        }

        if (addComponentDataList != Null && addComponentDataList.size() > 0) {

            for (Object obj : addComponentDataList) {
                Map < String, Object > componentObjMap = (Map < String, Object >) obj;

                sobject objCom = createChildSObjectInstance(childSobjectType);

                Boolean isChecked = componentObjMap.containsKey('isChecked') ? Boolean.valueOf(componentObjMap.get('isChecked')) : false;
                if (isChecked) {
                    objCom.put(parentField, parentRecordId);
                    objCom.put('Quantity', 1);

                    string labelValue = componentObjMap.containsKey('label') ? String.valueOf(componentObjMap.get('label')) : null;

                    string unitPrice = componentObjMap.containsKey('value') ? String.valueOf(componentObjMap.get('value')) : null;

                    if (labelValue != null && labelValue != '' && (labelValue == 'Extended Warranty' || labelValue == 'Loyalty')) {

                        if(loyaltyProgramType == 'Pragati' && labelValue == 'Loyalty'){
                            objCom.put('UnitPrice', 0.0);
                        }else{
                            Integer taxAmount = Label.Tax_Amount != Null ? Integer.valueOf(Label.Tax_Amount) : 0;
                            decimal unitPriceValue = (decimal.valueOf(unitPrice) * taxAmount) / 100;

                            objCom.put('UnitPrice', (unitPrice != null && unitPrice != '') ? (unitPriceValue + decimal.valueOf(unitPrice)) : null);
                        }
                    } else {
                        objCom.put('UnitPrice', (unitPrice != null && unitPrice != '') ? decimal.valueOf(unitPrice) : null);
                    }


                    string name = componentObjMap.containsKey('label') ? String.valueOf(componentObjMap.get('label')) : null;

                    String priceEntryBookId = getPriceBookEntryId(name);
                    if (priceEntryBookId != Null && priceEntryBookId != '') {
                        objCom.put('priceBookEntryId', priceEntryBookId);
                    }

                    string objectId = componentObjMap.containsKey('comId') ? string.valueOf(componentObjMap.get('comId')) : null;
                    objCom.put('Id', objectId);


                    if (labelValue != null && labelValue != '' && labelValue == 'MCP') {
                        string mcpPackage = componentObjMap.containsKey('packageValue') ? String.valueOf(componentObjMap.get('packageValue')) : null;
                        string mcpValidity = componentObjMap.containsKey('validityValue') ? String.valueOf(componentObjMap.get('validityValue')) : null;
                        objCom.put('MCP_Package__c', mcpPackage);
                        objCom.put('MCP_Validity__c', mcpValidity);

                        objCom.put('Type__c', 'MCP');

                        objCom.put('Description', 'MCP ' + (mcpPackage != null ? mcpPackage + ' ' : '') + (mcpValidity != null ? mcpValidity : ''));

                    }
                    //Added By-: Nishant Prajapati Date-: 12/09/2019 Description-: Populate Exended Warranty on OLI.
                    if (labelValue != null && labelValue != '' && labelValue == 'Extended Warranty' && componentObjMap.containsKey('year')) {
                        String yearValue = string.valueOf(componentObjMap.get('year'));

                        string finalYearValue = '';
                        if (yearValue == '1 year') {
                            finalYearValue = 'I';
                        }
                        if (yearValue == '2 year') {
                            finalYearValue = 'II';
                        }
                        if (yearValue == '3 year') {
                            finalYearValue = 'III';
                        }
                        objCom.put('Description', 'Extended Warranty ' + yearValue);
                        objCom.put('Extended_Warranty_Validity__c', finalYearValue != '' ? finalYearValue.trim() : null);
                    }
                    if (labelValue != null && labelValue != '' && labelValue == 'Road Tax') {
                        objCom.put('Type__c', 'Road Tax');
                    }
                    if (labelValue != null && labelValue != '' && labelValue == 'FASTag charges') {
                        objCom.put('Type__c', 'Number Plate Charges');
                    }
                    if (labelValue != null && labelValue != '' && labelValue == 'Municipal Charges') {
                        objCom.put('Type__c', 'Municipal Charges');
                    }
                    if (labelValue != null && labelValue != '' && labelValue == 'Insurance') {
                        objCom.put('Type__c', 'Insurance');
                    }
                    if (labelValue != null && labelValue != '' && labelValue == 'Loyalty') {
                        objCom.put('Type__c', 'Loyalty');
                    }
                    if (labelValue != null && labelValue != '' && labelValue == 'Extended Warranty') {
                        objCom.put('Type__c', 'Extended Warranty');
                    }
                    objCom.put('SortOrder', 20);

                    if (labelValue != null && labelValue != '' && labelValue == 'Loyalty' && loyaltyProgramType == 'Pragati') {
                        productIdWithLineItemMap.put(string.valueOf(objCom.get('priceBookEntryId')), objCom);
                    }else{
                        if (unitPrice != null && unitPrice != '' && decimal.valueOf(unitPrice) > 0) {
                            productIdWithLineItemMap.put(string.valueOf(objCom.get('priceBookEntryId')), objCom);
                        }
                    }
                }
            }
        }
    }

    Public Static void otherAccessoryDiscountLineItem(Map < String, Object > mainDataMap) {

        Map < String, Object > otherAccessoryDiscountMap = (Map < String, Object >) mainDataMap.get('otherAccessoriesDiscount');
        if (otherAccessoryDiscountMap != Null && otherAccessoryDiscountMap.size() > 0) {

            sobject objReg = createChildSObjectInstance(childSobjectType);

            objReg.put(parentField, parentRecordId);
            objReg.put('Quantity', 1);

            string unitPrice = otherAccessoryDiscountMap.containsKey('UnitPrice') ? string.valueOf(otherAccessoryDiscountMap.get('UnitPrice')) : null;
            decimal price = unitPrice != null ? decimal.valueOf(unitPrice) : 0.0;
            objReg.put('UnitPrice', (-price));
            String priceEntryBookId;

            objReg.put('SortOrder', 10);
            priceEntryBookId = getPriceBookEntryId('Accessory Discount');


            if (priceEntryBookId != Null && priceEntryBookId != '') {
                objReg.put('priceBookEntryId', priceEntryBookId);
            }

            if (price > 0) {
                productIdWithLineItemMap.put(string.valueOf(objReg.get('priceBookEntryId')), objReg);
            }
        }
    }

    Public Static void otherChargeLineItem(Map < String, Object > mainDataMap) {

        Map < String, Object > otherChargeVariantMap = (Map < String, Object >) mainDataMap.get('otherCharge');
        if (otherChargeVariantMap != Null && otherChargeVariantMap.size() > 0) {

            sobject objReg = createChildSObjectInstance(childSobjectType);

            objReg.put(parentField, parentRecordId);
            objReg.put('Quantity', otherChargeVariantMap.containsKey('Quantity') ? Integer.valueOf(otherChargeVariantMap.get('Quantity')) : null);

            objReg.put('Description', otherChargeVariantMap.containsKey('Description') ? String.valueOf(otherChargeVariantMap.get('Description')) : null);

            string unitPrice = otherChargeVariantMap.containsKey('UnitPrice') ? string.valueOf(otherChargeVariantMap.get('UnitPrice')) : null;
            objReg.put('UnitPrice', unitPrice != null ? decimal.valueOf(unitPrice) : null);

            String priceEntryBookId = getPriceBookEntryId('Other Charges');
            if (priceEntryBookId != Null && priceEntryBookId != '') {
                objReg.put('priceBookEntryId', priceEntryBookId);
            }

            objReg.put('SortOrder', 20);

            decimal otheChargeAmount = unitPrice != null ? decimal.valueOf(unitPrice) : null;
            if (otheChargeAmount != null && otheChargeAmount > 0) {
                productIdWithLineItemMap.put(string.valueOf(objReg.get('priceBookEntryId')), objReg);
            }
        }
    }


    Public Static void schemesAndOfferLineItem(Map < String, Object > mainDataMap) {

        Map < String, Object > addSchemesMap = (Map < String, Object >) mainDataMap.get('addSchemes');
        if (addSchemesMap != null && addSchemesMap.size() > 0) {

            cashPayment = addSchemesMap.containsKey('cashPaymentData') ? String.valueOf(addSchemesMap.get('cashPaymentData')) : null;
            financeAmount = addSchemesMap.containsKey('financeAmountData') ? String.valueOf(addSchemesMap.get('financeAmountData')) : null;
            //#DE622 Start
            firstName = addSchemesMap.containsKey('firstName') ? String.valueOf(addSchemesMap.get('firstName')) : null;
            lastName = addSchemesMap.containsKey('lastName') ? String.valueOf(addSchemesMap.get('lastName')) : null;
            middleName = addSchemesMap.containsKey('middleName') ? String.valueOf(addSchemesMap.get('middleName')) : null;
            phoneNumber = addSchemesMap.containsKey('phoneNumber') ? String.valueOf(addSchemesMap.get('phoneNumber')) : null;
            //#DE622 End

            Boolean corporateDiscount = addSchemesMap.containsKey('corporateDiscountValue') ? Boolean.valueOf(addSchemesMap.get('corporateDiscountValue')) : false;
            Boolean exchangeBonus = addSchemesMap.containsKey('exchangeBonusValue') ? Boolean.valueOf(addSchemesMap.get('exchangeBonusValue')) : false;
            Boolean exchangeValue = addSchemesMap.containsKey('exchangeValue') ? Boolean.valueOf(addSchemesMap.get('exchangeValue')) : false;
            Boolean ruralOffers = addSchemesMap.containsKey('ruralOffersValue') ? Boolean.valueOf(addSchemesMap.get('ruralOffersValue')) : false;
            Boolean otherDiscount = addSchemesMap.containsKey('otherDiscountValue') ? Boolean.valueOf(addSchemesMap.get('otherDiscountValue')) : false;
            Boolean isCommercial = addSchemesMap.containsKey('isCommercial') ? Boolean.valueOf(addSchemesMap.get('isCommercial')) : false;
            Boolean loyaltyDiscount = addSchemesMap.containsKey('loyaltyDiscountValue') ? Boolean.valueOf(addSchemesMap.get('loyaltyDiscountValue')) : false;
            Boolean acquisitionDiscount = addSchemesMap.containsKey('acquisitionDiscountValue') ? Boolean.valueOf(addSchemesMap.get('acquisitionDiscountValue')) : false;
            Boolean bulkDiscount = addSchemesMap.containsKey('bulkDiscountValue') ? Boolean.valueOf(addSchemesMap.get('bulkDiscountValue')) : false;
            Boolean specialDiscount = addSchemesMap.containsKey('specialDiscountValue') ? Boolean.valueOf(addSchemesMap.get('specialDiscountValue')) : false;


            if (corporateDiscount) {
                sobject objCor = createChildSObjectInstance(childSobjectType);

                objCor.put(parentField, parentRecordId);
                objCor.put('Quantity', 1);
                string corpPrice = addSchemesMap.containsKey('corporateDiscountData') ? String.valueOf(addSchemesMap.get('corporateDiscountData')) : null;

                decimal price = corpPrice != null ? decimal.valueOf(corpPrice) : 0.0;
                objCor.put('UnitPrice', corpPrice != null ? (-price) : null);

                String priceEntryBookId = getPriceBookEntryId('Corporate Discount');
                if (priceEntryBookId != Null && priceEntryBookId != '') {
                    objCor.put('priceBookEntryId', priceEntryBookId);
                }

                objCor.put('Type__c', 'Corporate_Offer');
                objCor.put('SortOrder', 30);

                if (price > 0) {
                    productIdWithLineItemMap.put(string.valueOf(objCor.get('priceBookEntryId')), objCor);
                }
            }

            if (exchangeBonus) {
                sobject objBon = createChildSObjectInstance(childSobjectType);

                objBon.put(parentField, parentRecordId);
                objBon.put('Quantity', 1);
                string bonPrice = addSchemesMap.containsKey('exchangeBonusData') ? String.valueOf(addSchemesMap.get('exchangeBonusData')) : null;
                decimal price = bonPrice != null ? decimal.valueOf(bonPrice) : 0.0;

                objBon.put('UnitPrice', bonPrice != null ? (-price) : null);
                objBon.put('Type__c', 'Exchange_Bonus');
                objBon.put('SortOrder', 30);

                String priceEntryBookId = getPriceBookEntryId('Exchange Bonus');
                if (priceEntryBookId != Null && priceEntryBookId != '') {
                    objBon.put('priceBookEntryId', priceEntryBookId);
                }

                if (price > 0) {
                    productIdWithLineItemMap.put(string.valueOf(objBon.get('priceBookEntryId')), objBon);
                }
            }

            if (exchangeValue) {
                sobject objVal = createChildSObjectInstance(childSobjectType);

                objVal.put(parentField, parentRecordId);
                objVal.put('Quantity', 1);
                string valPrice = addSchemesMap.containsKey('exchangeData') ? String.valueOf(addSchemesMap.get('exchangeData')) : null;
                decimal price = valPrice != null ? decimal.valueOf(valPrice) : 0.0;

                objVal.put('UnitPrice', valPrice != null ? (-price) : null);

                String priceEntryBookId = getPriceBookEntryId('Exchange Value');
                if (priceEntryBookId != Null && priceEntryBookId != '') {
                    objVal.put('priceBookEntryId', priceEntryBookId);
                }
                objVal.put('Type__c', 'Exchange_Value');
                objVal.put('SortOrder', 30);

                if (price > 0) {
                    productIdWithLineItemMap.put(string.valueOf(objVal.get('priceBookEntryId')), objVal);
                }
            }

            if (otherDiscount) {
                sobject objOther = createChildSObjectInstance(childSobjectType);

                objOther.put(parentField, parentRecordId);
                objOther.put('Quantity', 1);
                string otherPrice = addSchemesMap.containsKey('otherDiscountData') ? String.valueOf(addSchemesMap.get('otherDiscountData')) : null;
                decimal price = otherPrice != null ? decimal.valueOf(otherPrice) : 0.0;

                objOther.put('UnitPrice', otherPrice != null ? (-price) : null);

                String priceEntryBookId = getPriceBookEntryId('Other Discount');
                if (priceEntryBookId != Null && priceEntryBookId != '') {
                    objOther.put('priceBookEntryId', priceEntryBookId);
                }
                objOther.put('Type__c', 'Other_Discount');
                objOther.put('SortOrder', 30);

                if (price > 0) {
                    productIdWithLineItemMap.put(string.valueOf(objOther.get('priceBookEntryId')), objOther);
                    addSchemesMap.put('objOtherId', objOther.get('priceBookEntryId'));
                }
            }

            if (ruralOffers) {

                sobject objROffer = createChildSObjectInstance(childSobjectType);

                objROffer.put(parentField, parentRecordId);
                objROffer.put('Quantity', 1);
                string otherPrice = addSchemesMap.containsKey('ruralDiscountData') ? String.valueOf(addSchemesMap.get('ruralDiscountData')) : null;
                decimal price = otherPrice != null ? decimal.valueOf(otherPrice) : 0.0;

                objROffer.put('UnitPrice', otherPrice != null ? (-price) : null);

                String priceEntryBookId = getPriceBookEntryId('Rural Offers');
                if (priceEntryBookId != Null && priceEntryBookId != '') {
                    objROffer.put('priceBookEntryId', priceEntryBookId);
                }
                objROffer.put('Type__c', 'Rural_Offer');
                objROffer.put('SortOrder', 30);

                if (price > 0) {
                    productIdWithLineItemMap.put(string.valueOf(objROffer.get('priceBookEntryId')), objROffer);
                }
            }

            if(acquisitionDiscount){

                sobject acquisitionDiscountObj = createChildSObjectInstance(childSobjectType);

                acquisitionDiscountObj.put(parentField, parentRecordId);
                acquisitionDiscountObj.put('Quantity', 1);
                string otherPrice = addSchemesMap.containsKey('acquisitionDiscount') ? String.valueOf(addSchemesMap.get('acquisitionDiscount')) : null;
                decimal price = otherPrice != null ? decimal.valueOf(otherPrice) : 0.0;

                acquisitionDiscountObj.put('UnitPrice', otherPrice != null ? (-price) : null);

                String priceEntryBookId = getPriceBookEntryId('Acquisition Discount');
                if (priceEntryBookId != Null && priceEntryBookId != '') {
                    acquisitionDiscountObj.put('priceBookEntryId', priceEntryBookId);
                }
                //acquisitionDiscountObj.put('Type__c', 'Rural_Offer');
                //acquisitionDiscountObj.put('SortOrder', 30);

                if (price > 0) {
                    productIdWithLineItemMap.put(string.valueOf(acquisitionDiscountObj.get('priceBookEntryId')), acquisitionDiscountObj);
                }
            }
            if(loyaltyDiscount){
                sobject loyaltyDiscountObj = createChildSObjectInstance(childSobjectType);

                loyaltyDiscountObj.put(parentField, parentRecordId);
                loyaltyDiscountObj.put('Quantity', 1);
                string loyaltyDiscountPrice = addSchemesMap.containsKey('loyaltyDiscount') ? String.valueOf(addSchemesMap.get('loyaltyDiscount')) : null;
                decimal loyaltyprice = loyaltyDiscountPrice != null ? decimal.valueOf(loyaltyDiscountPrice) : 0.0;

                loyaltyDiscountObj.put('UnitPrice', loyaltyDiscountPrice != null ? (- loyaltyprice) : null);

                String priceEntryBookIdForLoyalty = getPriceBookEntryId('Loyalty Discount');
                if (priceEntryBookIdForLoyalty != Null && priceEntryBookIdForLoyalty != '') {
                    loyaltyDiscountObj.put('priceBookEntryId', priceEntryBookIdForLoyalty);
                }
                //acquisitionDiscountObj.put('Type__c', 'Rural_Offer');
                //acquisitionDiscountObj.put('SortOrder', 30);

                if (loyaltyprice > 0) {
                    productIdWithLineItemMap.put(string.valueOf(loyaltyDiscountObj.get('priceBookEntryId')), loyaltyDiscountObj);
                }
            }
            if(bulkDiscount){
                sobject bulkDiscountObj = createChildSObjectInstance(childSobjectType);

                bulkDiscountObj.put(parentField, parentRecordId);
                bulkDiscountObj.put('Quantity', 1);
                string bulkDiscountPrice = addSchemesMap.containsKey('bulkDiscount') ? String.valueOf(addSchemesMap.get('bulkDiscount')) : null;
                decimal bulkPrice = bulkDiscountPrice != null ? decimal.valueOf(bulkDiscountPrice) : 0.0;

                bulkDiscountObj.put('UnitPrice', bulkDiscountPrice != null ? (- bulkPrice) : null);

                String priceEntryBookIdForLoyalty = getPriceBookEntryId('Bulk Discount');
                if(priceEntryBookIdForLoyalty != Null && priceEntryBookIdForLoyalty != ''){
                    bulkDiscountObj.put('priceBookEntryId', priceEntryBookIdForLoyalty);
                }
                //acquisitionDiscountObj.put('Type__c', 'Rural_Offer');
                //acquisitionDiscountObj.put('SortOrder', 30);

                if(bulkPrice > 0){
                    productIdWithLineItemMap.put(string.valueOf(bulkDiscountObj.get('priceBookEntryId')), bulkDiscountObj);
                }
            }

            if(specialDiscount){
                sobject specialDiscountObj = createChildSObjectInstance(childSobjectType);

                specialDiscountObj.put(parentField, parentRecordId);
                specialDiscountObj.put('Quantity', 1);
                string specialDiscountPrice = addSchemesMap.containsKey('bulkDiscount') ? String.valueOf(addSchemesMap.get('specialDiscount')) : null;
                decimal specialPrice = specialDiscountPrice != null ? decimal.valueOf(specialDiscountPrice) : 0.0;

                specialDiscountObj.put('UnitPrice', specialDiscountPrice != null ? (- specialPrice) : null);

                String priceEntryBookIdForLoyalty = getPriceBookEntryId('Special Discount');
                if(priceEntryBookIdForLoyalty != Null && priceEntryBookIdForLoyalty != ''){
                    specialDiscountObj.put('priceBookEntryId', priceEntryBookIdForLoyalty);
                }

                if(specialPrice > 0){
                    productIdWithLineItemMap.put(string.valueOf(specialDiscountObj.get('priceBookEntryId')), specialDiscountObj);
                }
            }
        }
    }


    Public Static void consumerOfferLineItem(Map < String, Object > mainDataMap) {

        List < Object > consumerOfferList = (List < Object >) mainDataMap.get('consumerOffer');
        if (consumerOfferList != Null && consumerOfferList.size() > 0) {

            for (object objOffer : consumerOfferList) {
                Map < string, object > singleConsumerOffer = (Map < string, object >) objOffer;
                sobject obj = createChildSObjectInstance(childSobjectType);
                obj.put(parentField, parentRecordId);

                obj.put('Quantity', singleConsumerOffer.containsKey('Quantity') ? Integer.valueOf(singleConsumerOffer.get('Quantity')) : null);
                obj.put('priceBookEntryId', singleConsumerOffer.containsKey('priceBookEntryId') ? String.valueOf(singleConsumerOffer.get('priceBookEntryId')) : null);

                string unitPrice = singleConsumerOffer.containsKey('UnitPrice') ? string.valueOf(singleConsumerOffer.get('UnitPrice')) : null;
                decimal offerAmount = unitPrice != null ? decimal.valueOf(unitPrice) : null;

                obj.put('UnitPrice', unitPrice != Null ? (-offerAmount) : null);

                obj.put('Type__c', 'Consumer_Offer');
                obj.put('SortOrder', 30);
                obj.put('Description', system.label.Consumer_Offer);

                system.debug('== Consumer offer ' + obj);

                if (offerAmount != null && offerAmount > 0) {
                    productIdWithLineItemMap.put(string.valueOf(obj.get('priceBookEntryId')), obj);
                }

            }
        }
    }
    /*
@Author: Deepak Kumar
@Created Date : 27/04/2020
@Discription: To check the loyalty bonus and create line item
@Date Of Modification : 27/04/2020
*/

    public static void LoyaltyBonusLineItem(Map < String, Object > mainDataMap) {
        Map<String, Object> loyaltyBonusMap = (Map<String, Object>) mainDataMap.get('loyaltyBonus');
        System.debug('loyaltyBonus::: ' + loyaltyBonusMap);
        if (loyaltyBonusMap != null) {
            if (loyaltyBonusMap.containsKey('loyaltyBonusValid') && loyaltyBonusMap.containsKey('loyaltyBonusAmount')) {
                Decimal amount = Decimal.valueOf((Integer) loyaltyBonusMap.get('loyaltyBonusAmount'));
                if (amount > 0) {
                    sobject objLoyaltyBonus = createChildSObjectInstance(childSobjectType);
                    objLoyaltyBonus.put(parentField, parentRecordId);
                    objLoyaltyBonus.put('Quantity', 1);
                    objLoyaltyBonus.put('UnitPrice', (-amount));
                    objLoyaltyBonus.put('Type__c', 'Loyalty Bonus');
                    String priceEntryBookId = getPriceBookEntryId('Loyalty Bonus');
                    objLoyaltyBonus.put('priceBookEntryId', priceEntryBookId);
                    productIdWithLineItemMap.put(string.valueOf(objLoyaltyBonus.get('priceBookEntryId')), objLoyaltyBonus);
                }
            }
        }
    }


    public static string getPriceBookEntryId(String Name) {

        String priceEntryBookId = '';
        if (Name != Null && Name != '' && allProductNameWithIdMap.containsKey(Name.toLowerCase())) {
            string productId = allProductNameWithIdMap.get(Name.toLowerCase());

            if (allproductIdWithPriceBookEntryIdMap.containsKey(productId)) {
                priceEntryBookId = allproductIdWithPriceBookEntryIdMap.get(productId);
            }
        }
        return priceEntryBookId;
    }

    public static Map < String, String > getPriceBookEntryIds(Set < string > productIdSet) {
        Map < String, String > productidWithPriceBookEntryMap = new Map < String, String > ();
        // if(productIdSet != Null && productIdSet.size() > 0 && isPricebookEntryAccessPermission()){
        if (productIdSet != Null && productIdSet.size() > 0) {
            for (PricebookEntry pbe : [
                SELECT Id, Name, Pricebook2Id, Product2Id, UnitPrice, IsActive
                FROM PricebookEntry
                where Product2Id IN:productIdSet AND isActive = true
            ]) {

                productidWithPriceBookEntryMap.put(pbe.Product2Id, pbe.Id);
            }
        }
        return productidWithPriceBookEntryMap;
    }

    public static Map < String, String > getAllProductIdFromName(Set < String > productNameSet, String recordTypeName, Map < String, String > allProductNameWithIdMap) {
        string productRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        if (isProductEntryAccessPermission()) {
            for (product2 pro : [
                Select id, Name
                from Product2
                where Name IN:productNameSet
                And recordTypeId = :productRecordTypeId And IsActive = True
            ]) {
                allProductNameWithIdMap.put(pro.Name.toLowerCase(), pro.Id);
            }
        }
        return allProductNameWithIdMap;
    }

    public static Map < String, String > createPriceBookEntryIds(Set < string > productIdSet, Map < String, String > allproductIdWithPriceBookEntryIdMap) {
        List < Pricebook2 > priceBookDetail = new List < Pricebook2 > ([select id, name from Pricebook2 where isStandard = true limit 1]);
        Map < String, PricebookEntry > priceBookInfoMap = new Map < String, PricebookEntry > ();

        if (productIdSet != Null && productIdSet.size() > 0 && priceBookDetail.size() > 0) {
            for (String productId : productIdSet) {
                priceBookInfoMap.put(productId, generatePriceBookEntryData(productId, priceBookDetail[0].Id));
            }

            if (priceBookInfoMap.size() > 0) {
                DataBase.insert(priceBookInfoMap.values(), false);
                for (PricebookEntry pbe : priceBookInfoMap.values()) {
                    if (pbe.Id != Null) {
                        allproductIdWithPriceBookEntryIdMap.put(pbe.Product2Id, pbe.Id);
                    }
                }
            }

        }
        return allproductIdWithPriceBookEntryIdMap;
    }

    public static Map < String, String > createProductIdFromName(Set < String > productNameSet, String recordTypeName, Map < String, String > allProductNameWithIdMap) {
        string productRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        Map < String, Product2 > productInfoMap = new Map < String, Product2 > ();

        for (String productName : productNameSet) {
            productInfoMap.put(productName, generateProductData(productName, productRecordTypeId));
        }

        if (productInfoMap.size() > 0) {
            DataBase.insert(productInfoMap.values(), false);
            for (product2 pro : productInfoMap.values()) {
                if (pro.Id != Null) {
                    allProductNameWithIdMap.put(pro.Name.toLowerCase(), pro.Id);
                }
            }
        }

        return allProductNameWithIdMap;
    }

    public static Product2 generateProductData(String productName, String productRecordTypeId) {

        Product2 pro = new Product2();

        pro.Name = productName;
        pro.recordTypeId = productRecordTypeId;
        pro.Fuel_Type__c = 'PET';
        pro.Start_Date__c = System.today().addYears(-1);
        pro.End_Date__c = System.today().addYears(5);
        pro.Model__c = 'Test';
        pro.Channel__c = 'EXC';
        pro.IsActive = true;

        return pro;
    }

    public static PricebookEntry generatePriceBookEntryData(String productId, String priceBookId) {

        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = priceBookId,
                                                Product2Id = productId,
                                                IsActive = true,
                                                UnitPrice = 0,
                                                UseStandardPrice = false);

        return pbe;
    }

    /******* TO Handle The Object And Field Permissions ********/

    /*
@Author: Anuj Kumar
@Created Date : 02/09/2019
@Discription: To Check the access permissions for PricebookEntry.
@Date Of Modification : 02/09/2019
*/
    public static Boolean isPricebookEntryAccessPermission() {
        if (CheckObjectAndField.objectCURDPermission('PricebookEntry', ConstantsUtility.IsAccessible) &&
            CheckObjectAndField.fieldCURDPermission('PricebookEntry', ConstantsUtility.IsAccessible, 'Name') &&
            CheckObjectAndField.fieldCURDPermission('PricebookEntry', ConstantsUtility.IsAccessible, 'Pricebook2Id') &&
            CheckObjectAndField.fieldCURDPermission('PricebookEntry', ConstantsUtility.IsAccessible, 'Product2Id') &&
            CheckObjectAndField.fieldCURDPermission('PricebookEntry', ConstantsUtility.IsAccessible, 'UnitPrice') &&
            CheckObjectAndField.fieldCURDPermission('PricebookEntry', ConstantsUtility.IsAccessible, 'IsActive')) {
                return True;
            } else {
                return false;
            }
    }


    /*
@Author: Anuj Kumar
@Created Date : 02/09/2019
@Discription: To Check the access permissions for Product2.
@Date Of Modification : 02/09/2019
*/
    public static Boolean isProductEntryAccessPermission() {
        if (CheckObjectAndField.objectCURDPermission('Product2', ConstantsUtility.IsAccessible) &&
            CheckObjectAndField.fieldCURDPermission('Product2', ConstantsUtility.IsAccessible, 'Name')) {
                return True;
            } else {
                return false;
            }
    }

}