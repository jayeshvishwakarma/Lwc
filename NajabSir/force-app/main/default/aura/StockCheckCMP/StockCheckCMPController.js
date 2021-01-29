({
	doInit : function(component, event, helper) {
		//Set device type
        //Added By-: Nishant Prajapati	Date-: 24/09/2019
        var screenType= $A.get("$Browser.formFactor");
        component.set('v.deviceFormFactor',screenType);
	}
})