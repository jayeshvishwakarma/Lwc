({
	closePopup : function(component, event) {
		$A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
	}
})