({
    doInit: function(component, event, helper) {
        component.set("v.showSpinner",true);
        var action=component.get("c.getAllDetails");
        action.setParams({
            "caseRecordId":component.get("v.recordId")			
        });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                if(response.getReturnValue().message.includes("SUCCESS")) {
                    component.set("v.wrapperClass",response.getReturnValue());
                    //component.set('v.newFollowUp.Customer_Mobile__c',response.getReturnValue().caseRecord.Mobile_Number__c);
                    component.set('v.newFollowUp.Next_Follow_Up_time__c',response.getReturnValue().nextFollowUpTime);
                    component.set("v.mapCallOriginToPhoneNumber",response.getReturnValue().mapCallOriginToPhoneNumbers);
                    window.setTimeout(
                        $A.getCallback(function() {
                            component.find("sendSMS").set("v.value","No");
                        })
                    );
                    //alert(JSON.stringify(component.get("v.mapCallOriginToPhoneNumber")));    
                }
                else {
                    helper.showToast(component,event,'ERROR!',response.getReturnValue().message,'error');    
                }
            }
            else if(response.getState() == "ERROR") {
                
            }
                else if(response.getState() == "INCOMPLETE") {
                    
                }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },
    
    save: function(component,event,helper) {
        /////////////////////////Added by Prashant Gahlaut///////////////////////////////////////
        var today = new Date();        
        if(component.find('followuptime').get("v.value") < today.toISOString()){
           component.set("v.validateRecordDateBasis",true);
        }
        else{
            component.set("v.validateRecordDateBasis",false);
        }
        ///////////////////////////////////////////////////////////////////////////////////////////
        var count = 0;
        if($A.util.isEmpty(component.get('v.newFollowUp.Call_Purpose__c'))) {
            count = 1;
            component.find('callPurpose').showHelpMessageIfInvalid();
        }
        if($A.util.isEmpty(component.get('v.newFollowUp.Call_Origin__c'))) {
            count = 1;
            component.find('callOrigin').showHelpMessageIfInvalid();
        }
        if($A.util.isEmpty(component.get('v.newFollowUp.Next_Follow_Up_time__c'))) {
            count = 1;
            component.find('followuptime').showHelpMessageIfInvalid();
        }
        if($A.util.isEmpty(component.get('v.newFollowUp.Send_SMS__c'))) {
            count = 1;
            component.find('sendSMS').showHelpMessageIfInvalid();
        }
        var isValidDate = component.get("v.validateRecordDateBasis");
        if(count == 0 && isValidDate != true) {
            event.getSource().set("v.disabled",true);
            component.set("v.showSpinner",true);
            var action = component.get("c.saveFollowUp");
            action.setParams({ 
                "taskObject": component.get("v.newFollowUp"),
                "caseObject" : component.get("v.wrapperClass.caseRecord")
            });
            action.setCallback(this,function(response){
                if(response.getState() === "SUCCESS"){
                    if(response.getReturnValue().includes('SUCCESS')) {
                        var workspaceAPI = component.find("workspace");
                        workspaceAPI.openSubtab({
                            recordId: response.getReturnValue().split('#')[1],
                            focus: true
                        }).then(function(response) {
                            workspaceAPI.getTabInfo({
                                tabId: response
                            }).then(function(tabInfo) {
                                console.log("The url for this tab is: " + tabInfo.url);
                            });
                        })
                        .catch(function(error) {
                            console.log(error);
                        });
                        helper.showToast(component,event,'SUCCESS!','Task has been created successfully','SUCCESS');
                        $A.get('e.force:refreshView').fire();
                    }
                    else {
                        helper.showToast(component,event,'ERROR!',response.getReturnValue(),'error');
                        event.getSource().set("v.disabled",false);
                    }
                } 
                component.set("v.showSpinner",false);
            });
            $A.enqueueAction(action); 
        }
    },
    
    getPhoneNumber : function(component,event,helper) {
        if(!$A.util.isEmpty(component.get("v.newFollowUp.Call_Origin__c"))) {
            component.set('v.newFollowUp.Mobile__c',component.get("v.mapCallOriginToPhoneNumber")[component.get("v.newFollowUp.Call_Origin__c")]);     
        }
    }
    
    
})