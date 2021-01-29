({
    
    recordUpdate: function(component, event, helper) {
    	var action = component.get("c.getRedirectURL");
        action.setParams({ key : 'Renewal_Calculator', policyNo : component.get("v.record").Policy_No__c});
        action.setCallback(this, function(response) {
            console.log(response.getReturnValue());
            var reponse= response.getReturnValue();
            if(reponse){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": reponse
                });
                component.set('v.loaded', true);
                urlEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    }
    
})