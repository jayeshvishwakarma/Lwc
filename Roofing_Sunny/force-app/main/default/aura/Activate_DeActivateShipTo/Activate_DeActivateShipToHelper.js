({
	createActivateorDeactivateAccountHelper : function(component, event, isSubmitted) {
		var accountId = component.get('v.accountId');
        var caseId = component.get('v.caseId');
        
        var activateInd = component.get('v.activateInd');
        var reason = component.get('v.reason');
        var reasonText = component.get('v.reasonText');
        var strRequestType = '';
        if(activateInd){
            strRequestType = 'Activate a Ship-To Account Request';
        }else{
            strRequestType = 'Deactivate a Ship-To Account Request';
        }
        
        var action = component.get("c.createActivateorDeactivateAccountRequest");    
        console.log('reason==>' + reason);
        console.log('reasonText==>' + reasonText);        
        action.setParams({
            actId : accountId,     
            csId : caseId,
            isSubmitted : isSubmitted,
            requestType : strRequestType,
            reason : reason,
            reasonText : reasonText
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
        
      /* var action1 = component.get("c.checkforInprogressRequestsOnAccount");                
        action1.setParams({actId : accountId});
        action1.setCallback(this, function(response){               
            var state = response.getState();
            console.log('state==>' + state);
            var currentMatch = response.getReturnValue();
            if (state === "SUCCESS") {  
               	console.log('currentMatch==>' + currentMatch);
                if(!currentMatch){
                   
                }
            }
        });
        $A.enqueueAction(action1);*/
	},   
})