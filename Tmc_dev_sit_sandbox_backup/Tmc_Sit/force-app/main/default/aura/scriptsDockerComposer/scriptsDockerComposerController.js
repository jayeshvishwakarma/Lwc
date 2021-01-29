({
    init: function (cmp, event, helper) {
        
        var loggedInProfileName=($A.get("$Label.c.Script_Docker_Profile_Check").split(';'));
        var action = cmp.get("c.getMetadataRecords");
        action.setParams({
            campaignType: null,
            campaignId: null
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if(loggedInProfileName.includes(data.profileName)){
                    var a = cmp.get("c.formFactorSet");
                    $A.enqueueAction(a);
                }else{
                    cmp.set("v.reloadForm",false);
                    cmp.set("v.isLarge",false);
                }
            }
        });
        $A.enqueueAction(action);
    },
   formFactorSet: function(cmp, event, helper){
        //Retrieve device form. Dont show scripts popup on a mobile
        var device = $A.get("$Browser.formFactor");
        console.log(device);
        if (device === 'DESKTOP' || device === 'TABLET') {
            cmp.set("v.isLarge",true);
        }
        else {
            console.log(device);            
            cmp.set("v.isLarge",false);
        }

    },
    
    handleFinish : function (cmp,event,helper) {
        console.log('success save');
        var reset = cmp.get("c.resetScript");
        $A.enqueueAction(reset);
    },  

    toggleOpen: function (cmp,event,helper) {
        if(event.getSource().get("v.iconName")!=='utility:minimize_window' && !cmp.get("v.showFlow") 
           && !cmp.get("v.displayFlow") && !cmp.get("v.showSurvey")){
            var reset = cmp.get("c.resetScript");
            $A.enqueueAction(reset);
            helper.callScript(cmp,event);
        }
        cmp.set("v.isOpen", !cmp.get("v.isOpen"));        
    },
    
    //This function will reset the script and will call the flow from begining
    resetScript : function (component,event,helper){
        try{
            component.set("v.showSurvey", false);
            component.set("v.showChoices", false);
            component.set("v.showSurvey",false);
            component.set("v.choiceMade","");
            if(component.get("v.displayFlow")){
                var flowfinal = component.find("flowData");
                flowfinal.destroy();
                $A.createComponent(
                    "lightning:flow", { 
                        "aura:id": "flowData"
                    },
                    function (flowComponent, status, errorMessage) {
                        var outerDiv = component.get("v.firstPanel");
                        outerDiv.push(flowComponent);
                        component.set("v.firstPanel", outerDiv);
                    }
                );
            }
            var a = component.get("c.formFactorSet");
            helper.callScript(component,event);
            $A.enqueueAction(a);
            
        }catch(error){
            console.log('error------>',error);
        }
    },
        
   toggleReset: function (component) { 
       
        helper.callScript(component,event);
        console.log('opening');
        component.set("v.isOpen", !component.get("v.isOpen"));       
   },
    handleChange: function (cmp, event, helper) {
        //fires when user makes a selection of script to run
        var changeValue = event.getParam("value");
        console.log(changeValue); 
        cmp.set("v.showChoices",false);
        console.log('calling helper'); 
        let campMeta = cmp.get("v.campMetadata");
        console.log(campMeta[0].Script_Name__c);
        let selectedMeta = campMeta.filter(obj => {
            return obj.Script_Name__c == changeValue;
        });
        console.log(selectedMeta);
        if (selectedMeta)
            helper.startScript(cmp,selectedMeta[0]);        
    },
})