({
    //Close the window (in case if used inside quick action)
	 handleClose: function(component,event,helper) {
         if (component.get("v.closePopup") === false){
            component.set("v.signCaptured","true");
         }
         else {
            $A.get('e.force:refreshView').fire();
            $A.get("e.force:closeQuickAction").fire();
         }
    }
})