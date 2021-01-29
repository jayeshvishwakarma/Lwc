({
    //Function to refresh and close the quick action
	closeQuickAction : function(component, event, helper) { 
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
	}
})