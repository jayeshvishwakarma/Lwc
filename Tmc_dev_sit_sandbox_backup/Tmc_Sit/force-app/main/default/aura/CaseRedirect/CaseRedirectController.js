({
    doinit : function(component, event) {
        var actionAPI = component.find("quickActionAPI");
        actionAPI.getSelectedActions().then(function(result){
            //All available actions shown;
            var quickAction= JSON.parse(JSON.stringify(result));
            var quickActionName= quickAction.actions[0].actionName.split('.')[1];
            console.log('quickActionName>>>', quickActionName);
            if(quickActionName){
                console.log('Policy No___', component.get("v.simpleRecord.Policy_No__c"));
                var action = component.get("c.getRedirectURL");
                action.setParams({ key : quickActionName, policyNo : component.get("v.simpleRecord.Policy_No__c")});
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
            
        }).catch(function(e){
            if(e.errors){
                //If the specified action isn't found on the page, show an error message in the my component
                console.log('Error___', e.errors);
            }
        });
        
    }
})