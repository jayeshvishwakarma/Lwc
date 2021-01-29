({
    doInit : function(component){
     // var name=  document.getElementsByClassName('modal-header slds-modal__header')[0].innerText;
    //  console.log('name'+name);
        //Set device type
       component.set('v.deviceFormFactor',$A.get("$Browser.formFactor"));
    },
    handelClose : function(component, event, helper) {
            $A.get('e.force:refreshView').fire();
            $A.get("e.force:closeQuickAction").fire();
        } 
        
    
})