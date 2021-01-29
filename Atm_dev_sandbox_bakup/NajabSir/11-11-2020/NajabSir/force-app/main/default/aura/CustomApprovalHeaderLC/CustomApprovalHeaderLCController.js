({
  handleFinish: function(component, event, helper) {
    $A.get('e.force:refreshView').fire();
  }
})