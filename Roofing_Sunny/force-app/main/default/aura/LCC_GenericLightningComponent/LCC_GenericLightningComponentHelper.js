({
	//use this method to keep the “alert” functionality
	showToast : function(message, type) {
        console.log(type);
        if(type === undefined || type === ""){
            type = "info";
        }
    	var toastEvent = $A.get("e.force:showToast");
    	toastEvent.setParams({
        	"title": "",
        	"type": type,
                "duration": 10000,
        	"message": message
    	});
    	toastEvent.fire();
	},
    
    //use this method to load user info in order to replace the global variable $User
    loadUserInfo : function(component,callback){
        //Call Your Apex Controller Method.
        var action = component.get("c.getUserInfo");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("User info is loaded successfully.");
                component.set("v.User",response.getReturnValue());
                callback();
            } else {
                //Do Something
            }
        });
        
        $A.enqueueAction(action);
    },
    
    //use this method to load profile info in order to replace the global variable $Profile
    loadProfileInfo : function(component, callback){
        //Call Your Apex Controller Method.
        var action = component.get("c.getProfileInfo");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Profile is loaded successfully.");
                component.set("v.Profile",response.getReturnValue());
                callback();
            } else {
                //Do Something
            }
        });
        
        $A.enqueueAction(action);
    },
    
    //use this method to load site info in order to replace the global variable $Site
    loadSiteInfo : function(component,callback){
        //Call Your Apex Controller Method.
        var action = component.get("c.getSiteInfo");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Site is loaded successfully.");
                component.set("v.Site",response.getReturnValue());
                callback();
            } else {
                //Do Something
            }
        });
        
        $A.enqueueAction(action);
    },
    
    //use this method to execute a query
    executeQuery : function(component, event, helper, query) {
		
        
        var action = component.get("c.executeQuery");
        action.setParams({
            "theQuery": query
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if(state == "SUCCESS" && component.isValid()){
                var queryResult = response.getReturnValue();
                component.set("v.queryResult", queryResult);
                var appEvent = $A.get("e.c:LCC_QueryApplicationEvent");
            	appEvent.fire();
            }
            else{
                console.error("fail:" + response.getError()[0].message); 
                var toastEvent = $A.get("e.force:showToast");
    		toastEvent.setParams({
        		"title": "Error",
                        "duration": 10000,
                        "type": "error",
        		"message": "Something went wrong in your org: " + response.getError()[0].message
    		});
    		toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },

	// For loading additional objects not supported by <force:recordData>
	loadAdditionalObject: function(component, event) {
		var action = component.get("c.loadObjectInfoById");
		action.setParams({
			"recordId": component.get("v.recordId")
		});

		action.setCallback(this, function(response) {
			var state = response.getState();

			if(state == "SUCCESS" && component.isValid()){
				component.set("v.sObjectInfo", response.getReturnValue());
			} else {
				console.error("Error loading object: " + response.getError()[0].message);
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"title": "Error",
					"duration": 10000,
					"type": "error",
					"message": "Something went wrong: " + response.getError()[0].message
				});
				toastEvent.fire();
				$A.get("e.force:closeQuickAction").fire();
			}
		});
		$A.enqueueAction(action);
	},

    // for Display Model,set the "isOpen" attribute to "true"
    openModel: function(component, event, helper,text) {
        component.set("v.promptText", text);
        component.set("v.isOpen", true);
        
    },
    
    // for Display Model,set the "isOpenAlert" attribute to "true"
    openModelAlert: function(component, event, helper,text) {
        component.set("v.alertText", text);
        component.set("v.isOpenAlert", true);
        
    },

	// for display alerts inside lightning modal popup
	showTextAlert: function(component, text) {
		component.set("v.alertText", text);
		component.set("v.showAlert", true);
	},
    
    //for navigate to another url
    gotoURL : function (component, urlToNavigate) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({"url": urlToNavigate});
        urlEvent.fire();
    },
    
    idTruncate : function (str) {
    	if (str != null && str.length > 15) {
            return str.substring(0, 15);
    	} else {
            return str;
    	}
    },
    
    cloneli : function (oldOppId, newOppId, component){
        //Call Your Apex Controller Method.
        var action = component.get("c.cloneOpportunityLineItems");
    
    	action.setParams({
            "oldOppId": oldOppId,
            "newOppId": newOppId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("LI cloned successfully.");
                
            } else {
                //Do Something
            }
        });
        
        $A.enqueueAction(action);
    }

})