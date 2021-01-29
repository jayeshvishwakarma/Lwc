({
	createPartneringRequestHelper : function(component, event, isSubmitted) {
		var accountId = component.get('v.accountId');              
        var csId = component.get('v.caseId');              
        var strRequestType = 'Partner Ship-To Account Request';
        var soldToAccount = component.get('v.soldToAccount');              
        var action = component.get("c.createPartnerShipToRequest");    		      
        action.setParams({
            	actId : accountId,    
           		csId :csId,
                isSubmitted : isSubmitted,
            	requestType : strRequestType,
            	partnerTo : soldToAccount.Id
            });
        action.setCallback(this, function(response){                       
            var state = response.getState();                   
            if (state === "SUCCESS") {                
                var currentRec = response.getReturnValue();       
                component.set("v.Spinner",false);               
                if(!isSubmitted){                   
                    component.set("v.caseId", currentRec);                     
                    var actDetailView = component.find('actDetailView');                    
        			actDetailView.reloadActDetails(currentRec);
                }  
            }
        });
        $A.enqueueAction(action); 	
	}
})