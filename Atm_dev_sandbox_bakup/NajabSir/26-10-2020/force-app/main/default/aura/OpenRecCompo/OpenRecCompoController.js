({
    init : function(component, event, helper) {
        
        var quickActions = $A.get("$Label.c.CustomerQuickActions");
        console.log('== quickActions ', quickActions);
        var quickActionsList = [];
        quickActionsList = JSON.parse(quickActions);
        
        component.set('v.picklistValues', quickActionsList);
        console.log('== quickActionsList ', quickActionsList);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);
        
        let customerPage = component.get("v.customerPage");
        console.log('== customerPage ', customerPage);
        
        var recId = component.get("v.recordId");
        component.set("v.accRecId", recId);
        console.log(' == onload change recId ', recId);
        if(recId){
            component.set("v.isSpinner", true);
            component.set("v.showForm", false);
            component.set("v.showSaveProceedBtn", false);
            component.set("v.showProceedBtn", true);
        	helper.loadCustomerData(component, recId);
        }else{
            component.set("v.showSaveProceedBtn", true);
            component.set("v.showProceedBtn", false);
        }
        
    },
    
    onRecordIdChange: function(component, event, helper){
        var recId = component.get("v.recordId");
        console.log(' == In change recId ', recId);
        
        if((typeof(recId) == 'string')){
            if((recId.startsWith('001') === true)){
                //component.set("v.showSaveProceedBtn", false);
            	//component.set("v.showProceedBtn", true);
            	
                component.set("v.onCustomerPage", true);
                component.set("v.showForm", false);
            	component.set("v.showProceedBtn", true);
            	
            }else{
                component.set("v.showForm", true);
                component.set("v.onCustomerPage", false);
                component.set("v.showSaveProceedBtn", true);
            	component.set("v.showProceedBtn", false);
            }
        }else{
            component.set("v.showForm", true);
            component.set("v.onCustomerPage", false);
            component.set("v.showSaveProceedBtn", true);
            component.set("v.showProceedBtn", false);
        }
    },
    
    handleSaveBtn: function(component, event, helper) {
        component.set("v.isSpinner", true);
        let btnType = event.getSource().get("v.name");
        console.log('== Button Name ', btnType);
        if(btnType == 'Proceed'){
        	let tempacc = component.get("v.acc");
            tempacc.Id = component.get("v.accRecId");
        	component.set("v.acc", tempacc);
        }
        console.log('== All values ', JSON.stringify(component.get("v.acc")));
        console.log('== Type values ', component.get('v.selectedEnquiryType'));
        
        //var customerAuraIds = ["FirstName","LastName","PersonEmail","PersonMobilePhone","PersonBirthDate","enqType"];
        
        var allValid = component.find('AccountField').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        console.log('== check validity ', allValid);
        if(allValid){
            let accData = component.get('v.acc');
            component.set("v.Type", accData.Enquiry_Type__c);
            var action = component.get("c.createCutomer");
            action.setParams({ recData : JSON.stringify(component.get("v.acc")) });
            // the server-side action returns
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    
                    component.set("v.showForm", false);
                    
                    if(btnType == 'SaveProceed'){
                        component.set("v.showSpinnerMsg", true);
                        let accId = response.getReturnValue();
                        console.log('== accId ',accId);
                        component.set('v.accRecId', accId);
                        
                        setTimeout(function(){
                            var navService = component.find("navService");
                            var pageReference = {
                                type: 'standard__recordPage',
                                attributes: {
                                    actionName: 'view',
                                    objectApiName: 'Account',
                                    recordId : accId // change record id. 
                                }
                            };
                            component.set("v.pageReference", pageReference);
                            navService.navigate(pageReference, true);
                        },500);
                            
                    }else if(btnType == 'Proceed'){
                        var appEvent = $A.get('e.c:actionType');
                        appEvent.setParams({
                            "actType" : component.get("v.Type")
                        });
                        appEvent.fire();
                    }
                }else if (state === "ERROR") {
                    component.set("v.isSpinner", false);
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            let msg = errors[0].message;
                            console.log("Error message: " + msg);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "",
                                "message": msg
                            });
                            toastEvent.fire();
                        }
                    } else {
                        console.log("Unknown error");
                        component.set("v.isSpinner", false);
                    }
                }
            });
            
            $A.enqueueAction(action);
            
        }else{
            console.log('== Not Valid');
            component.set("v.isSpinner", false);
        }
        
    },
    
    doRecIdCheckEvent : function( cmp, event, helper) {
        
        var recId = event.getParam("recId");
        console.log('== record Id eventParam ', recId);
        if(recId == cmp.get('v.accRecId')){
            var appEvent = $A.get('e.c:actionType');
            appEvent.setParams({
                "actType" : cmp.get("v.Type")
            });
            appEvent.fire();
        }
    },
    doSpinnerCheckEvent : function(cmp, event, helper){
        
        var eventParam = event.getParam("showSpinner");
        if(eventParam == false){
            
            window.setTimeout(
                $A.getCallback(function() {
                    cmp.set("v.isSpinner", false);
                    cmp.set("v.showSpinnerMsg", false);
                    let saveProceed = cmp.get("v.showSaveProceedBtn");
                    if(saveProceed){
                        var defaultData = {'First_Name__c': '','Last_Name__c': '', 'Email__c': '',
                                 'Mobile__c': '', 'Birthday__c': '', 'Last_Call_Center_For_Code__c': '',
                                           'Last_Call_Center_Dealership__c':'', 'Enquiry_Type__c': ''
                                          };
                        cmp.set("v.onCustomerPage", true);
                		cmp.set("v.showForm", false);
                        cmp.set("v.acc", defaultData);
                        
                    }else{
                        cmp.set("v.showForm", true);
                    }
                }), 5000
            );
        }
    },
    
    handleForcodeSelect: function(cmp, event, helper){
        let forCodeId = event.getParam('forCodeId');
        console.log('== ForCode Id ', forCodeId);
        let tempAcc =  cmp.get("v.acc");
        tempAcc.Last_Call_Center_For_Code__c = forCodeId;
        cmp.set("v.acc", tempAcc);
    },
    
    handleDealerSelect: function(cmp, event, helper){
        let dealerShipId = event.getParam('dealerShipId');
        console.log('== dealerShipId Id ', dealerShipId);
        let tempAcc =  cmp.get("v.acc");
        tempAcc.Last_Call_Center_Dealership__c = dealerShipId;
        cmp.set("v.acc", tempAcc);
    }
})