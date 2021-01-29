({
    doInit: function(component, event, helper) {
        let recId = component.get("v.recordId");
        if(recId.startsWith('006')){
            component.set("v.ObjectName","Opportunity");
        }
    },
    handleFinish: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        //$A.get('e.force:refreshView').fire();
    }
    
})