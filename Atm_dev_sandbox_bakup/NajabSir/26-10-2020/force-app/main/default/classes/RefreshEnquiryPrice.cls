/**
* @File Name          : RefreshEnquiryPrice.cls
* @Description        : This class is used to create LineItem for the related records.
* @Author             : Anuj Kumar
* @Group              : 
* @Last Modified By   : Nishant Prajapati
* @Last Modified On   : 03/09/2019 04:20 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    03/09/2019 04:20 PM          Anuj Kumar            Initial Version
1.1    05/09/2019 03:00 PM          Nishant Prajapati     Loyality, Extended Warranty, Accessories
**/

public with sharing class RefreshEnquiryPrice {
    
    /*
    @Author:                  Nishant Prajapati
    @Created Date :           03/09/2019
    @Discription:             To Update the Line Item details 
    @Date Of Modification :   03/09/2019
    */
    
    public static String updateEnquiryPrice(String dataList){
        
        String dealerForCode = '';
        
        if(dataList != null && dataList != ''){
            Map<String, Object> mainDataMap = (Map<String, Object>)JSON.deserializeUntyped(dataList);
            Map<String, Object> selectedVariantMap = (Map<String, Object>) mainDataMap.get('selectedVariant');
            // FOR UPDATE THE VARIANT RECORD INFO
            if(selectedVariantMap != Null && selectedVariantMap.size() > 0){
                
                String variantId = selectedVariantMap.containsKey('Id') ? string.valueOf(selectedVariantMap.get('Id')) : null;
                
                if(variantId != null && variantId != ''){
                    List<product2> proList = [Select Id, Name, Extended_Warranty_1_year__c, Extended_Warranty_2_year__c, 
                                              Extended_Warranty_3_year__c, Loyalty_Amount__c 
                                              From Product2 
                                              Where Id =: variantId AND IsActive = True];
                    if(proList != null && proList.size() > 0){
                        selectedVariantMap.put('Extended_Warranty_1_year__c', proList[0].Extended_Warranty_1_year__c);
                        selectedVariantMap.put('Extended_Warranty_2_year__c', proList[0].Extended_Warranty_2_year__c);
                        selectedVariantMap.put('Extended_Warranty_3_year__c', proList[0].Extended_Warranty_3_year__c);
                        selectedVariantMap.put('Loyalty_Amount__c', proList[0].Loyalty_Amount__c);
                        
                        mainDataMap.put('selectedVariant', selectedVariantMap);
                        
                    }
                }
            }
            
            // FOR UPDATE THE ADD COMPONENT INFO
            List<object> addComponentDataList = (List<object>) mainDataMap.get('addComponent');
            if(addComponentDataList != Null && addComponentDataList.size() > 0){
                List<object> tempAddCompoList = new List<object>();
                for(Object obj : addComponentDataList){
                    Map<String, Object> componentObjMap = (Map<String, Object>) obj;
                    
                    Boolean isChecked = componentObjMap.containsKey('isChecked') ? Boolean.valueOf(componentObjMap.get('isChecked')) : false;
                    if(isChecked){
                        string labelValue = componentObjMap.containsKey('label') ? String.valueOf(componentObjMap.get('label')) : null;
                        
                        if(labelValue != null && labelValue != '' && labelValue == 'Loyalty'){
                            componentObjMap.put('value', selectedVariantMap.get('Loyalty_Amount__c'));
                        }
                        if(labelValue != null && labelValue != '' && labelValue == 'Extended Warranty'){
                            string extendedWarrantyYear= componentObjMap.containsKey('year') ? String.valueOf(componentObjMap.get('year')) : '';
                            if(String.isNotBlank(extendedWarrantyYear)){
                                string key= extendedWarrantyYear.substring(0,1)+'_'+'year';
                                for(string mapKey : selectedVariantMap.keyset()){
                                    if(mapKey.containsIgnoreCase(key)){
                                        componentObjMap.put('value', selectedVariantMap.get(mapKey));
                                        break;
                                    }
                                }
                            }
                            
                        }
                    }
                    tempAddCompoList.add(obj);
                    mainDataMap.put('addComponent', tempAddCompoList);
                }
            }
            // FOR UPDATE THE ADD ACCESSORIES INFO
            List<object> addAccessoriesDataList= (List<object>)mainDataMap.get('addAccessories');
            if(addAccessoriesDataList != Null && addAccessoriesDataList.size() > 0){
                List<object> tempAccessoriesList= new List<object>();
                set<String> productIdSet= new set<String>();
                for(Object obj : addAccessoriesDataList){
                    Map<String, Object> accessorieObjMap= (Map<String, Object>) obj;
                    if(accessorieObjMap.containsKey('Id')){
                        if(accessorieObjMap.get('Id') <> null){
                            productIdSet.add(String.valueOf(accessorieObjMap.get('Id')));
                        }
                        
                    }
                    
                }
                if(productIdSet.size() > 0){
                    Id accessorieRecordTypeId= Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Accessories').getRecordTypeId();
                    Map<String, Double> discountPriceMap= new Map<String, Double>();
                    string priceBookId = AddLineItemCtrlHelper.queryStandardPriceBookId();
                    List<PricebookEntry> accessoriesList= [SELECT Id, Name, Pricebook2Id, Product2Id, UnitPrice, IsActive
                                                           FROM PricebookEntry where
                                                           Pricebook2Id =: priceBookId 
                                                           And Product2Id IN: productIdSet
                                                           AND isActive= true AND Product2.RecordTypeId=: accessorieRecordTypeId];
                    
                    
                    if(accessoriesList.size() > 0){
                        for(PricebookEntry pro : accessoriesList){
                            discountPriceMap.put(pro.Product2Id, pro.UnitPrice);
                        }
                    }
                    for(Object obj : addAccessoriesDataList){
                        Map<String, Object> accessorieObjMap= (Map<String, Object>) obj;
                        if(accessorieObjMap.containsKey('Id')){
                            if(accessorieObjMap.get('Id') <> null){
                                accessorieObjMap.put('unitPrice', discountPriceMap.get(string.valueof(accessorieObjMap.get('Id'))));
                                decimal qty = decimal.valueOf(string.valueof(accessorieObjMap.get('quantity')));
                                if(discountPriceMap.containsKey(string.valueof(accessorieObjMap.get('Id')))){
                                    accessorieObjMap.put('price', discountPriceMap.get(string.valueof(accessorieObjMap.get('Id'))) * qty);
                                    tempAccessoriesList.add(obj);
                                }
                                //tempAccessoriesList.add(obj);
                            }
                        }
                    }
                    mainDataMap.put('addAccessories', tempAccessoriesList);
                }
            }
            
            // FOR UPDATE THE EX SHOWROOM PRICE INFO
            Map<String, Object> addSchemesMap = (Map<String, Object>) mainDataMap.get('addSchemes');
            Map<String, Object> exShowRoomVariantMap = (Map<String, Object>) mainDataMap.get('exShowRoomVariant');
            Map<String, Object> selectedColorVariantMap = (Map<String, Object>) mainDataMap.get('selectedColorVariant');
            Map<String, Object> opportunityMap = (Map<String, Object>) mainDataMap.get('opportunityInfo');
            if(selectedColorVariantMap != Null && selectedColorVariantMap.size() > 0 && opportunityMap != null && opportunityMap.size() > 0){
                String exShowVariantId = selectedColorVariantMap.containsKey('Variant__c') ? string.valueOf(selectedColorVariantMap.get('Variant__c')) : null;
                String exShowColorType = selectedColorVariantMap.containsKey('Color_Type__c') ? string.valueOf(selectedColorVariantMap.get('Color_Type__c')) : null;
                String enquiryCustomerType = opportunityMap.containsKey('Customer_Type__c') ? string.valueOf(opportunityMap.get('Customer_Type__c')) : null;
                
                if(exShowVariantId != null && exShowVariantId != '' && exShowColorType != null && exShowColorType != '' && dealerForCode != null && dealerForCode != ''){
                    Decimal exShowAmount = AddLineItemCtrlHelper.calculateExShowroomPrice(exShowVariantId, dealerForCode, exShowColorType, enquiryCustomerType);
                    exShowRoomVariantMap.put('UnitPrice', exShowAmount);
                    mainDataMap.put('exShowRoomVariant', exShowRoomVariantMap);
                }
            }
            
            if(selectedVariantMap != Null && selectedVariantMap.size() > 0 && opportunityMap != null && opportunityMap.size() > 0){
                string forCode = opportunityMap.containsKey('forCode') ? string.valueOf(opportunityMap.get('forCode')) : null;
                string fuelType = selectedVariantMap.containsKey('Fuel_Type__c') ? string.valueOf(selectedVariantMap.get('Fuel_Type__c')) : null;
                string model = selectedVariantMap.containsKey('Model__c') ? string.valueOf(selectedVariantMap.get('Model__c')) : null;
                string schemeRegion = opportunityMap.containsKey('regionCode') ? string.valueOf(opportunityMap.get('regionCode')) : null;
                string state = opportunityMap.containsKey('billingState') ? string.valueOf(opportunityMap.get('billingState')) : null;
                string selectedVariant = selectedVariantMap.containsKey('ProductCode') ? string.valueOf(selectedVariantMap.get('ProductCode')) : null;
                
                Map<String, product2> pbEntryIdwithProductMap = AddLineItemCtrlHelper.queryConsumerOfferDetails(forCode, fuelType, model, schemeRegion, state, selectedVariant);
                system.debug('pbEntryIdwithProductMap>>>'+pbEntryIdwithProductMap);
                if(pbEntryIdwithProductMap != Null && pbEntryIdwithProductMap.size() > 0){
                    List<consummerOffer> consummerOfferList = new List<consummerOffer>();
                    decimal totalConsumerAmount = 0;
                    for(string pbeId : pbEntryIdwithProductMap.keySet()){
                        Product2 pro = pbEntryIdwithProductMap.get(pbeId);
                        consummerOffer co = new consummerOffer();
                        co.priceBookEntryId = pbeId;
                        co.UnitPrice = pro.Discount_Price__c;
                        co.Quantity = 1;
                        consummerOfferList.add(co);
                        totalConsumerAmount += co.UnitPrice;
                    }
                    
                    addSchemesMap.put('OfferData', totalConsumerAmount);
                    mainDataMap.put('addSchemes', addSchemesMap);
                    
                    if(consummerOfferList.size() > 0){
                        mainDataMap.put('consumerOffer', consummerOfferList);
                    }
                    
                }
            }
            
            
            // FOR UPDATE THE OFFER AND SCHEMES INFO
            dataList = JSON.serialize(mainDataMap);
            dataList = OfferSchemeCalcSrvc.retiveOfferAndSchemes(dataList);
            
        }
        return dataList;
    }
    
    public class consummerOffer{
        public string priceBookEntryId;
        public decimal UnitPrice;
        public Integer Quantity;
    }
}