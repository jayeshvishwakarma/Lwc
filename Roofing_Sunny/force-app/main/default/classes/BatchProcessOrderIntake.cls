/*******************************************************************************
Name                    : BatchProcessOrderIntake.cls
Created Date    : 25th Aug, 2014
Description     : Batch class which is responsible to create Order_Intake__c 
                    and Order_Intake_Line__c records for reporting
*******************************************************************************/
global class BatchProcessOrderIntake implements Database.Batchable<sObject>, Database.Stateful{

   // global Map<String, List<Hierarchy_Matrix__c>> hierarchyMatrix;
    global Date yearStartDate;
    global Date monthStartDate;
    global Date yesterdayDate;
    // Start Method : Initialization
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Fetch old Order Intake Items which will be no more required now.
     
        //List<Order_Intake__c> oldOrderIntakes = new List<Order_Intake__c>([Select Id, Name From 
                                   // Order_Intake__c ]);
                                    //Order_Intake__c Where CreatedDate <= YESTERDAY ]);
        // Deleting old Order Intake, if exist
      //  if(oldOrderIntakes.size() > 0){
           // delete oldOrderIntakes;
     //   } 
        
        //Initialize global variables
        yearStartDate = Date.newInstance(System.Today().year(), 1, 1);
        monthStartDate = Date.newInstance(System.Today().year(), System.Today().month(), 1);
        Datetime dt = System.now();
                String dayOfWeek = dt.format('E');
        if(dayOfWeek.trim().equalsIgnoreCase('Mon')){
            yesterdayDate = System.Today().addDays(-3);
        }else if(dayOfWeek.trim().equalsIgnoreCase('Sun')){
            yesterdayDate = System.Today().addDays(-2);
        }else{
            yesterdayDate = System.Today().addDays(-1);
        }

    /*    hierarchyMatrix = new Map<String, List<Hierarchy_Matrix__c>>();

        for(Hierarchy_Matrix__c hm : [Select Id, Territory__c, TM__C, DM__c, RM__c, PC__c, RVP__c, PC_2__c From Hierarchy_Matrix__c]){
            if(!hierarchyMatrix.containsKey(hm.Territory__c)){
                hierarchyMatrix.put(hm.Territory__c, new List<Hierarchy_Matrix__c>());
            }
            hierarchyMatrix.get(hm.Territory__c).add(hm);
        }
    */    
        // Fetching All existing territories to process 
        String soql = 'Select Id, Name, Region__c, Territory_Code__c, Type__c From Territory__c';
        return Database.getQueryLocator(soql);
    }
    
    // Execute Method : Main Execution
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        Set<String> orderStatuses = new Set<String>{'SHIPPED', 'ENTERED', 'CONFIRMED','PICKED','BILLED','CREDIT HOLD'}; 
        List<Competitors__c> compititorList = [SELECT ID,Name,Competitor__c FROM Competitors__c];
        String excludeCompetitors = '';
        for(Territory__c territory : (List<Territory__c>)scope){
            excludeCompetitors = '';
            if(compititorList.size()>0){
                for(Competitors__c c : compititorList){
                    if(excludeCompetitors=='' || String.isEmpty(excludeCompetitors)){
                        excludeCompetitors = ' AND (NOT Order.Ship_To_Account__r.Name LIKE \''+c.Competitor__c+'%\')';
                    }else{
                        excludeCompetitors += ' AND (NOT Order.Ship_To_Account__r.Name LIKE \''+c.Competitor__c+'%\')';
                    }
                }
            }

            /*if(hierarchyMatrix.containsKey(territory.Id)){
                for(Hierarchy_Matrix__c hm : hierarchyMatrix.get(territory.Id)){
                    // Initialize Order Intake Item
                //    Order_Intake__c orderIntake = new Order_Intake__c();
                  //  orderIntake.Territory__c = territory.Id;
                  //  orderIntake.TM__c = hm.TM__c;
                   // orderIntake.Yesterday_Orders__c = 0;
                    //orderIntake.MTD_Orders__c = 0;
                   // orderIntake.YTD_Orders__c = 0;
                    // Find all Ship-To Accouns associated with current territory
                    Set<String> shipToAccs = UtilityClass.fetchShipToAccounts(territory.Id);
                    
                    //Fetch All Order Associated with Ship-To : For YTD
                    String query = 'SELECT SUM(Selling_Quantity__c) YTD_Amount FROM OrderItem WHERE Order.Order_Entry_Date__c >= :yearStartDate'
                                +' AND Selling_UOM__c!=\'LB\' AND Order.Order_Entry_Date__c <= :yesterdayDate AND Order.Order_Status__c  IN : orderStatuses'
                                +' AND Order.Ship_To_Account__c IN :shipToAccs AND (Order.Order_Type__c = \'ZOR\' OR Order.Order_Type__c = \'ZTP\' )'
                                +' AND TM_Number__c = \''+territory.Territory_Code__c+'\'';
                    query += excludeCompetitors;
                    List<AggregateResult> ytdDetails = Database.query(query);
                    if(ytdDetails != null && ytdDetails.size() > 0){
                       // orderIntake.YTD_Orders__c = ((Decimal)ytdDetails.get(0).get('YTD_Amount'));
                       // orderIntake.YTD_Orders__c = orderIntake.YTD_Orders__c == null ? 0 : orderIntake.YTD_Orders__c;
                    }
                        
                    //Fetch All Order Associated with Ship-To : For MTD
                    query = 'SELECT SUM(Selling_Quantity__c) MTD_Amount FROM OrderItem WHERE Order.Order_Entry_Date__c >= :monthStartDate'
                            +' AND Selling_UOM__c!=\'LB\' AND Order.Order_Entry_Date__c <= :yesterdayDate AND Order.Order_Status__c  IN : orderStatuses'
                            +' AND Order.Ship_To_Account__c IN :shipToAccs AND (Order.Order_Type__c = \'ZOR\' OR Order.Order_Type__c = \'ZTP\')'
                            +' AND TM_Number__c = \''+territory.Territory_Code__c+'\''+excludeCompetitors;
                    List<AggregateResult> mtdDetails = Database.query(query);
                    if(mtdDetails != null && mtdDetails.size() > 0){
                    //    orderIntake.MTD_Orders__c = (Decimal)mtdDetails.get(0).get('MTD_Amount');
                      //  orderIntake.MTD_Orders__c = orderIntake.MTD_Orders__c == null ? 0 : orderIntake.MTD_Orders__c;
                    }
                    
                    Double yesterdayAmount = 0;
                    //List<Order_Intake_Line__c> orderIntakeLines = new List<Order_Intake_Line__c>();
                    //Fetch All Order Lines Associated with Order.Ship-To : For Yesterday's Orde
                    query = 'SELECT Id, Selling_Quantity__c, Quantity__c, Order.Sold_To__c FROM OrderItem WHERE Order.Order_Entry_Date__c = :yesterdayDate'
                            +' AND Selling_UOM__c!=\'LB\' AND Order.Order_Status__c IN: orderStatuses AND Order.Ship_To_Account__c IN :shipToAccs'
                            +' AND (Order.Order_Type__c = \'ZOR\' OR Order.Order_Type__c = \'ZTP\') AND TM_Number__c = \''+territory.Territory_Code__c+'\''+excludeCompetitors;
                    for(OrderItem oli : Database.query(query)){
                            Order_Intake_Line__c oil = new Order_Intake_Line__c();
                            oil.Order_For__c = oli.Order.Sold_To__c;
                            oil.Yesterday_Orders__c = oli.Selling_Quantity__c;
                            orderIntakeLines.add(oil);
                            yesterdayAmount += oli.Selling_Quantity__c;
                    }
                    //orderIntake.Yesterday_Orders__c = yesterdayAmount;
                    
                    // Creating Order Intake record for Current Territory
                  //  insert orderIntake;
                    
                    // Creating Order Intake Line Record for Current Territory
                    if(orderIntakeLines.size() > 0){
                        for(Order_Intake_Line__c oil : orderIntakeLines){
                         //  oil.Order_Intake__c = orderIntake.Id;
                        }
                        insert orderIntakeLines;
                    }
                    //Added This Break so we can always have exactly one record per Territory, this is to handle Multiple TM issue
                    break;
                }
            } else{
                    // Initialize Order Intake Item
                  //  Order_Intake__c orderIntake = new Order_Intake__c();
                   // orderIntake.Territory__c = territory.Id; 
                   // orderIntake.Yesterday_Orders__c = 0;
                   // orderIntake.MTD_Orders__c = 0;
                   // orderIntake.YTD_Orders__c = 0;
                    
                    // Find all Ship-To Accouns associated with current territory
                    List<Account> shipToAccs = new List<Account>([SELECT Id, Name FROM Account WHERE ParentId != null  
                        AND Hierarchy_Level_BPCS__c = :Constants.SHIP_TO AND Status__c = :Constants.ACTIVE     
                        AND (Mechanical_Territory__c = :territory.Id OR Finishing_Territory__c = :territory.Id)]);
                    
                    //Fetch All Order Associated with Ship-To : For YTD
                    String query = 'SELECT SUM(Selling_Quantity__c) YTD_Amount FROM OrderItem WHERE Order.Order_Entry_Date__c >= :yearStartDate AND Selling_UOM__c!=\'LB\''
                        +' AND Order.Order_Entry_Date__c <= :yesterdayDate AND Order.Order_Status__c IN: orderStatuses AND Order.Ship_To_Account__c IN :shipToAccs'
                        +' AND (Order.Order_Type__c = \'ZOR\' OR Order.Order_Type__c = \'ZTP\') AND TM_Number__c = \''+territory.Territory_Code__c+'\''+excludeCompetitors;
                    List<AggregateResult> ytdDetails = Database.query(query);
                    if(ytdDetails != null && ytdDetails.size() > 0){
                       // orderIntake.YTD_Orders__c = ((Decimal)ytdDetails.get(0).get('YTD_Amount'));
                       // orderIntake.YTD_Orders__c = orderIntake.YTD_Orders__c == null ? 0 : orderIntake.YTD_Orders__c;
                    }
                        
                    //Fetch All Order Associated with Ship-To : For MTD
                    query = 'SELECT SUM(Selling_Quantity__c) MTD_Amount FROM OrderItem WHERE Order.Order_Entry_Date__c >= :monthStartDate AND Selling_UOM__c!=\'LB\''
                        +' AND Order.Order_Entry_Date__c <= :yesterdayDate AND Order.Order_Status__c  IN: orderStatuses AND Order.Ship_To_Account__c IN :shipToAccs'
                        +' AND (Order.Order_Type__c = \'ZOR\' OR Order.Order_Type__c = \'ZTP\') AND TM_Number__c = \''+territory.Territory_Code__c+'\''+excludeCompetitors;
                    List<AggregateResult> mtdDetails = Database.query(query);
                    if(mtdDetails != null && mtdDetails.size() > 0){
                      //  orderIntake.MTD_Orders__c = (Decimal)mtdDetails.get(0).get('MTD_Amount');
                      //  orderIntake.MTD_Orders__c = orderIntake.MTD_Orders__c == null ? 0 : orderIntake.MTD_Orders__c;
                    }
                    
                    //Fetch All Order Lines Associated with Order.Ship-To : For Yesterday's Orde
                    query = 'SELECT Id, Selling_Quantity__c, Quantity__c, Order.Sold_To__c FROM OrderItem WHERE Order.Order_Entry_Date__c = :yesterdayDate'
                        +' AND Selling_UOM__c!=\'LB\' AND Order.Order_Status__c IN : orderStatuses AND Order.Ship_To_Account__c IN :shipToAccs'
                        +' AND (Order.Order_Type__c = \'ZOR\' OR Order.Order_Type__c = \'ZTP\') AND TM_Number__c = \''+territory.Territory_Code__c+'\''+excludeCompetitors;
                    Double yesterdayAmount = 0;
                 //  List<Order_Intake_Line__c> orderIntakeLines = new List<Order_Intake_Line__c>();
                    //for(OrderItem oli : Database.query(query)){
                           // Order_Intake_Line__c oil = new Order_Intake_Line__c();
                            //oil.Order_For__c = oli.Order.Sold_To__c;
                            //oil.Yesterday_Orders__c = oli.Selling_Quantity__c;
                            //orderIntakeLines.add(oil);
                            //yesterdayAmount += oli.Selling_Quantity__c;
                    //}
                   // orderIntake.Yesterday_Orders__c = yesterdayAmount;
                    
                    // Creating Order Intake record for Current Territory
                   // insert orderIntake;
                    
                    // Creating Order Intake Line Record for Current Territory
                    //if(orderIntakeLines.size() > 0){
                        //for(Order_Intake_Line__c oil : orderIntakeLines){
                          //  oil.Order_Intake__c = orderIntake.Id;
                        //}
                       // insert orderIntakeLines;
                    //}
            }*/
        }
    }
    
    // Finish Method : FInalization
    global void finish(Database.BatchableContext BC){
        
    }
}