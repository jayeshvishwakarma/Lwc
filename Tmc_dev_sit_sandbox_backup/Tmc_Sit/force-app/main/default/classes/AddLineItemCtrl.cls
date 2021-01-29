/**
 * @File Name : AddLineItemCtrl.cls
 * @Description : This class is used to create LineItem for the related records.
 * @Author : Anuj Kumar
 * @Group : 
 * @Last Modified By : Rajesh Ramachandran
 * @Last Modified On : 1/7/2020, 6:02:43 AM
 * @Modification Log : 
 *==============================================================================
 * Ver Date Author Modification
 *==============================================================================
 * 1.0 05/08/2019 11:17 AM Anuj Kumar Initial Version
**/

public with sharing class AddLineItemCtrl {
 
    /*
    @Author: Anuj Kumar
    @Created Date : 05/08/2019
    @Discription: Search the Model Varient infromation from a perticular Model Name.
    @Date Of Modification : 05/08/2019
    */
    @AuraEnabled(cacheable=true)
    public static List<Product2> retriveModelVarient(String name, String modelName, String channel){
    
    if(String.isNotBlank(name)){ 
    return AddLineItemCtrlHelper.queryModelVarient(name, modelName, channel); 
    }
    
    return new List<product2>();
    }
    
    /*
    @Author: Anuj Kumar
    @Created Date : 05/08/2019
    @Discription: Retrive the Color Varient infromation for a perticular Product.
    @Date Of Modification : 05/08/2019
    */
    @AuraEnabled(cacheable=true)
    public static List<Color_Variant_Master__c> retriveColorVarient(String productId){
    
    if(String.isNotBlank(productId)){ 
    return AddLineItemCtrlHelper.queryColorVarient(productId); 
    }
    
    return new List<Color_Variant_Master__c>();
    }
    
    
    /*
    @Author: Anuj Kumar
    @Created Date : 05/08/2019
    @Discription: Retrive the Color Varient infromation for a perticular Product.
    @Date Of Modification : 05/08/2019
    */
    @AuraEnabled(cacheable=true)
    public static Decimal retriveExShowroomPrice(String variantId, String enquiryForCodeId, String paintType, String enquirySalesType){
    
    Decimal amount = 0.0;
    //&& String.isNotBlank(enquirySalesType)
    if(String.isNotBlank(variantId) && String.isNotBlank(enquiryForCodeId) && String.isNotBlank(paintType)){
    return AddLineItemCtrlHelper.calculateExShowroomPrice(variantId, enquiryForCodeId, paintType, enquirySalesType);
    } 
    return amount;
    }
    
    /*
    @Author: Anuj Kumar
    @Created Date : 06/08/2019
    @Discription: Create Varient lineItem.
    @Date Of Modification : 06/08/2019
    */
    @AuraEnabled
    public static String fetchVariantProducts(String productId){
    
    if(String.isNotBlank(productId)){
    
    List<PricebookEntry> priceBookEntryList = AddLineItemCtrlHelper.queryProductPriceBookEntry(productId);
    if(priceBookEntryList != Null && priceBookEntryList.size() > 0){
    return priceBookEntryList[0].Id;
    }else{
    List<Pricebook2> priceBookDetail = new List<Pricebook2>([select id, name from Pricebook2 where isStandard = true limit 1]);
    if(priceBookDetail != null && priceBookDetail.size() > 0){
    PricebookEntry pbe = new PricebookEntry (Pricebook2Id = priceBookDetail[0].Id, Product2Id = productId, IsActive = true, UnitPrice = 0, UseStandardPrice = false);
    insert pbe;
    
    return pbe.Id;
    }else{
    return 'No PriceBook Found.';
    }
    }
    }
    return 'No PriceBook Found.';
    }
    
    
    /*
    @Author: Sunit Kumar Chand
    @Created Date : 13/08/2019
    @Discription: Retrive list of accessories related to that model as per the searche criteria.
    @Date Of Modification : 
    */
    @AuraEnabled
    public static BasicReturn getAccessories(String enquiryRecordType, String model,String var,String type){
    BasicReturn br = new BasicReturn();
    try{
    List<Product2> accessList = AddLineItemCtrlHelper.getAccessoriesInfo(enquiryRecordType, model, var, type);
    
    if(accessList != Null && accessList.size() > 0){
    br.code = 200;
    br.message = 'Success';
    br.status = 'Success';
    br.dataList = accessList;
    }else{
    br.code = 0;
    br.message = 'No Data Found';
    br.status = 'Failed';
    }
    }catch(Exception e){
    br.code = 0; br.message=e.getMessage(); br.status='Failed'; ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace();ehst.componentName='Add Line Item'; ehst.userId=UserInfo.getUserId(); ExceptionHandler.LogError('AddLineItemCtrl', e.getMessage(), 'AddLineItemCtrl', '', ehst);
    }
    return br;
    }
    
    /*
    @Author: Sunit Kumar Chand
    @Created Date : 13/08/2019
    @Discription: Retrive list of accessories related to that model as per the searche criteria.
    @Date Of Modification : 
    */
    @AuraEnabled
    public static BasicReturn getAccessoryPrice(String productId){
    BasicReturn br=new BasicReturn();
    try{
    List<PricebookEntry> priceBookEntryList = AddLineItemCtrlHelper.queryProductPriceBookEntry(productId);
    if(priceBookEntryList != Null && priceBookEntryList.size() > 0){
    br.code = 200;
    br.message = 'Success';
    br.status = 'Success';
    br.dataList = priceBookEntryList;
    }else{
    br.code = 0;
    br.message = 'No Data Found';
    br.status = 'Failed';
    }
    }catch(Exception e){
    br.code = 0;br.message = e.getMessage();br.status = 'Failed';ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();ehst.componentName = 'Add Line Item';ehst.userId = UserInfo.getUserId();ExceptionHandler.LogError('AddLineItemCtrl', e.getMessage(), 'AddLineItemCtrl', '', ehst); 
    }
    return br;
    }
    
    
    /**
    Author: Prabhat Sharma
    Company: Techmatrix
    Description: This method will return list of line items from Quote/Opportunity
    Inputs: Object name, Record Id
    Returns: List of line item records (Opportunity/Quote line Items)
    History:
    ================
    1.0 19 Aug 2019 Prabhat Initial Version
    */
    @AuraEnabled
    public static Object queryLineItemDetail(String recordId, String sobjectName){
    
    return AddLineItemCtrlHelper.queryParentLineItemSummaryField(recordId, sobjectName);
    }
    
    /*
    @Author: Rajesh Ramachandran
    @Created Date : 18/08/2019
    @Discription: Derive details of offers and Schemes
    @Date Of Modification : 
    */
    @AuraEnabled(cacheable=true)
    public static String retriveOffersSchemes(String dataList){
    return AddLineItemCtrlHelper.queryOffersSchemesDetails(dataList);
    }
    
    @AuraEnabled
    public static SObject createChildSObjectInstance(String sObjectName){
    return Schema.getGlobalDescribe().get(sObjectName).newSObject();
    }
    
    /*
    @Author: Anuj Kumar
    @Created Date : 14/08/2019
    @Discription: Create Line Item for related Object.
    @Date Of Modification : 
    */
    @AuraEnabled
    public static string createLineItemRecords(String dataList, string parentSobjectId){
    return AddLineItemCtrlHelper.generateLineItemRecords(dataList, parentSobjectId);
    }
    
    /*
    @Author: Anuj Kumar
    @Created Date : 25/09/2019
    @Discription: Method to get the updated Amount from Opportunity.
    @Date Of Modification : 
    */
    @AuraEnabled
    public static SObjectDetails retriveOpportunityAmount(String recordId){
    SObjectDetails obj = new SObjectDetails();
    Decimal oppAmount = 0.0;
    if(string.isNotBlank(recordId)){
    List<Opportunity> oppList = new List<Opportunity>([Select id, Amount, Line_Item_Summary__c from Opportunity where Id =: recordId]);
    if(oppList != null && oppList.size() > 0){
    oppAmount = oppList[0].Amount;
    obj.amount = oppAmount;
    obj.lineItemSummary = oppList[0].Line_Item_Summary__c;
    }
    }
    return obj;
    }
    
    /*
    @Author: Anuj Kumar
    @Created Date : 19-Nov-2019
    @Discription: Method To Fetch Enq Model dependent on Dealership Channel picklist value.
    @Date Of Modification : 19-Nov-2019
    */
    @AuraEnabled(cacheable=true)
    public static List<String> retriveEnqModelList(String recordId){
    
    List<Opportunity> opp = new List<Opportunity>([Select id, Dealership_Channel__c from Opportunity where Id =: recordId]);
    if(opp != Null && opp.size() > 0){
    String dealerShipChannel = opp[0].Dealership_Channel__c;
    Map<String, List<String>> dependentEnqModalMap = new Map<String, List<String>>();
    
    if(String.isNotBlank(dealerShipChannel)){
    Opportunity oppt = new Opportunity();
    dependentEnqModalMap = RetriveDependentPicklistData.getDependentMap(oppt, ConstantsUtility.FIELD_DEALERSHIP_CHANNEL, ConstantsUtility.FIELD_ENQ_MODEL);
    
    if(dependentEnqModalMap.containsKey(dealerShipChannel)){
    return dependentEnqModalMap.get(dealerShipChannel);
    }
    }
    }
    return new List<String>();
    
    }
    
    /*
    @Author: Anuj Kumar
    @Created Date : 21-Nov-2019
    @Discription: Get Consumer Offer details for Variant
    @Date Of Modification : 21-Nov-2019
    */
    @AuraEnabled(cacheable=true)
    public static Map<String, Product2> retriveConsumerOffer(String forCode, String fuelType, String model, String schemeRegion, String state, String selectedVariant){
    
    if(String.isNotBlank(forCode)){ 
    return AddLineItemCtrlHelper.queryConsumerOfferDetails(forCode, fuelType, model, schemeRegion, state, selectedVariant); 
    }
    
    return new Map<String, Product2>();
    }
    
    
    @AuraEnabled
    public static OtherAmountValidation__c getOtherAmount(){
    OtherAmountValidation__c mc = OtherAmountValidation__c.getOrgDefaults();
    return mc;
    }
    
    /*
    @Author: Anuj Kumar
    @Created Date : 26/Sep/2019
    @Discription: Wrapper class used to return the sObject Details.
    @Date Of Modification : 26/Sep/2019
    */
    public class SObjectDetails{
    
    @AuraEnabled public string lineItemSummary;
    @AuraEnabled public decimal amount;
    }
    

      /*
    @Author: Deepak Kumar
    @Created Date : 28/May/2020
    @Discription: To get the non static values of ConstantsUtility variable to used on the component
    @Date Of Modification : 28/May/2020
    */
    @AuraEnabled
    public static ConstantsUtility getConstants(){
        return new ConstantsUtility();
    }
   }