({
  doInit: function(component, event, helper) {
    var flow = component.find("flowData");
    var inputVariables = [
      {
        name: "recordId",
        type: "String",
        value: component.get("v.recordId")
      }
    ];
    flow.startFlow("Pre_Booking_of_Enquiry", inputVariables);
  }
});