/**
 * @File Name          : PartLineItemCtrl.cls
 * @Description        : This class allow us to show or create the part line item records
 * @Author             : Anuj Kumar
 * @Group              : 
 * @Last Modified By   : Anuj Kumar
 * @Last Modified On   : 
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    03/09/2019 11:17 AM          Anuj Kumar            Initial Version
**/
public without sharing class PartLineItemCtrl{
    
    Public Static String parentSobjectType = '';
    Public Static String childSobjectType = '';
    
    Public Static String parentField = '';
    Public Static String parentRecordId = '';
    Public Static sObject parentSObj;
    
    Public Static Map < String, String > existingPriceBookEntryIdMap = new Map < String, String > ();
    Public Static Map < string, SObject > productIdWithLineItemMap = new Map < String, SObject > ();
    
    public static SObject createChildSObjectInstance(String SObjectName) {
        return Schema.getGlobalDescribe().get(SObjectName).newSObject();
    }
    
    
    @AuraEnabled
    public static Opportunity getPartLineItemDetails(String recordId){
        Opportunity opp = new Opportunity();
        if(String.isNotBlank(recordId)){
            List<Opportunity> oppList = [Select id, Name, Dealership__c, Dealership__r.Name, DMS_Enquiry_Name__c, 
                Customer__c, SVOC_Customer_Name__c, RecordType.Name, StageName, Variant__c, Variant__r.Name, Pricebook2Id,
                Email__c, Mobile__c, 
                Amount, (Select id, Name, UnitPrice, Quantity, priceBookEntryId, 
                            priceBookEntry.product2Id, priceBookEntry.product2.Name, priceBookEntry.product2.RecordType.Name,
                            priceBookEntry.product2.RecordTypeId, TotalPrice, priceBookEntry.product2.ProductCode, 
                            opportunityId, Status__c, Invoice_Number__c, Invoice_Date__c, Customer_Booking_Order_Number__c,
                            Customer_Booking_Order_Date__c
                            From OpportunityLineItems where (DMS_Acc_Cust_Serv__c = 'Y' OR DMS_Acc_Cust_Serv__c = null))
                From Opportunity where Id =: recordId];
                
            opp = (oppList != null && oppList.size() > 0) ? oppList[0] : new Opportunity();
        }
        return opp;
    }
    
    @AuraEnabled
    public static String ceratePartLineItemDetails(String recordList, String recordId, String opportunityData, String formType, Boolean msgpaSelected, Decimal partOfferAmount){
        
        system.debug('== recordList '+recordList);
        
        String errorData = '';
        Opportunity opp = new Opportunity();
        if(String.isNotBlank(opportunityData)){
            opp = (Opportunity)JSON.deserialize(opportunityData, Opportunity.class);
        }
        Quote qot = new Quote();
        
        if(String.isNotBlank(recordId)){ parentRecordId = recordId; }
        if(String.isNotBlank(formType)){ 
            parentSobjectType = formType;
            if(formType == ConstantsUtility.OPPORTUNITY){
                parentField = 'opportunityId';
                childSobjectType = 'OpportunityLineItem';
                parentSObj = Schema.getGlobalDescribe().get(ConstantsUtility.OPPORTUNITY).newSObject();

                for (OpportunityLineItem obj : [SELECT Id, PriceBookEntryId FROM OpportunityLineItem where opportunityId =: recordId]) {
                    existingPriceBookEntryIdMap.put(obj.PriceBookEntryId, obj.Id);
                }
                
            }else if(formType == ConstantsUtility.QUOTE){
                parentField = 'quoteId';
                childSobjectType = 'QuoteLineItem';
                parentSObj = Schema.getGlobalDescribe().get(ConstantsUtility.QUOTE).newSObject();
                
                
                Integer dtYear = Date.Today().Year();
                Integer dtMonth = Date.Today().Month();
                Integer dtDay = Date.Today().Day();
                string nameData = opp.Name + '_' + +dtDay+'/'+dtMonth+'/'+dtYear;
                qot.Name = nameData;
                
                qot.Variant__c = opp.Variant__c;
                qot.Pricebook2Id = opp.Pricebook2Id;
                qot.Email = opp.Email__c;
                qot.Phone = opp.Mobile__c;
                
                qot.opportunityId = recordId;
                
                try{
                    insert qot;
                    parentRecordId = qot.Id; 
                    
                    if(qot.Id != null){
                        
                        // Need to store the count of quotation related to the enquiry.
                        
                        TriggerHandler.bypass('OpportunityTriggerHandler_Strategy');
                        update (new Opportunity(Id = recordId, 
                                Quotations_count__c = [Select count() from quote Where opportunityId =: recordId]));
                        TriggerHandler.clearBypass('OpportunityTriggerHandler_Strategy');
                        
                    }
                }catch(Exception ex){
                    ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace();ehst.componentName='Parts Line Item';ehst.userId=UserInfo.getUserId();ExceptionHandler.LogError('AddLineItemCtrl', ex.getMessage(), 'AddLineItemCtrl', '', ehst);
                }
            }
        }
        
        if(String.isNotBlank(recordList)){
            // Create child records
            addChildRecords(recordList, partOfferAmount);
            
            Set < String > newLineItemIdSet = new Set < String > ();
            
            system.debug('== productIdWithLineItemMap '+productIdWithLineItemMap);
            
            if (productIdWithLineItemMap != null && productIdWithLineItemMap.size() > 0 && productIdWithLineItemMap.values().size() > 0) {

                List < sObject > oliInsertList = new List < sObject > ();
                List < sObject > oliUpdateList = new List < sObject > ();
    
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
                        }
                    }
                }
                
                if (oliInsertList != Null && oliInsertList.size() > 0) {
                    try {
                        Database.SaveResult[] oliSR = Database.Insert(oliInsertList, false);
                        for (integer i = 0; i < oliInsertList.size(); i++) {
                            if (oliSR.get(i).isSuccess()) {
                                newLineItemIdSet.add(oliSR.get(i).getId());
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
            }
    
            if (parentSobjectType == 'Opportunity'){
                
                Set < String > existingLineItemIdSet = new Set < String > (existingPriceBookEntryIdMap.values());
                List < String > deleteLineItemIdList = new List < String > ();
    
                if (existingLineItemIdSet != Null && existingLineItemIdSet.size() > 0) {
                    for (string str : existingLineItemIdSet) {
                        if (!newLineItemIdSet.contains(str)) {
                            deleteLineItemIdList.add(str);
                        }
                    }
                }
                
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
                
                parentSObj.put('Id', parentRecordId);
                if(msgpaSelected){
                    parentSObj.put('StageName', 'MSGP&A Selected');
                    parentSObj.put('By_Pass_Stage_Validation__c', true);
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
            
            if (parentSobjectType == 'Quote' && errorData == '' ){
                return qot.Id+'#success';
            }
        }
        if (errorData == '') {
                return 'success';
        }
        
        return errorData;
    }
    
    
    public static void addChildRecords(String recordList, Decimal partOfferAmount){
        
        List < object > addchildDataList = (List < object >) JSON.deserializeUntyped(recordList);
        
        if (!addchildDataList.isEmpty()) {
            for (Object obj : addchildDataList) {
                Map < String, Object > childObjMap = (Map < String, Object >) obj;

                sobject objPart = createChildSObjectInstance(childSobjectType);
                objPart.put(parentField, parentRecordId);
                objPart.put('Quantity', childObjMap.containsKey('quantity') ? Integer.valueOf(childObjMap.get('quantity')) : null);

                string unitPrice = childObjMap.containsKey('unitPrice') ? String.valueOf(childObjMap.get('unitPrice')) : null;
                objPart.put('UnitPrice', unitPrice != null ? decimal.valueOf(unitPrice) : null);
                objPart.put('priceBookEntryId', childObjMap.containsKey('priceBookEntryId') ? String.valueOf(childObjMap.get('priceBookEntryId')) : null);
                objPart.put('ServiceDate', system.today());

                if (parentSobjectType == 'Opportunity'){
                    objPart.put('DMS_Acc_Cust_Serv__c', 'y');
                }

                objPart.put('SortOrder', 10);

                if (unitPrice != null && unitPrice != '' && decimal.valueOf(unitPrice) > 0) {
                    productIdWithLineItemMap.put(string.valueOf(objPart.get('priceBookEntryId')), objPart);
                }
            }
        }
        
        if(partOfferAmount != null && partOfferAmount > 0 ){
            String offerProductRecordTypeId = Schema.Sobjecttype.Product2.getRecordTypeInfosByName().get(ConstantsUtility.OFFER_CONST).getRecordTypeId();
            List<Product2> productList = [Select id, name, (Select id from PriceBookEntries)  from Product2 where recordTypeId =: offerProductRecordTypeId and Name =: ConstantsUtility.OFFER_CONST limit 1];
            if(!productList.isEmpty()){
            
                sobject offerPart = createChildSObjectInstance(childSobjectType);
                
                offerPart.put(parentField, parentRecordId);
                offerPart.put('Quantity', 1);
                offerPart.put('UnitPrice', partOfferAmount > 0 ? (-partOfferAmount) : 0.0);
                
                String offerPriceBookEntryId;
                if(!productList[0].PriceBookEntries.isEmpty()){
                    offerPriceBookEntryId = productList[0].PriceBookEntries[0].Id;
                    offerPart.put('priceBookEntryId', offerPriceBookEntryId);
                }
                offerPart.put('ServiceDate', system.today());
                if (parentSobjectType == 'Opportunity'){
                    offerPart.put('DMS_Acc_Cust_Serv__c', 'y');
                }
                offerPart.put('SortOrder', 10);
                
                if (partOfferAmount > 0 && offerPriceBookEntryId != null) {
                    productIdWithLineItemMap.put(offerPriceBookEntryId, offerPart);
                }
                
            }
        }
        
    }
}