/*******************************************************************************
Name                    : OrderIntakeReport.cls
Created Date    : 25th Aug, 2014
Descriprion     : Custom Salesforce1 Report to show Order Intake records 
            for Diff-Diff Users based on their Role and accessibility
*******************************************************************************/

public without sharing class OrderIntakeReport {
    // Public Variables
    public String measurementUnit {get; set;}
    public String sortExp {get; set;}
    public String sortType {get; set;}
    public User userInfo {get; set;} 
    public String detailInfo {get; set;}
    public String selectedTerriroryType {get; set;}
    public List<SelectOption> territoryType{get; set;}

 // public Map<String, Hierarchy_Matrix__c> hierarchyMatrix {get; set;} 

  public List<OrderIntakeWrapper> orderIntake { get; set; }
  public List<RVPOrderIntakeWrapper> rvpOrderIntake { get; set; }
  public String detailId {get; set;}
 // public List<Order_Intake_Line__c> orderIntakeDetails { get; set;}
  //public List<Order_Intake__c> rvpOrderIntakeDetails { get; set;}
  public Set<String> regionForRVP {get; set;}
  
  public SET<ID> setCurrentTMRegion {get;set;}
  
  public string RVPDrillDown {get;set;}
  
  public string CurrentTime {get;set;}
   
  // COnstructor
  public OrderIntakeReport(){
    CurrentTime = system.now().format('M/d/yyy hh:mm a');
    measurementUnit = '';
    detailInfo = '';
    sortExp = '';
    sortType = '';
    detailId = null;
    orderIntake = new List<OrderIntakeWrapper>();
    rvpOrderIntake = new List<RVPOrderIntakeWrapper>();
   // orderIntakeDetails = new List<Order_Intake_Line__c>();
   // rvpOrderIntakeDetails = new List<Order_Intake__c>();
    userInfo = UtilityClass.userDetail;
    // Fetch Hierarchy Matrix for Logged User

   //     hierarchyMatrix = UtilityClass.fetchHierarchyMatrix();

        regionForRVP = new Set<String>();
        Set<String> availableTerritories = new Set<String>();
        setCurrentTMRegion = new SET<ID>();
        
        // Check for Available Reagions and Territories for logged User
     
    /*    for(Hierarchy_Matrix__c hm : hierarchyMatrix.values()){
            if(!regionForRVP.contains(hm.Territory__r.Region__c))
                regionForRVP.add(hm.Territory__r.Region__c);
            if(!availableTerritories.contains(hm.Territory__r.Type__c))
                availableTerritories.add(hm.Territory__r.Type__c);
            
            setCurrentTMRegion.add(hm.Territory__r.Region__c);  
        }
    */
        // Dynamicly build Territory select list
        territoryType = new List<SelectOption>();
        if(availableTerritories.size() > 1){
            territoryType.add(new SelectOption('none','--Select--'));
        }
        for(String str : availableTerritories){
        territoryType.add(new SelectOption(str,str));
        }
        
        if(territoryType.size() > 0){
            selectedTerriroryType = territoryType.get(0).getValue();
        }else{
            selectedTerriroryType = 'none';
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, 'No Territory Found for '+userInfo.Name));
    }
    
    // Read from Parameters
    if(Apexpages.currentPage().getParameters().containsKey('sortExp')){
        sortExp = Apexpages.currentPage().getParameters().get('sortExp');
    }
        if(Apexpages.currentPage().getParameters().containsKey('sortType')){
        sortType = Apexpages.currentPage().getParameters().get('sortType');
    }
    if(Apexpages.currentPage().getParameters().containsKey('type')){
        selectedTerriroryType = Apexpages.currentPage().getParameters().get('type');
    }
    if(Apexpages.currentPage().getParameters().containsKey('detailId')){
        detailId = Apexpages.currentPage().getParameters().get('detailId');
    }
    if(Apexpages.currentPage().getParameters().containsKey('RVP')){
        RVPDrillDown = Apexpages.currentPage().getParameters().get('RVP');
    }
        
        // Show Report landing page OR details page
        if((detailId == null || detailId.trim().equals(''))
            && !selectedTerriroryType.trim().equals('') && !selectedTerriroryType.trim().equals('none')){
        fetchOrderIntake();
    }else if(detailId != null && !detailId.trim().equals('')){
        fetchDetails();
    }
    if(selectedTerriroryType != null && selectedTerriroryType.trim().equalsIgnoreCase('Residential')){
        measurementUnit = 'Squares';
    }else if(selectedTerriroryType != null && selectedTerriroryType.trim().equalsIgnoreCase('Commercial')){
        measurementUnit = 'Rolls';
    }
    
        User currUser = UtilityClass.userDetail;
        
        string TerritoryNum = '';

    /*    for(Hierarchy_Matrix__c hm : hierarchyMatrix.values()){
            if(currUser.Role__c == Constants.ROLE_TM && hm.TM__c == currUser.Id){
                TerritoryNum = hm.Territory__r.Territory_Code__c; 
                break;
            }
            if(currUser.Role__c == Constants.ROLE_DM && hm.DM__c == currUser.Id){
                TerritoryNum = hm.Territory__r.Territory_Code__c; 
                break;
            }
            if(currUser.Role__c == Constants.ROLE_RM && hm.RM__c == currUser.Id){
                TerritoryNum = hm.Territory__r.Region__r.Name + ' Region'; 
                break;
            }
            if((currUser.Role__c == Constants.ROLE_RVP && hm.RVP__c == currUser.Id) 
                || currUser.Role__c == Constants.ROLE_VP){
                TerritoryNum = hm.Territory__r.Region__r.Name + ' Region'; 
                break;
            }
        }
    */    
    // Removed User Name From Header    
    //detailInfo = 'CertainTeed Roofing Products Order Intake for ' + TerritoryNum + ' - '+ userInfo.Name;
    detailInfo = 'CertainTeed Roofing Products Order Intake';
    
    }
    
    // Method to fetch all Order Intake records
    public void fetchOrderIntake(){
        orderIntake = new List<OrderIntakeWrapper>();
        rvpOrderIntake = new List<RVPOrderIntakeWrapper>();
        // Map to Store Region Name and Ids - Used in case of RVP User Only
        Map<String, String> regionNames = new Map<String, String>();
        // Map to store All Order Intake records from available Region - Used in case of RVP User Only 
       // Map<String, List<Order_Intake__c>> rvpOrderMap = new Map<String, List<Order_Intake__c>>();

    //    Set<String> territories = hierarchyMatrix.keySet();
        // Check Required Parameters
        if(selectedTerriroryType != null && !selectedTerriroryType.trim().equalsIgnoreCase('none')){
            if(userInfo.Role__c != null && !userInfo.Role__c.trim().equals('') ){
               /* if(!userInfo.Role__c.trim().equalsIgnoreCase('RVP') 
                    && !userInfo.Role__c.trim().equalsIgnoreCase('VP')){
                    // Fetch All Order Intake for Sellected Territory Type
                    String soql = 'Select Id, Name,Lines__c, Territory__c, Territory__r.Region__c, Territory__r.Region__r.Name, '+ 
                                ' Territory__r.Name, Territory_Code__c, TM__c, TM__r.Name, Yesterday_Orders__c, '+
                                ' MTD_Orders__c, YTD_Orders__c '+
                            ' From Order_Intake__c '+ 
                            ' Where Territory__r.Type__c = :selectedTerriroryType ' ;
                            
                            if(userInfo.Role__c.trim().equalsIgnoreCase('TM')){
                                soql += ' AND Territory__r.Region__c IN: setCurrentTMRegion ' ; 
                            }
                          ///  else{
                          //   soql += '  AND Territory__c IN :territories  ' ;    
                          //  } 
                            
                            if(sortExp != null && !sortExp.trim().equals('')){
                                soql += ' ORDER BY '+sortExp+' '+sortType;
                            }
                            else{
                                soql += ' ORDER BY Territory_Code__c ASC ' ;
                            }       
                                
                            
                    for(Order_Intake__c oi : (List<Order_Intake__c>)database.query(soql)){
                        // For Non-RVP User the directly show Order Intake Records      
    //                        orderIntake.add(new OrderIntakeWrapper(oi, hierarchyMatrix.containsKey(oi.Territory__c)));
                    }
                }
                // For RVP User the show Aggregated values from all elligible Orde Intake Records
                 if(userInfo.Role__c.trim().equalsIgnoreCase('RVP')
                    || userInfo.Role__c.trim().equalsIgnoreCase('VP')){
                    // Fetch All Order Intake for Sellected Territory Type
                    String soql = 'Select Territory__r.Region__c regionId, Territory__r.Region__r.Name regionName, '+ 
                                ' SUM(Yesterday_Orders__c) yesterdayOrders, '+
                                ' SUM(MTD_Orders__c) mtdOrders, SUM(YTD_Orders__c) ytdOrders '+
                            ' From Order_Intake__c '+ 
                            ' Where Territory__r.Type__c = :selectedTerriroryType   '+
                        //    ' AND Territory__c IN :territories '+
                            ' GROUP BY Territory__r.Region__c, Territory__r.Region__r.Name ';
                            if(sortExp != null && !sortExp.trim().equals(''))
                                soql += ' ORDER BY '+sortExp+' '+sortType;
                        
                    for(AggregateResult agg: (List<AggregateResult>)Database.query(soql)){
                        rvpOrderIntake.add(new RVPOrderIntakeWrapper(agg, regionForRVP.contains((String)agg.get('regionId'))));
                    }
                }*/
            }
        }else{
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, 'Please select territory type'));
        }
    }
    
    // Method to fetch Details - Drill Down functionality 
    public void fetchDetails(){
        if(detailId != null){
            // Show Order Intake Line Records - For Non - RVP Users Only
            //orderIntakeDetails = new List<Order_Intake_Line__c>();
        // Show Order Intake Records - For RVP Users Only
       // rvpOrderIntakeDetails = new List<Order_Intake__c>();
        if((userInfo.Role__c != null && !userInfo.Role__c.trim().equalsIgnoreCase('RVP') 
            && !userInfo.Role__c.trim().equalsIgnoreCase('VP')) 
            || (RVPDrillDown == 'YES') ){
          //  orderIntakeDetails = new List<Order_Intake_Line__c>();
            String soql = 'SELECT Order_For__c OrderForId, Order_For__r.Name OrderForName, '+ 
                ' SUM(Yesterday_Orders__c) yesterdayOrder FROM Order_Intake_Line__c '+
                ' Where Order_Intake__r.Territory__c = :detailId AND Order_Intake__r.Territory__r.Type__c = :selectedTerriroryType '+
                ' Group By Order_For__c, Order_For__r.Name ';
            if(sortExp != null && !sortExp.trim().equals(''))
                    soql += ' ORDER BY '+sortExp+' '+sortType;
            // Fetch Aggregated Result for Order For Account to show as line details
            for(AggregateResult res : (List<AggregateResult>)Database.query(soql)){
                Account orderFor = new Account(Id = (String)res.get('OrderForId'), Name = (String)res.get('OrderForName'));
               
                //Order_Intake_Line__c oil = new Order_Intake_Line__c();
                //oil.Order_For__r = orderFor;
                //oil.Yesterday_Orders__c = (Double)res.get('yesterdayOrder');
                //orderIntakeDetails.add(oil);
            }
        }
            /*else if(userInfo.Role__c != null && (userInfo.Role__c.trim().equalsIgnoreCase('RVP') || userInfo.Role__c.trim().equalsIgnoreCase('VP'))){
            String soql = 'Select Territory__c tId, Territory__r.Name tName, Territory__r.Territory_Code__c tCode, '+
                    ' TM__c tmId, TM__r.Name tmName, '+
                        ' SUM(Yesterday_Orders__c) yesterdayOrder, SUM(MTD_Orders__c) mtdOrder, SUM(YTD_Orders__c) ytdOrder '+
                        ' From Order_Intake__c '+
                        ' Where Territory__r.Type__c = :selectedTerriroryType AND Territory__r.Region__c = :detailId '+
                        ' GROUP BY Territory__c, Territory__r.Name, Territory__r.Territory_Code__c, TM__c, TM__r.Name ';
                if(sortExp != null && !sortExp.trim().equals(''))
                    soql += ' ORDER BY '+sortExp+' '+sortType;
            // Fetch Order Intake to show as line details
            for(AggregateResult res : (List<AggregateResult>)Database.query(soql)){
                Territory__c trr = new Territory__c(Id = (String)res.get('tId'), 
                    Name = (String)res.get('tName'), Territory_Code__c = (String)res.get('tCode'));
                User tm = new User(Id = (String)res.get('tmId'), UserName = (String)res.get('tmName'));
                Order_Intake__c oi = new Order_Intake__c();
                oi.Territory__r = trr;
                oi.TM__r = tm;
                oi.Yesterday_Orders__c = (Double)res.get('yesterdayOrder');
                oi.MTD_Orders__c = (Double)res.get('mtdOrder');
                oi.YTD_Orders__c = (Double)res.get('ytdOrder');
       //         rvpOrderIntakeDetails.add(oi);
            }
        }*/
        }else{
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, 'Please select territory first to see details'));
        }
    }
    
    public void doNothing() {
    
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
    
    
    // Wrapper class to show Non-RVP Details
    public class OrderIntakeWrapper{
            //public Order_Intake__c orderIntake {get; set;}
            public Boolean isExpandAllow {get; set;}
           /* public OrderIntakeWrapper(Order_Intake__c oi, Boolean expand){
                orderIntake = oi;
                isExpandAllow = expand;
            }*/
    }
    
    // Wrapper class to show RVP Details
    public class RVPOrderIntakeWrapper{
            public String regionId {get; set;}
            public String reagionName {get; set;}
            public Double yesterdayOrder {get; set;}
            public Double MTDOrder {get; set;}
            public Double YTDOrder {get; set;}
            public Boolean isExpandAllow {get; set;}
            
            public RVPOrderIntakeWrapper(AggregateResult agg, Boolean expand){
                regionId = (String)agg.get('regionId');
                reagionName = (String)agg.get('regionName');
                yesterdayOrder = (Double)agg.get('yesterdayOrders');
                MTDOrder = (Double)agg.get('mtdOrders');
                YTDOrder = (Double)agg.get('ytdOrders');
                isExpandAllow = expand;
            }
    }
}