/*******************************************************************************
Name                    : TestOrderIntakeReport.cls
Created Date    : 26th Aug, 2014
Descriprion     : Test Class for OrderIntakeReport.cls
*******************************************************************************/
@isTest
private class TestOrderIntakeReport {
    public static List<Region__c> regions;
    public static List<Territory__c> territories;
    public static User TMUser;
    public static User RVPUser;
   // public static List<Hierarchy_Matrix__c> hierarchy;
    public static List<Account> soldToAccs;
    public static List<Account> orderForAccs;
    public static List<Account> shipToAccs;
    public static List<Order> orders;
    public static List<OrderItem> orderLines;
    //public static List<Order_Intake__c> orderIntakes;
   // public static List<Order_Intake_Line__c> orderIntakeLines;

/*  
    static testMethod void myOrderIntakeBatch() {
    createTestData();
    Test.startTest();
    // Test Batch Class which will create Order intake Records
    BatchProcessOrderIntake jobToDo = new BatchProcessOrderIntake();
        //Execute batch with batch size 10 - For Testing Only
        Database.executeBatch(jobToDo, 10);
        
        //Manually Create Order_Intake records
        createOrderIntake();
        List<Order_Intake__c> lst = new List<Order_Intake__c>([Select Id From Order_Intake__c]);
        System.assert(lst.size() > 0);
        
        // Test Order Intake report Page - With TM User
        System.runAs(TMUser){
            Pagereference pg = Page.OrderIntakeReport;
            Test.setCurrentPage(pg);
            OrderIntakeReport con = new OrderIntakeReport();
            System.assert(con.hierarchyMatrix != null);
            System.assert(con.territoryType.size() > 0);
            con.selectedTerriroryType = 'Residential';
            con.fetchOrderIntake();
            System.assert(con.orderIntake != null);
            System.assert(con.orderIntake.size() > 0);
            con.detailId = con.orderIntake.get(0).orderIntake.Id;
            con.fetchDetails();
        }
        //Test Order Intake Report - With RVP User
        System.runAs(RVPUser){
            Pagereference pg = Page.OrderIntakeReport;
            Test.setCurrentPage(pg);
            OrderIntakeReport con = new OrderIntakeReport();
            System.assert(con.hierarchyMatrix != null);
            System.assert(con.territoryType.size() > 0);
            con.selectedTerriroryType = 'Commercial';
            con.fetchOrderIntake();
            System.assert(con.orderIntake != null);
            System.assert(con.orderIntake.size() > 0);
            con.detailId = con.orderIntake.get(0).orderIntake.Id;
            con.fetchDetails();
        }
        Test.stopTest();
  }
  
  static testMethod void myUnitTestTMUser() {
    createTestData();
    Test.startTest();
    
        //Manually Create Order_Intake records
        createOrderIntake();
        List<Order_Intake__c> lst = new List<Order_Intake__c>([Select Id From Order_Intake__c]);
        System.assert(lst.size() > 0);
        
        // Test Order Intake report Page - With TM User
        System.runAs(TMUser){
            Pagereference pg = Page.OrderIntakeReport;
            Test.setCurrentPage(pg);
            OrderIntakeReport con = new OrderIntakeReport();
            System.assert(con.hierarchyMatrix != null);
            System.assert(con.territoryType.size() > 0);
            con.selectedTerriroryType = 'Residential';
            con.fetchOrderIntake();
            System.assert(con.orderIntake != null);
            System.assert(con.orderIntake.size() > 0);
            con.detailId = con.orderIntake.get(0).orderIntake.Id;
            con.fetchDetails();
        }
        Test.stopTest();
  }
  
  static testMethod void myUnitTestRVPUser() {
    createTestData();
    Test.startTest();
    
        //Manually Create Order_Intake records
        createOrderIntake();
        List<Order_Intake__c> lst = new List<Order_Intake__c>([Select Id From Order_Intake__c]);
        System.assert(lst.size() > 0);
        
        //Test Order Intake Report - With RVP User
        System.runAs(RVPUser){
            Pagereference pg = Page.OrderIntakeReport;
            Test.setCurrentPage(pg);
            OrderIntakeReport con = new OrderIntakeReport();
            System.assert(con.hierarchyMatrix != null);
            System.assert(con.territoryType.size() > 0);
            con.selectedTerriroryType = 'Commercial';
            con.fetchOrderIntake();
            System.assert(con.rvpOrderIntake != null);
            System.assert(con.rvpOrderIntake.size() > 0);
            con.detailId = con.rvpOrderIntake.get(0).regionId;
            con.fetchDetails();
        }
        Test.stopTest();
  }
  
  private static void createTestData(){
    TMUser = TestClassUtility.createTestUser('System Administrator Integration', 'TMUSR', 'testTm@user.com', 'TM USER', 'testTm@user.com', 'TM', true);
    RVPUser = TestClassUtility.createTestUser('System Administrator Integration', 'RVPUSR', 'testRvp@user.com', 'RVP USER', 'testRvp@user.com', 'RVP', true);
    
    regions = new List<Region__c>();
    regions.add(TestClassUtility.createRegion('TestClass1','TC1',false));
    regions.add(TestClassUtility.createRegion('TestClass2','TC2',false));
    insert regions;
    
    territories = new List<Territory__c>();
    territories.add(TestClassUtility.createTerritory('TRR1', 'TRR1','Commercial', regions.get(0).Id, false));
    territories.add(TestClassUtility.createTerritory('TRR2', 'TRR2','Residential', regions.get(0).Id, false));
    territories.add(TestClassUtility.createTerritory('TRR3', 'TRR3','Commercial', regions.get(1).Id, false));
    territories.add(TestClassUtility.createTerritory('TRR4', 'TRR4','Residential', regions.get(1).Id, false));
    insert territories;
    
    hierarchy = new List<Hierarchy_Matrix__c>();
    for(Integer i=0; i<4; i++){
        hierarchy.add(TestClassUtility.createHierarchyMatrix(territories.get(i).Id, TMUser.Id, null, null, null, RVPUser.Id, false));
    }
    insert hierarchy;
    
    soldToAccs = new List<Account>();
    for(Integer i=0; i<4; i++){
        soldToAccs.add(TestClassUtility.createAccount('Sold_To_Acc_'+i,null, 'All_Other_Accounts', 'Other', 'Other', territories.get(i).Id, false));
    }
    insert soldToAccs;
    
    orderForAccs = new List<Account>();
    for(Integer i=0; i<4; i++){
        orderForAccs.add(TestClassUtility.createAccount('Order_For_Acc_'+i, soldToAccs.get(i).Id, 'All_Other_Accounts', 'Other', 'Other', territories.get(i).Id, false));
    }
    insert orderForAccs;
    
    shipToAccs = new List<Account>();
    for(Integer i=0; i<4; i++){
        shipToAccs.add(TestClassUtility.createAccount('Ship_To_Acc_'+i, orderForAccs.get(i).Id, 'All_Other_Accounts', 'Other', 'Other', territories.get(i).Id, false));
    }
    insert shipToAccs;
    
    orders = new List<Order>();
    for(Integer i=0; i<4; i++){
        orders.add(TestClassUtility.createOrder('Order_'+i+'_1', System.Today().addDays(-1), orderForAccs.get(i).Id, 'PICKED', 800, shipToAccs.get(i).id, false));
        orders.add(TestClassUtility.createOrder('Order_'+i+'_2', System.Today().addDays(-10), orderForAccs.get(i).Id, 'PICKED', 800, shipToAccs.get(i).id, false));
        orders.add(TestClassUtility.createOrder('Order_'+i+'_3', System.Today().addDays(-30), orderForAccs.get(i).Id, 'PICKED', 800, shipToAccs.get(i).id, false));
        orders.add(TestClassUtility.createOrder('Order_'+i+'_4', System.Today().addDays(-45), orderForAccs.get(i).Id, 'PICKED', 800, shipToAccs.get(i).id, false));
    }
    insert orders;
    
    orderLines = new List<OrderItem>();
    for(Integer i=0; i<4; i++){
        orderLines.add(TestClassUtility.createOrderLineItem(orders.get(i*4).Id, 1, 1, 300, false));
        orderLines.add(TestClassUtility.createOrderLineItem(orders.get(i*4).Id, 2, 1, 500, false));
    }
    insert orderLines; 
  }
  
  private static void createOrderIntake(){
    List<Order_Intake__c> orderIntakes = new List<Order_Intake__c>();
    for(Integer i=0; i<4; i++){
        orderIntakes.add(TestClassUtility.createOrderIntake(territories.get(i).Id, TMUser.Id, 800, 1500, 2500, false));
    }
    insert orderIntakes;
    
    List<Order_Intake_Line__c> orderIntakeLines = new List<Order_Intake_Line__c>();
    for(Integer i=0; i<4; i++){
        orderIntakeLines.add(TestClassUtility.createOrderIntakeLine(orderIntakes.get(i).Id, orderForAccs.get(i).Id, 300, false));
        orderIntakeLines.add(TestClassUtility.createOrderIntakeLine(orderIntakes.get(i).Id, orderForAccs.get(i).Id, 500, false));
    }
    insert orderIntakeLines;
  } 
  */
    private static void createUser(){
        TMUser = TestClassUtility.createTestUser('System Administrator Integration', 'TMUSR', 'testTm@user.com', 'TM USER', 'testTm@user.com', 'TM', true);
        RVPUser = TestClassUtility.createTestUser('System Administrator Integration', 'RVPUSR', 'testRvp@user.com', 'RVP USER', 'testRvp@user.com', 'RVP', true);
        /*TMUser = new User();
        TMUser = [Select Id, Name, Email, Role__c from User where id = '005K0000001zALPIA2'];
        RVPUser = new User();
        RVPUser = [Select Id, Name, Email, Role__c from User where id = '005K0000001zALMIA2'];*/
    }
    private static void createTestData(){
        regions = new List<Region__c>();
        regions.add(TestClassUtility.createRegion('TestClass1','TC1',false));
        regions.add(TestClassUtility.createRegion('TestClass2','TC2',false));
        insert regions;
        
        territories = new List<Territory__c>();
        territories.add(TestClassUtility.createTerritory('TRR1', 'TRR1','Commercial', regions.get(0).Id, false));
        territories.add(TestClassUtility.createTerritory('TRR2', 'TRR2','Residential', regions.get(0).Id, false));
        territories.add(TestClassUtility.createTerritory('TRR3', 'TRR3','Commercial', regions.get(1).Id, false));
        territories.add(TestClassUtility.createTerritory('TRR4', 'TRR4','Residential', regions.get(1).Id, false));
        insert territories;
        
       /* hierarchy = new List<Hierarchy_Matrix__c>();
        for(Integer i=0; i<4; i++){
            hierarchy.add(TestClassUtility.createHierarchyMatrix(territories.get(i).Id, null, null, null, null, RVPUser.Id, false));
            hierarchy.add(TestClassUtility.createHierarchyMatrix(territories.get(i).Id, TMUser.Id, null, null, null, null, false));
        }
        insert hierarchy; */
        
        soldToAccs = new List<Account>();
        for(Integer i=0; i<4; i++){
            soldToAccs.add(TestClassUtility.createAccount('Sold_To_Acc_'+i,null, 'All_Other_Accounts', 'Other', 'Other', territories.get(i).Id, false));
        }
        insert soldToAccs;
        
        orderForAccs = new List<Account>();
        for(Integer i=0; i<4; i++){
            orderForAccs.add(TestClassUtility.createAccount('Order_For_Acc_'+i, soldToAccs.get(i).Id, 'All_Other_Accounts', 'Other', 'Other', territories.get(i).Id, false));
        }
        insert orderForAccs;
        
        shipToAccs = new List<Account>();
        for(Integer i=0; i<4; i++){
            shipToAccs.add(TestClassUtility.createAccount('Ship_To_Acc_'+i, orderForAccs.get(i).Id, 'All_Other_Accounts', 'Other', 'Other', territories.get(i).Id, false));
        }
        insert shipToAccs;
        
        orders = new List<Order>();
        for(Integer i=0; i<4; i++){
            orders.add(TestClassUtility.createOrder('Order_'+i+'_1', System.Today().addDays(-1), orderForAccs.get(i).Id, 'PICKED', 800, shipToAccs.get(i).id, false));
            orders.add(TestClassUtility.createOrder('Order_'+i+'_2', System.Today().addDays(-10), orderForAccs.get(i).Id, 'PICKED', 800, shipToAccs.get(i).id, false));
            orders.add(TestClassUtility.createOrder('Order_'+i+'_3', System.Today().addDays(-30), orderForAccs.get(i).Id, 'PICKED', 800, shipToAccs.get(i).id, false));
            orders.add(TestClassUtility.createOrder('Order_'+i+'_4', System.Today().addDays(-45), orderForAccs.get(i).Id, 'PICKED', 800, shipToAccs.get(i).id, false));
        }
        insert orders;
        
        orderLines = new List<OrderItem>();
        for(Integer i=0; i<4; i++){
            orderLines.add(TestClassUtility.createOrderLineItem(orders.get(i*4).Id, 1, 1, 300, false));
            orderLines.add(TestClassUtility.createOrderLineItem(orders.get(i*4).Id, 2, 1, 500, false));
        }
        insert orderLines;
        
       // orderIntakes = new List<Order_Intake__c>();
        for(Integer i=0; i<4; i++){
       //     orderIntakes.add(TestClassUtility.createOrderIntake(territories.get(i).Id, TMUser.Id, 800, 1500, 2500, false));
         //   orderIntakes.add(TestClassUtility.createOrderIntake(territories.get(i).Id, RVPUser.Id, 800, 1500, 2500, false));
        }
       // insert orderIntakes;
        
     //   orderIntakeLines = new List<Order_Intake_Line__c>();
        for(Integer i=0; i<4; i++){
          //  orderIntakeLines.add(TestClassUtility.createOrderIntakeLine(orderIntakes.get(i).Id, orderForAccs.get(i).Id, 300, false));
          //  orderIntakeLines.add(TestClassUtility.createOrderIntakeLine(orderIntakes.get(i).Id, orderForAccs.get(i).Id, 500, false));
        }
       // insert orderIntakeLines;
        
    }
    
    static testMethod void methodA(){
        createUser();   
        OrderIntakeReport obj = new OrderIntakeReport();
        System.runAs(RVPUser){
            createTestData();
            String TerType = territories[0].Type__c;
            String TerRegion = territories[0].Region__c;    
            //Apexpages.currentPage().getParameters().put('sortExp','Territory__r.Region__r.Name');
            Apexpages.currentPage().getParameters().put('sortType','asc');
            Apexpages.currentPage().getParameters().put('type','Residential');
            Apexpages.currentPage().getParameters().put('detailId',territories[1].Region__c);
            Apexpages.currentPage().getParameters().put('RVP','Yes');
            OrderIntakeReport oir = new OrderIntakeReport();
            oir.fetchOrderIntake();
            System.debug(UserInfo.getUserId());
            System.debug(UtilityClass.userDetail);
            //oir.detailId = oir.orderIntake.get(0).orderIntake.Id;
            oir.fetchDetails();
           // OrderIntakeReport.OrderIntakeWrapper oiw = new OrderIntakeReport.OrderIntakeWrapper(orderIntakes[0],true);
           /* String soql = 'Select Territory__r.Region__c regionId, Territory__r.Region__r.Name regionName, '+ 
                                    ' SUM(Yesterday_Orders__c) yesterdayOrders, '+
                                    ' SUM(MTD_Orders__c) mtdOrders, SUM(YTD_Orders__c) ytdOrders '+
                                ' From Order_Intake__c '+ 
                                ' GROUP BY Territory__r.Region__c, Territory__r.Region__r.Name ';*/
           // List<AggregateResult> agg = (List<AggregateResult>)Database.query(soql);
            //AggregateResult aggTemp = agg[0];
            //OrderIntakeReport.RVPOrderIntakeWrapper rvp = new OrderIntakeReport.RVPOrderIntakeWrapper(aggTemp,true);
        }
        System.runAs(TMUser){
            createTestData();
            String TerType = territories[0].Type__c;
            String TerRegion = territories[0].Region__c;    
            
            OrderIntakeReport oir = new OrderIntakeReport();
            oir.selectedTerriroryType = 'Residential';
            oir.fetchOrderIntake();
            System.debug(UserInfo.getUserId());
            System.debug(UtilityClass.userDetail);
            //oir.detailId = orderIntakes[0].Id;
            oir.fetchDetails();
          //  OrderIntakeReport.OrderIntakeWrapper oiw = new OrderIntakeReport.OrderIntakeWrapper(orderIntakes[0],true);
           /* String soql = 'Select Territory__r.Region__c regionId, Territory__r.Region__r.Name regionName, '+ 
                                    ' SUM(Yesterday_Orders__c) yesterdayOrders, '+
                                    ' SUM(MTD_Orders__c) mtdOrders, SUM(YTD_Orders__c) ytdOrders '+
                                ' From Order_Intake__c '+ 
                                ' GROUP BY Territory__r.Region__c, Territory__r.Region__r.Name ';*/
          //  List<AggregateResult> agg = (List<AggregateResult>)Database.query(soql);
            //AggregateResult aggTemp = agg[0];
//            OrderIntakeReport.RVPOrderIntakeWrapper rvp = new OrderIntakeReport.RVPOrderIntakeWrapper(aggTemp,true);
        }
    }
    static testMethod void methodB(){
        createUser();
        System.runAs(RVPUser){
            createTestData();
            //Apexpages.currentPage().getParameters().put('sortExp','Territory__r.Name');
            Apexpages.currentPage().getParameters().put('sortType','asc');
            Apexpages.currentPage().getParameters().put('type','none');
            //Apexpages.currentPage().getParameters().put('detailId',orderIntakes[0].Id);
            Apexpages.currentPage().getParameters().put('RVP','Yes');
            String TerType = territories[0].Type__c;
            String TerRegion = territories[0].Region__c;    
            
            OrderIntakeReport oir = new OrderIntakeReport();
            oir.fetchOrderIntake();
            System.debug(UserInfo.getUserId());
            System.debug(UtilityClass.userDetail);
            //oir.detailId = orderIntakes[0].Id;
            oir.fetchDetails();
           // OrderIntakeReport.OrderIntakeWrapper oiw = new OrderIntakeReport.OrderIntakeWrapper(orderIntakes[0],true);
            /*String soql = 'Select Territory__r.Region__c regionId, Territory__r.Region__r.Name regionName, '+ 
                                    ' SUM(Yesterday_Orders__c) yesterdayOrders, '+
                                    ' SUM(MTD_Orders__c) mtdOrders, SUM(YTD_Orders__c) ytdOrders '+
                                ' From Order_Intake__c '+ 
                                ' GROUP BY Territory__r.Region__c, Territory__r.Region__r.Name ';*/
           // List<AggregateResult> agg = (List<AggregateResult>)Database.query(soql);
          //  AggregateResult aggTemp = agg[0];
           // OrderIntakeReport.RVPOrderIntakeWrapper rvp = new OrderIntakeReport.RVPOrderIntakeWrapper(aggTemp,true);
        }
        System.runAs(TMUser){
            createTestData();
            String TerType = territories[0].Type__c;
            String TerRegion = territories[0].Region__c;    
            //Apexpages.currentPage().getParameters().put('sortExp','Order_For__r.Name');
            Apexpages.currentPage().getParameters().put('sortType','desc');
            Apexpages.currentPage().getParameters().put('type','none');
          //  Apexpages.currentPage().getParameters().put('detailId',orderIntakes[0].Id);
            Apexpages.currentPage().getParameters().put('RVP','No');
            OrderIntakeReport oir = new OrderIntakeReport();
            oir.fetchOrderIntake();
            System.debug(UserInfo.getUserId());
            System.debug(UtilityClass.userDetail);
            //oir.detailId = oir.orderIntake.get(0).orderIntake.Id;
            Apexpages.currentPage().getParameters().put('sortExp','Order_For__r.Name');
            oir.fetchDetails();
          //  OrderIntakeReport.OrderIntakeWrapper oiw = new OrderIntakeReport.OrderIntakeWrapper(orderIntakes[0],true);
            /*String soql = 'Select Territory__r.Region__c regionId, Territory__r.Region__r.Name regionName, '+ 
                                    ' SUM(Yesterday_Orders__c) yesterdayOrders, '+
                                    ' SUM(MTD_Orders__c) mtdOrders, SUM(YTD_Orders__c) ytdOrders '+
                                ' From Order_Intake__c '+ 
                                ' GROUP BY Territory__r.Region__c, Territory__r.Region__r.Name ';*/
            //List<AggregateResult> agg = (List<AggregateResult>)Database.query(soql);
           // AggregateResult aggTemp = agg[0];
            //OrderIntakeReport.RVPOrderIntakeWrapper rvp = new OrderIntakeReport.RVPOrderIntakeWrapper(aggTemp,true);
        }
    }
    
    static testMethod void methodC(){
        createUser();
        System.runAs(RVPUser){
            createTestData();
            String TerType = territories[0].Type__c;
            String TerRegion = territories[0].Region__c;    
            Apexpages.currentPage().getParameters().put('sortExp','Order_For__r.Name');
            Apexpages.currentPage().getParameters().put('sortType','asc');
            Apexpages.currentPage().getParameters().put('type','none');
            //Apexpages.currentPage().getParameters().put('detailId',);
            Apexpages.currentPage().getParameters().put('RVP','Yes');
            OrderIntakeReport oir = new OrderIntakeReport();
            oir.fetchOrderIntake();
            System.debug(UserInfo.getUserId());
            System.debug(UtilityClass.userDetail);
            //oir.detailId = oir.orderIntake.get(0).orderIntake.Id;
            oir.fetchDetails();
            //OrderIntakeReport.OrderIntakeWrapper oiw = new OrderIntakeReport.OrderIntakeWrapper(orderIntakes[0],true);
           /* String soql = 'Select Territory__r.Region__c regionId, Territory__r.Region__r.Name regionName, '+ 
                                    ' SUM(Yesterday_Orders__c) yesterdayOrders, '+
                                    ' SUM(MTD_Orders__c) mtdOrders, SUM(YTD_Orders__c) ytdOrders '+
                                ' From Order_Intake__c '+ 
                                ' GROUP BY Territory__r.Region__c, Territory__r.Region__r.Name ';*/
            //List<AggregateResult> agg = (List<AggregateResult>)Database.query(soql);
            //AggregateResult aggTemp = agg[0];
            //OrderIntakeReport.RVPOrderIntakeWrapper rvp = new OrderIntakeReport.RVPOrderIntakeWrapper(aggTemp,true);
        }
        System.runAs(TMUser){
            createTestData();
            String TerType = territories[0].Type__c;
            String TerRegion = territories[0].Region__c;    
            
            OrderIntakeReport oir = new OrderIntakeReport();
            oir.selectedTerriroryType = 'none';
            oir.fetchOrderIntake();
            System.debug(UserInfo.getUserId());
            System.debug(UtilityClass.userDetail);
            //oir.detailId = oir.orderIntake.get(0).orderIntake.Id;
            oir.fetchDetails();
            OrderIntakeReport.emailExcelReport('demo@demo.com;','sub','hi',null);
          //  OrderIntakeReport.OrderIntakeWrapper oiw = new OrderIntakeReport.OrderIntakeWrapper(orderIntakes[0],true);
            /*String soql = 'Select Territory__r.Region__c regionId, Territory__r.Region__r.Name regionName, '+ 
                                    ' SUM(Yesterday_Orders__c) yesterdayOrders, '+
                                    ' SUM(MTD_Orders__c) mtdOrders, SUM(YTD_Orders__c) ytdOrders '+
                                ' From Order_Intake__c '+ 
                                ' GROUP BY Territory__r.Region__c, Territory__r.Region__r.Name ';*/
          //  List<AggregateResult> agg = (List<AggregateResult>)Database.query(soql);
          //  AggregateResult aggTemp = agg[0];
           // OrderIntakeReport.RVPOrderIntakeWrapper rvp = new OrderIntakeReport.RVPOrderIntakeWrapper(aggTemp,true);
        }
    }
}