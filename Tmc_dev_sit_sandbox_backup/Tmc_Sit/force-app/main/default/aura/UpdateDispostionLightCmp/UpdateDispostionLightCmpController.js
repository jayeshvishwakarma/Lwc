({
    handleFinish: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
        });
        navEvt.fire();
        setTimeout(function(){ $A.get('e.force:refreshView').fire(); }, 1000);
    }
})