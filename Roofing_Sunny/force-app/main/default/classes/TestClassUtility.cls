/*******************************************************************************
Name                    : TestClassUtility.cls
Created Date    : 26th Aug, 2014
Descriprion     : Utility Class to create test data
*******************************************************************************/
@isTest
public class TestClassUtility {
    public static Map<String, Map<String, String>> recordTypeMap {
        get{
            if(recordTypeMap == null){
                recordTypeMap = new Map<String, Map<String, String>>();
                for(RecordType rt : [Select Id, Name, DeveloperName, SObjectType From RecordType]){
                    if(!recordTypeMap.containsKey(rt.SObjectType)){
                        recordTypeMap.put(rt.SObjectType, new Map<String, String>());
                    }
                    if(!recordTypeMap.get(rt.SObjectType).containsKey(rt.DeveloperName)){
                        recordTypeMap.get(rt.SObjectType).put(rt.DeveloperName,rt.Id);
                    }
                }
            }
            return recordTypeMap;
        }
        protected set;
    }
    // Created Region__c
    public static Region__c createRegion(String name, String code, Boolean isInsert){
        Region__c reg = new Region__c(Name = name, Region_Code__c = code);
        if(isInsert)
            insert reg;
        return reg;
    }
    
    // Created Territory__c
    public static Territory__c createTerritory(String name, String code, String territoryType, String regionId, Boolean isInsert){
        Territory__c trr = new Territory__c(Name = name, Territory_Code__c = code, Type__c = territoryType, Region__c = regionId);
        if(isInsert)
            insert trr;
        return trr;
    }
    
    // Create Test User
    public static User createTestUser(String profileName, String alias, String email, String lastName, String userName, String role, Boolean isInsert){
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName];
        User newUser = new User(Alias = alias, Email=email, 
            EmailEncodingKey='UTF-8', LastName=lastName, 
            LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName= 'U'+ system.now().format('yyMMddhhmmss') + userName, Role__c = role);
            
        if(isInsert)
            insert newUser;
        return newUser;
    }
    
    // Create Hierarchy_Matrix__c

/*    public static Hierarchy_Matrix__c createHierarchyMatrix(String territoryId, String tmUserId, String dmUserId, String rmUserId, String pcUserId, String rvpUserId, Boolean isInsert){
        Hierarchy_Matrix__c hierarchy = new Hierarchy_Matrix__c(Territory__c = territoryId, TM__c = tmUserId, DM__c = dmUserId, RM__c = rmUserId, PC__c = pcUserId, RVP__c = rvpUserId);
        if(isInsert)
            insert hierarchy;
        return hierarchy;
    }
*/    
    public static Account createAccount(String name, String parentAccId, String recordTypeName, String accType, String accSubType, String territoryId, Boolean isInsert){
        Account acc = new Account();
        acc.Name = name;
        acc.ParentId = parentAccId;
        acc.RecordTypeId = recordTypeMap.get('Account').get('Indirect Accounts');
//        acc.RecordTypeId = recordTypeMap.get('Account').get(recordTypeName);
        acc.Type = accType;
        acc.Account_Sub_Type__c = accSubType;
        acc.Mechanical_Territory__c = territoryId;
        acc.LOB__c = '1501'; // Added Sales Org field value to insert - Sandip - 11/02/2018
        if(isInsert)
            insert acc;
        return acc;
    }
    public static Case createCase(String type, String sub, String subType, String status, String contId,String orderId, Boolean isInsert){
        Case c = new Case();
        c.Type = type;
        c.Subject = sub;
        c.SubType__c = subType;
        c.Status = status;
        c.ContactId = contId;
        c.Order__c = orderId;
        if(isInsert)
            insert c;
        return c;
    }
    public static Region__c createReg(String name,String BPCSCode, String RMId, String PCId, Boolean isInsert){
        Region__c r = new Region__c();
        r.BPCS_Code__c = BPCSCode;
        r.Regional_Sales_Manager__c = RMId;
        r.Pricing_Coordinator__c = PCId;
        r.Name = name;
        if(isInsert)
            insert r;
        return r;
    }
    
    public static Order createOrder(String name, Date entryDate, String orderForId, String status, Double amount, String shipToId, Boolean isInsert){
        Order ordr = new Order();
        ordr.Name = name;
        ordr.EffectiveDate = entryDate;
        ordr.Sold_To__c = orderForId;
        ordr.Status = status;
        ordr.Order_Total__c = amount;
        ordr.Ship_To__c = shipToId;
        if(isInsert)
            insert ordr;
        return ordr;
    }
    
    public static OrderItem createOrderLineItem(String orderId, Double lineNumber, Double quantity, Double price, Boolean isInsert){
        OrderItem ob = new OrderItem();
        ob.OrderId = orderId;
        ob.Line_Number__c = lineNumber;
        ob.Qty_Ordered__c = quantity;
        ob.Net_Price__c = price;
        if(isInsert)
            insert ob;
        return ob; 
    }
    
  /*  public static Order_Intake__c createOrderIntake(String territoryId, String tmUserId, Double yesterdayOrders, Double mtd, Double ytd, Boolean isInsert){
        Order_Intake__c ob = new Order_Intake__c();
        ob.Territory__c = territoryId;
        ob.TM__c = tmUserId;
        ob.Yesterday_Orders__c = yesterdayOrders;
        ob.MTD_Orders__c = mtd;
        ob.YTD_Orders__c = ytd;
        if(isInsert)
            insert ob;
        return ob; 
    }
*/    
   /* public static Order_Intake_Line__c createOrderIntakeLine(String orderIntakeId, String orderForId, Double yesterdayOrders, Boolean isInsert){
        Order_Intake_Line__c ob = new Order_Intake_Line__c();
        //ob.Order_Intake__c = orderIntakeId;
        ob.Order_For__c = orderForId;
        ob.Yesterday_Orders__c = yesterdayOrders;
        if(isInsert)
            insert ob;
        return ob; 
    }*/
    /*public static Large_Job_Quote__c  createLargeJobQuote(String territory,String regionManager, String ProjectName,String ProjectType,String city,String state,String deliverTo,String billingMethod,String TotalSquareRolls,String status,Date fUpDate,Date sDate,Date eDate,Boolean isInsert) {
        Large_Job_Quote__c lq = new Large_Job_Quote__c ();
         lq.Territory__c = territory;
         lq.Project_Name__c = ProjectName;
         lq.Project_Type__c = ProjectType;
         lq.City__c = city;
         lq.State__c = state;
         lq.Deliver_To__c = deliverTo;
         lq.Billing_Method__c = billingMethod;
         lq.Total_Squares_Rolls__c = TotalSquareRolls;
         lq.Start_Date__c = sDate ;
         lq.Completion_Date__c = sDate ;
         lq.Status__c = status;
         lq.Region_Manager__c = regionManager;
         lq.Follow_up_Date__c = fUpDate;
         if(isInsert)
            insert lq;
        return lq; 
    }*/
    
    /*public static LJQ_Approval_History__c createLJQApprovalHis(String LargeJobQuoteId,Boolean isInsert){
        LJQ_Approval_History__c ljAP = new LJQ_Approval_History__c();
        //ljAP.Large_Job_Quote__c = LargeJobQuoteId;
        //bpcr.Customer__c = Name;
        if(isInsert)
            insert ljAP;
        return ljAP; 
    }*/
    
    /*public static LJQ_Product_Escalator__c createLJQProductEscalator(String LJQProduct,Decimal percentChange,Decimal QuotedPrice,Date startDate,Date endDate,Boolean isInsert) {
        LJQ_Product_Escalator__c lpe = new LJQ_Product_Escalator__c();
        lpe.LJQ_Product__c = LJQProduct;
        lpe.Change__c = percentChange;
        lpe.Quoted_Price__c = QuotedPrice;
        lpe.Start__c = startDate;
        lpe.End__c = endDate;
        if(isInsert)
            insert lpe;
        return lpe;
    }*/
    
    /*public static LJQ_Product__c createLJQProduct(/*String LJQuote,Integer quantity, String warehouse,String productType ,Boolean isInsert) {
        LJQ_Product__c lp  = new LJQ_Product__c();
        lp.Quantity__c = quantity;
        //lp.Large_Job_Quote__c = LJQuote;
        lp.Warehouse__c = warehouse;
        lp.Product_Type__c= productType;
        if(isInsert)
            insert lp;
        return lp; 
    }*/
    
    /*public static LJQ_Color__c createLJQColor(String LJProductId ,/*String ColorId, Boolean isInsert) {
        LJQ_Color__c lp  = new LJQ_Color__c();
        lp.LJQ_Product__c = LJProductId;
        //lp.Color__c = ColorId;
        if(isInsert)
            insert lp;
        return lp; 
    }*/
    
    public static Area_Price__c createPriceArea(String PriceArea,String territory,Boolean isInsert) {
        Area_Price__c pa = new Area_Price__c();
        pa.Name = PriceArea;
       // pa.Territory__c = territory;
        if(isInsert)
            insert pa;
        return pa;
    }
  /*  public static LJQ_Contract__c createLJQContract(/*String LargeJobQuote,Boolean isInsert) {
        LJQ_Contract__c cn  = new LJQ_Contract__c();
        //cn.Large_Job_Quote__c = LargeJobQuote;
        
         if(isInsert)
            insert cn;
        return cn; 
    }*/
   /* public static LJQ_Competitor__c createLJQCompetitor(String LargeJobQuote,String product,String customerId,String contactId,String cname,Decimal price,Boolean isInsert) {
        LJQ_Competitor__c cn  = new LJQ_Competitor__c();
        cn.Large_Job_Quote__c = LargeJobQuote;
        cn.Product__c = product; 
        cn.Price__c = price; 
        cn.Customer__c = customerId; 
        cn.Contact__c = contactId; 
        cn.Company_Name__c  = cname;
         if(isInsert)
            insert cn;
        return cn; 
    }*/
    
   /* public static LJQ_Customer__c createLJQCustomer(Boolean include,/*String LargeJobQuote,String soldTo,String orderFor, String ShipTo, Boolean isInsert) {
        LJQ_Customer__c cn  = new LJQ_Customer__c();
        //cn.Large_Job_Quote__c = LargeJobQuote;
        //cn.Contact__c = contact;
        cn.Include__c = include;
        cn.Sold_To__c = soldTo;
        cn.Order_For__c= orderFor;
        cn.Ship_To__c = shipTo;
        
         if(isInsert)
            insert cn;
        return cn; 
    }*/
    public static Plants__c createWarehouse(String plantCode, String LogisticsCoordinator, Boolean isInsert) {
        Plants__c wh  = new Plants__c();
        //wh.Plant_Code__c = plantCode;
        wh.Logistics_Coordinator__c =  LogisticsCoordinator;
         
         if(isInsert)
            insert wh;
        return wh; 
    }
    public static States__c createStates(String name,String abbrev, Boolean isInsert) {
        States__c state  = new States__c();
        state.Name = name;
        state.Abbrivation__c = abbrev;
        if(isInsert)
            insert state;
        return state; 
    }
    public static Product_Type__c createProductType(String name,String idc, String ProductTypeCode ,String Marketclass, Boolean isInsert) {
        Product_Type__c pt  = new Product_Type__c();
        pt.Name =name;
        pt.IDC__c = idc;
        pt.Product_Type_Code__c= ProductTypeCode;
       // pt.Market_Class__c= Marketclass;
         if(isInsert)
            insert pt;
        return pt; 
    }
    
    /*public static Market_Class__c createMarketClass(String marketclass  ,Boolean isInsert) {
        Market_Class__c mc  = new Market_Class__c();
        mc.Market_Class_Code__c= marketclass;
         if(isInsert)
            insert mc;
        return mc; 
    }*/
   
    public static Contact createcontact(String lastname, String account,String mailingstate,String email,String phone, Boolean isInsert)  {
       Contact con = new Contact();
            
       con.FirstName = 'test';
       con.LastName = lastname;
       con.AccountId = account;
       con.MailingState = mailingstate;
       con.Email = email;
       con.Phone = phone;
        
       if(isInsert)
        insert con;
        return con; 
        
    }
    
   /* public static  LJQ_Contact__c createcontact(String contact,Boolean isInsert){
        LJQ_Contact__c lcn = new  LJQ_Contact__c();
        //lcn.Name= name;
        lcn.Contact__c =contact;
        if(isInsert)
            insert lcn;
        return lcn; 
    }*/
     
    /*public static Product_Stocked_Plant__c createProductStockedPlant(String StockedPlant,Boolean isInsert)  {
        Product_Stocked_Plant__c psp = new Product_Stocked_Plant__c();
        //psp.Name = name;
        psp.Stocked_Plant__c = StockedPlant;
        if(isInsert)
            insert psp;
        return psp; 
    }*/
    
    public static Product2 createProduct2(String name,Boolean isInsert)  {
        Product2 product = new Product2();
        product.Name = name;
        if(isInsert)
            insert product;
        return product; 
    }
   /* public static Price_Change_Request__c createPriceChangeRequest(String TerritoryId,Boolean isInsert){
        Price_Change_Request__c pcr = new Price_Change_Request__c();
        pcr.Territory__c = TerritoryId;
        if(isInsert)
            insert pcr;
        return pcr; 
    }*/
   /* public static PCR_Approval_History__c createPCRApprovalHis(String PCRId,Boolean isInsert){
        PCR_Approval_History__c pcr = new PCR_Approval_History__c();
        pcr.Price_Change_Request__c = PCRId;
        if(isInsert)
            insert pcr;
        return pcr; 
    }*/
    /*public static BPCR_Product__c createBlanketPCRProduct(String Name,String BPCRId,Boolean isInsert){
        BPCR_Product__c bpcrProd = new BPCR_Product__c();
        bpcrProd.Name = Name;
        bpcrProd.Blanket_PCR__c = BPCRId;
        if(isInsert)
            insert bpcrProd;
        return bpcrProd; 
    }
    public static Blanket_PCR__c createBlanketPCR(String customerId,String distributor,Boolean isInsert){
        Blanket_PCR__c bpcr = new Blanket_PCR__c();
        bpcr.Customer__c = customerId;
        bpcr.Distributor__c = distributor;
        //bpcr.Customer__c = Name;
        if(isInsert)
            insert bpcr;
        return bpcr; 
    }
    public static BPCR_Approval_History__c createBlanketPCRApprovalHis(String BlanketPCRId,Boolean isInsert){
        BPCR_Approval_History__c bpcr = new BPCR_Approval_History__c();
        bpcr.Blanket_PCR__c = BlanketPCRId;
        //bpcr.Customer__c = Name;
        if(isInsert)
            insert bpcr;
        return bpcr; 
    }*/
   /* public static PCR_Product__c createPCRProduct(String name,String pcrId,Boolean isInsert){
        PCR_Product__c pcr = new PCR_Product__c();
        //pcr.Name = name;
        //pcr.Price_Change_Request__c = pcrId;
        if(isInsert)
            insert pcr;
        return pcr; 
    } */
}