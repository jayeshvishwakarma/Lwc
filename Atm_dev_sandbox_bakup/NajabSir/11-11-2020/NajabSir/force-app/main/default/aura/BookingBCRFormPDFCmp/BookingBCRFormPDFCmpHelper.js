({
    updateSendBCRTime : function(component, event, helper){
        component.set('v.showSpinner',true);
        var action = component.get('c.updateSendBCRTimeonOpp');
        
        action.setParams({
            'recordId' : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            if(response.getState()==='SUCCESS'){
                var message = response.getReturnValue();
                
                if(message.includes('Success')){
                    //event.getSource().set('v.disabled',true);
                    helper.showToast(component, event, message, 'success');
                    component.set("v.BCRRequestSent",true);//Set the BCR Request to true indicating the BCR has been requested for the session.
                    //helper.loadSpinnerIcon(component, event,helper);
                }
                else{
                    helper.showToast(component, event, message, 'error');
                }
                component.set('v.showSpinner',false);
            }
            if(response.getState()==='ERROR'){
                let error = response.getError();
                helper.showToast(component, event, error[0].message, 'error');
                component.set('v.showSpinner',false);
            }
            if(response.getState()==='INCOMPLETE'){
                
            }
        });
        $A.enqueueAction(action);
    },
    
    closePopup : function(component, event) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },
    
    showToast : function(component, event, msg, msgType){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": msgType,
            "type":msgType,
            "message": msg
        });
        toastEvent.fire();
    },
    
    bookingNumberValidation: function(component, event, helper){
        component.set('v.errorMessage','Booking Number cannot be blank');
        component.set('v.showDetail',false);
    },
    
    receiptTimeValidation: function(component, event, helper){
        component.set('v.errorMessage','Receipt Time cannot be blank or cannot be less than BCR Request Time');
        component.set('v.showDetail',false);
    },
    populateURLs: function(component, event, helper){
        var pdfUrl='';
        //Get the community full url
        let fullUrl = window.location.href;
        //Get the hostname
        let hostname = window.location.hostname;
        //Split by site.com suffix for community
        let urls = fullUrl.split('/s/');
        
        
        
        if(urls.length>1){
            let n1 = urls[0].lastIndexOf("/")+1;
            let n2 = urls[0].length;
            //Get the community path
            let communityPath = urls[0].substring(n1,n2);
            if(communityPath!=hostname){
                pdfUrl='/'+communityPath;
            }
        }
        
        var device = $A.get("$Browser.formFactor");
        if(device==='DESKTOP' || device==='TABLET'){
            // alert('ok');
            pdfUrl+='/apex/BookingBCRFormPDF?id='+component.get('v.recordId');
        }else{
            // alert('ok2');
            pdfUrl+='/dealers/apex/BookingBCRFormPDFMobile?id='+component.get('v.recordId');
        }
        
        //Set it to the PDF URL to be rendered
        component.set('v.url',pdfUrl);
        
    },    
    
    fetchRecordCompleted: function(component, event, helper){
        //Fetch the latest records
        var sendbcrtime = component.get("v.simpleRecord.Send_BCR_Time__c");
        var receiptTime = component.get("v.simpleRecord.BCR_Receipt_Time__c");
        // If Record is fetched then set the variable to true
        if(receiptTime > sendbcrtime){
            component.set("v.fetchRecordComplete",true);
            component.set('v.showRequestBCRBtn',false); //Set the show pdf to true
        }
        
        
    },
    
    loadSpinnerIcon : function(component, event, helper){
        var loaderMsg = component.find('ajaxmessage');
        var loader = component.find('ajaxLoader');
        
        $A.util.removeClass(loaderMsg,'slds-hide');
        $A.util.removeClass(loader,'slds-hide');
        
        var count = component.get('v.counter');
        count = parseInt(count)+1;
        component.set('v.counter', count);
        
        window.setTimeout(
            $A.getCallback(function() {
                var obj = component.find('recordLoader');
                if(obj!=null && obj!=undefined){
                    obj.reloadRecord(true);
                }
            }), 5000
        );
    }
    
})