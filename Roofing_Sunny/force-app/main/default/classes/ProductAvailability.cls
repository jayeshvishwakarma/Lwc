/*********************************************************************************
* {Type} Class: {ProductAvailability}
* Created by {Madan}, Navivo, {DateCreated 09/2/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Search functionality based on Territory, Plant, Market Class, Product Type, Item Description using REST Technology.}
----------------------------------------------------------------------------------
* Unit Test: {TestProductAvailability}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Madan 9/4/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
3.0 Dru Luce-Edwards 1-30-2017: Updated to use WS class for callout
*********************************************************************************/

public with sharing class ProductAvailability {

    public List<ProductAvailabilityResponse> lstProductAvailabilityResponse {get;set;}
    public WS.StockAvailabiltyResponse stockAvailResponse {get;set;}
    public List<WS.StockAvailSuccess> getLstSuccesses(){
        List<WS.StockAvailSuccess> lstReturn = null;
        if(stockAvailResponse != null && stockAvailResponse.lstSuccesses != null){
            lstReturn = new List<WS.StockAvailSuccess>();
            Integer intNonNullItems = 0;
            for(WS.StockAvailSuccess sas : stockAvailResponse.lstSuccesses){
                if(sas.strMaterial != null){
                    intNonNullItems++;
                    lstReturn.add(sas);
                } else if(intNonNullItems <= 1){
                    lstReturn.add(sas);
                }
            }
        }
        return lstReturn;
    }
    private ProductAvailabilityRequest productAvailabilityRequest {get;set;}
    public Boolean isSearchResultView {get;set;}
    public transient String displayMsg {get;set;}
    
    public String territoryId {get;set;}
    public String territoryType {get;set;}
    public String plantId {get;set;}
    public String marketClassId {get;set;}
    public String productTypeId {get;set;}
    public String itemDescriptionId {get;set;}
    
    public List<SelectOption> territoryTypeOption {get;set;}
    public List<SelectOption> territoriesOption {get;set;}
    public List<SelectOption> plantesOption {get;set;}
    public List<SelectOption> marketClassesOption {get;set;}
    public List<SelectOption> productTypesOption {get;set;}
    public List<SelectOption> itemDescriptionOption {get;set;}
    
    public User userInfo {get; set;}
    
    public ProductAvailability(){
        try{
            userInfo = UtilityClass.userDetail;
            
            territoryId = null;
            plantId = null;
            marketClassId = null;
            productTypeId = null;
            itemDescriptionId = null;
            territoryType = null;
            //lstProductAvailabilityResponse = new List<ProductAvailabilityResponse>();
            stockAvailResponse = null;
            
            territoriesOption = territories();
            
            plantesOption = plantes();
            //marketClassesOption = marketClasses();
          //  productTypesOption = productTypes();
            itemDescriptionOption = itemDescription();
        }
        catch(Exception ex){
            System.debug('Exception:::' + ex.getMessage());
        }
    }
    
    //called below method on page load
    public Pagereference onPageLoad(){
        if(ApexPages.currentPage().getParameters().containsKey('territoryType')){
            territoryType = ApexPages.currentPage().getParameters().get('territoryType');
            isSearchResultView = true;
        }else if(territoriesOption.size() == 2 && (ApexPages.currentPage().getParameters().get('territoryId') == '' || ApexPages.currentPage().getParameters().get('territoryId') == null)){
            territoryId = territoriesOption[1].getValue();
            territoryType = [Select Type__c from Territory__c where id =: territoryId].Type__c;
            isSearchResultView = true;
            Pagereference pr = new Pagereference('/apex/ProductAvailability?territoryId=' + territoryId);
            pr.setRedirect(true);
            return pr;
        }else if(ApexPages.currentPage().getParameters().get('territoryId') != '' && ApexPages.currentPage().getParameters().get('territoryId') != null){
            territoryId = ApexPages.currentPage().getParameters().get('territoryId');
            territoryType = [Select Type__c from Territory__c where id =: territoryId].Type__c;
            isSearchResultView = true;
        }
        
        plantesOption = plantes();
      //  marketClassesOption = marketClasses();
       // productTypesOption = productTypes();
        itemDescriptionOption = itemDescription();
        
        return null;
    }
    
    //Get Territories Option List which are permitted to current Logged in User
    public Map<String, List<Territory__c>> territoryTypeMap {get; set;}
    public List<SelectOption> territories(){
        try{
            territoryTypeMap = new Map<String, List<Territory__c>>();
            territoryTypeOption = new List<SelectOption>();
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','--Select--'));
            if(userInfo.Role__c != null){
                String userID = userInfo.Id;
              /*  String query = 'Select Id, Territory__r.Type__c, Territory__r.Region__c, Territory__c, '+                ' Territory__r.Name From Hierarchy_Matrix__c ';
                if(userInfo.Role__c != Constants.ROLE_VP){
                    query += ' Where '+userInfo.Role__c+'__c = :userID ';
                    // Added below if condition to handle multiple PC (PC #1 and PC #2)
                    if(userInfo.Role__c == Constants.ROLE_PC){
                        query += ' OR '+userInfo.Role__c+'_2__c =: userID';
                    }
                }
                query += ' ORDER BY Territory__r.Type__c DESC'; 
                for(Hierarchy_Matrix__c hMatrix : Database.query(query)){
                    if(!territoryTypeMap.containsKey(hMatrix.Territory__r.Type__c)){
                        territoryTypeMap.put(hMatrix.Territory__r.Type__c, new List<Territory__c>());
                        territoryTypeOption.add(new SelectOption(hMatrix.Territory__r.Type__c, hMatrix.Territory__r.Type__c));
                    } 
                   territoryTypeMap.get(hMatrix.Territory__r.Type__c).add(hMatrix.Territory__r);
                    options.add(new SelectOption(hMatrix.Territory__c, hMatrix.Territory__r.Name));
                }*/
            }
            
            return options;
        }catch(Exception ex){ ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,ex.getMessage())); return null;}
    }
    
    //Get Plant Option List
    public List<SelectOption> plantes(){
        try{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','--Select--'));
            List<Territory__c> territoryList = new List<Territory__c>();
            if(territoryId != null && territoryId != ''){
                if(userInfo.Role__c == Constants.ROLE_TM){
                    //territoryList = UtilityClass.ProductAvailabilityTMTrerritories(territoryId);
                    territoryList = [Select Id, Name, Type__c From Territory__c WHERE Id = :territoryId];
                }else{
                    territoryList.add(new Territory__c(Id=territoryId));
                }
            }else if(territoryType != null && territoryType != '' && territoryTypeMap.containsKey(territoryType)){
                territoryList = territoryTypeMap.get(territoryType);
            }
            if(territoryList.size() > 0){
                Set<String> warehouseIds = new Set<String>();
                  
                if(territoryId != null && territoryId != ''){
                    for(Territory_Warehouse__c tw : [Select t.Plant__c, t.Territory__c, t.Name From Territory_Warehouse__c t where t.Territory__c IN :territoryList]){
                        warehouseIds.add(tw.Plant__c);
                    }
                    for(Plants__c w : [Select w.Plant_code__c, w.Id From Plants__c w where w.Id in: warehouseIds order By Plant_code__c Limit 1000]){
                        options.add(new SelectOption(w.Id, w.Plant_code__c));
                    }
                }
                else{
                    for(Plants__c w : [Select w.Plant_code__c, w.Id From Plants__c w Where Warehouse_Status__c = 'Active' order By Plant_code__c Limit 1000]){
                        options.add(new SelectOption(w.Id, w.Plant_code__c));
                    }
                }
            }
            return options;
        }catch(Exception ex){ 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,ex.getMessage()));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,ex.getStackTraceString())); 
            return null;
        }
    }
    
    //Get Market Classe Option List
    /*public List<SelectOption> marketClasses(){
        try{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','--Select--'));
           /* String soql = 'Select m.Name, m.Id From Market_Class__c m ';
            soql += 'where Hidden_in_App__c = false ';
            if(userInfo.Role__c != Constants.ROLE_TM){
                soql += 'and Type__c =: territoryType ';
            }
            soql += 'order By Name';
           for(Market_Class__c m : (List<Market_Class__c>)Database.query(soql)){
                options.add(new SelectOption(m.Id, m.Name));
            }
            return options;
        }catch(Exception ex){ ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,ex.getMessage())); return null;}
    }
    
    //Get Product Type Option List
    public List<SelectOption> productTypes(){
        try{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','--Select--'));
            if(marketClassId != null && marketClassId != '' && plantId != null && plantId != ''){
                
               // Map<Id, Product_Type_Stocked_Plant__c> mapProductTypeStockedPlant = new Map<Id, Product_Type_Stocked_Plant__c>([Select p.Stocked_Plant__r.Plant_Code__c, p.Stocked_Plant__c, p.Product_Type__r.Market_Class__c, p.Product_Type__r.Name, p.Product_Type__c From Product_Type_Stocked_Plant__c p where p.Stocked_Plant__c =: plantId and  p.Product_Type__r.Market_Class__c =: marketClassId Order By p.Product_Type__r.Name]);
                
                //System.debug('Product Type Stocked Plant::: ' + mapProductTypeStockedPlant + ', PlantId:::' + plantId + ', MarketClassId:::' + marketClassId);
                
                Set<Id> ids = new Set<Id>();
                for(Product_Type_Stocked_Plant__c ptsPlant : mapProductTypeStockedPlant.values()){
                    if(!ids.contains(ptsPlant.Product_Type__c)){
                        ids.add(ptsPlant.Product_Type__c);
                        options.add(new SelectOption(ptsPlant.Product_Type__c, ptsPlant.Product_Type__r.Name)); 
                    }
                }
            }
            return options;
        }catch(Exception ex){ ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,ex.getMessage())); return null;}
    }*/
    
    //Get Item Description Option List
    public List<SelectOption> itemDescription(){
        try{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','--Select--'));
            /*if(productTypeId != null && productTypeId != '' && plantId != null && plantId != ''){
                
                Map<Id, Product_Stocked_Plant__c> mapProductStockedPlant = new Map<Id, Product_Stocked_Plant__c>([Select p.Stocked_Plant__c, p.Product__r.Name, p.Product__r.Product_Type__c, p.Product__c , p.Product__r.ProductCode  From Product_Stocked_Plant__c p where p.Stocked_Plant__c =: plantId and  p.Product__r.Product_Type__c =: productTypeId Order By p.Product__r.Name]);
                
                System.debug('Product Stocked Plant::: ' + mapProductStockedPlant + ', PlantId:::' + plantId + ', Product Type Id:::' + productTypeId);
                
                Set<Id> ids = new Set<Id>();
                for(Product_Stocked_Plant__c psPlant : mapProductStockedPlant.values()){
                    if(!ids.contains(psPlant.Product__c)){
                        ids.add(psPlant.Product__c);
                        options.add(new SelectOption(psPlant.Product__c, psPlant.Product__r.Name));
                    }
                }
            }*/
            return options;
        }catch(Exception ex){ ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,ex.getMessage())); return null;}
    }
    
    //Set Search Result Panel
    public void showSearchResultView(){
        isSearchResultView = true;
    }
    
    //Search Callout on the basis of selected attributes
    public void searchProducts(){
        try{
            
            /*lstProductAvailabilityResponse = new List<ProductAvailabilityResponse>();
            
            if(plantId == null || plantId == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please select Plant'));
                return;
            }
            if(itemDescriptionId == null || itemDescriptionId == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please select Item'));
                return;
            }
            
            productAvailabilityRequest = new ProductAvailabilityRequest();
            
            for(Plants__c w: [Select Id,SAP_Plant__c From Plants__c Where Id = : plantId  limit 1] ){
                productAvailabilityRequest.plant =  w.SAP_Plant__c ;
            }
            
            for(Product2 p: [Select Id,ProductCode From Product2 Where Id = : itemDescriptionId  limit 1] ){
                productAvailabilityRequest.material =  p.ProductCode;
            }
             
            
            lstProductAvailabilityResponse = ProductAvailabilityCallout.searchProductAvailability(productAvailabilityRequest);
            */
            //1-30-2017 Dru: Updated to use WS class for callout
            
            if(plantId == null || plantId == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please select Plant'));
                return;
            }
            if(itemDescriptionId == null || itemDescriptionId == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please select Item'));
                return;
            }
            WS.StockAvailRequest request = new WS.StockAvailRequest();
            for(Plants__c w: [Select Id,SAP_Plant__c From Plants__c Where Id = : plantId  limit 1] ){
                request.strPlant =  w.SAP_Plant__c ;
            }
            
            for(Product2 p: [Select Id,ProductCode From Product2 Where Id = : itemDescriptionId  limit 1] ){
                if(request.lstMaterials == null) request.lstMaterials = new List<String>();
                request.lstMaterials.add(p.ProductCode);
            }
            stockAvailResponse = WS.stockAvailabilityCall(request);
            String strErrors = '';
            for(integer i = 0; i < stockAvailResponse.lstErrors.size(); i++){
                if(i != 0) strErrors += '/n';
                WS.StockAvailabilityError e = stockAvailResponse.lstErrors.get(i);
                strErrors += e.strMessage;
            }
            if(!String.isEmpty(strErrors)) throw new WS.WSException(strErrors);
        }catch(Exception ex){ 
            System.debug('============================= ERROR '+ex.getMessage());
            System.debug('============================= Full Stack Track '+ex.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,ex.getMessage())); 
        }
    }
    
    //Reset search parameters and old Result
    public void reset(){
        plantId = '';
        marketClassId = '';
        productTypeId = '';
        itemDescriptionId = '';
        //lstProductAvailabilityResponse = new List<ProductAvailabilityResponse>();
        stockAvailResponse = null;
        plantesOption = plantes();
      //  marketClassesOption = marketClasses();
       // productTypesOption = productTypes();
        itemDescriptionOption = itemDescription();
    }
    
    public void refreshSelectOptions(){
        plantesOption = plantes();
       // marketClassesOption = marketClasses();
       // productTypesOption = productTypes();
        itemDescriptionOption = itemDescription();
    }
    
    public void refreshPage(){
        
    }

}