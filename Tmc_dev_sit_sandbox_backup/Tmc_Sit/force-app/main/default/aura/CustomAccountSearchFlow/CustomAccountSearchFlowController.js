({
  doInit: function(component, event, helper) {
    component.set("v.deviceFormFactor", $A.get("$Browser.formFactor"));
  }
});