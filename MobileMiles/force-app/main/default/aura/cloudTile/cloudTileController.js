({
	img1img2 : function(component, event, helper) {		
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/contactsupport"
        });
        urlEvent.fire();
	},
    img3img4 : function(component, event, helper) {		
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/"
        });
        urlEvent.fire();
	}
})