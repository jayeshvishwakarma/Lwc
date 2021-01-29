({
    //To set the values of fields to be retrived in case object changes
    //Added by Prabhat 16-August-2019
    doInit : function(component){
        //Opportunity fields to be queried
        var oppFields = $A.get("$Label.c.Opportunity_Fields");
        //Quote fields to be queried
        var quoteFields = $A.get("$Label.c.Quote_Fields");
        //To store the fields to be queried
        var sobjectFields = [];
        //If source Object is Opportunity
        if(component.get('v.sObjectName')==$A.get("$Label.c.Opportunity_Object"))
            sobjectFields = oppFields.split(';');
        //If source Object is Quote
        else if(component.get('v.sObjectName')==$A.get("$Label.c.Quote_Object"))
            sobjectFields = quoteFields.split(';');
        
        //Pass the fields to LWC
        component.set('v.sObjectFields',sobjectFields);
        
        //Set device type
        component.set('v.deviceFormFactor',$A.get("$Browser.formFactor"));
    },
    
    //Function to be called on click of confirm from Summary screen
    onSubmit : function(component, event, helper) {
        console.log('== For CLosing the Quick Action');
    /*    
        var showNotification = event.getParam('showNotification');
        console.log('== From lightning component ', showNotification);
        
        if(showNotification){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "",
                "message": $A.get("$Label.c.Refresh_Amount_Msg"),
                "type" : "success"
            });
            toastEvent.fire();
        }
	*/        
        //Hide the Add Line Item Component and Show the Flow
        component.set('v.showAddLineItem', false);
        
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        var inputVariables = [
            {	
                name : 'recordId', type : 'String', 
                value : component.get("v.recordId")
            }
        ];
        // In that component, start your flow.p
        flow.startFlow("Pre_Booking_of_Enquiry", inputVariables);
    },
    
    closePopup : function (component, event) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },

    handleQuoteCreateSuccess: function(component, event, helper){
        let recordId = event.getParam('recordId');
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
})