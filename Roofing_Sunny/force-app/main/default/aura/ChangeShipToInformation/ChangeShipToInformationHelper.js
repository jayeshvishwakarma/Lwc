({
    doInitHelper : function(component, event){   
        var recordId = component.get("v.recordId");	
        var accountId = component.get("v.accountId");		
        var caseId = component.get("v.caseId");	
        var chgActId = component.get("v.changeaccountId");	
        var warehouse = component.get("v.selectedWarehouse");
		var tmUser = component.get("v.tmUser");        
        console.log('caseId==>' + caseId);
        console.log('accountId==>' + accountId);
        console.log('chgActId==>' + chgActId);        
        if(!$A.util.isEmpty(caseId)){                
              var action = component.get("c.getCaseDetails");                
            action.setParams({caseId : caseId});
            action.setCallback(this, function(response){            
                var currentMatch = response.getReturnValue();                             
                var state = response.getState();
                if (state === "SUCCESS") {                       
                  	component.set("v.request",currentMatch);
                    component.set("v.customerRegion",component.get("v.request.Origin"));
                    if(chgActId == undefined){
                        chgActId = component.get("v.request.Change_Info_Account__c");
                    }
                    var action = component.get("c.getAccountDetails");                
                    action.setParams({accountId : chgActId});
                    action.setCallback(this, function(response){            
                        var currentMatch = response.getReturnValue(); 
                        component.set("v.newActRec",currentMatch);
                        var state = response.getState();
                        if (state === "SUCCESS") {                       
                            warehouse = {"Id" : component.get("v.newActRec.Default_Warehouse__c"), "Name" : component.get("v.newActRec.Default_Warehouse__r.Name"), "Warehouse_Description__c" : component.get("v.newActRec.Default_Warehouse__r.Warehouse_Description__c")};
                            component.set("v.selectedWarehouse", warehouse);   
                            tmUser = {"Id" : component.get("v.newActRec.Territory_Manager__c"), "Name" : component.get("v.newActRec.Territory_Manager__r.Name"), "Role__c" : component.get("v.newActRec.Territory_Manager__r.Role__c")};
                            component.set("v.tmUser", tmUser);
                            component.set("v.lookupRenderInd", true); 
                            var checkboxval = [];                        
                            checkboxval.push(component.get("v.newActRec.Customer_Origin__c"))                      
                            component.set("v.checkboxValue", checkboxval);
                            var pricesheetValue = [];           
                            var pricesheet = component.get("v.newActRec.Price_Sheet__c");                                                                                    
                            if(pricesheet){
                                pricesheetValue.push('Yes');                                
                            }else if(!pricesheet){
                                pricesheetValue.push('No');                              
                            }                                        
                            component.set("v.pricesheetValue", pricesheetValue);
                             var name = component.get("v.existingActRec.Name");
                             var new_name = component.get("v.newActRec.Name");
                            if(name == new_name){
                                component.set("v.newActRec.Name", '');
                            }
                            
                            if(!$A.util.isEmpty(recordId) && recordId != undefined){   
                                component.set("v.showSave",true);
                                component.set("v.chgNameandAddressInfo",true);
                                component.set("v.chgShippingInfo",true);
                            }
                        }
                    });
                    $A.enqueueAction(action);	     
                }
            });
             $A.enqueueAction(action);	     
        }else{           
            this.initRec(component); 
            component.set("v.lookupRenderInd", true);
        }                
        var action = component.get("c.getAccountDetails");                
        action.setParams({accountId : accountId});
        action.setCallback(this, function(response){            
            var currentMatch = response.getReturnValue();           
            component.set("v.existingActRec",currentMatch);      
            
            var state = response.getState();
            if (state === "SUCCESS") {  
                var country = component.get("v.existingActRec.ShippingCountry");
                var name = component.get("v.existingActRec.Name");
                var salesorg = component.get("v.existingActRec.Sales_Org__c");
                var new_country = component.get("v.newActRec.ShippingCountry");
                var new_name = component.get("v.newActRec.Name");
                var new_salesorg = component.get("v.newActRec.Sales_Org__c");
                var newAcct = component.get("v.newActRec");
                if(newAcct != undefined){
                    if(new_country == undefined || new_country == ''){
                        if(country == 'USA' || country == 'US'){
                            country = 'UNITED STATES';
                        } 
                        if(country == 'CAN'){
                            country = 'CANADA';
                        } 
                        component.set("v.newActRec.ShippingCountry", country);                        
                    }
                                   
                    if(new_salesorg == undefined || new_salesorg == ''){
                        component.set("v.newActRec.Sales_Org__c", salesorg);
                    }  
                    
                }
              
                var checkboxval = [];   
                
              /*  if(country == "USA" || country == 'UNITED STATES'){                           
                    checkboxval.push("US");                                                
                }
                else if(country == "CAN" || country == "CANADA"){
                    checkboxval.push("CANADA");                                                  
                }
                    else if(country != ""){
                        checkboxval.push("EXPORT");                                                  
                    }*/
                if(component.get("v.existingActRec.Sales_Office__c") != undefined){
                    checkboxval.push(component.get("v.existingActRec.Sales_Office__c"));
                    component.set("v.checkboxVal", checkboxval);
                }
               
                var pricesheetValue = [];           
                var pricesheet = component.get("v.existingActRec.Price_Sheet__c");                
                if(pricesheet){
                    component.set("v.pricesheetVal", "Yes");                              
                }else if(!pricesheet){
                    component.set("v.pricesheetVal", "");                                                    
                }
                var plantName =  component.get("v.existingActRec.Default_Warehouse__r.Name");
                var plantDesc =  component.get("v.existingActRec.Default_Warehouse__r.Warehouse_Description__c");
                var deliveryPlant = '';
                
                if(!$A.util.isEmpty(plantName) && plantName != undefined){
                    deliveryPlant = plantName;
                }
                if(!$A.util.isEmpty(plantDesc) && plantDesc != undefined){
                    deliveryPlant+= ' - ' + plantDesc;
                }
                component.set("v.deliveryPlant", deliveryPlant);
            }
        });
        $A.enqueueAction(action);
    }, 
     getUserDetails : function(component, event){
        var action = component.get("c.getLoggedinUserDetails");                            
            action.setCallback(this, function(response){            
                var currentMatch = response.getReturnValue();            
                var state = response.getState();
                if (state === "SUCCESS") {
                      component.set("v.loggedinUser",currentMatch);                      
                }            
          });
        $A.enqueueAction(action);
    },
    changeShipToInfoRequestHelper : function(component, event, isSubmitted, isCSRSubmitted) {
        var accountId = component.get('v.accountId');              
        var newAccount = component.get("v.newActRec");
        var caseId = component.get("v.caseId");        
        var warehouse = component.get("v.selectedWarehouse");              
        var customerRegion = component.get("v.customerRegion");
        var isActSave = component.get("v.showSave");
        var tmUser = component.get("v.tmUser");
        var cregion;
        if(!$A.util.isEmpty(customerRegion) && customerRegion != undefined){
            cregion = customerRegion;
        }
        else{
           cregion = null;
        } 
        if(newAccount.Name == undefined || newAccount.Name == ''){
            newAccount.Name = component.get("v.existingActRec.Name");
        }
        newAccount.Default_Warehouse__c = warehouse.Id;        
        if(tmUser != null && tmUser != undefined)
        	newAccount.Territory_Manager__c = tmUser.Id;
        newAccount.Request_Type__c = 'Change Ship-To Account Information Request';
        var formattedData=JSON.stringify(newAccount);                      
        var action = component.get("c.createAccount");             
        action.setParams({
            accountDetails : formattedData,
            csId : caseId,
            isSubmitted : isSubmitted,
            acctId : accountId,
            region : cregion,            
            isActSave : isActSave,
            isCSRSubmitted : isCSRSubmitted
        });
        action.setCallback(this, function(response){                       
            var state = response.getState();                   
            if (state === "SUCCESS") {
                 var currentRec = response.getReturnValue();       
                component.set("v.Spinner",false);
                console.log('currentRec==>' + currentRec);
                if(!isSubmitted){                   
                    component.set("v.caseId", currentRec);
                    this.doInitHelper(component, event)
                }                     
            }
        });
        $A.enqueueAction(action);		
    },
    initRec : function(component){
        var action = component.get("c.getAccount");
        action.setCallback(this, function(response){
            var currentRec = response.getReturnValue();          
            component.set("v.newActRec", currentRec);
           //  component.set("v.newActRec.ShippingCountry","UNITED STATES");
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
    }
})