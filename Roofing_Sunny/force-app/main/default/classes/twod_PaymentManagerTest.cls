@isTest
public class twod_PaymentManagerTest {
    
    public static testmethod void testGetlaborCost(){
        CreateRSMeans();
        string productId = CreateWarrantyProduct();
        insert new twod__WOD__c(
            Name='Enable OnPolicyChange',twod__isTriggered__c= false
        );
        insert new twod_TriggerControl__c(SetupOwnerId=UserInfo.getOrganizationId(), 
                                          twod_Payment_Trigger__c=true,
                                          twod_AccountCreationTrigger__c=true,
                                          twod_AccountCreationWarrantyTransferTrig__c=true,
                                          twod_AnswerTrigger__c=true,
                                          twod_ClaimInterestedPartiesTrigger__c=true,
                                          twod_ClaimTrigger__c=true,
                                          twod_RecordSharingTrigger__c=true
                                         );        
        insert new Certain_Teed__c(
            Name='isDev',BooleanValue__c = false
        );
        insert new Certain_Teed__c(
            Name='isRoofing',BooleanValue__c = true
        );
        insert new Certain_Teed__c(
            Name='isSiding',BooleanValue__c = false
        );
        
         insert new twod_payment__c(
            Name='max',Limit__c= 44000
        );
        
        Test.startTest();
        twod_PaymentManager.GetLaborCost(True, productId,'State','25077', 'City', false, false, false);
        twod_PaymentManager.GetMaterialCost('state', '25077', 'city', productId);
        twod_PaymentManager.GetPitchRoofCost(4);
        //system.assert(laborCost >0);
        Test.stopTest();
    }
    
    public static testMethod void testGetMaterialPrice(){
        insert new twod_TriggerControl__c(SetupOwnerId=UserInfo.getOrganizationId(), 
                                          twod_Payment_Trigger__c=true,
                                          twod_AccountCreationTrigger__c=true,
                                          twod_AccountCreationWarrantyTransferTrig__c=true,
                                          twod_AnswerTrigger__c=true,
                                          twod_ClaimInterestedPartiesTrigger__c=true,
                                          twod_ClaimTrigger__c=true,
                                          twod_RecordSharingTrigger__c=true
                                         );        
        
         insert new twod__WOD__c(
            Name='Enable OnPolicyChange',twod__isTriggered__c= false
        );
        insert new WSDefaults__c(
            Customer_Price_Endpoint__c='http://sap-wddev.certainteed.com/sap/EQR100/SFDCPricingRequest'
        );
        insert new Certain_Teed__c(
            Name='isDev',BooleanValue__c = false
        );
        insert new Certain_Teed__c(
            Name='isRoofing',BooleanValue__c = true
        );
        insert new Certain_Teed__c(
            Name='isSiding',BooleanValue__c = false
        );
        
        
         insert new twod_payment__c(
            Name='max',Limit__c= 44000
        );
        
        string productId = CreateWarrantyProduct();
        string accId = CreateAccount();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WSMockResponse(WSMockResponse.Type.SIDINGPRICECALL));
        WS.PricingSuccess success = twod_PaymentManager.GetMaterialPrice(false, productId, null,accId, accId);
        //system.assert(success != null);
         Test.stopTest();
    }
    
    public static testMethod void testSendOrderToSAPCreditDebit(){
        insert new twod__WOD__c(
            Name='Enable OnPolicyChange',twod__isTriggered__c= false
        );
        insert new WSDefaults__c(
            Order_Endpoint__c='http://sap-wddev.certainteed.com/qa/WarrantyOrder'
        );
        
        
        insert new twod_TriggerControl__c(SetupOwnerId=UserInfo.getOrganizationId(), 
                                          twod_Payment_Trigger__c=true,
                                          twod_AccountCreationTrigger__c=true,
                                          twod_AccountCreationWarrantyTransferTrig__c=true,
                                          twod_AnswerTrigger__c=true,
                                          twod_ClaimInterestedPartiesTrigger__c=true,
                                          twod_ClaimTrigger__c=true,
                                          twod_RecordSharingTrigger__c=true
                                         );        
         insert new twod_payment__c(
            Name='max',Limit__c= 44000
        );
        Test.setMock(HttpCalloutMock.class, new WSMockResponse(WSMockResponse.Type.ORDERCALLSUCCESS));
        
        string paymentId = CreatePayment('Credit/Debit');
        Test.startTest();

        SAP_Log__c log = twod_PaymentManager.SendOrderToSAP(paymentId);
        Test.stopTest();
        system.assert(log != null);
        system.debug('--debug--' +log);
        system.assert(log.Request__c != null);
        system.debug('*****Log request****' +log.Request__c);
        system.debug('*****Log Error****' +log.Error__c);
    }
    public static testMethod void testSendOrderToSAPFreeMaterial(){
        insert new twod__WOD__c(
            Name='Enable OnPolicyChange',twod__isTriggered__c= false
        );
        insert new WSDefaults__c(
            Order_Endpoint__c='http://sap-wddev.certainteed.com/qa/WarrantyOrder'
        );
        
        insert new twod_TriggerControl__c(SetupOwnerId=UserInfo.getOrganizationId(), 
                                          twod_Payment_Trigger__c=true,
                                          twod_AccountCreationTrigger__c=true,
                                          twod_AccountCreationWarrantyTransferTrig__c=true,
                                          twod_AnswerTrigger__c=true,
                                          twod_ClaimInterestedPartiesTrigger__c=true,
                                          twod_ClaimTrigger__c=true,
                                          twod_RecordSharingTrigger__c=true
                                         );        
         insert new twod_payment__c(
            Name='max',Limit__c= 44000
        );
        Test.setMock(HttpCalloutMock.class, new WSMockResponse(WSMockResponse.Type.ORDERCALLSUCCESS));
        
        string paymentId = CreatePayment2('Free Material');
        Test.startTest();

        SAP_Log__c log = twod_PaymentManager.SendOrderToSAP(paymentId);
        Test.stopTest();
        system.assert(log != null);
    }
    
    public static testMethod void testSendOrderToSAPCreditDebit2(){
        insert new twod__WOD__c(
            Name='Enable OnPolicyChange',twod__isTriggered__c= false
        );
        insert new WSDefaults__c(
            Order_Endpoint__c='http://sap-wddev.certainteed.com/qa/WarrantyOrder'
        );
        
        insert new twod_TriggerControl__c(SetupOwnerId=UserInfo.getOrganizationId(), 
                                          twod_Payment_Trigger__c=true,
                                          twod_AccountCreationTrigger__c=true,
                                          twod_AccountCreationWarrantyTransferTrig__c=true,
                                          twod_AnswerTrigger__c=true,
                                          twod_ClaimInterestedPartiesTrigger__c=true,
                                          twod_ClaimTrigger__c=true,
                                          twod_RecordSharingTrigger__c=true
                                         );        
         insert new twod_payment__c(
            Name='max',Limit__c= 44000
        );
        Test.setMock(HttpCalloutMock.class, new WSMockResponse(WSMockResponse.Type.ORDERCALLSUCCESS));
        
        string paymentId = CreatePayment3('Credit/Debit');
        Test.startTest();

        SAP_Log__c log = twod_PaymentManager.SendOrderToSAP(paymentId);
        Test.stopTest();
    }
    
    public static testMethod void testSendOrderToSAPCreditDebit3(){
        insert new twod__WOD__c(
            Name='Enable OnPolicyChange',twod__isTriggered__c= false
        );
        insert new WSDefaults__c(
            Order_Endpoint__c='http://sap-wddev.certainteed.com/qa/WarrantyOrder'
        );
        insert new twod_TriggerControl__c(SetupOwnerId=UserInfo.getOrganizationId(), 
                                          twod_Payment_Trigger__c=true,
                                          twod_AccountCreationTrigger__c=true,
                                          twod_AccountCreationWarrantyTransferTrig__c=true,
                                          twod_AnswerTrigger__c=true,
                                          twod_ClaimInterestedPartiesTrigger__c=true,
                                          twod_ClaimTrigger__c=true,
                                          twod_RecordSharingTrigger__c=true
                                         );        
        
         insert new twod_payment__c(
            Name='max',Limit__c= 44000
        );
        
        Test.setMock(HttpCalloutMock.class, new WSMockResponse(WSMockResponse.Type.ORDERCALLSUCCESS));
        
        string paymentId = CreatePayment4('Gelco');
        Test.startTest();

        SAP_Log__c log = twod_PaymentManager.SendOrderToSAP(paymentId);
        Test.stopTest();
    }
    
    private static string CreateAccount(){
        Account acct = new Account(Name='TestAcc');
        acct.BillingCity='Noida';
        acct.BillingCountry='India';
        acct.BillingPostalCode='00501';
        acct.BillingState='UP';
        acct.BillingStreet='sdfsfsf';
        //acct.Account_Number__C = 'Test';
        insert acct;
        return acct.Id;
    }
    
    private static string CreatePayment(string paymentType){
        
        string productId =  CreateWarrantyProduct();
        string accId = CreateAccount();
        //Added by Mahima
        Exchange_Rate__c exc = new Exchange_Rate__c();
        exc.Currency__c = 'USD';
        exc.Date__c  = System.Today();
        exc.Exchange_Rate__c = 1;
        Insert exc;
        
        insert new ClassAction_Amount__c(Name='Warranty',Value__c= 74);
           twod__Policy_Definition__c pd = new twod__Policy_Definition__c();
        pd.Name='dasdad';
        pd.twod__Description__c='dsfsdsf';
        pd.Maxiumum_Liability__c=1020;
        pd.twod__Months_Covered__c=2;
        pd.twod__Active_From__c=system.today()-200;
        pd.twod__Active_Until__c=system.today()+300;
        pd.twod__Status__c='Active';
        insert pd;
        
        twod__Claim__c claim = new twod__Claim__c();
        claim.name = 'test';
        //claim.recordtypeId=claimrecordMap.get('Standard');
        //claim.twod__Claim_Status__c= 'test';
        claim.Producing_Plant__c='avery';
        claim.Product_Group__c='Residential Roofing'; 
        claim.twod__Warranty_Product__c=productId;
        claim.twod__Date_of_Failure__c=system.today();
        claim.Country_BL__c='United States';//Added by Mahima
        claim.Ship_To_Party__c = accId;
        claim.Sold_To_Party__c = accId;
        claim.twod__Claim_Status__c = 'Approved';
        claim.twod__Applicable_Policy__c=pd.Id;
        claim.Install_Date__c=system.today()-100;
        claim.Postal_code_BL__c='25077';
        //claim.State_BL__c='Alaska (AK)';
        claim.City_BL__c='dasda';
        insert claim;
        
        twod_PaymentManager.GetProrateMaterialCost(claim.Id);
        twod_PaymentManager.GetWarrantyClassActionCost(claim.Id);
        twod_PaymentManager.GetReleasorClassActionCost(claim.Id);
        twod_PaymentManager.GetTransferClassActionCost(claim.Id);
        
        Claim_Interested_Parties__c CIP = new Claim_Interested_Parties__c(Claim__c=claim.Id,Comments__c='dsfs',Type__c='Contractor',Zip_Code__c='12345');
        insert CIP;
        
        map<String,id> recordMap_Payment = new map<String,id>();
        List<RecordType> rtList = new List<RecordType>();
        rtList = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where SobjectType = 'Payment__c'];
          if(rtList.size() > 0){
              for(RecordType r : rtList){ 
              recordMap_Payment.put(r.Name, r.id); 
          }
        } 
        
        Payment__c pay1 = new Payment__c();
        pay1.recordtypeId =recordMap_Payment.get(paymentType);
        pay1.Claim__c = claim.Id;
        pay1.Settlement_Type__c ='WAR - Warranty Adjustment';
        pay1.Order_Reason__c = 'Z48 - Warranty Credit';
        pay1.Order_Type__c = 'Credit Memo';
        pay1.Approved__c = false;
        pay1.Released_To_SAP__c = false;
        pay1.Payment_Type__c = paymentType;
        pay1.Shipping_Condition__c = 'Z2 - Less than Truckload';
        pay1.Exchange_Rate__c=1.00;
        pay1.Total_Amount_Converted__c = 100.00;
        
        pay1.comments__C = 'Helloerrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr' +
                            'rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr' + 
                            'rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr' +
                            'rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr' +
                            'rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr';
        insert pay1;
        
        Payment_Line__c line = new Payment_Line__c();
        line.Payment__c = pay1.Id;
        line.Settlement_Basis__c = 'Material';
        line.Quantity__c = 1;
        line.Amount__c =100.0;
        line.Amount_Converted__c =100.0;
        line.UOM__c ='CAR';
        line.Material_Code__c ='WARRANTY-0269';
        insert line;
        return pay1.Id;
    }
    
    private static string CreatePayment2(string paymentType){
        
        string productId =  CreateWarrantyProduct();
        string accId = CreateAccount();
        //Added by Mahima
        Exchange_Rate__c exc = new Exchange_Rate__c();
        exc.Currency__c = 'USD';
        exc.Date__c  = System.Today();
        exc.Exchange_Rate__c = 1;
        Insert exc;
        
        twod__Claim__c claim = new twod__Claim__c();
        claim.name = 'test';
        //claim.recordtypeId=claimrecordMap.get('Standard');
        //claim.twod__Claim_Status__c= 'test';
        claim.Producing_Plant__c='avery';
        claim.Product_Group__c='Residential Roofing'; 
        claim.twod__Warranty_Product__c=productId;
        claim.twod__Date_of_Failure__c=system.today();
        claim.Country_BL__c='United States';   //Added by Mahima
        claim.Ship_To_Party__c = accId;
        claim.Sold_To_Party__c = accId;
        claim.twod__Claim_Status__c = 'Approved';
        insert claim;
        
        map<String,id> recordMap_Payment = new map<String,id>();
        List<RecordType> rtList = new List<RecordType>();
        rtList = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where SobjectType = 'Payment__c'];
          if(rtList.size() > 0){
              for(RecordType r : rtList){ 
              recordMap_Payment.put(r.Name, r.id); 
          }
        } 
        
        Payment__c pay1 = new Payment__c();
        pay1.recordtypeId =recordMap_Payment.get(paymentType);
        pay1.Claim__c = claim.Id;
        pay1.Settlement_Type__c ='MTL - Free Material Settlement';
        pay1.Order_Reason__c = 'Z10 - Claim';
        pay1.Order_Type__c = 'Credit Memo';
        pay1.Approved__c = false;
        pay1.Released_To_SAP__c = false;
        pay1.Payment_Type__c = paymentType;
        pay1.Shipping_Condition__c = 'Z2 - Less than Truckload';
        pay1.comments__C = 'Hello';
        insert pay1;
        
        Payment_Line__c line = new Payment_Line__c();
        line.Payment__c = pay1.Id;
        line.Settlement_Basis__c = 'Material';
        line.Quantity__c = 1;
        line.Amount__c =100.0;
        line.Amount_Converted__c =100.0;
        line.UOM__c ='CAR';
        line.Material_Code__c ='WARRANTY-0269';
        insert line;
        return pay1.Id;
    }
    
    private static string CreatePayment3(string paymentType){
        
        string productId =  CreateWarrantyProduct();
        string accId = CreateAccount();
        
        //Added by Mahima
        Exchange_Rate__c exc = new Exchange_Rate__c();
        exc.Currency__c = 'USD';
        exc.Date__c  = System.Today();
        exc.Exchange_Rate__c = 1;
        Insert exc;
        
        twod__Claim__c claim = new twod__Claim__c();
        claim.name = 'test';
        //claim.recordtypeId=claimrecordMap.get('Standard');
        //claim.twod__Claim_Status__c= 'test';
        claim.Producing_Plant__c='avery';
        claim.Product_Group__c='Residential Roofing'; 
        claim.twod__Warranty_Product__c=productId;
        claim.twod__Date_of_Failure__c=system.today();
        claim.Country_BL__c='United States';
        claim.Ship_To_Party__c = accId;
        claim.Sold_To_Party__c = accId;
        claim.twod__Claim_Status__c = 'Approved';
        insert claim;
        
        map<String,id> recordMap_Payment = new map<String,id>();
        List<RecordType> rtList = new List<RecordType>();
        rtList = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where SobjectType = 'Payment__c'];
          if(rtList.size() > 0){
              for(RecordType r : rtList){ 
              recordMap_Payment.put(r.Name, r.id); 
          }
        } 
        
        Payment__c pay1 = new Payment__c();
        pay1.recordtypeId =recordMap_Payment.get(paymentType);
        pay1.Claim__c = claim.Id;
        pay1.Settlement_Type__c ='WAR - Warranty Adjustment';
        pay1.Order_Reason__c = 'Z48 - Warranty Credit';
        pay1.Order_Type__c = 'Credit Memo';
        pay1.Approved__c = false;
        pay1.Released_To_SAP__c = false;
        pay1.Payment_Type__c = paymentType;
        pay1.Shipping_Condition__c = 'Z2 - Less than Truckload';
        pay1.comments__C = 'Hello';
        insert pay1; 
        return pay1.Id;
    }
    
    private static string CreatePayment4(string paymentType){
        
        string productId =  CreateWarrantyProduct();
        string accId = CreateAccount();
        
        //Added by Mahima
        Exchange_Rate__c exc = new Exchange_Rate__c();
        exc.Currency__c = 'USD';
        exc.Date__c  = System.Today();
        exc.Exchange_Rate__c = 1;
        Insert exc;
        
        twod__Claim__c claim = new twod__Claim__c();
        claim.name = 'test';
        //claim.recordtypeId=claimrecordMap.get('Standard');
        //claim.twod__Claim_Status__c= 'test';
        claim.Producing_Plant__c='avery';
        claim.Product_Group__c='Residential Roofing'; 
        claim.twod__Warranty_Product__c=productId;
        claim.twod__Date_of_Failure__c=system.today();
        claim.Country_BL__c='United States';//Added by Mahima
        claim.Ship_To_Party__c = accId;
        claim.Sold_To_Party__c = accId;
        claim.twod__Claim_Status__c = 'Approved';
        insert claim;
        
        map<String,id> recordMap_Payment = new map<String,id>();
        List<RecordType> rtList = new List<RecordType>();
        rtList = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where SobjectType = 'Payment__c'];
          if(rtList.size() > 0){
              for(RecordType r : rtList){ 
              recordMap_Payment.put(r.Name, r.id); 
          }
        } 
        
        Payment__c pay1 = new Payment__c();
        pay1.recordtypeId =recordMap_Payment.get(paymentType);
        pay1.Claim__c = claim.Id;
        pay1.Settlement_Type__c ='WAR - Warranty Adjustment';
        pay1.Order_Reason__c = 'Z48 - Warranty Credit';
        pay1.Order_Type__c = 'Credit Memo';
        pay1.Approved__c = false;
        pay1.Released_To_SAP__c = false;
        pay1.Payment_Type__c = paymentType;
        pay1.Shipping_Condition__c = 'Z2 - Less than Truckload';
        pay1.comments__C = 'Hello';
        pay1.Organization__c='dsfsdf';
        pay1.RemitTo_FirstName__c='dsfsdgsdgd';
        pay1.RemitTo_LastName__c='dfdsgdfsg';
        pay1.RemitTo_Address1__c='fsdfs';
        pay1.RemitTo_City__c='dsaasd';
        pay1.RemitTo_State__c='dsfsdfs';
        pay1.RemitTo_ZipCode__c='00501';
        pay1.RemitTo_Country__c='United States';
        pay1.Exchange_Rate__c=1.00;
        pay1.Total_Amount_Converted__c = 100.00;
        insert pay1;
        
        Payment_Line__c line = new Payment_Line__c();
        line.Payment__c = pay1.Id;
        line.Settlement_Basis__c = 'Material';
        line.Quantity__c = 1;
        line.Amount__c =100.0;
        line.Amount_Converted__c =100.0;
        line.UOM__c ='CAR';
        line.Material_Code__c ='WARRANTY-0269';
        insert line;
        return pay1.Id;
    }
    
    private static string CreateWarrantyProduct(){
        
       // Market_Class__c mc = new Market_Class__c();
       // mc.Market_Class_Code__c='dsfsdf';
       // mc.Sequence_No__c='sd';
        //insert mc;
        
        Product_Type__c pt = new Product_Type__c();
       // pt.Market_Class__c=mc.Id;
        pt.IDC__c='sdfsf';
        pt.Warranty_Labor_Cost__c=500;
        pt.Warranty_Material_Cost__c=400;
        pt.Steep_Pitch__c=545;
        pt.Demolish_Tearoff__c=343;
        insert pt;
        
        Product2 product = new Product2();
        product.Name = 'Test';
        product.ProductCode = '403675';
        product.Product_Line__c = '11';
        product.MKT_CLASS__c = 'fdgfdssd';
        product.Product_Type__c=pt.Id;
        insert product;
        
        twod__warranty_product__c wp = new twod__warranty_product__c();
        wp.Name = product.productCode;
        wp.twod__Product_Name__c = 'Test';
        wp.Product__c = product.Id;
        wp.twod__Units_of_Measure__c='squares';
        wp.twod__Track_Type__c='Non-Serialized';
        wp.Product_Type__c=pt.Id;
           
        insert wp;      
        return wp.Id;
    }
    
    private static void CreateRSMeans(){
        RSMeans__c rs = new RSMeans__c();
        rs.Zip__c = '250';
        rs.State__c = 'State';
        rs.City__c = 'City';
        rs.Location_Factor__c = 0.97;
        insert rs;
    }
    
    private static testmethod void Call_GetProrateMaterialLaborCost(){
        
        CreateRSMeans();
        string productId = CreateWarrantyProduct();    
        string accId = CreateAccount();
        
        insert new twod__WOD__c(
            Name='Enable OnPolicyChange',twod__isTriggered__c= false
        );
        
        insert new twod_TriggerControl__c(SetupOwnerId=UserInfo.getOrganizationId(), 
                                          twod_Payment_Trigger__c=true,
                                          twod_AccountCreationTrigger__c=true,
                                          twod_AccountCreationWarrantyTransferTrig__c=true,
                                          twod_AnswerTrigger__c=true,
                                          twod_ClaimInterestedPartiesTrigger__c=true,
                                          twod_ClaimTrigger__c=true,
                                          twod_RecordSharingTrigger__c=true
                                         );        
        
        insert new Certain_Teed__c(
            Name='isDev',BooleanValue__c = false
        );
        insert new Certain_Teed__c(
            Name='isRoofing',BooleanValue__c = true
        );
        insert new Certain_Teed__c(
            Name='isSiding',BooleanValue__c = false
        );
        
        
         insert new twod_payment__c(
            Name='max',Limit__c= 44000
        );
        
        twod__Policy_Definition__c pd = new twod__Policy_Definition__c();
        pd.Name='dasdad';
        pd.twod__Description__c='dsfsdsf';
        pd.Maxiumum_Liability__c=1020;
        pd.twod__Months_Covered__c=2;
        pd.twod__Active_From__c=system.today()-200;
        pd.twod__Active_Until__c=system.today()+300;
        pd.twod__Status__c='Active';
        insert pd;
        
        twod__Claim__c claim = new twod__Claim__c();
        claim.name = 'test';
        //claim.recordtypeId=claimrecordMap.get('Standard');
        //claim.twod__Claim_Status__c= 'test';
        claim.Producing_Plant__c='avery';
        claim.Product_Group__c='Residential Roofing'; 
        claim.twod__Warranty_Product__c=productId;
        claim.twod__Date_of_Failure__c=system.today();
        claim.Ship_To_Party__c = accId;
        claim.Sold_To_Party__c = accId;
        claim.twod__Claim_Status__c = 'Approved';
        claim.twod__Applicable_Policy__c=pd.Id;
        claim.Install_Date__c=system.today()-100;
        claim.Postal_code_BL__c='25077';
        //claim.State_BL__c='Alaska (AK)';
        claim.City_BL__c='dasda';
        insert claim;
        
        system.debug('Value of Product ID ******** ' + claim.twod__Warranty_Product__c);
        
        twod_PaymentManager.GetProrateMaterialLaborCost(claim.Id);
    }

}