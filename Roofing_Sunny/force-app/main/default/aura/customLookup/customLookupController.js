({
    doInit : function(component, event, helper) {
         var selectedRecord = component.get("v.selectedRecord");	
        
        if(!$A.util.isEmpty(selectedRecord) && selectedRecord.Id != undefined){
            
       //  var searchField = component.get("v.searchField");
       //  var fieldList = searchField.split(',');            
       // component.set("v.selectedRecordValue",selectedRecord[fieldList[0]]);
        var fields = component.get("v.fieldsToShow");
        var fieldList = fields.split(',');
        var result = '';
        
         for (var idx in fieldList) {               
             if(selectedRecord[fieldList[idx]] != undefined){
             	if(result == ''){
                 	result = selectedRecord[fieldList[idx]];
                 }else{                     
                    result +=' - ' + selectedRecord[fieldList[idx]];
                 }    
             }             
         }              
        component.set("v.selectedRecordValue",result); 
   
        
        var forclose = component.find("lookup-pill");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
  
        var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');
          
         var searchIcon = component.find("search-icon");
              console.log('searchIcon==>' + searchIcon);
           $A.util.addClass(searchIcon, 'slds-hide');
           $A.util.removeClass(searchIcon, 'slds-show');   
          
        }              
    },
   onfocus : function(component,event,helper){
       $A.util.addClass(component.find("mySpinner"), "slds-show");
        
        var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
         var getInputkeyWord = component.get("v.SearchKeyWord"); 
           if($A.util.isEmpty(getInputkeyWord) || getInputkeyWord == undefined){
               getInputkeyWord = '';
           }
         helper.searchHelper(component,event,getInputkeyWord);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
       // get the search Input keyword   
         var getInputkeyWord = component.get("v.SearchKeyWord");        
       // check if getInputKeyWord size id more then 0 then open the lookup result List and 
       // call the helper 
       // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
             var forOpen = component.find("searchRes");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
             component.set("v.listOfSearchRecords", null ); 
             var forclose = component.find("searchRes");
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
          }
	},
    
  // function for clear the Record Selaction 
    clear :function(component,event,helper){
         var pillTarget = component.find("lookup-pill");
         var lookUpTarget = component.find("lookupField"); 
        
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');
        
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        var searchIcon = component.find("search-icon");
           $A.util.addClass(searchIcon, 'slds-show');
           $A.util.removeClass(searchIcon, 'slds-hide'); 
      
         component.set("v.SearchKeyWord",null);
         component.set("v.listOfSearchRecords", null );
         component.set("v.selectedRecord", {} );   
    },
    
  // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
    // get the selected Account record from the COMPONETN event 	 
       var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	   component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
      // var searchField = component.get("v.searchField");
       //  var fieldList = searchField.split(',');
      //  component.set("v.selectedRecordValue",selectedAccountGetFromEvent[fieldList[0]]);
         var fields = component.get("v.fieldsToShow");
        var fieldList = fields.split(',');
        var result = '';
        
         for (var idx in fieldList) {               
             if(selectedAccountGetFromEvent[fieldList[idx]] != undefined){
             	if(result == ''){
                 	result = selectedAccountGetFromEvent[fieldList[idx]];
                 }else{                     
                    result +=' - ' + selectedAccountGetFromEvent[fieldList[idx]];
                 }    
             }             
         }              
        component.set("v.selectedRecordValue",result);        
        var forclose = component.find("lookup-pill");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
  
        var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show'); 
        
        var searchIcon = component.find("search-icon");
           $A.util.addClass(searchIcon, 'slds-hide');
           $A.util.removeClass(searchIcon, 'slds-show');
      
	},
    selectedRecordChange : function(component, event, helper){
        var selectedRecord = component.get("v.selectedRecord");
        if(selectedRecord == undefined){
            component.set("v.selectedRecordValue", "");
        }
    }
})