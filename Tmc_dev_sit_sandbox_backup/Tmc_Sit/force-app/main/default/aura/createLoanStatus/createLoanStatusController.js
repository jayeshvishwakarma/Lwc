/**
 * @File Name          : createLoanStatusController.js
 * @Description        : 
 * @Author             : Satish Kumar
 * @Group              : 
 * @Last Modified By   :Satish Kumar
 * @Last Modified On   : 11/5/2020, 3:48:19 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/5/2020       Satish Kumar     Initial Version
**/
({
	//To set the values of fields to be retrived in case object changes
    doInitAction : function(component, event, helper) {
         var oppId = component.get("v.oppId");
         var url=component.set("v.currentUrl", window.location);
         console.log('URL1=='+url);
        console.log('id'+oppId);
              var action = component.get("c.getLoanStatusFromFMP");
        console.log(action);

        console.log('action'+oppId);
         
        action.setParams({
            "oppId": oppId
           
        });
         action.setCallback( this, function(response) {
            var state = response.getState();
              console.log('status'+state);
            if (state === "SUCCESS") {
                var wrapRecord=component.set("v.wrapRecord", response.getReturnValue());
               // alert(wrapRecord);
                if($A.util.isEmpty(wrapRecord)){
                  component.set("v.loading", false);
                 }else{
                  component.set("v.loading", true);
                 }
                var isEnquiryBlank = component.get("v.wrapRecord.enqNo");
                //alert(isEnquiryBlank);
                if($A.util.isEmpty(isEnquiryBlank)){
                    component.set("v.isEnquiryBlank", false);
                   }else{
                     component.set("v.isEnquiryBlank", true);  
                   }
                 
                console.log('from server:='+response.getReturnValue());
            }
            else{
                console.log('failes:+'+response); 
            }
        });
       $A.enqueueAction(action);
    },
    redirectCurrent : function (component, event) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    }
})