({
    helperMethod : function(component, event) {
        //close quick action
        window.setTimeout(
            $A.getCallback(function() {
                $A.get("e.force:closeQuickAction").fire();
            }), 1000
        );
    }
})