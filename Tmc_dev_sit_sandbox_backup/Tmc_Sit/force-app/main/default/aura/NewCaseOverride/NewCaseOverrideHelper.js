({
	openRelatedComplaintPage : function(component) {
		try {
            let currentUserProfileName = component.get('v.currentUserProfileName');
			let MOS_Complaint_Profiles = $A.get("$Label.c.MOS_Complaint_Profiles");
			let ATM_Complaint_Profiles = $A.get("$Label.c.ATM_Complaint_Profiles");
			let Dealer_Inbound_Complaint_Profiles = $A.get("$Label.c.Dealer_Inbound_Complaint_Profiles");
			MOS_Complaint_Profiles = MOS_Complaint_Profiles.split(',');
			ATM_Complaint_Profiles = ATM_Complaint_Profiles.split(',');
			Dealer_Inbound_Complaint_Profiles = Dealer_Inbound_Complaint_Profiles.split(',');
			
            if(ATM_Complaint_Profiles.includes(currentUserProfileName)){
                var recordTypeId = component.get("v.pageReference").state.recordTypeId;
                if(recordTypeId == component.get("v.mosRecordTypeId")) {
                    let newCaseEvt = $A.get("e.force:createRecord");
                    newCaseEvt.setParams({
                        "entityApiName": "Case",
                        "recordTypeId" : component.get("v.mosRecordTypeId"),
                        "defaultFieldValues": {
                            'Source' : 'Salesforce'
                        }
                    });
                    newCaseEvt.fire();    
                }
                else {
                	component.set("v.isATMCaseComponentShow",true);    
                }
				
			}else if(Dealer_Inbound_Complaint_Profiles.includes(currentUserProfileName)){
				console.log('Dealer Inbound Process Initiated');
				component.set("v.isDealerInboundCaseComponentShow",true);
			}else{
				/** WHEN PROFILE IS NOT DEFINED ON THE LABEL OR SYSTEM ADMIN */
				let newCaseEvt = $A.get("e.force:createRecord");
				newCaseEvt.setParams({
					"entityApiName": "Case",
					"defaultFieldValues": {
						'Source' : 'Salesforce'
					}
				});
				newCaseEvt.fire();
			}
		} catch (e) {
			console.log('Exception In doInit JS openRelatedComplaintPage');
			console.log(e.message);
		}
	}
});