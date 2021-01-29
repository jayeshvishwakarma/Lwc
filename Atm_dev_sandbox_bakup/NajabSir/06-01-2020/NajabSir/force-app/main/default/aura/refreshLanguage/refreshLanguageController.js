({
    /*handleLanguageSuccess : function(component, event, helper) {
        var newRecordId = component.get("v.recordId");

        console.log(">>>>>>newRecordId"+newRecordId);

        //$A.get('e.force:refreshView').fire();
        var workspaceAPI = component.find("workspace");
        console.log(">>>>>>workspaceAPI"+workspaceAPI);
        //Close the current Tab.
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId})
            .then(function(response) {
                  setTimeout(function()
                  {
                        console.log(">>>>>About to Open the Tab");
                        workspaceAPI.openTab({
                            url:'/lightning/r/Report/00O7F00000BCwcPUAT/view?queryScope=userFolders',
                            //recordId: newRecordId,
                            focus: true
                        })
                        .then(function(tabInfo) {
                        console.log("The recordId for this tab is: " + newRecordId);
                        });
                  }, 1000);

            })
            .catch(function(error) {
            console.log(">>>>>>"+error);
            });
        })
        .catch(function(error) {
            console.log(error);
        });

    },*/
    onRecordIdChange: function (component, event, helper) {
        var newRecordId = component.get("v.recordId");
        var takerStarts = $A.get("$Label.c.SurveyTakerStartingString");
        var showVOC = component.get("v.showVOC");
        if ((typeof (newRecordId) == 'string') &&
            (newRecordId.startsWith(takerStarts) === true)) {
            showVOC = true;
            component.set("v.showVOC", true);
            component.set("v.noShowVOC", false);
        } else {
            showVOC = false;
            component.set("v.showVOC", false);
            component.set("v.noShowVOC", true);
        }

        console.log(newRecordId);
        console.log('>>>>' + showVOC);
    },
    handleSuccess: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})