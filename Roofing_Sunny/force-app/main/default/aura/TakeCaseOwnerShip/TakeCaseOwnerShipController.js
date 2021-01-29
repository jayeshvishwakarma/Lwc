({ 
  
  recordLoaded: function(component, event, helper) {
      var currentUserId = $A.get("$SObjectType.CurrentUser.Id");	
      component.set("v.record.OwnerId", currentUserId);
      var recordData = component.find("recordData");         
      if(!component.get("v.complete")) {
          component.set("v.complete", true);
         // component.set("v.record", caseRecord);
          console.log(JSON.stringify(component.get("v.record.OwnerId")));
          recordData.saveRecord($A.getCallback(function(result) {                       
              if(result.state === "SUCCESS" || result.state === "DRAFT") {
                  $A.get("e.force:closeQuickAction").fire();
                  $A.get("e.force:refreshView").fire();               
                 helper.showSuccessToast(component, event);
              } 
              else if(result.state === "ERROR"){
                  console.log('Error: ' + JSON.stringify(result.error)); 
                  var errMsg = "";                   
                  for (var i = 0; i < result.error.length; i++) {
                      errMsg += result.error[i].message + "\n";
                  }
                  component.set("v.recordSaveError", errMsg);
                  helper.showErrorToast(component, event);
				  $A.get("e.force:closeQuickAction").fire();                  
                  helper.showErrorToast(component, event);
              }
          }));
      }
  }  ,
  showSpinner: function(component, event, helper) {      
        component.set("v.Spinner", true); 
   },  
    hideSpinner : function(component,event,helper){
       component.set("v.Spinner", false);
    }  
})