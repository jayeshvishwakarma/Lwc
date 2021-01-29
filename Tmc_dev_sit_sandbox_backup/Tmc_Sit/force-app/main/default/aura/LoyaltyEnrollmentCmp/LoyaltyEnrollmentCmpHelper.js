({
    
    validateEnrollment : function(component, event, helper) {
        component.set('v.showSpinner',true);
        var action = component.get("c.validateLoyalty");
        action.setParams({
            'recordId' : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            if(response.getState()==='SUCCESS'){
                var responseMessage = response.getReturnValue();
                if(responseMessage.length>0){
                    component.set('v.showSpinner',false);
                    component.set('v.showValidation',true);
                    component.set('v.validateMessage',responseMessage);
                }else{
                    helper.init(component, event, helper);
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    
    
    init : function(component, event, helper) {
        component.set('v.showSpinner',true);
        var action = component.get("c.fetchCustomerDetails");
        action.setParams({
            'recordId' : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            if(response.getState()==='SUCCESS'){
                component.set('v.oppObject',response.getReturnValue());
                component.set('v.showSpinner',false);
            }
        });
        $A.enqueueAction(action);
    },
    
    showToastMessage : function(component, event, msg, msgType) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": msgType+'!',
            "type": msgType,
            "message": msg
        });
        toastEvent.fire();
    },
    
    closeQuickActionHelper : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    
    navigateToRecord : function (component, event, helper,optyid) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": optyid,
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
    
    
})