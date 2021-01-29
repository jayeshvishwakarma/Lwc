({

    handleRecordUpdated: function (component, event, helper) {
        var eventParams = event.getParams();
        if (eventParams.changeType === "LOADED") {
            //To Pull Customer & AssetId and pass to create Case cmp
            if (component.get("v.simpleRecord.AssetId")) {
                component.set("v.customerAssetId", component.get("v.simpleRecord.AssetId"));
                component.set("v.assetValue", true);
            } else if (component.get("v.simpleRecord.Customer__c")) {
                component.set("v.customerAssetId", component.get("v.simpleRecord.Customer__c"));
                component.set("v.assetValue", true);
            }
        }
    },
    closeModel : function(component, event, helper) {

        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
            .catch(function(error) {
                console.log(error);
            });
        console.log('close');
        let caseId = event.getParam("caseId");
        if(caseId){
            workspaceAPI.openTab({
                url: '#/sObject/'+caseId+'/view',
                focus: true
            });
        }
    },
})