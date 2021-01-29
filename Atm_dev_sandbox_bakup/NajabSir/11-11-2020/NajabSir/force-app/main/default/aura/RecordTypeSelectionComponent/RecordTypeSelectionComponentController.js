({
	handleCreateRecord : function(component, event, helper) {
		var appEvent = $A.get("e.c:PassRecordTypeValue");
        appEvent.setParams({"recordTypeValue" : component.get("v.value")});
        appEvent.fire();
        component.find("overlayLib").notifyClose();
	}
})