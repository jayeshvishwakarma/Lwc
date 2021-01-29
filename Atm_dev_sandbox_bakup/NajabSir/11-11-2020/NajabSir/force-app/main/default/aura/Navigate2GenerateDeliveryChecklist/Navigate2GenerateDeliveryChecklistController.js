({
    doInit : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        let enquiryId= component.get('v.recordId');
        urlEvent.setParams({
            "url": 'https://devr1dot1-marutidev.cs57.force.com/apex/TakeSurvey?id=a0G0k000005dBdXEAU&enqId='+enquiryId
        });
        urlEvent.fire();
        helper.helperMethod(component, event);
    }
})