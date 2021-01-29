({
    doInit : function(cmp, event, helper) {
        
        let actions = cmp.get("v.availableActions");
        cmp.set("v.showNext", actions.includes("NEXT"));
        cmp.set("v.showFinish", actions.includes("FINISH"));
        cmp.set("v.showPrevious", actions.includes("BACK"));
        cmp.set("v.showPause", actions.includes("PAUSE"));
        cmp.set('v.deviceFormFactor',$A.get("$Browser.formFactor"));
        
        console.log('== screenDecision on Load ', cmp.get("v.screenDecision"));
        //console.log('== Record Data on Load ', JSON.stringify(cmp.get("v.record")));
        
    },
    
    handleNext: function(cmp, event, helper) {
        cmp.set("v.screenDecision", "NEXT");
        //console.log('== screenDecision In Next Method ', cmp.get("v.screenDecision"));
        //console.log('== Next Method Record Data ', JSON.stringify(cmp.get("v.record")));
        helper.navigate(cmp, "NEXT");
    },
    handleFinish: function(cmp, event, helper) {
        helper.navigate(cmp, "FINISH");
    },
    handlePrevious: function(cmp, event, helper) {
        //cmp.set("v.screenDecision", "");
        //console.log('== screenDecision In Previous Method ', cmp.get("v.screenDecision"));
        helper.navigate(cmp, "BACK");
        
    },
    handlePause: function(cmp, event, helper) {
        helper.navigate(cmp, "PAUSE");
    },
    handleSubmit : function(cmp, event, helper) {
        //console.log('== On submit Method');
        cmp.set("v.screenDecision", "SaveAndSubmit");
        helper.navigate(cmp, "NEXT");
        //console.log('== On submit Method', JSON.stringify(cmp.get("v.record")));
    }
})