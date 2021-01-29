({
   selectRecord : function(component, event, helper){      
    // get the selected record from list  
      var getSelectRecord = component.get("v.oRecord");       
    // call the event   
      var compEvent = component.getEvent("oSelectedRecordEvent");
    // set the Selected sObject Record to the event attribute.  
         compEvent.setParams({"recordByEvent" : getSelectRecord });  
    // fire the event  
         compEvent.fire();
    },
    doInit : function(component, event, helper) {
         var getSelectRecord = component.get("v.oRecord");
         var fields = component.get("v.fieldsToShow");
        var fieldList = fields.split(',');
        var result = '';
        
         for (var idx in fieldList) {               
             if(getSelectRecord[fieldList[idx]] != undefined){
             	if(result == ''){
                 	result = getSelectRecord[fieldList[idx]];
                 }else{                     
                    result +=' - ' + getSelectRecord[fieldList[idx]];
                 }    
             }             
         }              
        component.set("v.resultValue",result);
	}
})