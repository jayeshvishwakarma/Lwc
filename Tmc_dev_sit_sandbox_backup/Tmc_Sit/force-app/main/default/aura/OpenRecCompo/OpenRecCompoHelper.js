({
    loadCustomerData : function(cmp, recId) {
        
        var action = cmp.get("c.getCutomerDetail");
        action.setParams({ recId : recId });
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.isSpinner", false);
                cmp.set("v.showForm", true);
                
                let result = response.getReturnValue();
                let accRec = {'First_Name__c': result.FirstName,'Last_Name__c': result.LastName, 
                              'Email__c': result.PersonEmail, 'Mobile__c': result.PersonMobilePhone, 
                              'Birthday__c': result.PersonBirthdate, 
                              'Last_Call_Center_For_Code__c': '',
                             'Parent_CC_Outlet__c': '',
                              'Enquiry_Type__c': ''
                                      };;
                
              //   'Last_Call_Center_For_Code__c': result.Last_Call_Center_For_Code__c,
              //               'Last_Call_Center_Dealership__c': result.Last_Call_Center_Dealership__c,
                             
                
                console.log('== Customer Data ', result);
                if(result){
                    cmp.set("v.acc", accRec);
                    cmp.set("v.Type", result.Enquiry_Type__c);
                  /*  cmp.set("v.forCodeId", result.Last_Call_Center_For_Code__r.Id);
                    cmp.set("v.forCodeName", result.Last_Call_Center_For_Code__r.Name);
                    cmp.set("v.accountId", result.Last_Call_Center_Dealership__r.Id);
                    cmp.set("v.accountName", result.Last_Call_Center_Dealership__r.Name);
                    */
                    console.log('== forCodeName Aura ', cmp.get("v.forCodeName"));
                    
                }
                
            }else if (state === "ERROR") {
                cmp.set("v.isSpinner", false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
        
    },
    
    setDefaultValue : function(cmp){
        let tempAcc =  cmp.get("v.acc");
        tempAcc.Last_Call_Center_Dealership__c = '';
        tempAcc.Last_Call_Center_For_Code__c = '';
        cmp.set("v.acc", tempAcc);
        
        cmp.find("dealershipSelect").defaultvalue();
    }
})