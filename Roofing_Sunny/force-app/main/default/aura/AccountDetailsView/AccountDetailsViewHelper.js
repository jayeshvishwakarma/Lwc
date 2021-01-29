({
	getCaseDetails : function(component, event) {
		var caseId = component.get("v.caseId");
        var soldToAccount = component.get("v.soldToAccount");
        var partnerInd = component.get("v.partnerInd");
        var action = component.get("c.getCaseDetails");                
        action.setParams({caseId : caseId});
        action.setCallback(this, function(response){            
            var request = response.getReturnValue();            
            var state = response.getState();
            if (state === "SUCCESS") {               
                component.set("v.request",request);              
                 component.set("v.accountId", component.get("v.request.AccountId")); 
                if(partnerInd){                    
                    soldToAccount = {"Id" : component.get("v.request.PartnerTo_UnPartner_from_Sold_To_Account__c"), "Name" : component.get("v.request.PartnerTo_UnPartner_from_Sold_To_Account__r.Name"), "ShippingCity" : component.get("v.request.PartnerTo_UnPartner_from_Sold_To_Account__r.ShippingCity"), "BPCS_Account_ID__c" : component.get("v.request.PartnerTo_UnPartner_from_Sold_To_Account__r.BPCS_Account_ID__c")};
                    component.set("v.soldToAccount", soldToAccount);   
                    component.set("v.partnerInd1",partnerInd);                   
                }else{
                    component.set("v.reason", component.get("v.request.Reason"));
                	component.set("v.reasonText", component.get("v.request.Comments__c")); 
                }
                                               
            }
      	});
        $A.enqueueAction(action);	
	}
})