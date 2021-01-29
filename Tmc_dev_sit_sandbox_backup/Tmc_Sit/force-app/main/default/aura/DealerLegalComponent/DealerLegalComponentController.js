({
   
    handelClose : function(component, event, helper) {
            $A.get('e.force:refreshView').fire();
            $A.get("e.force:closeQuickAction").fire();
        },
        openFile : function(component, event) {
           console.log('== ID ',event.getParam('value'));
           let ids = [];
           ids.push(event.getParam('value'));
            $A.get('e.lightning:openFiles').fire({
                recordIds:  ids
            });
        } 
        
    
})