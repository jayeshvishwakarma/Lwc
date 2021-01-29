({
    doInit : function(component, event, helper) {
        component.set("v.showSpinner",true);
        var action = component.get("c.getCustomActivity");
        action.setParams({
            "taskId" : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS") {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": response.getReturnValue(),
                });
                navEvt.fire();
            }   
            else if(response.getState() === "ERROR") {
                
            }
                else if(response.getState() === "INCOMPLETE") {
                    
                }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },
    /*
    doEdit : function(component,event,helper){
        component.set("v.isEditable",true);
    },
    
    doCancel : function(component,event,helper){
        component.set("v.isEditable",false);
    },
    
    save : function(component,event,helper) {
        component.set("v.showSpinner",true);
        component.find("edit").get("e.recordSave").fire();
        component.set("v.showSpinner",false);
    },
    
    handleSaveSuccess : function(component,event,helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully.",
            "type" : "success"
        });
        toastEvent.fire();
        component.set("v.isEditable",false);
        
    }
    */
})