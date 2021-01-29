({
    handleCloseEvent : function(component, event, helper) {
        console.log('Thus call');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
            .catch(function(error) {
                console.log(error);
            });
        console.log('close');
        let caseId = event.getParam("caserecId");
        if(caseId){
            workspaceAPI.openTab({
                url: '#/sObject/'+caseId+'/view',
                focus: true
            });
        }
    },
})