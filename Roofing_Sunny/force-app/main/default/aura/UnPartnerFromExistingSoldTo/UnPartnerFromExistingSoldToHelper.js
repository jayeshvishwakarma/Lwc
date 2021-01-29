({
	createUnPartneringRequestHelper : function(component, event, isSubmitted) {
		var accountId = component.get('v.accountId');              
        var caseId = component.get('v.caseId');                      
        var strRequestType = 'Un-Partner Ship-To Account Request';
        var soldToAccount = component.get('v.soldToAccount');              
        var action = component.get("c.createUnPartnerfromSoldToRequest");          
        action.setParams({
            	actId : accountId,   
            	csId : caseId,
                isSubmitted : isSubmitted,
            	requestType : strRequestType,
            	unpartnerFrom : soldToAccount.Id
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