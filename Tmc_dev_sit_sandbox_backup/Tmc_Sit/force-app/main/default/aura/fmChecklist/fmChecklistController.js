({
    doinit: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getProfessionType");
        action.setParams({ 'recordId': recordId });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var onloadWrapperCls = response.getReturnValue();
                if (onloadWrapperCls.authUser === 'Not Authorized') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": 'You are not an authorized user',
                        "type": 'error'
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                } else if (onloadWrapperCls.authUser === 'Inactive_PC') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": $A.get("$Label.c.Inactive_Preliminary_Checklist"),
                        "type": 'error'
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                } else if (onloadWrapperCls.authUser === 'Authorized') {
                    if (!$A.util.isEmpty(onloadWrapperCls.professionType)) {
                        component.set("v.selectedType", onloadWrapperCls.professionType);
                        component.set("v.showChecklist", true);
                        component.set("v.showPicklist", false);
                    } else {
                        component.set("v.professionPicklistValues", onloadWrapperCls.professionPicklistValues);
                        component.set("v.showPicklist", true);
                    }
                }

            }
        });
        $A.enqueueAction(action);

    },

    onChange: function (component, event, helper) {
        var selectedValue = component.find('select').get('v.value');

        if (!$A.util.isEmpty(selectedValue)) {
            component.set("v.selectedType", selectedValue);
            component.set("v.showChecklist", true);
            component.set("v.showPicklist", false);
        }
    },

    closeQuickAction: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

})