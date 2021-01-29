({
    doInit: function (component, event, helper) {
        try {
            let action = component.get("c.getCurrentUserProfileName");
            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    console.log('Current User Profile : ' + response.getReturnValue())
                    component.set("v.currentUserProfileName", response.getReturnValue().split('#')[0]);
                    component.set("v.mosRecordTypeId", response.getReturnValue().split('#')[1]);
                    helper.openRelatedComplaintPage(component);
                } else if (response.getState() === "INCOMPLETE") {
                    // do something
                } else if (response.getState() === "ERROR") {
                    let errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        } catch (e) {
            console.log('Exception In doInit JS function');
            console.log(e.message);
        }
    },
    //Added to close Quick Action Popup
    closePopup: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
});