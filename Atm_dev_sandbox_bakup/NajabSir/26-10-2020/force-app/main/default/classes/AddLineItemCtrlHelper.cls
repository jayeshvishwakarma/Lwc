/**
 * @File Name          : AddLineItemCtrlHelper.cls
 * @Description        : This class is helper class used in AddLineItemCtrl class.
 * @Author             : Anuj Kumar
 * @Group              : 
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 1/14/2020, 6:51:48 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    02/09/2019 11:17 AM          Anuj Kumar            Initial Version
   1.1    12/09/2019                   Nishant               fetch MCP Amount 
**/

public with sharing class AddLineItemCtrlHelper {
    
     /**
        Author: Anuj Kumar
        Company: Techmatrix
        Description: This method will return standard PriceBookEntryId.
        Inputs: N/A
        Returns: PriceBookEntry'Id
        History:
        ================
        1.0     20 Aug 2019      Anuj     Initial Version
    */
    public static string queryStandardPriceBookId(){
        List<Pricebook2> priceBookList = new List<Pricebook2> (
            [select Id from Pricebook2 where Name =: ConstantsUtility.STDPRICEBOOK]
        );
        
        if(priceBookList != null && priceBookList.size() > 0){
            return priceBookList[0].Id;
        }
        return null;
    }
    
    /**
        Author: Anuj Kumar
        Company: Techmatrix
        Description: This method will return standard PriceBookEntryId.
        Inputs: name => text to search and modelName => type of model (Ex: BA for Baleno)
        Returns: List of Product on the basis of filter criteria
        History:
        ================
        1.0     -      Anuj     Initial Version
    */
    @AuraEnabled(cacheable=true)
    public static List<Product2> queryModelVarient(String name, String modelName){
        
        String productRecordTypeId = Schema.Sobjecttype.Product2.getRecordTypeInfosByName().get(ConstantsUtility.VARIANT_CONST).getRecordTypeId();
        string nameData = '%'+name.trim()+'%';
        List<Product2> prodList = new List<Product2>();
        
        if(isProductAccessPermission()){
            if(modelName != null && modelName != '' && (modelName.contains(';') == false)){
                prodList = [Select Id, Name, Extended_Warranty_1_year__c, Extended_Warranty_2_year__c, Extended_Warranty_3_year__c, 
                            Loyalty_Amount__c, Fuel_Type__c, Family, Model__c, ProductCode
                            from Product2 
                            where recordTypeId =: productRecordTypeId AND Name Like : nameData AND Model__c =: modelName AND IsActive = True AND Enquiry__c =: ConstantsUtility.YES Limit 20];                   
            }else {
               prodList = [Select Id, Name, Extended_Warranty_1_year__c, Extended_Warranty_2_year__c, Extended_Warranty_3_year__c, 
                            Loyalty_Amount__c, Fuel_Type__c, Family, Model__c, ProductCode
                            from Product2 
                            where recordTypeId =: productRecordTypeId AND Name Like : nameData AND IsActive = True AND Enquiry__c =: ConstantsUtility.YES Limit 20];
            }
        }
        return prodList;
    }
    
     /*
        @Author:                  Anuj Kumar
        @Created Date :           21-Nov-2019
        @Discription:             Get Consumer Offer details for Variant
        @Date Of Modification :   21-Nov-2019
    */
    @AuraEnabled(cacheable=true)
    public static Map<String, Product2> queryConsumerOfferDetails(String forCode, String fuelType, String model, String schemeRegion, String state, String selectedVariant){
        
        Map<String, Product2> pbeIdWithProductMap = new Map<String, Product2>();
        
        String productRecordTypeId = Schema.sObjectType.Product2.getRecordTypeInfosByName().get(ConstantsUtility.OFFER_CONST).getRecordTypeId();

        Map<Id, Product2> offerProductMap = new Map<Id, Product2>([Select Id, Name, Discount_Price__c from Product2 Where 
                                RecordTypeId =: productRecordTypeId AND
                                Start_Date__c <: System.today() AND
                                End_Date__c >: System.today() AND
                                For_Code__c =: forCode AND
                                Fuel_Type__c =: fuelType AND
                                Model__c =: model AND
                                Scheme_Regiom__c =: schemeRegion AND
                                State__c =: state AND
                                Variant__c =: selectedVariant]);
        
         if(offerProductMap != Null && offerProductMap.size() > 0){
             for(PricebookEntry pbe : [SELECT Id, Pricebook2Id, Product2Id
                                      FROM PricebookEntry where Product2Id IN : offerProductMap.keySet()]){
                if(offerProductMap.containsKey(pbe.Product2Id)){
                    pbeIdWithProductMap.put(pbe.Id, offerProductMap.get(pbe.Product2Id));
                }
             }
         } 
        
        return pbeIdWithProductMap;
    }
    
     /*
        @Author:                  Anuj Kumar
        @Created Date :           05/08/2019
        @Discription:             Retrive the Color Varient infromation for a perticular Product.
        @Date Of Modification :   05/08/2019
    */
    @AuraEnabled(cacheable=true)
    public static List<Color_Variant_Master__c> queryColorVarient(String productId){
        
        List<Color_Variant_Master__c> colorVarientList = new List<Color_Variant_Master__c>();
            
        if(isColorVariantAccessPermission()){
            colorVarientList = [SELECT Id, Name, Color_Code__c, Variant__r.ProductCode, Color_Type__c
                                                from Color_Variant_Master__c 
                                                where Variant__c =: productId];
        }
        
        return colorVarientList;
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           05/08/2019
        @Discription:             Retrive the Color Varient infromation for a perticular Product.
        @Date Of Modification :   05/08/2019
    */
    @AuraEnabled(cacheable=true)
    public static Decimal calculateExShowroomPrice(String variantId, String enquiryForCodeId, String paintType, String enquirySalesType){
        
        if (enquirySalesType == null || enquirySalesType == '' || enquirySalesType == 'LEA' || enquirySalesType == 'HCI' || enquirySalesType == 'HNC' || enquirySalesType == 'N2N'){
            enquirySalesType = 'IND';
        }
        decimal exShowRoomPrice = 0.0;
        if(isPriceMasterAccessPermission()){
            Date todayDate = system.today();
            List<Price_Master__c> priceMasterList = [SELECT Id, Name, Amount__c from Price_Master__c 
                                                where Variant_Code__c =: variantId AND (For_Code__c =: enquiryForCodeId OR For_Code__c = null)
                                                AND Color_Type__c =: paintType 
                                                 AND Sales_Type__c =: enquirySalesType
                                                AND From_Date__c <=: todayDate AND To_Date__c >=: todayDate];
                                                
            if(priceMasterList != Null && priceMasterList.size() > 0){
                exShowRoomPrice = priceMasterList[0].Amount__c;
            }
        }
        return exShowRoomPrice;
    }
    
    //Added By-: Nishant Prajapati    Date-: 12/09/2019    Description-: fetch MCP price from MCP master object.
    @AuraEnabled
    public static decimal fetchMCPAmount(string selectedPackage, string selectedValidity, string varientId){
        Date todayDate = system.today();
        Decimal mcpAmount = 0;
        Boolean condition = string.isNotBlank(varientId) && string.isNotBlank(selectedPackage) && string.isNotBlank(selectedValidity);
        if(condition && isMCPMasterAccessPermission()){
            List<MCP_Master__c> mcpMasterList= [select id, Amount__c FROM MCP_Master__c WHERE Package_Description__c=: selectedPackage AND 
                                                Package_Validity__c=: selectedValidity AND From_Date__c <=: todayDate AND To_Date__c >=: todayDate
                                                AND Fuel_Type__c=: varientId];
            
            if(mcpMasterList.size() > 0){
                mcpAmount= mcpMasterList[0].Amount__c;
            }
        }
        return mcpAmount;
        
    }
    
     /*
        @Author:                  Anuj Kumar
        @Created Date :           06/08/2019
        @Discription:             Create Varient lineItem.
        @Date Of Modification :   06/08/2019
    */
    @AuraEnabled
    public static List<PricebookEntry> queryProductPriceBookEntry(String productId){
        
        string priceBookId = queryStandardPriceBookId();
        if(priceBookId != null && isPricebookEntryAccessPermission()){
            return [SELECT Id, Name, Pricebook2Id, Product2Id, UnitPrice, IsActive
                                                    FROM PricebookEntry where
                                                    Pricebook2Id =: priceBookId 
                                                    And Product2Id =: productId
                                                    AND isActive= true];
        }
        return new List<PricebookEntry>();
    }
    
     /*
        @Author:                  Sunit Kumar Chand
        @Created Date :           13/08/2019
        @Discription:             Retrive list of accessories related to that model as per the searche criteria.
        @Date Of Modification :   
    */
    @AuraEnabled
    public static List<Product2> getAccessoriesInfo(String enquiryRecordType, String model, String var, String type){
        
        List<Product2> accessoriesProList = new List<Product2>();
        
        String namevar = '%'+var+'%';
        namevar = String.escapeSingleQuotes(namevar);
        String rid = Schema.Sobjecttype.Product2.getRecordTypeInfosByName().get(ConstantsUtility.ACCESSORIES_CONST).getRecordTypeId();
        
        String query = 'select Id,Name,ProductCode,Minimum_Quantity__c,Maximum_Quantity__c,Applicable_Model__c, Variant_LKP__c, Variant_LKP__r.Name from Product2 Where ';
        if(type == 'Name'){
            if(String.isNotBlank(enquiryRecordType)){
                query += 'RecordTypeId =: rid AND Name Like : namevar AND Variant_LKP__c =: model AND IsActive = True Limit 20';
            }
        }else{
            if(String.isNotBlank(enquiryRecordType) && enquiryRecordType == ConstantsUtility.ACCESSORIES_SALES_CONST){
                query += 'RecordTypeId =: rid AND ProductCode Like : namevar AND IsActive = True Limit 20';
            }else{
                query += 'RecordTypeId =: rid AND ProductCode Like : namevar AND (Variant_LKP__c =: model Or Variant_LKP__c = Null) AND IsActive = True Limit 20';
            }
        }
        
        try{
            if(isProductDiffAccessPermission()){
                accessoriesProList = (List<product2>) dataBase.query(query);
                
                if(type == 'Name' && (accessoriesProList.isEmpty() || accessoriesProList.size() == 0)){
                    String accQuery = 'select Id, Name, ProductCode, Minimum_Quantity__c, Maximum_Quantity__c, Applicable_Model__c ';
                    accQuery += ' from Product2 Where RecordTypeId =: rid AND Name Like : namevar AND Variant_LKP__c = Null Limit 20';
                    
                    accessoriesProList.clear();
                    
                    accessoriesProList = (List<product2>) dataBase.query(accQuery);
                }else if(type != 'Name' && (accessoriesProList.isEmpty() || accessoriesProList.size() == 0)){
                    String accQuery = 'select Id, Name, ProductCode, Minimum_Quantity__c, Maximum_Quantity__c, Applicable_Model__c ';
                    accQuery += ' from Product2 Where RecordTypeId =: rid AND ProductCode Like : namevar AND Variant_LKP__c = Null Limit 20';
                    
                    accessoriesProList.clear();
                    
                    accessoriesProList = (List<product2>) dataBase.query(accQuery);
                }
                
            }
        }catch(Exception ex){ ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace(); ehst.componentName='Add Line Item'; ehst.userId=UserInfo.getUserId(); ExceptionHandler.LogError('AddLineItemCtrl', ex.getMessage(), 'AddLineItemCtrl', '', ehst); }
        
        return accessoriesProList;
    }
    
    /**
        Author: Anuj Kumar
        Company: Techmatrix
        Description: This method will return list of line items from Quote/Opportunity
        Inputs: Object name, Record Id
        Returns: List of line item records (Opportunity/Quote line Items)
        History:
        ================
        1.0     25 Aug 2019      Prabhat     Initial Version
    */
    @AuraEnabled
    public static SObjectDetails queryParentLineItemSummaryField(String recordId, String sobjectName){
        SObjectDetails details = new SObjectDetails();
        
        // Fetch valid amount information from Custom Setting
        OtherAmountValidation__c mc = OtherAmountValidation__c.getOrgDefaults();
        details.amountValidation = mc;
        
        // Fetch Offer fields configuration details from Custom Setting
        Offer_Fields_Configuration__c offerFields = Offer_Fields_Configuration__c.getOrgDefaults();
        details.offerFieldsConfig = offerFields;
        
        List<sObject> parentObjRecordList = new List<sObject>();
        
        List<sObject> childObjRecordList = new List<sObject>();
        
        String lineItemSummary = '';
        String objectFields = '';
        if(String.isNotBlank(sobjectName) && sobjectName == ConstantsUtility.OPPORTUNITY && String.isNotBlank(system.label.Opportunity_Fields)){
            objectFields = system.label.Opportunity_Fields;
        }else if(String.isNotBlank(sobjectName) && sobjectName == ConstantsUtility.QUOTE && String.isNotBlank(system.label.Quote_Fields)){
            objectFields = system.label.Quote_Fields;
        }
        
        String query = 'SELECT Id, Line_Item_Summary__c, '+objectFields+ ' FROM '+sobjectName;
        query+=' WHERE Id =: recordId';
        
        String childRecordQuery = 'SELECT Id From '+sobjectName+'LineItem Where '+sobjectName+'Id =: recordId';

        try{
            parentObjRecordList = Database.query(query);
            
            childObjRecordList = Database.query(childRecordQuery);
            
            if(parentObjRecordList != Null && parentObjRecordList.size()> 0){
                details.obj = parentObjRecordList[0];
                lineItemSummary = (parentObjRecordList[0].get(ConstantsUtility.LINE_ITEM_SUMMARY_FIELD) != Null || parentObjRecordList[0].get(ConstantsUtility.LINE_ITEM_SUMMARY_FIELD) != '') ? string.valueOf(parentObjRecordList[0].get(ConstantsUtility.LINE_ITEM_SUMMARY_FIELD)) : '';
            }else{
                lineItemSummary = '';
            }
            
            if(childObjRecordList.size() > 0 && (lineItemSummary == null || lineItemSummary == '')){
                lineItemSummary = GenerateJSONFromLineItems.generateJSONForEnquiry(recordId);
                lineItemSummary = formatJSONData(lineItemSummary);
                details.lineItemSummary = lineItemSummary;
                return details;
            }else{
                lineItemSummary = formatJSONData(lineItemSummary);
                
                details.lineItemSummary = lineItemSummary;
            
                return details;
            }
            
            
        }catch(Exception ex){ lineItemSummary = ''; return new SObjectDetails(); }
        
    }
    
    public static string formatJSONData(String lineItemSummary){
        
        if(lineItemSummary != null && lineItemSummary != ''){
            if(lineItemSummary.contains(ConstantsUtility.DOUBLE_BACK_SLASH)){
               lineItemSummary = lineItemSummary.replace(ConstantsUtility.DOUBLE_BACK_SLASH, ConstantsUtility.BLANK_VALUE);
            }
            
            if(lineItemSummary.contains(ConstantsUtility.OPEN_DOUBLE_QUOTE_CURLY_BRACES)){
               lineItemSummary = lineItemSummary.replace(ConstantsUtility.OPEN_DOUBLE_QUOTE_CURLY_BRACES, ConstantsUtility.OPEN_CURLY_BRACES);
            }
            
            if(lineItemSummary.contains(ConstantsUtility.CLOSE_DOUBLE_QUOTE_CURLY_BRACES)){
               lineItemSummary = lineItemSummary.replace(ConstantsUtility.CLOSE_DOUBLE_QUOTE_CURLY_BRACES, ConstantsUtility.CLOSE_CURLY_BRACES);
            }
            
            if(lineItemSummary.contains(ConstantsUtility.OPEN_DOUBLE_QUOTE_SQUARE_BRACKET)){
               lineItemSummary = lineItemSummary.replace(ConstantsUtility.OPEN_DOUBLE_QUOTE_SQUARE_BRACKET, ConstantsUtility.OPEN_SQUARE_BRACKET);
            }
            
            if(lineItemSummary.contains(ConstantsUtility.CLOSE_DOUBLE_QUOTE_SQUARE_BRACKET)){
               lineItemSummary = lineItemSummary.replace(ConstantsUtility.CLOSE_DOUBLE_QUOTE_SQUARE_BRACKET, ConstantsUtility.CLOSE_SQUARE_BRACKET);
            }
        }
        lineItemSummary = lineItemSummary != null ? lineItemSummary : '';
        return lineItemSummary;
    }
    
    
    /**
        Author: Anuj Kumar
        Company: Techmatrix
        Description: This method will return the quote record Id with message.
        Inputs: Component JSON structure 
        Returns: Quote record Id with message.
        History:
        ================
        1.0     25 Aug 2019      Prabhat     Initial Version
    */
    @AuraEnabled
    public static String generateQuotation(String dataList){

        String message = '';
        Map<String, Object> mainDataMap = (Map<String, Object>)JSON.deserializeUntyped(dataList);
        
        Map<String, Object> exShowRoomVariantMap = (Map<String, Object>) mainDataMap.get(ConstantsUtility.EX_SHOWROOM_VARIANT_KEY);
        
        String enquiryId = '';
        if(exShowRoomVariantMap != Null && exShowRoomVariantMap.size() > 0){
            enquiryId = exShowRoomVariantMap.containsKey(ConstantsUtility.OPPORTUNITY_ID_KEY) ? string.valueOf(exShowRoomVariantMap.get(ConstantsUtility.OPPORTUNITY_ID_KEY)) : null;
        }
        Map<String, Object> opportunityInfoMap = (Map<String, Object>) mainDataMap.get(ConstantsUtility.OPPORTUNITY_INFO_KEY);
        
        Map<String, Object> selectedVariantMap = (Map<String, Object>) mainDataMap.get(ConstantsUtility.SELECTED_VARIANT_KEY);
        
        Quote qot = new Quote();
        if(enquiryId != null && enquiryId != ''){
        
            Integer dtYear = Date.Today().Year();
            Integer dtMonth = Date.Today().Month();
            Integer dtDay = Date.Today().Day();
            
            string nameData = opportunityInfoMap.containsKey(ConstantsUtility.NAME_CONST) ? String.valueOf(opportunityInfoMap.get(ConstantsUtility.NAME_CONST)) : '';
            
            string modalName = '';
            if(selectedVariantMap != null && selectedVariantMap.size() > 0){
                modalName = selectedVariantMap.containsKey(ConstantsUtility.NAME_CONST) ? String.valueOf(selectedVariantMap.get(ConstantsUtility.NAME_CONST)) : '';
            }
            nameData += '_'+modalName+'_'+dtDay+'/'+dtMonth+'/'+dtYear;
            
            qot.Name = nameData;
            qot.Pricebook2Id = opportunityInfoMap.containsKey(ConstantsUtility.PRICEBOOK2_ID_CONST) ? String.valueOf(opportunityInfoMap.get(ConstantsUtility.PRICEBOOK2_ID_CONST)) : Null;
            qot.Email = opportunityInfoMap.containsKey(ConstantsUtility.EMAIL_CONST) ? String.valueOf(opportunityInfoMap.get(ConstantsUtility.EMAIL_CONST)) : Null;
            qot.Phone = opportunityInfoMap.containsKey(ConstantsUtility.Mobile_CONST) ? String.valueOf(opportunityInfoMap.get(ConstantsUtility.Mobile_CONST)) : Null;
            
            qot.Variant__c = selectedVariantMap.containsKey(ConstantsUtility.ID_CONST) ? String.valueOf(selectedVariantMap.get(ConstantsUtility.ID_CONST)) : '';
            qot.opportunityId = enquiryId;
            try{
                if(isQuoteCreatePermission()){
                    insert qot;
                }
                if(qot.Id != null){
                    
                    // Need to store the count of quotation related to the enquiry.
                    
                    TriggerHandler.bypass('OpportunityTriggerHandler');
                    update (new Opportunity(Id = enquiryId, 
                            Quotations_count__c = [Select count() from quote Where opportunityId =: enquiryId ]));
                    TriggerHandler.clearBypass('OpportunityTriggerHandler');
                    
                    // To Generate the Quote Line Items
                    message = generateLineItemRecords(dataList, qot.Id);
                    if(message == 'success'){
                        return qot.Id+'#'+message;
                    }
                }
            }catch(Exception ex){
                ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace();ehst.componentName='Add Line Item';ehst.userId=UserInfo.getUserId();ExceptionHandler.LogError('AddLineItemCtrl', ex.getMessage(), 'AddLineItemCtrl', '', ehst);
            }
        }    
        
        return message;
    }
    
    @AuraEnabled(cacheable=true)
    public static String queryOffersSchemesDetails(String dataList){
        return OfferSchemeCalcSrvc.retiveOfferAndSchemes(dataList);    
    }
    
    @AuraEnabled
    public static string generateLineItemRecords(String dataList, string parentSobjectId){
        
        if(parentSobjectId == ''){
            dataList = RefreshEnquiryPrice.updateEnquiryPrice(dataList);
        }
        return PriceCalcSrvc.calculateLineItemInfo(dataList, parentSobjectId);
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           20/Sep/2019
        @Discription:             Wrapper class used to return the sObject Details.
        @Date Of Modification :   20/Sep/2019
    */
    public class SObjectDetails{
        
        @AuraEnabled public string lineItemSummary;
        @AuraEnabled public sObject obj;
        @AuraEnabled public OtherAmountValidation__c amountValidation;
        @AuraEnabled public Offer_Fields_Configuration__c offerFieldsConfig;
    }
    
    
    /*******       TO Handle The Object And Field Permissions    ********/
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           16/09/2019
        @Discription:             To Check the access permissions for Product.
        @Date Of Modification :   16/09/2019
    */
    public static Boolean isProductAccessPermission(){
        if(CheckObjectAndField.objectCURDPermission('Product2', ConstantsUtility.IsAccessible) && 
           CheckObjectAndField.fieldCURDPermission('Product2', ConstantsUtility.IsAccessible, 'Name') && 
           CheckObjectAndField.fieldCURDPermission('Product2', ConstantsUtility.IsAccessible, 'Extended_Warranty_1_year__c') && 
           CheckObjectAndField.fieldCURDPermission('Product2', ConstantsUtility.IsAccessible, 'Extended_Warranty_2_year__c') && 
           CheckObjectAndField.fieldCURDPermission('Product2', ConstantsUtility.IsAccessible, 'Extended_Warranty_3_year__c') && 
           CheckObjectAndField.fieldCURDPermission('Product2', ConstantsUtility.IsAccessible, 'Loyalty_Amount__c') && 
           CheckObjectAndField.fieldCURDPermission('Product2', ConstantsUtility.IsAccessible, 'Fuel_Type__c') && 
           CheckObjectAndField.fieldCURDPermission('Product2', ConstantsUtility.IsAccessible, 'Family')){
            return True;
        }else{
            return false;
        }
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           16/09/2019
        @Discription:             To Check the access permissions for Product.
        @Date Of Modification :   16/09/2019
    */
    public static Boolean isProductDiffAccessPermission(){
        if(CheckObjectAndField.objectCURDPermission('Product2', ConstantsUtility.IsAccessible) && 
           CheckObjectAndField.fieldCURDPermission('Product2', ConstantsUtility.IsAccessible, 'Name') && 
           CheckObjectAndField.fieldCURDPermission('Product2', ConstantsUtility.IsAccessible, 'ProductCode') && 
           CheckObjectAndField.fieldCURDPermission('Product2', ConstantsUtility.IsAccessible, 'Minimum_Quantity__c') && 
           CheckObjectAndField.fieldCURDPermission('Product2', ConstantsUtility.IsAccessible, 'Maximum_Quantity__c') && 
           CheckObjectAndField.fieldCURDPermission('Product2', ConstantsUtility.IsAccessible, 'Applicable_Model__c')){
            return True;
        }else{
            return false;
        }
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           16/09/2019
        @Discription:             To Check the access permissions for ColorVariant.
        @Date Of Modification :   16/09/2019
    */
    public static Boolean isColorVariantAccessPermission(){
        if(CheckObjectAndField.objectCURDPermission('Color_Variant_Master__c', ConstantsUtility.IsAccessible) &&
           CheckObjectAndField.fieldCURDPermission('Color_Variant_Master__c', ConstantsUtility.IsAccessible, 'Name') && 
           CheckObjectAndField.fieldCURDPermission('Color_Variant_Master__c', ConstantsUtility.IsAccessible, 'Color_Code__c') && 
           CheckObjectAndField.fieldCURDPermission('Color_Variant_Master__c', ConstantsUtility.IsAccessible, 'Variant__c')){
            return True;
        }else{
            return false;
        }
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           16/09/2019
        @Discription:             To Check the access permissions for Price Master.
        @Date Of Modification :   16/09/2019
    */
    public static Boolean isPriceMasterAccessPermission(){
        if(CheckObjectAndField.objectCURDPermission('Price_Master__c', ConstantsUtility.IsAccessible) &&
           CheckObjectAndField.fieldCURDPermission('Price_Master__c', ConstantsUtility.IsAccessible, 'Name') && 
           CheckObjectAndField.fieldCURDPermission('Price_Master__c', ConstantsUtility.IsAccessible, 'Amount__c')){
            return True;
        }else{
            return false;
        }
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           16/09/2019
        @Discription:             To Check the access permissions for MCP Master.
        @Date Of Modification :   16/09/2019
    */
    public static Boolean isMCPMasterAccessPermission(){
        if(CheckObjectAndField.objectCURDPermission('MCP_Master__c', ConstantsUtility.IsAccessible) &&
           CheckObjectAndField.fieldCURDPermission('MCP_Master__c', ConstantsUtility.IsAccessible, 'Package_Description__c') && 
           CheckObjectAndField.fieldCURDPermission('MCP_Master__c', ConstantsUtility.IsAccessible, 'Amount__c') && 
           CheckObjectAndField.fieldCURDPermission('MCP_Master__c', ConstantsUtility.IsAccessible, 'Package_Validity__c') && 
           CheckObjectAndField.fieldCURDPermission('MCP_Master__c', ConstantsUtility.IsAccessible, 'From_Date__c') && 
           CheckObjectAndField.fieldCURDPermission('MCP_Master__c', ConstantsUtility.IsAccessible, 'To_Date__c') && 
           CheckObjectAndField.fieldCURDPermission('MCP_Master__c', ConstantsUtility.IsAccessible, 'Fuel_Type__c')){
            return True;
        }else{
            return false;
        }
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           16/09/2019
        @Discription:             To Check the access permissions for Quote.
        @Date Of Modification :   16/09/2019
    */
    public static Boolean isQuoteCreatePermission(){
        if(CheckObjectAndField.objectCURDPermission('Quote', ConstantsUtility.IsCreateable) && 
           CheckObjectAndField.fieldCURDPermission('Quote', ConstantsUtility.IsCreateable, 'Name') && 
           CheckObjectAndField.fieldCURDPermission('Quote', ConstantsUtility.IsCreateable, 'Pricebook2Id') && 
           CheckObjectAndField.fieldCURDPermission('Quote', ConstantsUtility.IsCreateable, 'Email') && 
           CheckObjectAndField.fieldCURDPermission('Quote', ConstantsUtility.IsCreateable, 'Phone') && 
           CheckObjectAndField.fieldCURDPermission('Quote', ConstantsUtility.IsCreateable, 'Variant__c') && 
           CheckObjectAndField.fieldCURDPermission('Quote', ConstantsUtility.IsCreateable, 'opportunityId')){
            return True;
        }else{
            return false;
        }
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           02/09/2019
        @Discription:             To Check the access permissions for PricebookEntry.
        @Date Of Modification :   02/09/2019
    */
    public static Boolean isPricebookEntryAccessPermission(){
        if(CheckObjectAndField.objectCURDPermission('PricebookEntry', ConstantsUtility.IsAccessible) && 
           CheckObjectAndField.fieldCURDPermission('PricebookEntry', ConstantsUtility.IsAccessible, 'Name') && 
           CheckObjectAndField.fieldCURDPermission('PricebookEntry', ConstantsUtility.IsAccessible, 'Pricebook2Id') && 
           CheckObjectAndField.fieldCURDPermission('PricebookEntry', ConstantsUtility.IsAccessible, 'Product2Id') && 
           CheckObjectAndField.fieldCURDPermission('PricebookEntry', ConstantsUtility.IsAccessible, 'UnitPrice') && 
           CheckObjectAndField.fieldCURDPermission('PricebookEntry', ConstantsUtility.IsAccessible, 'IsActive'))
       {
           return True;
       }else{
           return false;
       }
    }
}