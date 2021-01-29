({
    updateRecord: function(component, event, helper) {       
        var acctId = component.get("v.accRecordId");                 
        var actionType = component.get("v.action");
        var action;
        console.log(actionType, acctId);
        if(actionType == 'Direct Order KPN'){
            action = component.get("c.updateDirectOrderKpnEENMobiel"); 
        	action.setParams({"accountId" : acctId});
        }else if(actionType == 'Update KPN Small Quote'){
            action = component.get("c.updateKPNSmallQuote"); 
        	action.setParams({"accountId" : acctId});
        }else if(actionType == 'Update KPN One Offer'){
            action = component.get("c.updateKPNOneOffer"); 
        	action.setParams({"accountId" : acctId});
        }else if(actionType == 'Update TMobile Quotation'){
            action = component.get("c.updateTMobileQuotation"); 
        	action.setParams({"accountId" : acctId});
        }       
        action.setCallback(this, function(response)
                           {            
                               var state = response.getState();
                               console.log(state);
                               if (state === "SUCCESS") {  
                                   var accountInfo = response.getReturnValue();   
                                   if(!accountInfo || accountInfo [0] == null)      {
                                       alert("Contact Check cannot be done. Contact info system does not return any result for the same");      
                                   }else     {                   
                                       location.reload();               
                                   }               
                                   $A.get("e.force:closeQuickAction").fire();               
                                   /*var toastEvent = $A.get("e.force:showToast"); 
                                   toastEvent.setParams({  "title": "Succes","message": "Record succesvol bijgewerkt." }); 
                                   toastEvent.fire(); */
                                   $A.get("e.force:refreshView").fire(); 
                               }else if (state === "INCOMPLETE") {
                                   
                               }else if (state === "ERROR") { 
                                   var errors = response.getError(); 
                                   if (errors) {                   
                                       if (errors[0] && errors[0].message) {                        
                                           console.log("Error message: " + errors[0].message);                    
                                       }               
                                   }else {                    
                                       console.log("Unknown error");                
                                   }  
                               }
                           });
        $A.enqueueAction(action);  
    }              
})