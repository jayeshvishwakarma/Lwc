({
	fetchData : function(component, helper) {
		console.log('in helper');
        var action = component.get("c.getContentList");
        action.setParams({
            "Category" : component.get("v.Category")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response state', state);
            if(state === "SUCCESS"){
                var list = response.getReturnValue();
                console.log('response', response);
                component.set("v.contentsList", response.getReturnValue());
                component.set("v.tileFound", true);
			} else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
        	}else {
                component.set("v.tileFound", false);
            }
        })
        console.log('tileFound-'+component.get("v.tileFound"));
        console.log('contentsList-'+component.get("v.contentsList"));
		$A.enqueueAction(action); 
	}
})