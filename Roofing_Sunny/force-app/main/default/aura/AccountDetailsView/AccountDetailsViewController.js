({
	doInit : function(component, event, helper) {
        var activationInd = component.get("v.activationInd");
        var reasons = component.get("v.reasons");
        console.log('activationInd==>' + activationInd);
        reasons.push('');
        if(activationInd){
            reasons.push('UNBLOCK TO APPLY CREDIT');
            reasons.push('MARKED DNU IN ERROR');
            reasons.push('REOPENED LOCATION');            
        }
        else{
            reasons.push('BUSINESS ACQUIRED');
            reasons.push('DUPLICATE ACCT');
            reasons.push('LOCATION CLOSED');
            reasons.push('REBLOCK');            
        }
        component.set("v.reasons", reasons);
      
      var caseId = component.get("v.caseId");
         var params = event.getParam('arguments');
            if (params) {                
                if(caseId == null || caseId == undefined){
                    caseId = params.paramCaseId;
                }
            }
             
        if(!$A.util.isEmpty(caseId)){
        	helper.getCaseDetails(component, event);    
        }else{
             var partnerInd = component.get("v.partnerInd");
            if(partnerInd){
                 component.set("v.partnerInd1",partnerInd);                   
            }
        }
        
	}
})