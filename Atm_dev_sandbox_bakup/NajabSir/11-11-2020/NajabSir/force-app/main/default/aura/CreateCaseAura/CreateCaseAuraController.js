({
    doInit : function(component, event, helper) {
        let workspaceAPI = component.find("workspace");
        let recordId ='';
        if(component.get("v.pageReference") && component.get("v.pageReference").state){
            recordId = component.get("v.pageReference").state.c__recordId;
        }else{
            recordId = component.get( "v.recordId");
        }
        workspaceAPI.generateConsoleURL({
            "pageReferences": [
                {
                    "type": "standard__objectPage",
                    "attributes": {
                        "objectApiName": "Case",
                        "actionName": "new"
                    },
                    "state":{
                        recordId :recordId,
                        override: "1"
                    }
                }
            ]
        }).then(function(url) {
            console.log('url   ' +url);
            workspaceAPI.openConsoleURL({
                url: url,
                focus: true
            });
        })
            .catch(function(error) {
                console.log(error);
            });
        if(component.get("v.pageReference") && component.get("v.pageReference").state){
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                //workspaceAPI.closeTab({tabId: focusedTabId});
            })
                .catch(function(error) {
                    console.log(error);
                });
        }


    }
});