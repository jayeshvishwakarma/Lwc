global class twod_PaymentController{
    
    public Payment_Line__c currentEdit{get;set;}
    public Payment_Line__c currEditCD {get;set;}
    public string claimId{get;set;}
    public string packageId{get;set;}
    public string claimStatus {get;set;}
    //CT Multi currency changes
    public string plant{get;set;}
    public list<Payment_Line__c> paymentLineList{get;set;}
    public list<Payment_Line__c> allPayLineItem{get;set;}
    public boolean isNew{get;set;}
    public List<String> listOfStrings {get; set;}
    public boolean textField {get;set;}
    public String packageRecordType {get;set;}    
    public String setChar {get;set;}
    public boolean releasedToSap {get;set;}
    public boolean isPaymentApproved {get;set;}
    public string OrderType {get;set;}
    public twod__Warranty_Product__c clmWarrantyProduct {get;set;}
    public String description{get;set;}
    public String BaseUOM{get;set;}
    public String AltUOM{get;set;}        
    public Decimal UOMConversion{get;set;}
    public Decimal Max{get;set;}
    public Decimal maximumLimit{get;set;}
    public Decimal TotalDefectiveQuantity{get;set;}
    public boolean isFreematerialPresent{get;set;}
    public boolean isAltUOM{get;set;}
    public List<SelectOption> UOMList{get;set;}
    public String settlementType{get;set;} 
    //CT Multi currency changes
    public Decimal exchangeRate{get;set;}
    public boolean isCAD {get;set;}
    
    
    
    public twod_PaymentController(ApexPages.StandardController controller) {
        //Description='';
        Certain_Teed__c mcs = Certain_Teed__c.getValues('isSiding');
        TotalDefectiveQuantity=0;
        textField = false;
        if (mcs.BooleanValue__c == true) {
            textField = true;
        }               
        isNew = true;
        paymentLineList = new list<Payment_Line__c>();
        packageId= apexPages.currentPage().getParameters().get('retURL');
        claimId = apexPages.currentPage().getParameters().get('claimURL');
        Payment_Line__c cli = new Payment_Line__c();
        if(packageId!= null && packageId!='/a06/o' ){
            isNew = true;
            packageId= packageId.substring(1,16);
            system.debug('package id'+packageId);
            system.debug('claimId id'+claimId);
            Payment__c pay=new Payment__c();
            pay =[Select claim__c,Total_Weight__c,claim__r.twod__Claim_Status__c,claim__r.ClaimType__c, claim__r.Plant__r.Name from Payment__c where Id =:packageId Limit 1];
            claimId = pay.claim__c;
            claimStatus = pay.claim__r.twod__Claim_Status__c;    
      plant = pay.Claim__r.Plant__r.Name;            
            Decimal TotalWeight=pay.Total_Weight__c;
            Max=[select Name,Limit__c from twod_payment__c where Name ='Max'].Limit__c;         
            maximumLimit=Max-TotalWeight;
        }else{ 
            isNew = false;
            cli = (Payment_Line__c)controller.getrecord();
            claimId = cli.Payment__r.claim__c;
            packageId = cli.Payment__c;
            claimStatus = cli.Payment__r.claim__r.twod__Claim_Status__c;
            Decimal TotalWeight=[Select Total_Weight__c from Payment__c where Id =:packageId Limit 1].Total_Weight__c;
            Max=[select Name,Limit__c from twod_payment__c where Name ='Max'].Limit__c;         
            maximumLimit=Max-TotalWeight;
        }        
        Payment__c payment =  [Select Released_To_SAP__c, Order_Type__c,Settlement_Type__c,Approval_Status__c,Currency__c,Sales_Org__c From Payment__c where Id =: packageId]; 
        releasedToSap = payment.Released_To_SAP__c;
        isPaymentApproved = false;
        if(payment.Approval_Status__c == 'Approved'){
            isPaymentApproved = true;
        }
        
        if(payment.Currency__c == 'CAD' && payment.Sales_Org__c == '1102'){
            isCAD = true;
        }else
            isCAD = false;
        
        OrderType = payment.Order_Type__c; 
        settlementType=payment.Settlement_Type__c; 
        system.debug('irdertype'+OrderType);
        allPayLineItem= [SELECT Payment__r.Exchange_Rate__c, Additional_Story__c,Amount__c,Amount_Converted__c,Comments__c,UOM__c,Demolish_TearOff__c,Previous_Amount__c,Months_Covered__c,Months_Used__c,Material_Name__c,
                         Description__c,Id,Manufacturing_Plant__c,Manufacturing_Plant__r.Id,Manufacturing_Plant__r.Name,Material_Code__c,Material_Number__c,Total_Weight__c,Gross_Weight__c,
                         Name,On_Hold__c,Payment__c,Plant_Code__c,Policy_Requestor__c,Quantity__c,Remit_To__c,Product_Name__c,LocationFactor__c,OriginalPrice__c,
                         Sequence_Number__c,Previous_Recieved_Amount__c ,Settlement_Basis__c,Settlement_Type_new__c,Steep_Pitch__c,is_Primary_Material__c,Payment__r.Claim__r.Quantity__c,
                         Total_Payment_Amount__c,Total_Payment_Amount_Converted__c,Unit_of_Measure__c,Pitch__c,Warranty_Product__c,Calculation_Formula__c,Payment__r.recordType.Name,Payment__r.Settlement_Type__c FROM 
                         Payment_Line__c where Payment__c =: packageId order by createdDate];
        if(allPayLineItem.size()>0){
            packageRecordType = allPayLineItem[0].Payment__r.recordType.Name;
            TotalDefectiveQuantity= allPayLineItem[0].Payment__r.Claim__r.Quantity__c;
            setChar = allPayLineItem[0].Payment__r.Settlement_Type__c.substring(0, 3); 
            //CT Multi currency changes
            exchangeRate = allPayLineItem[0].Payment__r.Exchange_Rate__c;
        }else{
            Payment__c payRec = [Select Exchange_Rate__C, RecordType.Name,Settlement_Type__c,Claim__r.Quantity__c From Payment__c Where Id=: packageId];
            packageRecordType = payRec.RecordType.Name;
            TotalDefectiveQuantity= payRec.Claim__r.Quantity__c;
            setChar = payRec.Settlement_Type__c .substring(0, 3); 
            settlementType=payRec.Settlement_Type__c; 
            //taking Exchange rate from Payment record
            exchangeRate = payRec.Exchange_Rate__c;
            
        }   
        if(packageRecordType == 'Free Material'){
            Integer count=[select count() from Payment_Line__c where Payment__c =: packageId and is_Primary_Material__c=true];
            if(count==0){
                isFreematerialPresent=false;
            }else{
                isFreematerialPresent=true;        
            }
        }
        system.debug('Free Material -- >' + isFreematerialPresent);
        for(Payment_Line__c co:allPayLineItem){
            paymentLineList.add(co);
            system.debug('@@@'+paymentLineList);
        }   
        
        List<Payment__c > packageClmStatus = new List<Payment__c >();
        packageClmStatus =[Select Sales_Org__c,Claim__r.twod__Claim_Status__c,Claim__r.twod__Warranty_Product__c ,Claim__r.twod__Warranty_Product__r.Sales_Org__c from Payment__c where Id =: packageId];
        claimStatus = packageClmStatus[0].Claim__r.twod__Claim_Status__c;

        
        //if(packageClmStatus[0].Claim__r.twod__Warranty_Product__r.Sales_Org__c == payment.Sales_Org__c) 
        list<twod__Warranty_Product__c> wpList = [Select Id,Name from twod__Warranty_Product__c where Id=:packageClmStatus[0].Claim__r.twod__Warranty_Product__c]; //AND Sales_Org__c=:packageClmStatus[0].Sales_Org__c];
        if(!wpList.isEmpty())
            clmWarrantyProduct = wpList[0];
        //added to get policy requester Users
        listOfStrings = new List<String>();
        for(User a: [SELECT id, Name From User Where IsActive = true LIMIT 20]){
            listOfStrings.add(a.Name);
            
        }
        
    }
    
    //Refresh List
    public List<Payment_Line__c> paymentLineList(){
        List<Payment_Line__c> tempList = new List<Payment_Line__c>();
        tempList = [SELECT Additional_Story__c,Amount__c,Amount_Converted__c,Comments__c,UOM__c,Demolish_TearOff__c,Description__c,Id,Material_Name__c,Months_Covered__c,Months_Used__c,Product_Name__c,Payment__r.Claim__r.Quantity__c,
                    Manufacturing_Plant__c,Manufacturing_Plant__r.Id,Pitch__c,Manufacturing_Plant__r.Name,Material_Code__c,Material_Number__c,Name,On_Hold__c,Payment__c,Plant_Code__c,is_Primary_Material__c,
                    Policy_Requestor__c,Previous_Recieved_Amount__c ,Quantity__c,Remit_To__c,Sequence_Number__c,Settlement_Basis__c,Settlement_Type_new__c,Steep_Pitch__c,Total_Payment_Amount__c,Total_Payment_Amount_Converted__c,Calculation_Formula__c,Unit_of_Measure__c,Warranty_Product__c,Previous_Amount__c,
                    Payment__r.recordType.Name,LocationFactor__c,OriginalPrice__c,Total_Weight__c,Gross_Weight__c,payment__r.Total_Weight__c FROM Payment_Line__c where Payment__c =: packageId order by createdDate];
        if(tempList.size()>0){
        Decimal TotalWeight=tempList[0].Payment__r.Total_Weight__c;
           Max=[select Name,Limit__c from twod_payment__c where Name ='Max'].Limit__c;         
        maximumLimit=Max-TotalWeight;
        }
        return tempList;
    }
    
    //User options
    /*CERP-34 :Add Policy Requestor Field to Payment */
    public List<selectOption> getPolicyReqOptions() {
        List<selectOption> options = new List<selectOption>(); 
        options.add(new selectOption('', '- None -')); 
        Id salesUserId=[Select Id from Profile where Name='Sales User' limit 1].Id;
        for (User users :[
            SELECT id, Name From User Where IsActive = true and ProfileId=:salesUserId Order by Name]){ 
                options.add(new selectOption(users.Id, users.Name)); 
            }
        return options; 
    }    
    
    
    //new item
    public void addCostLineItem(){
        
        UOMList=new List<SelectOption>();


        if(packageRecordType !='Credit/Debit'){
            currentEdit = new Payment_Line__c(); 
            currentEdit.Payment__c = packageId; 
            
            if(packageRecordType == 'Check')    
                currentEdit.Product_Filter__c = false;
            else
                currentEdit.Product_Filter__c = true;
            //Setting Payment line Sales_Org from Payment
            if(isCAD)
                currentEdit.Sales_Org__c = '1102';
            else  
                currentEdit.Sales_Org__c = '1501';
                
      
            if((settlementType =='AST - Assistance' || settlementType =='RSS - Cls Action Assistanc') &&  packageRecordType=='Check'){
                if(!isCAD){
                    currentEdit.amount__c=50;
                    currentEdit.amount__c.setScale(2);
                }else {
                    currentEdit.Amount_Converted__c=50;
                    currentEdit.Amount_Converted__c.setScale(2);
                }
              
            } 
            if(settlementType =='DIS - Disposal' && packageRecordType=='Check'){
                if(!isCAD){
                    currentEdit.amount__c=400;
                    currentEdit.amount__c.setScale(2);
                }else {
                    currentEdit.Amount_Converted__c=400;
                    currentEdit.Amount_Converted__c.setScale(2);
                }
        
              }
        
             
            if(setChar == 'WAR' || setChar == 'PRS' || setChar == 'RCR' || setChar == 'RCW' || setChar == 'RCT') {
                    currentEdit.Warranty_Product__c = clmWarrantyProduct.Id;
            }
                
                
            //Setting Default Material Code             
            system.debug('material code'+currentEdit.Material_Code__c);
        }else{            
            currEditCD = new Payment_Line__c(); 
            currEditCD.Payment__c = packageId;            
            currEditCD.Material_Code__c='WARRANTY-' + plant;
            currEditCD.Product_Filter__c= true;

           if(isCAD)
                currEditCD.Sales_Org__c = '1102';
            else    
                currEditCD.Sales_Org__c = '1501'; 
            
        }
    }
    
    //save item 
    public void saveEditedRow(){
        try{
            
            //currentEdit.Product_Name__c=description;
            //currEditCD.Product_Name__c=ProductDescription; 
            if(packageRecordType !='Credit/Debit'){
                Payment__c payment = [Select Id,Settlement_Type__c,Calculation_Formula__c from Payment__c where Id=: packageId];
                currentEdit.Settlement_Type_new__c = payment.Settlement_Type__c;
              
                //currentEdit.Payment__c = packageId;
                system.debug(currentEdit+'####');
                
                if(setChar == 'RCW' && (currentEdit.Months_Used__c/12) < 10)
                    throw new customException('Claim is less than 10 years old and cannot be processed for Defect Code PREM", please contact your warranty adiminstrator');
                
                upsert currentEdit;
                calculateTotalAmountOnPackage(packageId);
                //if(setChar == 'RCR'||setChar == 'RCT'||setChar == 'RCW'||setChar == 'RSS'){ 
                if(setChar == 'WAR'||setChar == 'PRS'||setChar == 'RCW'){ 
                    Payment_Line__c payLine = [Select Id,Calculation_Formula__c,Payment__c from Payment_Line__c  where Payment__c=: packageId Limit 1];
                    payment.Calculation_Formula__c = payLine.Calculation_Formula__c;
                    update payment;
                }
                if(packageRecordType == 'Free Material'){
                    Integer count=[select count() from Payment_Line__c where Payment__c =: packageId and is_Primary_Material__c=true];
                    if(count==0){
                        isFreematerialPresent=false;
                    }else{
                        isFreematerialPresent=true;                         
                    }
                    
                }
                system.debug('Free Material -- >' + isFreematerialPresent);
            }else{
                system.debug(currEditCD +'####');
                if(OrderType == 'Debit Memo'){
                    system.debug('OrderType' + currEditCD.Amount__c);
                    currEditCD.Amount__c = -1  * Math.ABS(currEditCD.Amount__c);
                    currEditCD.Amount_Converted__c = -1  * Math.ABS(currEditCD.Amount_Converted__c);
                }
               
                upsert currEditCD ;
                 calculateTotalAmountOnPackage(packageId);
                system.debug('completed'+currEditCD .Id);
            }
            UOMList=new List<SelectOption>();
        }catch(exception ex){
            system.debug('the exception is '+ex);
            ApexPages.addMessages(ex);
            //throw new customException('Unable to save: '+ex);
        }
        paymentLineList = paymentLineList();
    }
    
    //edit item
    public void editRow(){
        String UOM='';
        system.debug('!!!'+apexPages.currentPage().getParameters().get('editingId'));
        if(packageRecordType !='Credit/Debit'){
            for(Payment_Line__c csi : paymentLineList ){
                if(csi.id == apexPages.currentPage().getParameters().get('editingId')){
                    currentEdit = csi.clone(true, true, true, true);
                    currentEdit.Product_Name__c=currentEdit.Material_Name__c;
                    UOM=csi.UOM__c;
                    system.debug('@@@'+csi);
                    if(packageRecordType == 'Free Material'){                        
                        if(currentEdit.is_Primary_Material__c){
                            isFreematerialPresent=false;
                        }
                    }
                    if(currentEdit.Total_Weight__c!=null){                        
                        maximumLimit=maximumLimit+currentEdit.Total_Weight__c;
                    }
                    system.debug('Free Material -- >' + isFreematerialPresent);
                }
            }
        }else{
            for(Payment_Line__c csi : paymentLineList ){
                if(csi.id == apexPages.currentPage().getParameters().get('editingId')){
                    currEditCD = csi.clone(true, true, true, true);
                    system.debug('name'+CurrEditCD.Material_Name__c);
                    currEditCD.Product_Name__c=currEditCD.Material_Name__c;
                    UOM=csi.UOM__c;
                    system.debug('@@@'+csi);                   
                }
            }
        }
        fetchUOM();
        if(packageRecordType !='Credit/Debit'){
            currentEdit.UOM__c=UOM;
        }else{
            currEditCD.UOM__c=UOM;
        }
        
    }
    
    
    
    
    
    
    //delete item
    public void deleteRow(){
        delete [Select id from Payment_Line__c where id =: apexPages.currentPage().getParameters().get('deleteId')];
        calculateTotalAmountOnPackage(packageId);
        paymentLineList = paymentLineList();
    }
    
    //delete all item 
    public void deleteAll(){
        delete paymentLineList ;
        calculateTotalAmountOnPackage(packageId);
        paymentLineList = paymentLineList() ;
    } 
    
    
    
    
    @RemoteAction
    public static Decimal getPitchCost(Integer pitch){
        
        Decimal price = twod_PaymentManager.GetPitchRoofCost(pitch).setScale(2);
        return price;
    }
    @RemoteAction
    
    public static fetchSapAmt getAmountCreditDebit(String setChar,String setBasis,String packageRecordType,Id Claimid,Id paymentId,Id productId,boolean roofing_siding){
        fetchSapAmt sapAmt;
        String uom;
        boolean isRoofing;
        Decimal price;    
        WS.PricingSuccess ps;
        twod__Claim__c clm = new twod__Claim__c();
        Payment__c pay = new Payment__c();
        if(roofing_siding == true){
            isRoofing = false;}
        else{
            isRoofing = true;}
        
        
        
        clm =[Select Plant_Code__c,State_BL__c,Postal_Code_BL__c,City_BL__c,Sold_To_Party__c,Ship_to__c from twod__Claim__c where Id =: Claimid];
        //clm =[Select Plant_Code__c,State_BL__c,Postal_Code_BL__c,City_BL__c,Sold_To_Party__c,Ship_to__c, Plant__r.Name from twod__Claim__c where Id =: Claimid];
        pay = [Select Ship_To__c,Sold_To__c From Payment__c Where Id=: paymentId];
        if(clm.State_BL__c == ''){
            throw new customException('State is not present on the claim,thus price is not fetched: ');
        }
        if(clm.Postal_Code_BL__c == ''){
            throw new customException('Zip Code is not present on the claim,thus price is not fetched: ');
        }
        if(clm.City_BL__c  == ''){
            throw new customException('City is not present on the claim,thus price is not fetched:');
        }
        //this if loop will be exceuted only for record type Credit/Debit and Basis type Material which will be passed from page
        if(setBasis =='Material' && packageRecordType== 'Credit/Debit'){
            ps = twod_PaymentManager.GetMaterialPrice(isRoofing ,productId,clm.Plant_Code__c,pay.Ship_to__c,pay.Sold_To__c );
            //ps = twod_PaymentManager.GetMaterialPrice(isRoofing ,productId,clm.Plant__r.Name,pay.Ship_to__c,pay.Sold_To__c );
            uom=ps.strUOM;
            price = ps.decPrice.setScale(2);
            sapAmt = new fetchSapAmt(uom,price,0.0,0.0,0.0,0.0,0.0);            
        }
        return sapAmt;
    }
    
    @RemoteAction
    
    public static fetchSapAmt getAmountCheckCost(String setChar,String setBasis,String packageRecordType,Id Claimid,Id paymentId,Id productId,boolean roofing_siding,boolean steepPitch,boolean addstorey,boolean demolish){
        system.debug('steep'+steepPitch+'&&& addstry'+addstorey+'%%%demolish'+demolish +'---'+productId);
        //roofing_siding-->true means siding org
        //roofing_siding -->false means roofing org
        fetchSapAmt sapAmt;
        String uom;
        boolean isRoofing;
        Decimal price;
        Decimal OriginalPrice;
        Decimal LocationFactor;
        WS.PricingSuccess ps;
        twod__Warranty_Product__c wr;
        twod__Claim__c clm = new twod__Claim__c();
        Payment__c pay = new Payment__c();
        if(roofing_siding == true){
            isRoofing = false;}
        else{
            isRoofing = true;}
        
        //warranty product UOM for labor type
        wr = [Select Base_UOM__c From twod__Warranty_Product__c where Id=: productId];
        clm =[Select Plant_Code__c,Country_BL__c ,State_BL__c,Postal_Code_BL__c,City_BL__c,Sold_To_Party__c,Ship_to__c from twod__Claim__c where Id =: Claimid];
        pay = [Select Ship_To__c,Sold_To__c From Payment__c Where Id=: paymentId];
        if(clm.State_BL__c == ''){
            throw new customException('State is not present on the claim,thus price is not fetched: ');
        }
        if(clm.Postal_Code_BL__c == ''){
            throw new customException('Zip Code is not present on the claim,thus price is not fetched: ');
        }
        if(clm.City_BL__c  == ''){
            throw new customException('City is not present on the claim,thus price is not fetched:');
        }
        
        
        if(setChar == 'RSL'||setChar == 'STP'||setChar == 'TOF'||setChar == '2ND'){
            
            system.debug('Labor'+clm.State_BL__c+'****'+clm.Postal_Code_BL__c+'****'+clm.City_BL__c+'****'+addstorey+'****' );  
            if(clm.Country_BL__c != 'Canada'){     
                twod_PaymentManager.PriceWrapper wrapper = twod_PaymentManager.GetLaborCost(isRoofing ,productId,clm.State_BL__c,clm.Postal_Code_BL__c,clm.City_BL__c ,steepPitch,addstorey,demolish);
                price = wrapper.Price.setScale(2);
                OriginalPrice = wrapper.OriginalPrice.setScale(2);
                LocationFactor = wrapper.LocationFactor.setScale(2);
            }else{
                 twod_PaymentManager.PriceWrapper wrapper = twod_PaymentManager.GetLaborCost(isRoofing ,productId,clm.State_BL__c,'',clm.City_BL__c ,steepPitch,addstorey,demolish);
                price = wrapper.Price.setScale(2);
                OriginalPrice = wrapper.OriginalPrice.setScale(2);
                LocationFactor = wrapper.LocationFactor.setScale(2);
            }
            uom =wr.Base_UOM__c ;
            sapAmt = new fetchSapAmt(uom,price,0.0,0.0,0.0,OriginalPrice,LocationFactor);
        }
        else if(setChar == 'MTL'){
            
            ps = twod_PaymentManager.GetMaterialPrice(isRoofing ,productId,clm.Plant_Code__c,pay.Ship_to__c,pay.Sold_To__c );
            system.debug('Test'+ps);
            if(ps.strUOM!=null){
                uom=ps.strUOM;
            }
            price = ps.decPrice.setScale(2);
            sapAmt = new fetchSapAmt(uom,price,0.0,0.0,0.0,0.0,0.0);
        }
        else if(setChar == 'RSM'){
            if(clm.Country_BL__c != 'Canada'){     
                twod_PaymentManager.PriceWrapper wrapper = twod_PaymentManager.GetMaterialCost(clm.State_BL__c,clm.Postal_Code_BL__c,clm.City_BL__c,productId);
                price = wrapper.Price.setScale(2);
                OriginalPrice = wrapper.OriginalPrice.setScale(2);
                LocationFactor = wrapper.LocationFactor.setScale(2);
                
            }else{
                twod_PaymentManager.PriceWrapper wrapper = twod_PaymentManager.GetMaterialCost(clm.State_BL__c,'',clm.City_BL__c,productId);
                price = wrapper.Price.setScale(2);
                OriginalPrice = wrapper.OriginalPrice.setScale(2);
                LocationFactor = wrapper.LocationFactor.setScale(2);

            }
            uom=wr.Base_UOM__c ;
            sapAmt = new fetchSapAmt(uom,price,0.0,0.0,0.0,OriginalPrice,LocationFactor);
        }
        
        return sapAmt;
        
    }
    
    //remote method for PRS,RCW,RCT,RCR,WAR(no warranty product or uom req...function called on load)
    @RemoteAction 
    public static fetchSapAmt getPriceOnLoad(String setChar,Id Claimid){
        
        fetchSapAmt sapAmt;
        
        Decimal price;
        Decimal prevAmt;
        Payment_Line__c payFromSAP = new Payment_Line__c();
        Decimal months_covered;
        Decimal months_Used;

        if(setChar == 'PRS'){
           /*price = twod_PaymentManager.GetProrateMaterialLaborCost(Claimid).setScale(2);
            sapAmt = new fetchSapAmt('',price,0.0,0.0,0.0,0.0,0.0);*/
            payFromSAP = twod_PaymentManager.GetProrateMaterialLaborCost(Claimid);
            price = payFromSAP.Amount__c.setScale(4);
            months_covered = payFromSAP.Months_Covered__c ;
            months_Used = payFromSAP.Months_Used__c;            
            sapAmt = new fetchSapAmt('',price,0.0,months_covered,months_Used,0.0,0.0);
        }
        else if(setChar == 'WAR'){
            /*price = twod_PaymentManager.GetProrateMaterialCost(Claimid).setScale(2);
            sapAmt = new fetchSapAmt('',price,0.0,0.0,0.0,0.0,0.0);*/
            payFromSAP = twod_PaymentManager.GetProrateMaterialCost(Claimid);
            price = payFromSAP.Amount__c.setScale(4);
            months_covered = payFromSAP.Months_Covered__c ;
            months_Used = payFromSAP.Months_Used__c;
            sapAmt = new fetchSapAmt('',price,0.0,months_covered,months_Used,0.0,0.0);            
        }
        else if(setChar == 'RCW'){
            system.debug('****Inside block3****');
            payFromSAP = twod_PaymentManager.GetWarrantyClassActionCost(Claimid);
            price = payFromSAP.Amount__c.setScale(4);
            months_covered = payFromSAP.Months_Covered__c ;
            months_Used = payFromSAP.Months_Used__c;
            sapAmt = new fetchSapAmt('',price,0.0,months_covered,months_Used,0.0,0.0);
        }
        return sapAmt;
        
    }

    //Added By Hampesh
    public List<SelectOption> getmaterialcodes()   
    { 
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =
            payment_line__c.Material_Code__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        } 
        return options;
    }
    
    /*public List<SelectOption> getsalesorgs()   
    { 
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =
            payment_line__c.Sales_Org__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        } 
        return options;
    } */
    
    //Function to find Base UOM and ALT UOM
    Public void fetchUOM(){
        List<SelectOption> options = new List<SelectOption>();    
        twod__warranty_product__c wp=new twod__warranty_product__c();
        if(packageRecordType !='Credit/Debit' && currentEdit.Warranty_Product__c != null){
            wp=[Select UOM_Conversion__c,Alt_UOM__c,Base_UOM__c from twod__warranty_product__c where Id=:currentEdit.Warranty_Product__c];    
            BaseUOM=wp.Base_UOM__c;
            AltUOM=wp.Alt_UOM__c;            
            currentEdit.UOM__c=wp.Base_UOM__c;
        }
        else if(packageRecordType =='Credit/Debit' && currEditCD.Warranty_Product__c != null){
            wp=[Select UOM_Conversion__c,Alt_UOM__c,Base_UOM__c from twod__warranty_product__c where Id=:currEditCD.Warranty_Product__c];        
            BaseUOM=wp.Base_UOM__c;            
            currEditCD.UOM__c=wp.Base_UOM__c;         
        }        
        
        if(packageRecordType=='Check'){
            options.add(new SelectOption('SQ','SQ'));
            UOMConversion=wp.UOM_Conversion__c;
            UOMList=options;
            return ;
        }
        if(wp.Alt_UOM__c!=null && wp.UOM_Conversion__c !=null)
            options.add(new SelectOption(wp.Alt_UOM__c,wp.Alt_UOM__c));
        if(wp.Base_UOM__c!=null)
            options.add(new SelectOption(wp.Base_UOM__c,wp.Base_UOM__c));                 
        UOMConversion=wp.UOM_Conversion__c;
        UOMList=options;
    }
    
    //Wrapper for fetching Amount and UOM from SAP
    public class fetchSapAmt {
        public String uom {get; set;}
        public Decimal price {get; set;}
        public Decimal previousAmount {get;set;} 
        public Decimal monthsCovered {get;set;}
        public Decimal monthsUsed {get;set;}
        public decimal OriginalPrice {get;set;}
        public Decimal LocationFactor {get;set;}
        //This is the contructor method.
        public fetchSapAmt(String uom_sap,Decimal price_sap,Decimal previousAmount_sap,Decimal monthsCovered_sap, Decimal monthsUsed_sap,Decimal OriginalPrice_sap,Decimal LocationFactor_sap) {
            this.uom = uom_sap;
            this.price = price_sap;
            this.previousAmount = previousAmount_sap;
            this.monthsCovered = monthsCovered_sap;
            this.monthsUsed = monthsUsed_sap;
            this.OriginalPrice = OriginalPrice_sap;
            this.LocationFactor = LocationFactor_sap;
        }
    }
    
    public class customException extends Exception{}
    
    
    
    
    //Added by Hampesh to get Product Description
    
    public void getProductDescription(){
        try{
            if(packageRecordType !='Credit/Debit'){
                if(currentEdit.Warranty_Product__c !=null){
                    twod__Warranty_Product__c wp=[select id,twod__Product_Name__c,Gross_Weight__c from twod__Warranty_Product__c where id=:currentEdit.Warranty_Product__c];
                    currentEdit.Product_Name__c=wp.twod__Product_Name__c;
                    system.debug('desc'+currentEdit.Product_Name__c);
                    currentEdit.Gross_Weight__c=null;
                    if(packageRecordType == 'Free Material'){
                        currentEdit.Gross_Weight__c=wp.Gross_Weight__c;    
                    }
                }
                else{
                    currentEdit.Product_Name__c='';
                    currentEdit.Gross_Weight__c=null;
                }
            }
            if(packageRecordType =='Credit/Debit'){
                if(currEditCD.Warranty_Product__c !=null){
                    currEditCD.Product_Name__c=[select id,twod__Product_Name__c from twod__Warranty_Product__c where id=:currEditCD.Warranty_Product__c].twod__Product_Name__c;
                    //currentEdit.Product_Name__c=productName;
                    system.debug('prd'+currEditCD.Product_Name__c);
                    
                }
                else{
                    currEditCD.Product_Name__c='';
                }
            }
            fetchUOM();
        }
        
        catch(exception ex){
            ApexPages.addMessages(ex);
        }
        
    }
    
   //Calculate total amount
   //CT Multi currency changes 
   public void calculateTotalAmountOnPackage(Id packageId){
        system.debug('total called'+packageId);
        Payment__c payment = [Select Id,Total_Amount__c,Total_Amount_Converted__c,Exchange_Rate__c from Payment__c where Id=: packageId];
        if(setChar=='RCW'){
            payment.Total_Amount__c = ((currentEdit.Months_Covered__c - currentEdit.Months_Used__c)/currentEdit.Months_Covered__c) * currentEdit.Quantity__c * 74 ;
            if(payment.Exchange_Rate__c != null || payment.Exchange_Rate__c != 0)
                payment.Total_Amount_Converted__c = payment.Total_Amount__c / payment.Exchange_Rate__c;
            else
                payment.Total_Amount_Converted__c = payment.Total_Amount__c;
        }else{
            list<aggregateResult> aggResults = [SELECT SUM(Total_Payment_Amount__c)sumTmt, SUM(Total_Payment_Amount_Converted__c)sumTmtConv from Payment_Line__c where Payment__c=:packageId];
            payment.Total_Amount__c = double.ValueOf(aggResults[0].get('sumTmt'));
            payment.Total_Amount_Converted__c = double.ValueOf(aggResults[0].get('sumTmtConv'));
        }
        
        update payment;
  
   } 
    
}