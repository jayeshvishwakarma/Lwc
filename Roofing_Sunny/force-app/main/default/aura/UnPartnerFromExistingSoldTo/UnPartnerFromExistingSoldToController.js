({
	createUnPartneringRequest : function(component, event, helper) {
        var soldToAccount = component.get('v.soldToAccount');        
        if($A.util.isEmpty(soldToAccount)){
            component.set('v.requiredError', true); 
            component.set('v.errorMessage', 'Please select sold-To account from where we need to Unpartner ship-To!!');            
             window.scrollBy(0,-800);
        }
        else{
            component.set('v.requiredError', false);             
            component.set("v.requiredSuc", true);
            component.set("v.successMsg", 'Request Saved Successfully. Go to bottom of form to submit.');
            var params = event.getParam('arguments');
            if (params) {
                var isSubmitted = params.isSubmitted;       
                console.log('test==>' + isSubmitted);
                helper.createUnPartneringRequestHelper(component, event, isSubmitted);
            }
        }
	}
})