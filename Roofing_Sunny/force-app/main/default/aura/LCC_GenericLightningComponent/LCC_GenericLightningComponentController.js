({
    
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
           // record is loaded (render other component which needs record data value)
            console.log("Record is loaded successfully.");
            helper.loadUserInfo(component, function(){
                helper.loadProfileInfo(component, function(){
                    helper.loadSiteInfo(component, function(){
                        var appEvent = $A.get("e.c:LCC_GenericApplicationEvent")
                        appEvent.fire();
                    });
                });
            });
                   
        }  else if(eventParams.changeType === "ERROR") {
            //there’s an error while loading, saving, or deleting the record
            console.error("Can't load the record.");
            var toastEvent = $A.get("e.force:showToast");
    		toastEvent.setParams({
        		"title": "Can't load the record.",
                        "duration": 10000,
                        "type": "error",
        		"message": "Can't load the record."
    		});
    		toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
        }
    },

	// For loading additional objects not supported by <force:recordData>
	loadCurrentObject : function(component, event, helper) {
		if(component.get('v.isAdditionalObject')) {
			helper.loadAdditionalObject(component, event);
		}
	},
   
   //for Hide/Close Model,set the "isOpen" attribute to "false" 
   closeModel: function(component, event, helper) { 
      component.set("v.isOpen", false);
   },
   
   // set set the "isOpen" attribute to "false for close the model Box.
   okClose: function(component, event, helper) {
      component.set("v.isOpen", false);
   },
})