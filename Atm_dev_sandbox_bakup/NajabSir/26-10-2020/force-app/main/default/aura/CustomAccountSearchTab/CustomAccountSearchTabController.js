({
  doInit: function(component, event, helper) {
    var flow = component.find("flowData");
    flow.startFlow("Custom_Account_Search", []);
  }
});