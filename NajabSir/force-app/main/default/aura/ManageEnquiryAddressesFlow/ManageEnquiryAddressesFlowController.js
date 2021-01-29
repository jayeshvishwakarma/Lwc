({
  doInit: function(cmp, event, helper) {
    let actions = cmp.get("v.availableActions");
    cmp.set("v.showNext", actions.includes("NEXT"));
    cmp.set("v.showFinish", actions.includes("FINISH"));
    cmp.set("v.showPrevious", actions.includes("BACK"));
    cmp.set("v.showPause", actions.includes("PAUSE"));
    cmp.set("v.deviceFormFactor", $A.get("$Browser.formFactor"));
  },
  handleNext: function(cmp, event, helper) {
    helper.validate(cmp).then(result => {
      if (result) {
        helper.navigate(cmp, "NEXT");
      }
    });
  },
  handleFinish: function(cmp, event, helper) {
    helper.validate(cmp).then(result => {
      if (result) {
        helper.navigate(cmp, "FINISH");
      }
    });
  },
  handlePrevious: function(cmp, event, helper) {
    helper.navigate(cmp, "BACK");
  },
  handlePause: function(cmp, event, helper) {
    helper.navigate(cmp, "PAUSE");
  }
});