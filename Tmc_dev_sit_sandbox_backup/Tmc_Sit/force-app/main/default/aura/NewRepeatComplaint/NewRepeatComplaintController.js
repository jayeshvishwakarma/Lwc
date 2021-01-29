({
    doInit: function(cmp) {
        // Set the attribute value. 
        var staticLabel = $A.get("$Label.c.Repeat_Initiation_Message");
        cmp.set("v.message", staticLabel);
    },
	
    handelClose : function(component, event, helper) {
            $A.get('e.force:refreshView').fire();
            $A.get("e.force:closeQuickAction").fire();
        }
})