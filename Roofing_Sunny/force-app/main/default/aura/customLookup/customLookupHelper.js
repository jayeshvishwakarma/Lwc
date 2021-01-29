({
	searchHelper : function(component,event,getInputkeyWord) {
	  // call the apex class method 
     var action = component.get("c.fetchLookUpValues");
        var fieldList = component.get("v.fieldsToShow").split(',');
      // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'fieldsToShow':component.get("v.fieldsToShow"),
            'addlfieldsToQuery':component.get("v.addlfieldsToQuery"),
            'searchField':component.get("v.searchField"),
            'lookupFilter':component.get("v.lookupFilter"),
            'orderByField':component.get("v.orderByField"),
            'ObjectName' : component.get("v.objectAPIName"),
            'doGlobalSearch' : component.get("v.doGlobalSearch")
          });
      // set a callBack    
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                console.log('storeResponse==>' + storeResponse);
                component.set("v.listOfSearchRecords", storeResponse);                           
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
})