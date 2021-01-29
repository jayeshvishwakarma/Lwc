({
    doInit : function(component, event, helper) {
        helper.validateEnrollment(component, event, helper);
    },
    
    
    saveDetails : function(component,event,helper){
        component.set('v.showSpinner',true);
        var action = component.get("c.saveEnrollmentDetails");
        console.log('request==>'+JSON.stringify(component.get('v.oppObject')));
        action.setParams({
            'jsonWrap' : JSON.stringify(component.get('v.oppObject'))
        });
        action.setCallback(this, function(response){
            if(response.getState()==='SUCCESS'){
                var responseVar = response.getReturnValue();
                if(responseVar.includes('Success')){
                    helper.closeQuickActionHelper(component,event,helper);
                    helper.showToastMessage(component, event,'Loyalty Enrollment has been created successfully!','Success');
                    helper.navigateToRecord(component,event,helper,responseVar.split('#')[1]);
                    component.set('v.showSpinner',false);
                }
                else if(responseVar.includes('Error')){
                    helper.showToastMessage(component, event,responseVar,'Error');
                    component.set('v.showSpinner',false);
                }
            }
            else if(response.getState()==='ERROR'){
                helper.showToastMessage(component, event,responseVar,'Error');
            }
        });
        $A.enqueueAction(action);
    },
    
    
    closeQuickAction : function(component,event,helper){
        helper.closeQuickActionHelper(component,event,helper);
    }
})