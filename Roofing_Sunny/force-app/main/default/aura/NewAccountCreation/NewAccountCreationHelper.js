({
    doInitHelper : function(component, event){        
        var accountId = component.get("v.accountId");		
        var caseId = component.get("v.caseId");
         var recordId = component.get("v.recordId");       
        if(!$A.util.isEmpty(recordId) && recordId != undefined){
            component.set("v.isFromCase", false);
             component.set("v.showSave",true);
        }
        if($A.util.isEmpty(caseId) || caseId == undefined){
       		 caseId = component.get("v.recordId");	
             component.set("v.caseId", caseId);
        }
       
        console.log('Case ID==>' + caseId);   
      if(!$A.util.isEmpty(caseId)){
              var action = component.get("c.getCaseDetails");                
            action.setParams({caseId : caseId});
            action.setCallback(this, function(response){            
                var currentMatch = response.getReturnValue();                             
                var state = response.getState();
                if (state === "SUCCESS") {                       
                    component.set("v.request",currentMatch);
                    var actId;                   
                        actId = component.get("v.request.AccountId");          
                    console.log('actId-->' + actId);
                    console.log('test-->' + component.get("v.request.Origin"));
                    component.set("v.customerRegion",component.get("v.request.Origin"));
                    if(!$A.util.isEmpty(actId) && actId != undefined){
                         this.getAccountDetails(component, event,actId);
                    }
                   
                }
            });
            $A.enqueueAction(action);	
        }
        else{
              
            if(component.get("v.newActRec.ShippingStreet") != undefined){
                component.set("v.address1", component.get("v.newActRec.ShippingStreet"));
            }
            //this.initRec(component);           
            component.set("v.lookupRenderInd", true);
            
        }       
    }, 
    getUserDetails : function(component, event){
        var action = component.get("c.getLoggedinUserDetails");                            
            action.setCallback(this, function(response){            
                var currentMatch = response.getReturnValue();            
                var state = response.getState();
                if (state === "SUCCESS") {
                      component.set("v.loggedinUser",currentMatch);   
                    console.log('User==>' + currentMatch);
                }            
          });
        $A.enqueueAction(action);
    },
    createAccountHelper : function(component, event, isSubmitted,isCSRSubmitted) {
        var newAccount = component.get("v.newActRec");
        var caseId = component.get("v.caseId");
        var soldToAct = component.get("v.selectedLookUpRecord");         
        var warehouse = component.get("v.selectedWarehouse");         
        var customerGroup = component.get("v.selectedCustomerGroup"); 
        var address1 = component.get("v.address1"); 
        var address2 = component.get("v.address2");        
        var customerRegion = component.get("v.customerRegion");
        var tmUser = component.get("v.tmUser");            
        var isActSave = component.get("v.showSave");
        var cregion;    
        console.log('customerRegion==>' + customerRegion);
        if(!$A.util.isEmpty(customerRegion) && customerRegion != undefined){
            cregion = customerRegion;
        }
        else{
           cregion = null;
        }     
        console.log('cregion==>' + cregion);
        if($A.util.isEmpty(address2) ||  address2 == undefined){
            newAccount.ShippingStreet = address1;    
        }
        else{
            newAccount.ShippingStreet = address1 + ' | ' + address2;
        }        
        newAccount.BPCS_Account_ID__c = '';
        newAccount.Order_For_Account__c = soldToAct.Id;  
        newAccount.Default_Warehouse__c = warehouse.Id;
        newAccount.Customer_Group_Price__c = customerGroup.Id;
        
        if(tmUser != null && tmUser != undefined)
        	newAccount.Territory_Manager__c = tmUser.Id;
        newAccount.Request_Type__c = 'New Ship-To Account Request';
        var formattedData=JSON.stringify(newAccount);                   
        var action = component.get("c.createAccount");     
        console.log('isCSRSubmitted==>' +isCSRSubmitted);
        action.setParams({
            accountDetails : formattedData,
            csId : caseId,
            isSubmitted : isSubmitted,
            accId : null,
            region : cregion,
            isActSave : isActSave,
            isCSRSubmitted : isCSRSubmitted
        });
        action.setCallback(this, function(response){                       
            var state = response.getState();                   
            if (state === "SUCCESS") {
                var currentRec = response.getReturnValue();       
                component.set("v.Spinner",false);
                if(isSubmitted){
                     this.initRec(component);
                }else{
                    component.set("v.caseId", currentRec);
                    this.doInitHelper(component, event)
                }
                
            }
        });
        $A.enqueueAction(action); 	
    },
    getDifference : function(oldValue, newValue) {
        var result = [];      
        for (var i = 0; i < newValue.length; i++) {
            if (oldValue.indexOf(newValue[i]) === -1) {
                result.push(newValue[i]);
            }
        }        
        for (i = 0; i < oldValue.length; i++) {
            if (newValue.indexOf(oldValue[i]) === -1) {
                result.push(oldValue[i]);
            }
        }     
        return result;
    },
    initRec : function(component){
        var action = component.get("c.getAccount");
        action.setCallback(this, function(response){
            var currentRec = response.getReturnValue();          
            component.set("v.newActRec", currentRec);
            // component.set("v.newActRec.ShippingCountry","UNITED STATES");
        });
        $A.enqueueAction(action);
    },
    getAccountDetails : function(component, event, accountId){
        var soldToAct = component.get("v.selectedLookUpRecord");         
        var warehouse = component.get("v.selectedWarehouse"); 
        var tmUser = component.get("v.tmUser");        
        var action = component.get("c.getAccountDetails");                
            action.setParams({accountId : accountId});
            action.setCallback(this, function(response){            
                var currentMatch = response.getReturnValue();            
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.newActRec",currentMatch);     
                    console.log('Test==>' + component.get("v.newActRec.Order_For_Account__r.Res_TM__r.Email"));
                    soldToAct = {"Id" : component.get("v.newActRec.Order_For_Account__c"),"BPCS_Account_ID__c" : component.get("v.newActRec.Order_For_Account__r.BPCS_Account_ID__c"), "Name" : component.get("v.newActRec.Order_For_Account__r.Name"), "ShippingCity" : component.get("v.newActRec.Order_For_Account__r.ShippingCity"), "Res_TM__c" : component.get("v.newActRec.Order_For_Account__r.Res_TM__c"),"Res_TM__r.Email" : component.get("v.newActRec.Order_For_Account__r.Res_TM__r.Email")};
                    component.set("v.selectedLookUpRecord", soldToAct);   
                    warehouse = {"Id" : component.get("v.newActRec.Default_Warehouse__c"), "Name" : component.get("v.newActRec.Default_Warehouse__r.Name"), "Warehouse_Description__c" : component.get("v.newActRec.Default_Warehouse__r.Warehouse_Description__c")};
                    component.set("v.selectedWarehouse", warehouse);                    
                    tmUser = {"Id" : component.get("v.newActRec.Territory_Manager__c"), "Name" : component.get("v.newActRec.Territory_Manager__r.Name"), "Role__c" : component.get("v.newActRec.Territory_Manager__r.Role__c"), "Email" : component.get("v.newActRec.Territory_Manager__r.Email")};
                    component.set("v.tmUser", tmUser); 
                    console.log("1==" + component.get("v.tmUser.Email"));
                    console.log("1==" + component.get("v.selectedLookUpRecord.Res_TM__c"));
                    if(component.get("v.tmUser.Email") ==component.get("v.newActRec.Order_For_Account__r.Res_TM__r.Email")){                        
                        component.set("v.tmInd", true); 
                    }
                    component.set("v.lookupRenderInd", true);   
                    var checkboxval = [];                        
                    checkboxval.push(component.get("v.newActRec.Customer_Origin__c"))   
                    console.log('checkboxval==>' + checkboxval);
                    component.set("v.checkboxValue", checkboxval);
                    var pricesheetValue = [];           
                    var pricesheet = component.get("v.newActRec.Price_Sheet__c");
                    if(pricesheet){
                        pricesheetValue.push('Yes');   
                    }else if(!pricesheet){
                        pricesheetValue.push('No');   
                    }                    
                    component.set("v.pricesheetValue", pricesheetValue);
                    var streetaddress = component.get("v.newActRec.ShippingStreet");                        
                    if(!$A.util.isEmpty(streetaddress) && streetaddress.includes("|")){
                        var address = streetaddress.split(" | ");        
                        component.set("v.address1",address[0]);
                        component.set("v.address2",address[1]);
                    }
                    else{
                        component.set("v.address1",streetaddress);
                    }
                    var brokerID = component.get("v.newActRec.BrokerID__c");
                    if(brokerID == undefined){
                        component.set("v.newActRec.BrokerID__c",'');
                    }                  
                }
            });
            $A.enqueueAction(action);	 
    },
	getTMUserDetailshelper : function(component, event, accountId){
           component.set("v.tmInd", true);  
        var soldToAct = component.get("v.selectedLookUpRecord");
        console.log('soldToAct==>' + component.get("v.selectedLookUpRecord.Res_TM__r.Email"));
        var tmUser = component.get("v.tmUser"); 
        if(component.get("v.selectedLookUpRecord.Res_TM__r.Email") != undefined){
            var action = component.get("c.getTMUserDetails");                
            action.setParams({email : component.get("v.selectedLookUpRecord.Res_TM__r.Email")});
            action.setCallback(this, function(response){            
                var result = response.getReturnValue();            
                var state = response.getState();
                console.log('state==>' + state);
                if (state === "SUCCESS" && result != null) {      
                    console.log('result==>' + result);                   
                    component.set("v.tmUser", result);   
                    component.set("v.temptmUser", result);
                    component.set("v.tmInd", true);  
                    component.set("v.soldToTMInd", true);                       
                     this.solarCustomerCheck(component, event);                     
                }
                else{
                    component.set("v.tmUser", undefined);
                    component.set("v.temptmUser", undefined);
                    component.set("v.tmInd", false);   
                    component.set("v.soldToTMInd", false);                       
                }
            });
            $A.enqueueAction(action);	
        }
        else{
            component.set("v.tmUser", undefined);
            component.set("v.temptmUser", undefined);
            component.set("v.tmInd", false);       
            component.set("v.soldToTMInd", false);       
        }
         
    },
    solarCustomerCheck : function(component, event){
        var tmInd = component.get("v.tmInd");
        var salesOrg = component.get("v.newActRec.Sales_Org__c");
        var optioUS = component.get("v.checkboxValue");
        var solar = component.get("v.newActRec.Solar__c");
        var customerGroup = component.get("v.newActRec.Customer_Group__c");    
        console.log('BEfore tmInd===>' + tmInd)
        if(tmInd && salesOrg == '1501' && solar && optioUS == 'US' && customerGroup == 'SO - SOLAR EXCLUSIVE'){               
            component.set("v.tmUser", undefined);
            component.set("v.tmInd", false);
        }else{           
            if(component.get("v.temptmUser") != undefined){
                 component.set("v.tmUser", component.get("v.temptmUser"));
          		 component.set("v.tmInd", component.get("v.soldToTMInd"));
            }           
        } 
         console.log('after tmInd===>' + tmInd)
    }        
})