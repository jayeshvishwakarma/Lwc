({
    doInit : function( cmp, event, helper) {
        //console.log('== URL Value ',cmp.get("v.pageReference").state.testAttribute);
        var appEvent = $A.get('e.c:recordIdCheck');
        appEvent.setParams({
            "recId" : cmp.get('v.recordId')
        });
        appEvent.fire();
    },
    
    doHandleCompEvent : function( cmp, event, helper) {
        cmp.set("v.isSpinner", "true");
		var eventParam = event.getParam("actType");
        console.log('== eventParam ', eventParam); 
        /*
        var actionType = '';
        if(eventParam == 'Vehicle'){
            actionType = "Account.Vehicle";
        }else if(eventParam == 'Accessories'){
            actionType = "Account.Accessories";
        }
        */
        
        var actionAPI = cmp.find("quickActionAPI");
        var args = {actionName: eventParam};
        actionAPI.selectAction(args).then(function(result){
            //Action selected; show data and set field values
            cmp.set("v.isSpinner", false);
        }).catch(function(e){
            if(e.errors){
                //If the specified action isn't found on the page, show an error message in the my component
                console.log('== Error on Action Load ', e.errors);
            }
        });
        
        var appEvent = $A.get('e.c:handleSpinner');
        appEvent.setParams({
            "showSpinner" : false
        });
        appEvent.fire();
        
    }
    
})