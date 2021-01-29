({
  	init : function(cmp, event, helper) {
        
        var recId = cmp.get("v.recordId");
        console.log(' == recId ', recId);
  },
    onRecordIdChange: function(cmp, event, helper){
        var recId = cmp.get("v.recordId");
        console.log(' == In change recId ', recId);
        cmp.set('v.showMsg', false);
        cmp.set('v.showScripts', false);
        
        var customActivityId = $A.get("$Label.c.Custom_Activity_Id_Prefix");
        
        if((typeof(recId) == 'string')){
            
            if((recId.startsWith(customActivityId) === true)){
                setTimeout(function(){
                    helper.openScipt(cmp, recId);},1000);
            }else if(recId.startsWith('500') === true){
                var action = cmp.get("c.getCaseDetail");
                action.setParams({ recId : recId});
                // the server-side action returns
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        console.log('== Valid ', response.getReturnValue());
                        let result = response.getReturnValue();
                        console.log(' == result ', result);
                        if(result){
                            helper.openScipt(cmp, recId);
                        }else{
                            cmp.set('v.showMsg', true);
                			cmp.set('v.showScripts', false);
                        }
                    }
                });
                $A.enqueueAction(action);
            }else{
                cmp.set('v.showMsg', true);
                cmp.set('v.showScripts', false);
            }
        }else{
            cmp.set('v.showMsg', true);
            cmp.set('v.showScripts', false);
        }
    },
    
    handleRefresh: function(cmp){
        $A.get('e.force:refreshView').fire();
    }
})