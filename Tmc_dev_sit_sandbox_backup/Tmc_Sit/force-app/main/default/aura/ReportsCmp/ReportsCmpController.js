({
    myAction : function(component, event, helper) {
        var fetchReport = component.get("c.fetchData");
        fetchReport.setCallback(this,function(res){
            var state = res.getState();
            if(state === "SUCCESS"){
                var picklist = [];
                var mapValues = res.getReturnValue();
                for ( var key in mapValues.picklistValuesMap ) {
                    picklist.push({
                        value:mapValues.picklistValuesMap[key],
                        key:key
                    });
                }
                component.set("v.modelPicklist", picklist);
                component.set("v.reportsList",res.getReturnValue());
            }
        });
        $A.enqueueAction(fetchReport);
    },
    
    handleUrl : function(component,event,helper){
        var workspaceAPI = component.find("workspace");
        console.log('event.target.getAttribut-----',event.target.getAttribute("data-recName"));
        if(event.target.getAttribute("data-recName") !== "Consumer Offer report"){
            workspaceAPI.openTab({
                url: event.target.getAttribute("data-recUrl"),
                focus: true
            })
        }else{
            component.set("v.showReports",false);
            component.set("v.showlookUp",true);
            component.set("v.urlLink",event.target.getAttribute("data-recUrl"));
        }
    },
    
    handlePrev : function(component,event,helper){
        component.set("v.showReports",true);
        component.set("v.showlookUp",false);
    },
    
    handleFilter: function(component,event,helper){
        console.log('component.get("v.selectedLookUpRecord").Id--------',component.get("v.selectedLookUpRecord").For_Code__c);
        console.log('value is -----------',component.get("v.pickListApiValue"));
        console.log('value is --------------',component.get("v.urlLink"));
        console.log('component.get("v.selectedLoo--------',component.get("v.selectedLookUpRecordForProduct").Variant_Code__c);
        if(component.get("v.selectedLookUpRecord").For_Code__c && component.get("v.pickListApiValue")){
            var editUrl = component.get("v.urlLink");
            editUrl = editUrl+'&fv2='+component.get("v.selectedLookUpRecord").For_Code__c+'&fv3='+component.get("v.pickListApiValue");
            if(component.get("v.selectedLookUpRecordForProduct").Variant_Code__c){
                editUrl =   editUrl+'&fv4='+component.get("v.selectedLookUpRecordForProduct").Variant_Code__c;
            }
            var workspaceAPI = component.find("workspace");
            workspaceAPI.openTab({
                url: editUrl,
                focus: true
            }) 
        }else{
            var toast =$A.get("e.force:showToast");
                toast.setParams({
                    type:"Error",
                    title: "Provide Required Values",
                    message: "Please provide city and model values"
                });
                toast.fire(); 
        }
    },
    
    handlePicklistChange : function(component,event,helper){
        component.set("v.pickListApiValue",event.getSource().get("v.value"));
        var childComp = component.find('childComp');
        childComp.callChild();
    }
})