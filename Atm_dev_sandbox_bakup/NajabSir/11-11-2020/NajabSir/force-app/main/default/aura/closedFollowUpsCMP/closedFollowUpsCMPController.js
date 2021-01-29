({
	doInit : function(component, event, helper) {
        component.set('v.deviceFormFactor',$A.get("$Browser.formFactor"));
        console.log('== In Lightning Component ', $A.get("$Browser.formFactor"));
	}
})