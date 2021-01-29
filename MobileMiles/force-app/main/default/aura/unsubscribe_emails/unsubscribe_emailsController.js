({
    doInt : function(component, event, helper) {
        var flagAction = component.get("c.turnOnOffFlag");
        var recordId = helper.getParameterByName(component , event, 'recordId');
        flagAction.setParams({ 
                                objectName : component.get("v.objectName"),
                                fieldName : component.get("v.fieldName"),
                               recordId :  recordId,
                              flag : true
                             });
        flagAction.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
               component.set("v.success", true);
            }
        });
        $A.enqueueAction(flagAction);
        
        
    }
    
})