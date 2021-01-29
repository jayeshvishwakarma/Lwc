({
    //Function to be called on click of confirm from Summary screen
    onSubmit : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    //Close the modal
    closeModal : function(component, event, helper){
        helper.closePopup(component, event);
    }
    
})