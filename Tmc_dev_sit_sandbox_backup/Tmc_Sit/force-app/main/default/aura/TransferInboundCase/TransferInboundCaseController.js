({
	handleFinish: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        setTimeout(function(){ $A.get('e.force:refreshView').fire(); }, 1000);
    }
})