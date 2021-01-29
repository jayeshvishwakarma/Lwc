({
	doInit : function(component, event, helper) {
		//Set device type
        component.set('v.deviceFormFactor',$A.get("$Browser.formFactor"));
	},
    closePopup : function (component, event) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },

    handleQuoteCreateSuccess: function(component, event, helper){
        let recordId = event.getParam('recordId');
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
})