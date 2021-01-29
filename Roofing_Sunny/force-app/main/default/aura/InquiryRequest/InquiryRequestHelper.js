({
	submitInquiryRequesthelper : function(component, event) {
		var inQuirytext =  component.get("v.inquiryText");
        console.log('Inquiry');
        if(!$A.util.isEmpty(inQuirytext) && inQuirytext != undefined){
            component.set("v.requiredError", false);
            component.set("v.errorMessage", ''); 
            var action = component.get("c.createInquiryRequest"); 
            action.setParams({
                requestType : "Customer Master Inquiry Request",
                inquiryText : inQuirytext               
            });
            action.setCallback(this, function(response){                       
                var state = response.getState();                   
                if (state === "SUCCESS") {
                    component.set("v.Spinner",false);                     
                }
            });
            $A.enqueueAction(action); 	            
        }
        else{            
            component.set("v.requiredError", true); 
            component.set("v.errorMessage", 'Please enter inquiry text.'); 
             window.scrollBy(0,-800);
        }
	}
})