({
	doInithelper : function(component, event) {
		var caseId = component.get("v.recordId");	
        console.log("Case ID==>" + caseId);
        if(!$A.util.isEmpty(caseId)){
            var action = component.get("c.getCaseDetails");                
            action.setParams({caseId : caseId});
            action.setCallback(this, function(response){            
                var currentMatch = response.getReturnValue();                             
                var state = response.getState();
                if (state === "SUCCESS") {                       
                    component.set("v.request",currentMatch);
                    var customerregion = component.get("v.request.Origin");
                    if(customerregion != undefined && customerregion != ''){
                        customerregion = customerregion.replace(' Queue', '');
                    }
                    component.set("v.customerregion",customerregion);
                    var actId;
                    
                    if(component.get("v.request.Type")==="Change Ship-To Account Information Request"){
                        actId = component.get("v.request.Change_Info_Account__c");
                        
                          var shipToActName = component.get("v.request.Account.BPCS_Account_ID__c")  + ' - ' + component.get("v.request.Account.Name");
                    component.set('v.shipToActName', shipToActName);
                         var orgactID = component.get("v.request.AccountId");
                        //Added this method call to get actual account details against changed account
                        this.getOrigininalAccountDetails(component, orgactID);
                    }
                    else{
                        actId = component.get("v.request.AccountId");
                    }
                    console.log('actId-->' + actId);
                    var actPhone = component.get("v.request.Account.Phone");
                    if(!$A.util.isEmpty(actPhone) && actPhone != undefined){
                        actPhone = this.formatPhoneNumber(component, actPhone);
                        component.set("v.request.Account.Phone",actPhone);
                    }
                    if(!$A.util.isEmpty(actId) && actId != undefined){
                         this.getAccountDetails(component, actId);
                    }
                   
                }
            });
            $A.enqueueAction(action);	 
        }
	},
    getAccountDetails : function(component, accountId){
        var action = component.get("c.getAccountDetails");                
            action.setParams({accountId : accountId});
         console.log('accountId-->' + accountId);
            action.setCallback(this, function(response){            
                var currentMatch = response.getReturnValue();            
                var state = response.getState();
                console.log('state-->' + state);
                if (state === "SUCCESS") {
                    component.set("v.newActRec",currentMatch);  
                    console.log('TEst===>' + currentMatch);
                     var pricesheetValue = [];           
                    var pricesheet = component.get("v.newActRec.Price_Sheet__c");
                    var soldActNo = component.get("v.newActRec.Order_For_Account__r.BPCS_Account_ID__c");
                    var soldToAccName = component.get("v.newActRec.Order_For_Account__r.Name");
                    var actPhone = component.get("v.newActRec.Phone");
                    if(!$A.util.isEmpty(actPhone) && actPhone != undefined){
                        actPhone = this.formatPhoneNumber(component, actPhone);
                        component.set("v.newActRec.Phone",actPhone);
                    }
                    if(soldActNo != undefined){
                         component.set("v.soldActNo",soldActNo + ' - ' + soldToAccName); 
                    }
                  
                    console.log('pricesheet==>' + pricesheet);
                    if(pricesheet){
                        pricesheetValue = 'Yes';                                
                    }else if(!pricesheet){
                        pricesheetValue = 'No';                              
                    }
                    component.set("v.pricesheetVal", pricesheetValue);
                }
            });
         $A.enqueueAction(action);	
    },
    getOrigininalAccountDetails : function(component, accountId){
        var action = component.get("c.getAccountDetails");                
            action.setParams({accountId : accountId});
         console.log('accountId-->' + accountId);
            action.setCallback(this, function(response){            
                var currentMatch = response.getReturnValue();            
                var state = response.getState();
                console.log('state-->' + state);
                if (state === "SUCCESS") {
                    component.set("v.originalActRec",currentMatch);     
                     var shipcountry = component.get("v.originalActRec.ShippingCountry");
                    if(shipcountry == 'USA'){
                        component.set("v.originalActRec.ShippingCountry", 'UNITED STATES');
                    }
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
                    console.log('User==>' + currentMatch);
                }            
          });
        $A.enqueueAction(action);
    },
    formatPhoneNumber: function(component, phone) {
        var s2 = (""+phone).replace(/\D/g, '');
        var m = s2.match(/^(\d{3})(\d{3})(\d{4})$/);
        return (!m) ? null : "(" + m[1] + ") " + m[2] + "-" + m[3];
    }
})