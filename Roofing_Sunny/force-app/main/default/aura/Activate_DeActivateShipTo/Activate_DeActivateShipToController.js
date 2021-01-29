({
	createActivateorDeactivateAccount : function(component, event, helper) {
        var reason = component.get('v.reason'); 
        var activateInd = component.get('v.activateInd');
        if($A.util.isEmpty(reason) || reason == ''){
            component.set('v.requiredError', true);            
            component.set('v.errorMessage', 'Reason must be selected');     
            component.set("v.requiredSuc", false);
            component.set("v.successMsg", '');
            window.scrollBy(0,-800);
        }
        else{
            component.set('v.requiredError', false); 
            component.set("v.requiredSuc", true);
            component.set("v.successMsg", 'Request Saved Successfully. Go to bottom of form to submit.');
            var params = event.getParam('arguments');
            if (params) {
                var isSubmitted = params.isSubmitted;           
                helper.createActivateorDeactivateAccountHelper(component, event, isSubmitted);
            }
        }
	}
})