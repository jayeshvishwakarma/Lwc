({
	doInit : function(component, event, helper) {
		component.set('v.formFactor',$A.get("$Browser.formFactor"));
	},
    
     //Method for force:recordData cmp
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
           // record is loaded (render other component which needs record data value)
            var stage = component.get("v.simpleRecord.StageName");
            if(stage==='Delivery/Closed Won' || stage==='Retail')
                component.set('v.showChecklist',true);
                        
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    },
    
    closeQuickAction : function(component, event){
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    }
})