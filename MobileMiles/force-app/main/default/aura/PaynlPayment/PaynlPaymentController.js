({
	doInit : function(component, event, helper) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        var i;
        var sParameterName;
        var i;
		var orderid;
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.

            if (sParameterName[0] === 'orderStatusId') { 
                sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
               
            }
            if(sParameterName[0] === 'orderId'){
            	orderid =  sParameterName[1];   
            }
        }
        if(sParameterName[1] == "100")
        	component.set("v.Success", true);
        else
            component.set("v.Success", false);
        	
        var action = component.get("c.ParametersFromPage"); 
        action.setParams({ params : sParameterName[1], orderId : orderid });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                this.handleResponse(response, component);
			
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})