({
    doInit : function(component){
        //Set device type
        component.set('v.deviceFormFactor',$A.get("$Browser.formFactor"));
    },
    onClosePopUp : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },
    onSubmit : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        //$A.get('e.force:refreshView').fire();
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
        
    }
})