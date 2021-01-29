//
//
// 23 Aug, 2014      
// Description :
//              This page is basically about showing the Open Orders as a report .
//              Open orders can be searched on Territories, Accounts or Sold to or Order for parameteres
//

public without sharing class OpenOrdersReportController {
     
    //getter setter properties
    public String selectedRegion {get; set;}
    public String selectedTerrirory {get; set;}
    public String selectedOpenOrderOption {get; set;}
    public String selectedAccount {get; set;}
    public boolean isReportView {get; set;}
    public Map<String, Territory__c> mapTerritories {get; set;}
    public List<LIst<Order>> listOrderWrapper {get; set;}
    public User userInfo {get; set;}
   
    public ApexPages.StandardSetController conAP {get;set;}
    public boolean isForPDF {get; set;}
    public List<SelectOption> territories {get; set;}
    public transient string DisplayMag {get;set;}
    public String detailInfo {get; set;}
    public List<Region__c> listRVPRegions {get;set;}
    
    //FINAL variables
    static final Integer PAGE_SIZE = 20;
    
    public boolean IsCommercialTerritory {get;set;}
    
    //private variables
    private String sortDirection = 'ASC';
    private String sortExp = 'Ship_To__r.Territory__R.Region__r.Name, Ship_To__r.Territory__r.Territory_Code__c, Sold_To__r.Name';
    
    //functions called for sotring of data
    public String sortExpression{
         get{
            return sortExp;
         }
         set{
           //if the column is clicked on then switch between Ascending and Descending modes
           if (value == sortExp){
             sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
           }
           else{
             sortDirection = 'ASC';
           }
           sortExp = value;
         }
   } 

     public String getSortDirection(){
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
          return 'ASC';
        else
         return sortDirection;
     }

     public void setSortDirection(String value){  
       sortDirection = value;
     }
    
    public string CurrentTime {get;set;}
    public Boolean isFromWS {get; set;}
    //constructor
    public OpenOrdersReportController(){
        CurrentTime = system.now().format('M/d/yyy hh:mm a');
        isFromWS = false;
        isForPDF = false;
        detailInfo = '';
        mapTerritories = new Map<String, Territory__c>();
        listOrderWrapper = new List<LIst<Order>>();
        selectedOpenOrderOption = Constants.SELECTOPTION_ALL;
        selectedRegion = Constants.SELECTOPTION_ALL;
        userInfo = UtilityClass.userDetail;
        isReportView = false;
        headerText = '';

        if(Apexpages.currentPage().getParameters().containsKey('ws')
            && Apexpages.currentPage().getParameters().get('ws').trim().equalsIgnoreCase('true')){
            isFromWS = true;
        }
        //All these page parameters are fetched when report is called after setting parameters
        if(Apexpages.currentPage().getParameters().containsKey('regionId')){
            selectedRegion = Apexpages.currentPage().getParameters().get('regionId');
            //isReportView = true;
        }
        fetchTerritories();
        
        if(Apexpages.currentPage().getParameters().containsKey('territoryType')){
            selectedTerrirory = Apexpages.currentPage().getParameters().get('territoryType');
            //isReportView = true;
        }
        
        if(Apexpages.currentPage().getParameters().containsKey('orderOption')){
            selectedOpenOrderOption = Apexpages.currentPage().getParameters().get('orderOption');
            //isReportView = true;
        }
        
        if(Apexpages.currentPage().getParameters().containsKey('sortExpression')){
            sortExpression = Apexpages.currentPage().getParameters().get('sortExpression');
            //isReportView = true;
        }else{
            sortExpression = 'Sold_To__r.parent.Name,Sold_To__r.Name,Ship_To__r.Name,Ship_To__r.ShippingStreet';
            sortDirection = 'ASC';
        }
        
        if(Apexpages.currentPage().getParameters().containsKey('sortDirection')){
            sortDirection = Apexpages.currentPage().getParameters().get('sortDirection');
            //isReportView = true;
        }
        
        if(Apexpages.currentPage().getParameters().containsKey('accountId') && Apexpages.currentPage().getParameters().get('accountId') != null ){
            selectedAccount = Apexpages.currentPage().getParameters().get('accountId');
            //isReportView = true;
        }
        
        if(Apexpages.currentPage().getParameters().containsKey('isForPDF')){
            isForPDF = true;
        }
        
        if(Apexpages.currentPage().getParameters().containsKey('viewReport') 
            && Apexpages.currentPage().getParameters().get('viewReport').trim().equalsIgnoreCase('true')){
            isReportView = true;
        }

        String lStrSortCol = Apexpages.currentPage().getParameters().get('sortCol');
        String lStrSortDir = Apexpages.currentPage().getParameters().get('sortOrder');

        if(lStrSortCol != null) {
            sortExpression = lStrSortCol;
        }

        if(lStrSortDir != null) {
            sortDirection = lStrSortDir;
        }        
        
        String userID = userInfo.Id;
        // INC0715225 - Check for user having valid mobile role
        if(userInfo.Role__c == null){
        String v1 = 'No Mobile App Role defined for ';
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, v1 + userInfo.Name));
        }
        else {
            /*String query = 'Select Id, Territory__r.Region__c, Territory__c, Territory__r.Name '+
            'From Hierarchy_Matrix__c ';
            if(userInfo.Role__c != Constants.ROLE_VP && userInfo.Role__c != Constants.ROLE_PC_ADMIN){
                query += ' where '+userInfo.Role__c+'__c =: userID ';
                // Added below if condition to handle multiple PC (PC #1 and PC #2)
                if(userInfo.Role__c == Constants.ROLE_PC){
                    query += ' OR '+userInfo.Role__c+'_2__c =: userID';
                }
            }
            query += ' limit 1';
            if(Database.query(query).size() == 0){
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, Constants.NO_TERRITORY_FOUND + userInfo.Name));
            }*/
        }
        detailInfo = 'Open Orders for '+userInfo.Role__c+' '+userInfo.Name;
        
        if(isReportView){
            fetchCommonOrderData();
        }else {
            if((userInfo.Role__c == Constants.ROLE_RVP || userInfo.Role__c == Constants.ROLE_VP
                || userInfo.Role__c == Constants.ROLE_PC_ADMIN) 
                && isReportView != true ){
                fetchAllRegionRollupData();
            }
            if(selectedOpenOrderOption != null && selectedOpenOrderOption != '' && selectedOpenOrderOption != Constants.SELECTOPTION_ALL){
                renderAccountPicklist();
            }
        }
    }
    
    //this method is used for fetching territories for corresponding regions
    public void fetchTerritories(){
        try{
            territories = new List<SelectOption>();
            mapTerritories = new Map<String, Territory__c>();
              
            if(userInfo.Role__c != null){
                if(userInfo.Role__c == Constants.ROLE_RM || userInfo.Role__c == Constants.ROLE_DM 
                    || userInfo.Role__c == Constants.ROLE_RVP || userInfo.Role__c == Constants.ROLE_VP
                    || userInfo.Role__c == Constants.ROLE_PC_ADMIN){
                    territories.add(new SelectOPtion(Constants.SELECTOPTION_ALL, Constants.SELECTOPTION_ALL));
                }
                String userID = userInfo.Id;

    /*  String query = 'Select Id, Territory__r.Region__c, Territory__c, Territory__r.Territory_Code__c, ' +                      ' Territory__r.Type__c, Territory__r.Name From Hierarchy_Matrix__c ';
                String concatinateWith = ' WHERE ';
                if(userInfo.Role__c != Constants.ROLE_VP && userInfo.Role__c != Constants.ROLE_PC_ADMIN){
                    query += concatinateWith+' ('+userInfo.Role__c+'__c =: userID ';
                    // Added below if condition to handle multiple PC (PC #1 and PC #2)
                    if(userInfo.Role__c == Constants.ROLE_PC){
                        query += ' OR '+userInfo.Role__c+'_2__c =: userID';
                    }
                    query += ' ) ';
                    concatinateWith = ' AND ';
                }
                if(selectedRegion != null && selectedRegion != '' && selectedRegion != Constants.SELECTOPTION_ALL){
                    query = query + concatinateWith+' Territory__r.Region__c = \'' + selectedRegion + '\' ';
                }
                
                for(Hierarchy_Matrix__c hMatrix : Database.query(query)){
                    if(territories.size() == 0){
                        selectedTerrirory = hMatrix.Territory__c;
                    }
                    mapTerritories.put(hMatrix.Territory__c, hMatrix.Territory__r);
                }
    */
            }
             

            IsCommercialTerritory = false;
            for(Territory__c territory : [Select Id,Name,Territory_Code__c,Type__c From Territory__c Where Id IN: mapTerritories.keySet() Order By Territory_Code__c] ){
                territories.add(new SelectOPtion(territory.Id, territory.Territory_Code__c + ' - ' +territory.Name ));
            }
              
        }catch(Exception e){
            DisplayMag =  e.getMessage();
        }
    }
    
    //this will pick all the regions from the Region__c object 
    public List<SelectOption> getRegions(){ 
        List<SelectOption> options = new List<SelectOption>();
        
        if(userInfo.Role__c == Constants.ROLE_RVP || userInfo.Role__c == Constants.ROLE_VP
            || userInfo.Role__c == Constants.ROLE_PC_ADMIN){
            options.add(new SelectOPtion(Constants.SELECTOPTION_ALL, Constants.SELECTOPTION_ALL));
            String userID = userInfo.Id;
            
        /* String soql = 'Select Id,Territory__r.Region__c  From Hierarchy_Matrix__c';
                    // WE NEED TO INCLUDE ALL REAGION FOR VP
            if(userInfo.Role__c == Constants.ROLE_RVP){
                soql += ' Where RVP__c = :userID';
            }
            SET<ID> setRegId = new SET<ID>(); 
            for(Hierarchy_Matrix__c hm: Database.query(soql)){
                setRegId.add(hm.Territory__r.Region__c);
            }
        
            listRVPRegions = [Select Id,Name,Region_Code__c,Dummy_Number__c From Region__c Where Id IN: setRegId Order By Name]; 
            
            for(Region__c r : listRVPRegions){
                options.add(new SelectOPtion(r.Id, r.Name));
            } */
        }
        return options;
    }
    
    
    //this is getter for preparing picklist sold to, order to and all
    public List<SelectOption> getOpenOrdersOptions(){
        List<SelectOption> options = new List<SelectOption>();
        //if(userInfo.Role__c != Constants.ROLE_RVP){
            options.add(new SelectOPtion(Constants.SELECTOPTION_ALL, Constants.LIST_ALL_OPEN_ORDER));
            options.add(new SelectOPtion(Constants.SOLD_TO_PICKLIST, Constants.LIST_OPEN_ORDER_SOLD_TO));
            options.add(new SelectOPtion(Constants.ORDER_FOR_PICKLIST, Constants.LIST_OPEN_ORDER_ORDER_FOR));
        //}
        return options;
    } 
    
    //just used for rendering redndering section on the page
    public Pagereference renderAccountPicklist(){ 
        return null;
    }
    
    public Pagereference renderopenOrderPicklist(){
        IsCommercialTerritory = false;
        for(Territory__c territory : [Select Id,Name,Territory_Code__c,Type__c From Territory__c Where Id =: selectedTerrirory AND Type__c = 'Commercial'] ){ 
            IsCommercialTerritory = true; 
        }
        return null;
    }
    
    //this will pick all the accounts on the basis of territory selected and Sold to or order to selected
    public List<SelectOption> getAccounts(){
        
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOPtion('', '--All--')); 
        
        try{
             
             if( String.isNotEmpty(selectedOpenOrderOption) && String.isNotEmpty(selectedTerrirory)){
                
                Set<String> orderStatuses = new Set<String>{'ENTERED', 'CREDIT HOLD', 'PICKED', 'CUSTOMER HOLD'}; 
                
                List<Order> listOpenOrd = new List<Order>();
                Set<String> tempSet = mapTerritories.keySet();
                
                if(selectedTerrirory != Constants.SELECTOPTION_ALL){ 
                    listOpenOrd = [Select Id,Ship_To__c,Ship_To__r.Name, Ship_To__r.ShippingStreet, Ship_To__r.ShippingCity, Ship_To__r.ShippingState, Sold_To__c, Sold_To__r.Name,Sold_To__r.ParentId,Sold_To__r.Parent.Name, Status From Order 
                                    Where Status IN: orderStatuses AND (Doc_Type__c =  'ZOR' OR Doc_Type__c =  'ZTP' OR Doc_Type__c =  'ZFW') AND Selling_Quantity__c > 0 AND (Ship_To__r.Mechanical_Territory__c =: selectedTerrirory OR Ship_To__r.Finishing_Territory__c =: selectedTerrirory)
                                    AND Ship_To__c != null AND Sold_To__c != null AND Sold_To__r.ParentId != null ]; 
                }
                else{
                    listOpenOrd = [Select Id,Ship_To__c,Ship_To__r.Name, Ship_To__r.ShippingStreet, Ship_To__r.ShippingCity, Ship_To__r.ShippingState, Sold_To__c,Sold_To__r.Name,Sold_To__r.ParentId,Sold_To__r.Parent.Name, Status From Order 
                                    Where Status IN: orderStatuses  AND (Doc_Type__c =  'ZOR' OR Doc_Type__c =  'ZTP' OR Doc_Type__c =  'ZFW') AND Selling_Quantity__c > 0 AND (Ship_To__r.Mechanical_Territory__c IN : tempSet OR Ship_To__r.Finishing_Territory__c IN : tempSet)
                                    AND Ship_To__c != null AND Sold_To__c != null AND Sold_To__r.ParentId != null ]; 
                }
                
                String query = '';
                String heirachyLevel = Constants.SOLD_TO;
                
                SET<ID> setAccId = new SET<ID>();
                
                if(selectedOpenOrderOption == Constants.SOLD_TO_PICKLIST){
                    for(Order ord: listOpenOrd){
                        setAccId.add(ord.Sold_To__r.ParentId);
                    }
                    query = 'Select Id, Name from Account where Id =: setAccId and Hierarchy_Level_BPCS__c =: heirachyLevel Order By Name Limit 999';
                     
                }else if( selectedOpenOrderOption == Constants.ORDER_FOR_PICKLIST){ 
                    heirachyLevel = Constants.ORDER_FOR;
                    for(Order ord: listOpenOrd){
                        setAccId.add(ord.Sold_To__c);
                    }
                    query = 'Select Id, Name from Account where Id =: setAccId and Hierarchy_Level_BPCS__c =: heirachyLevel Order By Name Limit 999';
                }
                
                //if query is not empth then only preparing option list
                if(String.isNotEmpty(query)){
                     
                    for(Account accountInfo : Database.query(query)){
                        options.add(new SelectOPtion(accountInfo.Id, accountInfo.Name));
                    }
                    
                }
            }
        }catch(Exception e){
            DisplayMag = e.getMessage();
        }
        return options;
    }
    
    public String selectedAccountName {get; set;}
    public String headerText {get; set;}
    //this method is called for pulling  the order data to display on page
    //on the basis of selectedOpenOrderOption and territory selected
    public Pagereference fetchCommonOrderData(){
        try{
            isReportView = true;
            String sortFullExp = sortExpression  + ' ' + sortDirection;
            Set<String> orderStatuses = new Set<String>{'ENTERED', 'CREDIT HOLD', 'PICKED', 'CUSTOMER HOLD'};
            Set<String> orderTypes = new Set<String>{'ZOR', 'ZTP', 'ZFW'};
            Set<String> setTerritories = new Set<String>();
            Set<ID> setOrderId = new Set<ID>();            
            
            /*for(Territory__c ter: [Select Id,Territory_Code__c From Territory__c Where Id = : selectedTerrirory Limit 1]){                
                for(OrderItem oli: [Select OrderId From OrderItem Where (TM_Number__c =: ter.Territory_Code__c OR TM_Number__c =: ter.Territory_Code__c.replace('TR', '0') OR TM_Number__c =: ter.Territory_Code__c.replace('TC', '0')) AND Order.Status in : orderStatuses 
                        AND (Order.Order_Type__c =  'ZOR' OR Order.Order_Type__c =  'ZTP' OR Order.Order_Type__c = 'ZFW')]){
                    setOrderId.add(oli.OrderId);
                }
            }*/
            //String strOLITerritory;
            for(Territory__c ter: [Select Id,Territory_Code__c From Territory__c Where Id = : selectedTerrirory Limit 1]){
                //strOLITerritory = ter.Territory_Code__c; 
                for(OrderItem oli: [Select OrderId From OrderItem Where TM_Number__c =: ter.Territory_Code__c AND Order.Status in : orderStatuses 
                        AND (Order.Doc_Type__c =  'ZOR' OR Order.Doc_Type__c =  'ZTP' OR Order.Doc_Type__c = 'ZFW')]){
                    setOrderId.add(oli.OrderId);
                }
            }            
            
            String query = 'Select Id, Ship_To__r.Finishing_Territory__r.Territory_Code__c, BPCS_Order__c, Sold_To__r.parent.Id, Selling_Quantity__c,Sold_To__r.parent.Name, Name, Ship_To__r.Territory__c,Ship_To__r.Finishing_Territory__c, Ship_To__r.Territory__r.Territory_Code__c, Ship_To__r.Territory__r.Name, Sold_To__c, Sold_To__r.Name, Ship_To__c, Ship_To__r.Name, Ship_To__r.ShippingStreet, Ship_To__r.ShippingCity, Ship_To__r.ShippingState, '+
                               ' PONumber, Ship_Via__c, EffectiveDate, Schedule_Date__c, Request_Date__c, Ship_To__r.Territory__R.Region__c,  Ship_To__r.Territory__R.Region__R.Name, Ship_To__r.Finishing_Territory__r.Type__c, Ship_To__r.Territory__r.Type__c, '+
                       '(Select Id, Line_Number__c, Product__c, Product__r.Name, Selling_Quantity__c, Selling_UOM__c, Stocking_Quantity__c, Stocking_UOM__c  from OrderItems WHERE Stocking_UOM__c!=\'LB\' AND Item_Status__c  != \'REJECTED\' order by Line_Number__c), Warehouse_Name__c, Status from Order '+
                               ' Where Ship_To__c != null AND Sold_To__c != null AND Status in : orderStatuses AND Order_Type__c IN : orderTypes ';            
            
            if(selectedTerrirory != Constants.SELECTOPTION_ALL){
                query += ' AND  (Ship_To__r.Territory__c =: selectedTerrirory OR '+
                    'Ship_To__r.Finishing_Territory__c =: selectedTerrirory )';                
                if(mapTerritories.containskey(selectedTerrirory) && userInfo.Role__c != Constants.ROLE_TM){
                    query += ' AND  Territory_Type__c = \'' + mapTerritories.get(selectedTerrirory).Type__c + '\' ';                    
                }
                
                query += ' AND Id IN: setOrderId ';                
            }else{
                if(selectedRegion != null && selectedRegion != '' & selectedRegion != Constants.SELECTOPTION_ALL){
                    setTerritories = territoriesForARegion(mapTerritories.values(), selectedRegion);
                }else {
                    setTerritories = mapTerritories.keySet();
                }
                query += ' AND  (Ship_To__r.Territory__c in : setTerritories OR '+
                    'Ship_To__r.Finishing_Territory__c in : setTerritories )';
            }
            
            if(selectedRegion != null && selectedRegion != '' & selectedRegion != Constants.SELECTOPTION_ALL){
                query += ' AND  Ship_To__r.Territory__r.Region__c =: selectedRegion ';
            }
            
            if(selectedOpenOrderOption != Constants.SELECTOPTION_ALL && selectedAccount != null && String.isNOtEmpty(selectedAccount)){
                if(String.isNOtEmpty(selectedAccount)){
                    if(selectedOpenOrderOption == Constants.SOLD_TO_PICKLIST  ){
                        query += ' AND  Sold_To__r.parentId =: selectedAccount ';
                    }
                    else if( selectedOpenOrderOption == Constants.ORDER_FOR_PICKLIST){
                        query += ' AND  Sold_To__c =: selectedAccount ';
                    }
                } 
            } 
           
            List<Competitors__c> compititorList = [SELECT ID,Name,Competitor__c FROM Competitors__c];
            String excludeCompetitors = '';
            if(compititorList.size()>0){
                for(Competitors__c c : compititorList){
                    if(excludeCompetitors=='' || String.isEmpty(excludeCompetitors)){
                        excludeCompetitors = ' AND (NOT Ship_To__r.Name LIKE \''+c.Competitor__c+'%\')';
                    }else{
                        excludeCompetitors += ' AND (NOT Ship_To__r.Name LIKE \''+c.Competitor__c+'%\')';
                    }
                }
            }
            query += excludeCompetitors+' ';            
            //firing query only when query is not empty
            if(String.isNotEmpty(query)){
                String tempQuery = query+' LIMIT 9999';
                Set<ID> displayOrderIDs = new Set<ID>();
                for(Order orderInfo : Database.query(tempQuery)){
                    if(orderInfo.OrderItems==null || orderInfo.OrderItems.size()==0){
                        displayOrderIDs.add(orderInfo.ID);
                    }
                }
                if(displayOrderIDs.size()>0){
                    query += ' AND ID NOT IN :displayOrderIDs order by '+sortFullExp+' LIMIT 9999';
                }else{
                    query += ' order by '+sortFullExp+' LIMIT 9999';
                }
                
                //query += ' order by Order_For_Account__r.parent.Name, Order_For_Account__r.Name,Ship_To_Account__r.Name, BPCS_Order__c LIMIT 9999';
                system.debug('======== query : ' + query);
                system.debug('======== orderStatuses : ' + orderStatuses);
                system.debug('======== mapTerritories.keySet() : ' + mapTerritories.keySet());
                
                if(isForPDF){
                    List<Order> tempWrapper = new List<Order>();
                    for(Order orderInfo : Database.query(query)){
                        selectedAccountName  = orderInfo.Sold_To__r.parent.Name;
                          
                        tempWrapper.add(orderInfo);
                        if(tempWrapper.size() >999){
                            listOrderWrapper.add(tempWrapper);
                            tempWrapper = new List<Order>();
                        }
                    }
                listOrderWrapper.add(tempWrapper);
                }else{
                    system.debug('======== query : ' + query);
                    conAP = new ApexPages.StandardSetController(Database.getQueryLocator(query));
                    conAP.setPageSize(PAGE_SIZE);
                }
            }
            
            if(isFromWS){
                Territory__c tr = [Select Id, Name,Territory_Code__c From Territory__c WHERE ID = :selectedTerrirory Limit 1];
                headerText =  'Territory #' + tr.Territory_Code__c + ' ' + tr.Name;
            }else{
                headerText = selectedTerrirory == 'All' ? 'All Territories' : 'Territory #' + mapTerritories.get(selectedTerrirory).Territory_Code__c + ' ' + mapTerritories.get(selectedTerrirory).Name  ;
                
                if( selectedOpenOrderOption == Constants.SOLD_TO_PICKLIST || selectedOpenOrderOption == Constants.ORDER_FOR_PICKLIST ){
                    if(selectedAccount != null && String.isNotEmpty(selectedAccount)){
                        for(Account a: [Select Id,Name From Account Where Id = : selectedAccount Limit 1]){
                            headerText += ' '+selectedOpenOrderOption+' '+ a.Name;
                        }
                    }
                    else{
                        headerText += ' '+selectedOpenOrderOption+' All' ;
                    }
                }
            }
        }catch(Exception e){
            DisplayMag = e.getMessage();
        }
        return null;
    }
    
    public Set<String> territoriesForARegion(List<Territory__c> terriotries, String regnId){
        Set<String> tIds = new Set<String>();
        for(Territory__c t : terriotries){
            if(t.Region__c == (ID)regnId){
                tIds.add(t.Id);
            }
        }
        return tIds;
    }
    
    //common method called from page for viewing RVP data or Other data
    public Pagereference ViewData(){
        if(userInfo.Role__c == Constants.ROLE_RVP 
            || userInfo.Role__c == Constants.ROLE_VP
            || userInfo.Role__c == Constants.ROLE_PC_ADMIN){
            fetchCommonOrderDataActionRVP();
        }else{
            fetchCommonOrderData();
        }
        return null;
    }
    
    //this method is called for RVP view 
    //fetching all regions
    //then all territories of region selected
    public Pagereference fetchCommonOrderDataActionRVP(){
        try{
            isReportView = true;
            if(selectedRegion != null){
                if(selectedRegion != Constants.SELECTOPTION_ALL){
                    fetchAllRegionData(new Set<String>{selectedRegion});
                }else{
                    //find all Regions
                    Set<String> regionIds = new Set<String>();
                    for(TerriTory__c territory : mapTerritories.values()){
                        regionIds.add(territory.Region__c);
                    }
                    fetchAllRegionData(regionIds);
                }
            }
            
            //headerText = ' - RVP View'; 
            string RegionName = '';
            for(Region__c rg: [Select Name From Region__c Where Id = : selectedRegion  Limit 1]){
                RegionName = rg.Name;
            }
            headerText = selectedRegion == Constants.SELECTOPTION_ALL ? 'All Regions' : 'Region ' + RegionName ;
            
            
        }catch(Exception e){
            DisplayMag = e.getMessage();
        }
        return null;
    }
    
    private void fetchAllRegionRollupData( ){ 
        Set<String> orderStatuses = new Set<String>{'ENTERED', 'CREDIT HOLD', 'PICKED', 'CUSTOMER HOLD'}; 
        String userID = userInfo.Id;

    /*    String soql = 'Select Id,Territory__r.Region__c  From Hierarchy_Matrix__c ';
        if(userInfo.Role__c == Constants.ROLE_RVP){
            soql += ' Where RVP__c = :userID';
        }
        SET<ID> setRegId = new SET<ID>();
        for(Hierarchy_Matrix__c hm: Database.query(soql)){
            setRegId.add(hm.Territory__r.Region__c);
        }
        listRVPRegions = [Select Id,Name,Region_Code__c,Dummy_Number__c From Region__c Where Id IN: setRegId Order By Name]; 
        
        for(Region__c r : listRVPRegions){
             r.Dummy_Number__c = 0;
             
             List<AggregateResult> ordDetails = new List<AggregateResult>([SELECT SUM(Selling_Quantity__c) OrdQty FROM Order  
                        WHERE Ship_To__r.Mechanical_Territory__r.Region__c= : r.Id AND Status IN: orderStatuses AND Selling_Quantity__c > 0  ]);
            if(ordDetails != null && ordDetails.size() > 0){
                r.Dummy_Number__c = ((Decimal)ordDetails.get(0).get('OrdQty')); 
            }
                    
        } */
    }
    
    //this method is called when user selects the region and preparing the list order wrapper to display on page
    private void fetchAllRegionData(Set<String> regionIds){
        Set<String> orderStatuses = new Set<String>{'ENTERED', 'CREDIT HOLD', 'PICKED', 'CUSTOMER HOLD'}; 
        
        Map<String, Territory__c> mapTempTerritories = new Map<String, Territory__c>([Select Id, Name from Territory__c where Region__c in : regionIds]);
                //finding all orders
            Set<String> setTerritories = mapTempTerritories.keySet();
            String sortFullExp = sortExpression  + ' ' + sortDirection;
            String query = 'Select Ship_To__r.Finishing_Territory__r.Territory_Code__c, BPCS_Order__c, Sold_To__r.parent.Id, Sold_To__r.parent.Name, Name, Ship_To__r.Territory__c,Ship_To__r.Finishing_Territory__c,Selling_Quantity__c, Ship_To__r.Territory__r.Territory_Code__c , Ship_To__r.Territory__r.Name, Sold_To__c, Sold_To__r.Name, Ship_To__c, Ship_To__r.Name, Ship_To__r.ShippingStreet, Ship_To__r.ShippingCity, Ship_To__r.ShippingState, '+
                       ' PONumber, Ship_Via__c, EffectiveDate, Schedule_Date__c, Request_Date__c, Ship_To__r.Territory__R.Region__c,  Ship_To__r.Territory__R.Region__R.Name, '+
                       '(Select Id, Line_Number__c, Product__c, Product__r.Name, Selling_Quantity__c, Selling_UOM__c from OrderItems WHERE Stocking_UOM__c!=\'LB\' AND Item_Status__c  != \'REJECTED\' order by Line_Number__c), Warehouse_Name__c, Status from Order '+
                       ' Where Ship_To__c != null AND Sold_To__c != null AND Status IN: orderStatuses AND Selling_Quantity__c > 0 and (Ship_To__r.Territory__c in : setTerritories OR Ship_To__r.Finishing_Territory__c in : setTerritories) ';
            //query += ' order by '+sortFullExp;
            
            List<Competitors__c> compititorList = [SELECT ID,Name,Competitor__c FROM Competitors__c];
            String excludeCompetitors = '';
            if(compititorList.size()>0){
                for(Competitors__c c : compititorList){
                    if(excludeCompetitors=='' || String.isEmpty(excludeCompetitors)){
                        excludeCompetitors = ' AND (NOT Ship_To__r.Name LIKE \''+c.Competitor__c+'%\')';
                    }else{
                        excludeCompetitors += ' AND (NOT Ship_To__r.Name LIKE \''+c.Competitor__c+'%\')';
                    }
                }
            }
            query += excludeCompetitors+' ';
            
            String tempQuery = query+' LIMIT 9999';
            Set<ID> displayOrderIDs = new Set<ID>();
            for(Order orderInfo : Database.query(tempQuery)){
                if(orderInfo.OrderItems==null || orderInfo.OrderItems.size()==0){
                    displayOrderIDs.add(orderInfo.ID);
                }
            }
            if(displayOrderIDs.size()>0){
                query += ' AND ID NOT IN :displayOrderIDs order by Sold_To__r.parent.Name, Sold_To__r.Name,Ship_To__r.Name, BPCS_Order__c LIMIT 9999';
            }else{
                query += ' order by Sold_To__r.parent.Name, Sold_To__r.Name,Ship_To__r.Name, BPCS_Order__c LIMIT 9999';
            }
            
            system.debug('<<<<<query>>>>'+query);
            if(isForPDF){
                List<Order> tempWrapper = new List<Order>();
                for(Order orderInfo : Database.query(query)){
                    selectedAccountName  = orderInfo.Sold_To__r.parent.Name;
                    tempWrapper.add(orderInfo);
                    if(tempWrapper.size() >999){
                        listOrderWrapper.add(tempWrapper);
                        tempWrapper = new List<Order>();
                    }
                    
                }
            listOrderWrapper.add(tempWrapper);
            }else{
                conAP = new ApexPages.StandardSetController(Database.getQueryLocator(query));
                conAP.setPageSize(PAGE_SIZE);
            }  
    }
    
    public List<Order> getOrders() {
        if(conAP == null){
             return new List<Order>();
        }
        return (List<Order>) conAP.getRecords();
    }

    public PageReference FirstAP() {
        if(conAP == null){
            return null;
        }
        conAP.first();
        return null;
    }

    public PageReference PreviousAP() {
         if(conAP.getHasPrevious()){
             conAP.previous();
         }
         return null;
    }

    public PageReference NextAP() {
         if(conAP.getHasNext()){
             conAP.next();
         }
         return null;
    }

    public PageReference LastAP() {
        if(conAP == null){
            return null;
        }
        conAP.last();
        return null;
    }
    
    public Integer getPageNumber(){
        if(conAP == null){
            return 0;
        }
        return conAp.getPageNumber();
    }
    
    public Integer getTotalPages(){
        if(conAP == null){
            return 1;
        }
        return Integer.valueOf(Math.ceil(conAp.getResultSize()/Decimal.valueOf(PAGE_SIZE)));
    }
    
    // Remote action called from VF Remoting to send email 
    // NOTE : We used VF remoting to avoid use of <apex:form> in our page 
    @RemoteAction
  public static String emailPDFReport(String emails, String subject, String textBody, String pdfAttachmentURL){
    String status = 'success';
    List<String> recipeintEmails = new List<String>();
    if(emails != null && !emails.trim().equals('')){
        for(String em : emails.split(';')){
            recipeintEmails.add(em);
        }
    }
    status = UtilityClass.emailPDF(recipeintEmails, subject, textBody, pdfAttachmentURL);
    return status;
  }
  
  @RemoteAction
  public static String emailExcelReport(String emails, String subject, String textBody, String pdfAttachmentURL){
    String status = 'success';
    List<String> recipeintEmails = new List<String>();
    if(emails != null && !emails.trim().equals('')){
        for(String em : emails.split(';')){
            recipeintEmails.add(em);
        }
    }
    status = UtilityClass.emailExcel(recipeintEmails, subject, textBody, pdfAttachmentURL);
    return status;
  }
  
  public void doNothing() {
    
  }
  
  
}