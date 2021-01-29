public class twod_PaymentManager {
    
    public class PriceWrapper{
        public decimal Price {get; private set;}
        public decimal OriginalPrice{get; private set;}
        public decimal LocationFactor {get; private set;}
        
        public PriceWrapper(decimal originalPrice, decimal locationFactor){
            this.Price= originalPrice * locationFactor;
            this.OriginalPrice =  originalPrice;
            this.LocationFactor = locationFactor;
        }
    }
    Decimal monthsCovered;
    //Returns labor cost- Settlement types are RSL, STP,TOF,2ND Story
    public static PriceWrapper GetLaborCost(boolean isRoofing, string productId, string state, string zip, string city, boolean steepPitch, boolean addStory, boolean demolishTearOff){
        decimal costPerSquare;
        decimal locationFactor = GetLocationFactor(state, zip, city);
        system.debug('Value of ProductID ' + productId);
        Map<string,string> warrantyProductMap = twod_WarrantyProductWrapper.getProductDetails(productId);
        
        if(isRoofing){
            if(string.isEmpty(warrantyProductMap.get('LaborCost')))
                throw new twod_IntegrationException('Labor cost not defined for the selected product');
            
            costPerSquare = decimal.valueOf(warrantyProductMap.get('LaborCost')) ;
            
            if(steepPitch && !string.isEmpty(warrantyProductMap.get('SteepPitch')))
                  costPerSquare = decimal.valueOf(warrantyProductMap.get('SteepPitch'));
            if(addStory && !string.isEmpty(warrantyProductMap.get('AdditionalStory')))
                costPerSquare = decimal.valueOf(warrantyProductMap.get('AdditionalStory'));
            if(demolishTearOff && !string.isEmpty(warrantyProductMap.get('DemolishTearOff')))
                costPerSquare = decimal.valueOf(warrantyProductMap.get('DemolishTearOff'));
        }else{}
        
        PriceWrapper wrapper = new PriceWrapper(costPerSquare, locationFactor);
        return wrapper;
    } 
    
    //returns the location factor from RSMeans object
    private static decimal GetLocationFactor(string state, string zip, string city){
        List<RSMeans__c> rs;
        string zipLike = zip.left(3);
       
        //ZIP will be empty for Canadian states.
        if(!string.isEmpty(zip)){
            rs = [Select Location_Factor__c from RSMeans__c Where Zip__c=:zipLike];
        }else{
            rs = [Select Location_Factor__c from RSMeans__c Where State__c= :state ];
        }
                
        if(rs.size() == 0){
            throw new twod_IntegrationException('Unable to Fetch Location factor for the given address');
        }
        system.debug('Location Factor' +  rs[0].Location_Factor__c);
        return rs[0].Location_Factor__c;
    }
    
    //Returns material cost for Roofing from Product Structure.- Settlement - RSM
    public static PriceWrapper GetMaterialCost(string state, string zip, string city, string productId){
        decimal locationFactor = GetLocationFactor(state, zip, city);
        Map<string,string> warrantyProductMap = twod_WarrantyProductWrapper.getProductDetails(productId);
        if(warrantyProductMap.get('MaterialCost')!=null)
        return new PriceWrapper(decimal.valueOf(warrantyProductMap.get('MaterialCost')),  locationFactor);
        else return new PriceWrapper(0.0,  0.0);
    }
    
    //Settlement types- ALG,HAN,HAP
    public static decimal GetPitchRoofCost(integer pitch){
        List<Pitch_Cost__c> pitchCost = [Select Cost_per_Square__c from Pitch_Cost__c Where Pitch_of_Roof__c =:pitch];
        
        if(pitchCost.size() == 0){
            return null;
        }
        return pitchCost[0].Cost_per_Square__c;
     }
     
     /*public static decimal GetProrateMaterialCost(string claimId){
        twod__Claim__c claim = [Select Install_Date__c, CreatedDate, twod__Applicable_Policy__r.Maxiumum_Liability__c, twod__Applicable_Policy__r.twod__Months_Covered__c from twod__Claim__c Where id=:claimId];
        if(claim.twod__Applicable_Policy__r == null){
            throw new twod_IntegrationException('There is no applicable policy for the claim');
        }
        if(claim.twod__Applicable_Policy__r.Maxiumum_Liability__c == null){
            throw new twod_IntegrationException('Maximum Liability not defined for the Policy');
        }
        
        integer monthsUsed = claim.Install_Date__c.MonthsBetween(claim.CreatedDate.date());
        integer monthsRemaining = integer.valueof(calculateMonthsCovered(claim)) - monthsUsed;
        return (monthsRemaining/calculateMonthsCovered(claim))*claim.twod__Applicable_Policy__r.Maxiumum_Liability__c;
     }
   
      public static decimal GetProrateMaterialLaborCost(string claimId){
        twod__Claim__c claim = [Select twod__warranty_product__c, State_BL__c, Country_BL__c, Postal_code_BL__c, City_BL__c, Install_Date__c, CreatedDate, twod__Applicable_Policy__r.Maxiumum_Liability__c, twod__Applicable_Policy__r.twod__Months_Covered__c from twod__Claim__c Where id=:claimId];
        decimal laborCost;
        decimal materialCost;
        if(claim.twod__Applicable_Policy__r == null){
            throw new twod_IntegrationException('There is no applicable policy for the claim');
        }
        if(claim.Country_BL__c == 'Canada'){
            laborCost = GetLaborCost(true, claim.twod__warranty_product__c, claim.State_BL__c, '', claim.City_BL__c, false,false,false).Price;
            materialCost = GetMaterialCost(claim.State_BL__c, '', claim.City_BL__c, claim.twod__warranty_product__c).Price;
            
        }else{
            laborCost = GetLaborCost(true, claim.twod__warranty_product__c, claim.State_BL__c, claim.Postal_code_BL__c, claim.City_BL__c, false,false,false).Price;
            materialCost = GetMaterialCost(claim.State_BL__c, claim.Postal_code_BL__c, claim.City_BL__c, claim.twod__warranty_product__c).Price;
        }
                
        decimal totalCost = laborCost+materialCost;
        integer monthsUsed = claim.Install_Date__c.MonthsBetween(claim.CreatedDate.date());
        integer monthsRemaining = integer.valueof(calculateMonthsCovered(claim)) - monthsUsed;
        return (monthsRemaining/calculateMonthsCovered(claim))*totalCost;
      }
    */
    public static Payment_Line__c GetProrateMaterialCost(string claimId){
        decimal materialCost;
        twod__Claim__c claim = [Select twod__Warranty_Product__r.Product_Type__r.Warranty_Material_Cost__c,is_Before_SureStart__c,twod__warranty_product__c, Install_Date__c, State_BL__c, Country_BL__c, Postal_code_BL__c, City_BL__c,CreatedDate, twod__Applicable_Policy__r.Maxiumum_Liability__c, twod__Applicable_Policy__r.twod__Months_Covered__c,
                                twod__Applicable_Policy__r.SureStart_Period__c,OwnershipType__c,twod__Applicable_Policy__r.After_SureShort_Warranty_Period__c from twod__Claim__c Where id=:claimId];
        Payment_Line__c payLine = new Payment_Line__c();
        if(claim.twod__Applicable_Policy__r == null){
            throw new twod_IntegrationException('There is no applicable policy for the claim');
        }
        if(claim.twod__Applicable_Policy__r.Maxiumum_Liability__c == null){
           materialCost = claim.twod__Warranty_Product__r.Product_Type__r.Warranty_Material_Cost__c;
        }
        //Added on June 1
        else{
            materialCost = claim.twod__Applicable_Policy__r.Maxiumum_Liability__c;
        }
        Decimal monthsCovered= claim.twod__Applicable_Policy__r.twod__Months_Covered__c;
        integer monthsUsed = claim.Install_Date__c.MonthsBetween(claim.CreatedDate.date());
        payLine.Months_Used__c = monthsUsed;
        system.debug('monthsUsed is ---->' + monthsUsed);
        payLine.Months_Covered__c = monthsCovered;
        
        integer monthsRemaining = integer.valueof(monthsCovered) - monthsUsed;
        //payLine.Amount__c =  (monthsRemaining/monthsCovered)*claim.twod__Applicable_Policy__r.Maxiumum_Liability__c;
        payLine.Amount__c =  (monthsRemaining/monthsCovered)*materialCost;
        
        return payLine;
     }
    
    
    public static Payment_Line__c GetProrateMaterialLaborCost(string claimId){
        twod__Claim__c claim = [Select twod__warranty_product__c, is_Before_SureStart__c,State_BL__c, Country_BL__c, Postal_code_BL__c, City_BL__c, Install_Date__c, CreatedDate, twod__Applicable_Policy__r.SureStart_Period__c,OwnershipType__c,twod__Applicable_Policy__r.After_SureShort_Warranty_Period__c ,twod__Applicable_Policy__r.Maxiumum_Liability__c, twod__Applicable_Policy__r.twod__Months_Covered__c from twod__Claim__c Where id=:claimId];
        decimal laborCost;
        decimal materialCost;
        Decimal monthsCovered= claim.twod__Applicable_Policy__r.twod__Months_Covered__c;
        Payment_Line__c payLine = new Payment_Line__c();
        if(claim.twod__Applicable_Policy__r == null){
            throw new twod_IntegrationException('There is no applicable policy for the claim');
        }
        if(claim.Country_BL__c == 'Canada'){
            laborCost = GetLaborCost(true, claim.twod__warranty_product__c, claim.State_BL__c, '', claim.City_BL__c, false,false,false).Price;
            materialCost = GetMaterialCost(claim.State_BL__c, '', claim.City_BL__c, claim.twod__warranty_product__c).Price;
            
        }else{
            laborCost = GetLaborCost(true, claim.twod__warranty_product__c, claim.State_BL__c, claim.Postal_code_BL__c, claim.City_BL__c, false,false,false).Price;
            materialCost = GetMaterialCost(claim.State_BL__c, claim.Postal_code_BL__c, claim.City_BL__c, claim.twod__warranty_product__c).Price;
        }
                
        decimal totalCost = laborCost+materialCost;
        integer monthsUsed = claim.Install_Date__c.MonthsBetween(claim.CreatedDate.date());
        integer monthsRemaining = integer.valueof(monthsCovered) - monthsUsed;
        payLine.Months_Used__c = monthsUsed;
        payLine.Months_Covered__c = monthsCovered;
        payLine.Amount__c = (monthsRemaining/monthsCovered)*totalCost;
        
        return payLine;
      }
      
      public static Payment_Line__c GetWarrantyClassActionCost(string claimId){
        twod__Claim__c claim = [Select Install_Date__c, CreatedDate, is_Before_SureStart__c,twod__Applicable_Policy__r.SureStart_Period__c,OwnershipType__c,twod__Applicable_Policy__r.After_SureShort_Warranty_Period__c ,twod__Applicable_Policy__r.Maxiumum_Liability__c, twod__Applicable_Policy__r.twod__Months_Covered__c from twod__Claim__c Where id=:claimId];
        Payment_Line__c payLine = new Payment_Line__c();
        if(claim.twod__Applicable_Policy__r == null){
            throw new twod_IntegrationException('There is no applicable policy for the claim');
        }
          Decimal monthsCovered= claim.twod__Applicable_Policy__r.twod__Months_Covered__c;
        ClassAction_Amount__c cs =  ClassAction_Amount__c.GetValues('Warranty');        
        integer monthsUsed = claim.Install_Date__c.MonthsBetween(claim.CreatedDate.date());
        payLine.Months_Used__c = monthsUsed;
        payLine.Months_Covered__c = monthsCovered;
          
        //system.debug('Amount:' + ((monthsCovered - decimal.valueOf(monthsUsed))/monthsCovered)* cs.Value__c);
        payLine.Amount__c = ((monthsCovered - decimal.valueOf(monthsUsed))/monthsCovered)* cs.Value__c;
       
        return payLine;
      }
      
      public static Payment_Line__c GetReleasorClassActionCost(string claimId){
        Payment_Line__c payLine = GetWarrantyClassActionCost(claimId);
        decimal totalCost = payLine.Amount__c;
         decimal previousCost = 0.0;
        twod__claim__c claim = [Select Customer__c from twod__claim__c where Id=:claimId];
         AggregateResult[] result = [Select sum(Total_Amount__C) from Payment__C where Claim__r.Customer__c =: claim.Customer__c  and Settlement_Type__c ='RCR - Cls Action Releasor' and Claim__r.Id <> : claimId];
       
        if(result[0].get('expr0') != null)
        {previousCost = (decimal)result[0].get('expr0');} 
             
        payLine.Previous_Recieved_Amount__c = previousCost;
        payLine.Amount__c = totalCost;
        return payLine;
      }
          
       public static Payment_Line__c GetTransferClassActionCost(string claimId){
        Payment_Line__c payLine = new Payment_Line__c();
        twod__Claim__c claim = [Select Install_Date__c, CreatedDate, is_Before_SureStart__c,twod__Applicable_Policy__r.SureStart_Period__c,OwnershipType__c,twod__Applicable_Policy__r.After_SureShort_Warranty_Period__c ,twod__Applicable_Policy__r.Maxiumum_Liability__c, twod__Applicable_Policy__r.twod__Months_Covered__c from twod__Claim__c Where id=:claimId];
        if(claim.twod__Applicable_Policy__r == null){
            throw new twod_IntegrationException('There is no applicable policy for the claim');
        }
        Decimal monthsCovered= claim.twod__Applicable_Policy__r.twod__Months_Covered__c;        
        integer monthsUsed = claim.Install_Date__c.MonthsBetween(claim.CreatedDate.date());
        decimal totalCost = 34*(1- (monthsUsed/monthsCovered));
        payLine.Months_Used__c = monthsUsed;
        payLine.Months_Covered__c = monthsCovered;
        payLine.Amount__c = totalCost; 
        return payLine;
      }
    
    
    //Returns the material price from SAP    
    public static WS.PricingSuccess GetMaterialPrice(boolean isRoofing, string productId, string plantCode, string shipTo, string soldTo){
        Map<string,string> warrantyProductMap = twod_WarrantyProductWrapper.getProductDetails(productId);
        List<Account> shipToAcc = [Select SAP_ACCOUNT__c, Sales_District_lookup__r.Name, LOB__c from Account where id=:shipTo];
        if(shipToAcc.size()==0){
            throw new twod_IntegrationException('ShipTo account not specified');
        }
           
        List<Account> soldToAcc = [Select SAP_ACCOUNT__c, Sales_District_lookup__r.Name from Account where id=:soldTo];
        if(soldToAcc.size()==0){
            throw new twod_IntegrationException('SoldTo account not specified');
        }
        integer productCode = integer.valueOf(warrantyProductMap.get('ProductCode'));
                
        WS.PricingRequest request = new WS.PricingRequest();
        request.lstMaterials = new List<Integer>{productCode}; 
        request.strShipTo = shipToAcc[0].SAP_ACCOUNT__c;
        request.strSoldTo = soldToAcc[0].SAP_ACCOUNT__c;        
        request.strDivision = warrantyProductMap.get('DivisonCode');
        request.strDistChannel = '01';
        request.strDistrict = shipToAcc[0].Sales_District_lookup__r.Name;
        request.strPlant = plantCode;
        request.strIdc = warrantyProductMap.get('IDC');
        //request.strSalesOrg = '1501';//IvSorg //ISorg 
        request.strSalesOrg = shipToAcc[0].LOB__c; //CT Multi currency changes
        request.isRoofing = true;
        system.debug(request);        
        WS.PricingResponse r = WS.doPriceCall(request);
        if(r.mapSuccesses.containsKey(productCode)){
            WS.PricingSuccess ps = r.mapSuccesses.get(productCode);
            return ps;
        } else {
            for(Integer i = 0; i < r.lstErrors.size(); i++){
                WS.PricingError pe = r.lstErrors[i];
                if(i == 0){
                    throw new twod_IntegrationException('Type:' + pe.strType + ' Message:' + pe.strMessage);
                }else if(i == 1){
                    throw new twod_IntegrationException('Type:' + pe.strType + ' Message:' + pe.strMessage);
                }
            }
        }
        return null;
    }
    
    //Sends the free material order or credit debit order to SAP
    public static SAP_Log__c SendOrderToSAP(string paymentId){
        SAP_Log__c log;
        try{
            boolean isFreeMaterialOrder = false;
            log = new SAP_Log__c();
            log.Payment_Id__c = paymentId;
            
            List<Payment_Line__c> paymentLines = [Select  Quantity__c, Amount_Converted__c,Material_Name__c, Material_Number__c, Total_Payment_Amount_Converted__c,
            Material_Code__c, UOM__c, payment__r.Comments__c, payment__r.Order_Type__c, payment__r.Payment_Type__c, 
            payment__r.Order_Reason__c, payment__r.Shipping_Condition__c,  payment__r.Claim__r.Name, 
            payment__r.Claim__r.Territory_Manager__c, payment__r.Claim__r.Territory__r.Name, 
            payment__r.Claim__r.Owner.Name, payment__r.Ship_To__r.SAP_ACCOUNT__c ,Payment__r.Territory_Manager__c ,
            payment__r.Sold_To__r.SAP_ACCOUNT__c, payment__r.Product_Name__c, payment__r.Contact_Name__c,payment__r.Sales_Org__c, 
            payment__r.Contact_Phone__c, payment__r.Contact_Email__c, payment__r.Roofer_Name__c, payment__r.Roofer_Phone__c,payment__r.claim__r.ClaimType__c
            From Payment_Line__c Where payment__r.Id=:paymentId];
            
            if(paymentLines.size() == 0)     {
                log.Error__c = 'Package does not have any payment lines';
                log.Has_Error__c = true;
                return log;
            }
            
            if(paymentLines[0].payment__r.Payment_Type__c == 'Check' || paymentLines[0].payment__r.Payment_Type__c == 'Gelco'){
                log.Error__c = 'Only Credit/Debit and Material orders can be sent to SAP';
                log.Has_Error__c = true;
                return log;
            }       
            
            WS.OrderRequest request = new WS.OrderRequest();
             if(paymentLines[0].payment__r.Payment_Type__c == 'Free Material'){
                isFreeMaterialOrder = true;
                request.strType = 'ZFW';
            }else if(paymentLines[0].payment__r.Order_Type__c == 'Credit Memo'){
                request.strType = 'ZCR';
            }else{
                request.strType = 'ZDR';
            }
            request.strShipTo = paymentLines[0].payment__r.Ship_To__r.SAP_ACCOUNT__c; //KunnrSh
            request.strSoldTo = paymentLines[0].payment__r.Sold_To__r.SAP_ACCOUNT__c; //KunnrSp
            request.strOrdReason = paymentLines[0].payment__r.Order_Reason__c.Left(3); //Augru
            request.strPONumber = paymentLines[0].payment__r.Claim__r.Name; //Bstkd
            //request.strName = paymentLines[0].payment__r.Claim__r.Owner.Name; //Bname
            request.strName = UserInfo.getName(); //Bname
            if(paymentLines[0].payment__r.Payment_Type__c == 'Free Material'){
                request.strShipCondition = paymentLines[0].payment__r.Shipping_Condition__c.Left(2); //Vsbed
            }
            //request.strSalesOrg = '1501'; //Vkorg
            request.strSalesOrg = paymentLines[0].payment__r.Sales_Org__c; //CT Multi currency changes
            request.strDistChannel = '01'; //Vtweg
            request.strDivision = '01'; //Spart
            
            map<string,WS.OrderLine> tempLines = new map<string,WS.OrderLine>();
            request.lstOrdLines = new List<WS.OrderLine>();
            request.lstOrdNotes = new List<WS.OrderNote>();
            if(isFreeMaterialOrder){
                for(Payment_Line__c line : paymentLines){
                    WS.OrderLine oli = new WS.OrderLine();
                    oli.strMaterial = line.Material_Number__c; //Matnr
                    //oli.intQuantity = integer.valueOf(line.Quantity__c); //Kwmeng
                    oli.decQuantity = line.Quantity__c; //Kwmeng
                    //oli.decPrice = line.Amount__c; //Kbetr
                    oli.strUOM = line.UOM__c; //Vrkme
                    request.lstOrdLines.add(oli);
                }
            }else{
                
                for(Payment_Line__c line : paymentLines){
                    WS.OrderLine oli = tempLines.get(line.Material_Code__c);
                    if(oli == null){
                        oli = new WS.OrderLine();
                        oli.strMaterial = line.Material_Code__c; //Matnr
                        //oli.intQuantity = 1; //Kwmeng
                        oli.decQuantity = 1; //Kwmeng
                        oli.decPrice = (Math.abs(line.Amount_Converted__c) * line.Quantity__c).SetScale(2); //Kbetr
                        tempLines.put(line.Material_Code__c, oli);
                        request.lstOrdLines.add(oli);
                    }else{
                        oli.decPrice = (oli.decPrice + (Math.abs(line.Amount_Converted__c) * line.Quantity__c)).SetScale(2);
                    }
                }
            }
                       
            AddNotes(request, paymentLines, isFreeMaterialOrder);
            
            log.Request__c = JSON.SerializePretty(request);
            log.Request_Date__c = dateTime.now();
            system.debug(request);
            WS.OrderResponse r = WS.doOrderCall(request);
            if(r.intOrderNumber != null){
                log.Response__c = string.valueOf(r.intOrderNumber);
           } else {
                for(WS.OrderError oe : r.lstErrors){
                    if(string.isEmpty(log.Error__c)){
                        log.Error__c = 'Type:' + oe.strType + ' Message:' + oe.strMessage;
                    }else{
                        log.Error__c = log.Error__c + '\n Type:' + oe.strType + ' Message:' + oe.strMessage;
                    }
                    log.Has_Error__c = true;
                }
            }
        }catch (WS.WSException e){
            log.Error__c = e.getMessage();
            log.Has_Error__c = true;
        }catch (exception ex){
            log.Error__c = ex.getMessage();
            log.Has_Error__c = true;
        }
        
        return log;
        
    }
    
    private static void AddNotes(WS.OrderRequest request, List<Payment_Line__c> lines, boolean isFreeMaterialOrder){
        string stringId;
        boolean addNote =false;
        if(!isFreeMaterialOrder){
            stringId = 'Z006'; //TDID
        }else{
            stringId = 'Z013'; //TDID
        }
        
        WS.OrderNote oNote = new WS.OrderNote();
        oNote.strId = stringId;
        if(!isFreeMaterialOrder){
            oNote.strText = lines[0].payment__r.claim__r.Name + ', ' + 'TM ' + lines[0].payment__r.Territory_Manager__c + ', ' + lines[0].payment__r.Claim__r.Territory__r.Name;
        }
        else{
            oNote.strText = lines[0].payment__r.claim__r.Name + ', ' + 'TM ' + lines[0].payment__r.claim__r.Territory_Manager__c + ', ' + lines[0].payment__r.Claim__r.Territory__r.Name;
        }
        request.lstOrdNotes.add(oNote);
        
        if(!isFreeMaterialOrder){
            WS.OrderNote oNote3 = new WS.OrderNote();
            oNote3.strId = stringId;        
            oNote3.strText = 'To Settle Complaint# ' + lines[0].payment__r.claim__r.Name;
            request.lstOrdNotes.add(oNote3);
        }
        
        if(isFreeMaterialOrder){
            WS.OrderNote oNote2 = new WS.OrderNote();
            oNote2.strText = 'Distributor Contact ';
            oNote2.strId = stringId;
            if(!string.isEmpty(lines[0].payment__r.Contact_Name__c)){
                addNote =true;            
                oNote2.strText = 'Distributor Contact ' + lines[0].payment__r.Contact_Name__c; 
            }
            if(!string.isEmpty(lines[0].payment__r.Contact_Phone__c) ){
                addNote =true;
                oNote2.strText += ', ' + lines[0].payment__r.Contact_Phone__c;
            }
            if(!string.isEmpty(lines[0].payment__r.Contact_Email__c)){
                addNote =true;
                oNote2.strText += ', ' + lines[0].payment__r.Contact_Email__c;
            }
            if(addNote)
                request.lstOrdNotes.add(oNote2);
        }   
        //Added for JIRA CERUAT-715
        if(lines[0].payment__r.claim__r.ClaimType__c == 'Short Term'){
             oNote = new WS.OrderNote();
            oNote.strId = stringId; //TDID
            if(isFreeMaterialOrder){
                oNote.strText =  'Short Term';
            }
            request.lstOrdNotes.add(oNote);
        }
        
        for(Payment_Line__c line: lines ){
            oNote = new WS.OrderNote();
            oNote.strId = stringId; //TDID
            if(isFreeMaterialOrder){
                oNote.strText =  'Material Name ' + line.Material_Name__c + ', ' + 'Quantity ' +  line.Quantity__c + ', ' + 'UOM ' + line.UOM__c; //TDLINE
            }
            else{
                oNote.strText =  'Material Name ' + line.Material_Name__c + ', ' + 'Quantity ' +  line.Quantity__c + ', ' + 'UOM ' + line.UOM__c + ', ' + line.Total_Payment_Amount_Converted__c; //TDLINE
            }
            request.lstOrdNotes.add(oNote);
        }
        
        twod__Claim__c claim = [Select First_Name__C, Last_Name__c, Address_1__c, City__c, State__c From twod__Claim__c where Id =: lines[0].payment__r.claim__r.Id];
        oNote = new WS.OrderNote();
        oNote.strId = stringId; //TDID
        oNote.strText = 'Building Owner ' + claim.First_Name__C + ', ' +  claim.Last_Name__c + ', '  + claim.Address_1__c + ', ' + claim.City__c + ', ' + claim.State__c ;
        request.lstOrdNotes.Add(oNote);
        
        if(isFreeMaterialOrder){
            oNote = new WS.OrderNote();
            oNote.strId = 'Z008'; //TDID
            oNote.strText = 'Building Owner ' + claim.Last_Name__C + ', ' +  claim.First_Name__c + ', '  + claim.Address_1__c + ', ' + claim.City__c + ', ' + claim.State__c ;
            request.lstOrdNotes.Add(oNote);
            
            //Roofer Information
            addNote = false;
            oNote = new WS.OrderNote();
            oNote.strId = 'Z008'; //TDID
            if(!string.isEmpty(lines[0].payment__r.Roofer_Name__c)){
                addNote = true;   
                oNote.strText = 'Roofer Name ' + lines[0].payment__r.Roofer_Name__c; 
            }
            
            if(!string.isEmpty(lines[0].payment__r.Roofer_Phone__c)){
                addNote = true;
                oNote.strText += ', ' +  'Roofer Phone ' + lines[0].payment__r.Roofer_Phone__c;
            }
            if(addnote)
                request.lstOrdNotes.Add(oNote);
        }
        AddComments(lines[0].payment__r.Comments__c, request, isFreeMaterialOrder);
        
        
        List<Claim_Interested_Parties__c> claimParties =[Select Name, Address_1__c, City__c, State__c, Type__c, Phone__c from Claim_Interested_Parties__c where Claim__c =:lines[0].payment__r.claim__r.Id and Type__c in ('Contractor', 'Lumberyard')];
        for(Claim_Interested_Parties__c party: claimParties){
            oNote = new WS.OrderNote();
            oNote.strId = stringId; //TDID
            if(party.Type__c == 'Lumberyard'){
            oNote.strText = party.Type__c + ' ' + party.Name + ', ' + party.Address_1__c + ', ' + party.City__c + ', ' + party.State__c + ', ' + party.Phone__c;
            }
            else{
            oNote.strText = party.Type__c + ' ' + party.Name + ', ' + party.Address_1__c + ', ' + party.City__c + ', ' + party.State__c;
            }
            request.lstOrdNotes.add(oNote);
        }
            
         //Adding disclaimer in the end applicable only for creditdebit
         if(!isFreeMaterialOrder){
             AddDisclaimer(request,'Z006');
         }
        
    }
    
    private static void AddDisclaimer(WS.OrderRequest request, string stringId){
        WS.OrderNote oNote1 = new WS.OrderNote();
        WS.OrderNote oNote2 = new WS.OrderNote();
        WS.OrderNote oNote3 = new WS.OrderNote();
        WS.OrderNote oNote4 = new WS.OrderNote();
        WS.OrderNote oNote5 = new WS.OrderNote();
        //WS.OrderNote oNote6 = new WS.OrderNote();
        oNote1.strId = oNote2.strId = oNote3.strId = oNote4.strId = oNote5.strId = stringId;
        string strText1 = 'If the above DB/CR is being issued due to an applied product complaint, the recipient of such DB/CR agrees that it will be ';
        string strText2 = 'applied only toward satisfaction of the claim that arose from the use of a CertainTeed Roofing product on the above-described ';
        string strText3 = 'premises, and such DB/CR will not be applied toward, or used to satisfy, any other claim or account. The recipient also agrees ';
        string strText4 = 'that CertainTeed shall have no further liability or responsibility with regard to this claim should the recipient ';
        string strText5 = 'fail to perform as described above';
        //string strText6 = strText1 + strText2 + strText3 + strText4 +  strText5;
        oNote1.strText  = strText1;
        oNote2.strText  = strText2;
        oNote3.strText  = strText3;
        oNote4.strText  = strText4;
        oNote5.strText  = strText5;
        //oNote6.strText  = strText6;
        
        //TDID
        //request.lstOrdNotes.add(oNote6);
        request.lstOrdNotes.add(oNote1);        
        request.lstOrdNotes.add(oNote2);        
        request.lstOrdNotes.add(oNote3);        
        request.lstOrdNotes.add(oNote4);        
        request.lstOrdNotes.add(oNote5);
    }
    
   /* public static Decimal calculateMonthsCovered(twod__claim__c claim){
        Decimal months=claim.twod__Applicable_Policy__r.twod__Months_Covered__c;        
        if(claim.OwnershipType__c=='Second' && claim.is_Before_SureStart__c=='N'){           
            months=claim.twod__Applicable_Policy__r.After_SureShort_Warranty_Period__c;        
        }
        return months;
    }
    */
    
    private static void AddComments(string comments, WS.OrderRequest request, boolean isFreeMaterialOrder){
        if(string.isEmpty(comments)){
            return;
        }
        integer startIndex = 0;
        integer endIndex = 0;
        integer strLength = comments.length();
        WS.OrderNote oNote1;
        string strID;
        if(isFreeMaterialOrder)
            strID = 'Z013';
        else
            strID = 'Z006';
        if(strLength >= 132){
            while(strLength >= 132){
                endIndex = endIndex +132;
                oNote1 = new WS.OrderNote();
                oNote1.strId = strID; //TDID
                oNote1.strText = comments.substring(startIndex,endIndex);
                request.lstOrdNotes.add(oNote1);
                startIndex = startIndex +132;
                strLength = strLength -132;
            }
        }
        oNote1 = new WS.OrderNote();
        oNote1.strId = strID; //TDID
        oNote1.strText = comments.substring(startIndex);
        request.lstOrdNotes.add(oNote1);
    }
}