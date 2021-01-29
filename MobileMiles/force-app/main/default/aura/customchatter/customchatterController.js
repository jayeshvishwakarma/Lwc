({
	// Handle component initialization
    doInit : function(component, event, helper) {
        var type = component.get("v.type");
        var types = component.get("v.types");
        var opts = new Array();

        // Set the feed types on the lightning:select component
        for (var i = 0; i < types.length; i++) {
            opts.push({label: types[i], value: types[i], selected: types[i] === type});
        }
        component.set("v.options", opts);
        
        
    }
})