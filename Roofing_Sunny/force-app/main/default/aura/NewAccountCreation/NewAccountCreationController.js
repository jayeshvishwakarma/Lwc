({   
	doInit : function(component, event, helper) {        
   		var accountId = component.get("v.accountId");       
       	helper.doInitHelper(component, event);     
        helper.getUserDetails(component, event);
       
	},    
	saveAccount : function(component, event, helper) {
        var actname = component.get("v.newActRec.Name"); 
        var brokerID=component.get("v.newActRec.BrokerID__c"); 
        var option=component.get("v.checkboxValue"); 
        var customerRegion = component.get("v.customerRegion"); 
        var userProfile = component.get("v.loggedinUser.Profile.Name"); 
        var tmUser = component.get("v.tmUser");           
        var salesorg=component.get("v.newActRec.Sales_Org__c"); 
        var shippingCountry=component.get("v.newActRec.ShippingCountry");
        var customerGroup=component.get("v.newActRec.Customer_Group__c");
        var Status = component.get("v.request.Status");   
        var soldToAct = component.get("v.selectedLookUpRecord");
        var errorMsg = '';
        var newLine = "<br>";       
         if($A.util.isEmpty(salesorg) || salesorg == ''){
            component.set("v.requiredErr", true);
            //component.set("v.errorMsg", 'Sales region is Required. Please select.');                     
            errorMsg += 'Sales Org is Required.';  
            errorMsg +=  newLine;
        }
        if(($A.util.isEmpty(customerRegion) || customerRegion ==undefined) && salesorg == '1501' && shippingCountry == 'UNITED STATES'  && userProfile != 'Customer Service' && userProfile != 'Customer Service - Manager' && Status != 'Submitted to Territory Manager'){
            component.set("v.requiredErr", true);
            //component.set("v.errorMsg", 'Sales region is Required. Please select.');                     
            errorMsg += 'Sales region is Required.';
			errorMsg +=  newLine;             
        }
        if(($A.util.isEmpty(tmUser) || tmUser ==undefined) && (userProfile == 'Customer Service' || userProfile == 'Customer Service - Manager') && salesorg == '1501' && shippingCountry == 'UNITED STATES' && option != 'EXPORT'){
            component.set("v.requiredErr", true);
            //component.set("v.errorMsg", 'Territory Manager is Required. Please select.');            
            errorMsg +=  'Territory Manager is Required.'; 
            errorMsg +=  newLine;
        }
        if($A.util.isEmpty(soldToAct) || soldToAct ==undefined){
            component.set("v.requiredErr", true);
            //component.set("v.errorMsg", 'Territory Manager is Required. Please select.');            
            errorMsg +=  'Sold-to Account Number for Partnering is Required.'; 
            errorMsg +=  newLine;
        }
        if(($A.util.isEmpty(actname) || actname ==undefined)){
            component.set("v.requiredErr", true);            
            errorMsg += 'Account Name is Required.';
            errorMsg +=  newLine;
            //component.set("v.errorMsg", 'Account Name is Required. Please enter.'); 
        }
        if(($A.util.isEmpty(shippingCountry) || shippingCountry ==undefined)){
            component.set("v.requiredErr", true);            
            errorMsg += 'Country is Required.';
            errorMsg +=  newLine;          
        }       
        
        if(($A.util.isEmpty(customerGroup) || customerGroup ==undefined)){
            component.set("v.requiredErr", true);            
            errorMsg += 'Customer Group is Required.';
            errorMsg +=  newLine;          
        }   
         if(errorMsg != ''){
            component.set("v.errorMsg", errorMsg);
            component.set("v.requiredSuc", false);
            component.set("v.successMsg", ''); 
        }
        else{
            component.set("v.requiredErr", false);
            component.set("v.errorMsg", ''); 
            helper.createAccountHelper(component, event, false, false);
             component.set("v.requiredSuc", true);
            component.set("v.successMsg", 'Request Saved Successfully. Go to bottom of form to submit.'); 
        }    
         window.scrollBy(0,-800);
	},
    submitAccount : function(component, event, helper) {  
        var actname = component.get("v.newActRec.Name"); 
        var brokerID=component.get("v.newActRec.BrokerID__c"); 
        var option=component.get("v.checkboxValue"); 
        var customerRegion = component.get("v.customerRegion"); 
        var userProfile = component.get("v.loggedinUser.Profile.Name"); 
        var tmUser = component.get("v.tmUser");         
        var salesorg=component.get("v.newActRec.Sales_Org__c"); 
        var shippingCountry=component.get("v.newActRec.ShippingCountry");  
        var customerGroup=component.get("v.newActRec.Customer_Group__c");
        var Status = component.get("v.request.Status");  
         var soldToAct = component.get("v.selectedLookUpRecord");
        var errorMsg = '';
        var newLine = "<br>";
         if($A.util.isEmpty(salesorg) || salesorg == ''){
            component.set("v.requiredErr", true);
            //component.set("v.errorMsg", 'Sales region is Required. Please select.');                     
            errorMsg += 'Sales Org is Required.';  
            errorMsg +=  newLine;
        }
        if(($A.util.isEmpty(customerRegion) || customerRegion ==undefined) && salesorg == '1501' && shippingCountry == 'UNITED STATES'  && userProfile != 'Customer Service' && userProfile != 'Customer Service - Manager' && Status != 'Submitted to Territory Manager'){
            component.set("v.requiredErr", true);
            //component.set("v.errorMsg", 'Sales region is Required. Please select.');                     
            errorMsg += 'Sales region is Required.';
			errorMsg +=  newLine;             
        }
        if($A.util.isEmpty(soldToAct) || soldToAct ==undefined){
            component.set("v.requiredErr", true);
            //component.set("v.errorMsg", 'Territory Manager is Required. Please select.');            
            errorMsg +=  'Sold-to Account Number for Partnering is Required.'; 
            errorMsg +=  newLine;
        }
         if(($A.util.isEmpty(tmUser) || tmUser ==undefined) && (userProfile == 'Customer Service' || userProfile == 'Customer Service - Manager') && salesorg == '1501' && shippingCountry == 'UNITED STATES' && option != 'EXPORT'){
            component.set("v.requiredErr", true);
            //component.set("v.errorMsg", 'Territory Manager is Required. Please select.');            
            errorMsg +=  'Territory Manager is Required.'; 
            errorMsg +=  newLine;
        }
        if(($A.util.isEmpty(actname) || actname ==undefined)){
            component.set("v.requiredErr", true);            
            errorMsg += 'Account Name is Required.';
            errorMsg +=  newLine;
            //component.set("v.errorMsg", 'Account Name is Required. Please enter.'); 
        }
        if(($A.util.isEmpty(shippingCountry) || actname ==shippingCountry)){
            component.set("v.requiredErr", true);            
            errorMsg += 'Country is Required.';
            errorMsg +=  newLine;          
        }       
       
 
        if(($A.util.isEmpty(customerGroup) || customerGroup ==undefined)){
            component.set("v.requiredErr", true);            
            errorMsg += 'Customer Group is Required.';
            errorMsg +=  newLine;          
        } 
       /* if(($A.util.isEmpty(brokerID) || brokerID ==undefined) && ((shippingCountry == 'CANADA' && salesorg == '1501') || (shippingCountry == 'UNITED STATES' && salesorg == '1102'))){        
            component.set("v.requiredErr", true);
            //component.set("v.errorMsg", 'Broker ID is Required. Please enter.');             
            errorMsg +=  'Broker ID is Required.';
            errorMsg +=  newLine;
        }*/
        if(errorMsg != ''){
            component.set("v.errorMsg", errorMsg);
            component.set("v.requiredSuc", false);
            component.set("v.successMsg", ''); 
        }
        else{
            component.set("v.requiredErr", false);
            component.set("v.errorMsg", ''); 
            helper.createAccountHelper(component, event, true, false);
            var recordId = component.get("v.recordId"); 
            if(!$A.util.isEmpty(recordId) && recordId != undefined){
            helper.doInitHelper(component, event);
            }
            component.set("v.requiredSuc", true);
            component.set("v.successMsg", 'Request Saved Successfully. Go to bottom of form to submit.'); 
        }    
         window.scrollBy(0,-800);
	},
     SubmitforApproval : function(component, event, helper) {  
        var actname = component.get("v.newActRec.Name"); 
        var brokerID=component.get("v.newActRec.BrokerID__c"); 
        var option=component.get("v.checkboxValue"); 
        var customerRegion = component.get("v.customerRegion"); 
        var userProfile = component.get("v.loggedinUser.Profile.Name"); 
        var tmUser = component.get("v.tmUser");         
        var salesorg=component.get("v.newActRec.Sales_Org__c"); 
        var shippingCountry=component.get("v.newActRec.ShippingCountry");  
        var customerGroup=component.get("v.newActRec.Customer_Group__c");
        var Status = component.get("v.request.Status");  
         var soldToAct = component.get("v.selectedLookUpRecord");
        var errorMsg = '';
        var newLine = "<br>";
         if($A.util.isEmpty(salesorg) || salesorg == ''){
            component.set("v.requiredErr", true);
            //component.set("v.errorMsg", 'Sales region is Required. Please select.');                     
            errorMsg += 'Sales Org is Required.';  
            errorMsg +=  newLine;
        }
         if(($A.util.isEmpty(customerRegion) || customerRegion ==undefined) && salesorg == $A.get("$Label.c.CM_SalesOrg_1501") && shippingCountry == $A.get("$Label.c.CM_ShippingCountry_US")  && userProfile != $A.get("$Label.c.CM_Customer_Service_Profile") && userProfile != $A.get("$Label.c.CM_Customer_Service_Manager_Profile") && Status != $A.get("$Label.c.CM_Request_Status_SubtoTM")){
            component.set("v.requiredErr", true);
            //component.set("v.errorMsg", 'Sales region is Required. Please select.');                     
            errorMsg += 'Sales region is Required.';
			errorMsg +=  newLine;             
        }
        if($A.util.isEmpty(soldToAct) || soldToAct ==undefined){
            component.set("v.requiredErr", true);
            //component.set("v.errorMsg", 'Territory Manager is Required. Please select.');            
            errorMsg +=  'Sold-to Account Number for Partnering is Required.'; 
            errorMsg +=  newLine;
        }
        if(($A.util.isEmpty(tmUser) || tmUser ==undefined) && (userProfile == $A.get("$Label.c.CM_Customer_Service_Profile") || userProfile == $A.get("$Label.c.CM_Customer_Service_Manager_Profile")) && salesorg == $A.get("$Label.c.CM_SalesOrg_1501") && shippingCountry == $A.get("$Label.c.CM_ShippingCountry_US") && option != $A.get("$Label.c.CM_Customer_Region_Export")){
            component.set("v.requiredErr", true);
            //component.set("v.errorMsg", 'Territory Manager is Required. Please select.');            
            errorMsg +=  'Territory Manager is Required.'; 
            errorMsg +=  newLine;
        }
        if(($A.util.isEmpty(actname) || actname ==undefined)){
            component.set("v.requiredErr", true);            
            errorMsg += 'Account Name is Required.';
            errorMsg +=  newLine;
            //component.set("v.errorMsg", 'Account Name is Required. Please enter.'); 
        }
        if(($A.util.isEmpty(shippingCountry) || actname ==shippingCountry)){
            component.set("v.requiredErr", true);            
            errorMsg += 'Country is Required.';
            errorMsg +=  newLine;          
        }       
       
 
        if(($A.util.isEmpty(customerGroup) || customerGroup ==undefined)){
            component.set("v.requiredErr", true);            
            errorMsg += 'Customer Group is Required.';
            errorMsg +=  newLine;          
        } 
       /* if(($A.util.isEmpty(brokerID) || brokerID ==undefined) && ((shippingCountry == 'CANADA' && salesorg == '1501') || (shippingCountry == 'UNITED STATES' && salesorg == '1102'))){        
            component.set("v.requiredErr", true);
            //component.set("v.errorMsg", 'Broker ID is Required. Please enter.');             
            errorMsg +=  'Broker ID is Required.';
            errorMsg +=  newLine;
        }*/
        if(errorMsg != ''){
            component.set("v.errorMsg", errorMsg);
            component.set("v.requiredSuc", false);
            component.set("v.successMsg", ''); 
        }
        else{
            component.set("v.requiredErr", false);
            component.set("v.errorMsg", ''); 
            
            helper.createAccountHelper(component, event, true, true);          
            var recordId = component.get("v.recordId"); 
            if(!$A.util.isEmpty(recordId) && recordId != undefined){
            	helper.doInitHelper(component, event);                              
            }
            
            component.set("v.requiredSuc", true);
            component.set("v.successMsg", 'Request Submitted Sucessfully.');            
            window.open('/' + recordId, "_self");
        }    
         window.scrollBy(0,-800);
	}, 
    checkboxHandler : function(component, event, helper){
          var oldValue= event.getParam("oldValue");
          var newValue = event.getParam("value");     
		  var val = '';      
        var userProfile = component.get("v.loggedinUser.Profile.Name");
        if(oldValue.length < newValue.length){
            val = helper.getDifference(oldValue, newValue);           
            if(!$A.util.isEmpty(val)){				            
          		component.set("v.checkboxValue", val);
            	component.set("v.newActRec.Customer_Origin__c", String(val));  
            }                	
            if(val == 'US'){                 
                component.set("v.valOption", false);
               // component.set("v.newActRec.Broker_ID__c", '');
               // component.set("v.newActRec.AEB_Check_Completed__c", false);
               // component.set("v.newActRec.ShippingCountry","UNITED STATES");
            }
            else{
              /*  if(val == 'CANADA'){
                    component.set("v.newActRec.ShippingCountry","CANADA");
                }
                else{
                    component.set("v.newActRec.ShippingCountry","");
                }*/
                component.set("v.valOption", true);                               
            }
        } else{
                if(userProfile == 'Customer Service' || userProfile == 'Customer Service - Manager'){
                    helper.solarCustomerCheck(component, event);
                }
            }      
    },
    pricesheetcheckboxHandler : function(component, event, helper){
          var oldValue= event.getParam("oldValue");
          var newValue = event.getParam("value");     
		  var val = '';        
        if(oldValue.length < newValue.length){
            val = helper.getDifference(oldValue, newValue);           
            if(!$A.util.isEmpty(val)){				            
          		component.set("v.pricesheetValue", val);
                if(val=='Yes'){
                	component.set("v.newActRec.Price_Sheet__c", true);    
                }else{
                    component.set("v.newActRec.Price_Sheet__c", false);
                }                            	  
            }                	
          
        }       
    },
    soldTopartnerChange : function(component, event, helper){
        var userProfile = component.get("v.loggedinUser.Profile.Name");    
        console.log('TEST soldTopartnerChange');
        if(userProfile == 'Customer Service' || userProfile == 'Customer Service - Manager'){
            helper.getTMUserDetailshelper(component, event, helper);
        }
    },
    solarCustomerCheck : function(component, event, helper){        
        var userProfile = component.get("v.loggedinUser.Profile.Name");          
         if(userProfile == 'Customer Service' || userProfile == 'Customer Service - Manager'){
            helper.solarCustomerCheck(component, event);
        }
    },
    validateNoofDeliveries : function(component, event, helper){       
        if((event.which < 48 || event.which > 57)){
             event.preventDefault();
        }
    },
    validatePhoneNo : function(component, event, helper){       
        if((event.which < 48 || event.which > 57)){
             event.preventDefault();
        }
    },
    limitChars : function(component, event, helper){       
       var txtedpar = component.find("txtedpar");
        var txtedparValue = txtedpar.get("v.value");
        if(txtedparValue != undefined){
             
            if(txtedparValue.length > 19){
                event.preventDefault();
            }
        }       
    }
})