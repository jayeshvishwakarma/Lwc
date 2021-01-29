({
    doInit : function(component, event, helper){
        // alert(component.get('v.pageReference'));
    },
   
    //Method for force:recordData cmp
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        var BCRRequestSent = component.get("v.BCRRequestSent");
        var fetchRecordComplete = component.get("v.fetchRecordComplete");
        
        //If Record is fetched then return
        if(fetchRecordComplete) 
            return;

        if(eventParams.changeType === "LOADED") {

            //populate the URLs if not already populated.
            if(component.get('v.url') === undefined){
                helper.populateURLs(component, event, helper);
            }
           
            // record is loaded (render other component which needs record data value)
            var stage = component.get("v.simpleRecord.StageName");
            var bookingNumber = component.get("v.simpleRecord.Booking_Number__c");
            var count = component.get('v.counter');
           
            // Checking if the stage is booking or retail and booking number is generated to show the
            // BCR request page
            if((stage==='Booking' || stage==='Retail') &&
               (bookingNumber !== '' && bookingNumber !== null && bookingNumber !== undefined)){
                    component.set('v.showDetail',true);
                    component.set('v.showRequestBCRBtn',true);

                    //Send the BCR Request if not sent.
                    if(!BCRRequestSent){
                        helper.updateSendBCRTime(component, event, helper);
                    }else{
                        //Check if the fetch has been completed or not.
                        helper.fetchRecordCompleted(component, event, helper);
                    }

                    //If Record is not fetched then load the Spinner and then put the 10 second timer.
                    if(!fetchRecordComplete){
                        helper.loadSpinnerIcon(component, event, helper);
                    }

            }else{
                $A.util.removeClass(component.find('errorMessage'),'slds-hide');
                component.set('v.showDetail',false); //Hide details and show error
                component.set("v.errorMessage","BCR can only be generated in Booking or Retail stage.");
            }
           
        } else if(eventParams.changeType === "CHANGED") {
            //Only check if the BCR has been sent.
            var BCRRequestSent = component.get("v.BCRRequestSent");
            if(!BCRRequestSent){
                helper.fetchRecordCompleted(component, event, helper);
            }

        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    },
   
    //Method to save BCR form as a PDF in Salesforce
    savePdf : function(component,event, helper){
        component.set('v.showSpinner',true);
        var action = component.get('c.downloadBCRDocument');
       
        var btnLabel = event.getSource().get("v.label");
       
        var fieldToUpdate = 'BCR_Sent__c';
        var bcrSentFlag = component.get("v.simpleRecord.BCR_Sent__c");
        var revisedBCRSent = component.get("v.simpleRecord.Revised_BCR_Sent__c")
        
        //If revisedBCR is either N or Y then its an ammendment
        if(revisedBCRSent === 'N' || revisedBCRSent ==='Y'){
            fieldToUpdate = 'Revised_BCR_Sent__c';
        }
       
        action.setParams({
            'recordId' : component.get('v.recordId'),
            'btnLabels' : btnLabel,
            'pageName':'BookingBCRFormPDF',
            'fileName' : 'Booking Confirmation Receipt',
            'fieldName' : fieldToUpdate,
            'networkid' : ''
        });
        action.setCallback(this, function(response){
            if(response.getState()==='SUCCESS'){
                helper.closePopup(component, event);
                //Show Toast messgage
                var msg = 'Booking Confirmation Receipt has been generated successfully.';
                if(btnLabel==='Save & Send')
                    msg = 'Booking Confirmation Receipt has been sent successfully.';
               
                helper.showToast(component, event, msg, 'success');
            }
           
            else if(response.getState()==='ERROR'){
               
            }
        });
        $A.enqueueAction(action);
    },
   
    updateSendBCRTime : function(component, event, helper){
       
        helper.updateSendBCRTime(component, event, helper);
    },
   
    //Close the modal
    closeModal : function(component, event, helper){
        helper.closePopup(component, event);
    },

    //Close the modal
    resendFlag : function(component, event, helper){
        helper.updateSendBCRTime(component, event, helper);
    }


})