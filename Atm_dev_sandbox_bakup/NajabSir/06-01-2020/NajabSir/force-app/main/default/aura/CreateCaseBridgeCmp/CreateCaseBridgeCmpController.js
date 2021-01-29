({

    doInit: function(component, event, helper) {  
        let myPageRef = component.get("v.pageReference");
       // console.log(JSON.stringify(myPageRef));
        if(myPageRef && myPageRef.state && myPageRef.state.recordId){
            let recordId = myPageRef.state.recordId;
            component.set("v.parentRecordId",recordId);
            component.set("v.recordId",undefined);
        }else{
            let url = new URL(window.location);
            let recordId = url.searchParams.get("recordId");
            if(recordId){
                component.set("v.parentRecordId",recordId);
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
});