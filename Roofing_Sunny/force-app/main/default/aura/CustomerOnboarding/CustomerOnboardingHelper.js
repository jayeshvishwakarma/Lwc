({
    initRec : function(cmp){
        var action = cmp.get("c.getAccount");
        action.setCallback(this, function(response){
            var currentRec = response.getReturnValue();          
            cmp.set("v.accRec", currentRec);
        });        
        $A.enqueueAction(action);       
    },  
    getUserDetails : function(component, event){
        var action = component.get("c.getLoggedinUserDetails");                            
            action.setCallback(this, function(response){            
                var currentMatch = response.getReturnValue();            
                var state = response.getState();
                if (state === "SUCCESS") {
                      component.set("v.loggedinUser",currentMatch);                     
                }            
          });
        $A.enqueueAction(action);
    },
    getRowActions: function(component, row, cb) {
        var actions;
        var userProfile = component.get("v.loggedinUser.Profile.Name"); 
        /*= [
            { label: 'Change Ship-To Information', name: 'chgshipto' },
            { label: 'Partner existing Ship-To', name: 'peshipto' },
            { label: 'Un-Partner from an existing Sold-To', name: 'unpsoldto' },
            { label: 'Deactivate Ship-To', name: 'deactivate', disabled: row.Status_Code_BPCS__c ='Inactive'},
            { label: 'Activate Ship-To', name: 'activate', disabled: row.Status_Code_BPCS__c ='Active'}
        ];*/
        if(row.Status_Code_BPCS__c === 'Active' && row.RecordType.Name != 'Customer Master Request'){
            if(userProfile == 'Customer Service' || userProfile == 'Customer Service - Manager' || userProfile =='System Adminstrator'){
                actions = [{ label: 'Change the Ship-to account information', name: 'chgshipto' },
                       { label: 'Partner existing Ship-to to a Sold-to', name: 'peshipto' },
                       { label: 'Un-Partner from an existing Sold-to', name: 'unpsoldto' },
                       { label: 'Deactivate Ship-to', name: 'deactivate'}];
            }
            else{
                 actions = [{ label: 'Change the Ship-to account information', name: 'chgshipto' } ];
            }
            
            cb(actions);
        }
        else if(row.RecordType.Name === 'Customer Master Request'&& row.Status ==='New'){
            actions = [{ label: 'Change/Update', name: 'change'}];
            cb(actions);
        }
        /*else if(row.RecordType.Name === 'Customer Master Request'&& row.Status ==='Closed'){            
            actions = [{ label: 'Reopen', name: 'reopen'}];
            cb(actions);
        }*/
        else if(row.RecordType.Name != 'Customer Master Request'){
            if(userProfile == 'Customer Service' || userProfile == 'Customer Service - Manager' || userProfile =='System Adminstrator'){
                actions = [
                    { label: 'Reactivate', name: 'reactivate'}];
                cb(actions);
            }
        }
       else{
            actions = [
                { label: 'View Request', name: 'viewrequest'}];
            cb(actions);
        }
        
    },
    searchAccountshelper : function(cmp, currentProspect) {
        var actions = this.getRowActions.bind(this, cmp);
        cmp.set('v.actColumns', [
            {label: '', type: 'action', typeAttributes: { rowActions: actions, menuAlignment: 'auto'}},
            {label: 'Account #', fieldName: 'Site', type: 'url', typeAttributes: { label: { fieldName: 'BPCS_Account_ID__c' }, target: '_blank'}},
            {label: 'Sales Org', fieldName: 'Sales_Org__c', type: 'text'},    
            {label: 'Account Name', fieldName: 'Site', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank'}},
            {label: 'Street', fieldName: 'ShippingStreet', type: 'text'},
            {label: 'City', fieldName: 'ShippingCity', type: 'text'},
            {label: 'State / Province', fieldName: 'ShippingState', type: 'text'},
            {label: 'Postal Code', fieldName: 'ShippingPostalCode', type: 'text'},
            {label: 'Status', fieldName: 'Status_Code_BPCS__c', type: 'text'}
        ]);
            
        var formattedData=JSON.stringify(currentProspect);
        var action = cmp.get("c.searchAccountsData");                
        action.setParams({prospectData : formattedData})
        action.setCallback(this, function(response){            
            var currentMatch = response.getReturnValue();            
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.Spinner",false);
                var pageSize = cmp.get("v.pageSize");                
                if(currentMatch === undefined || currentMatch == '' || currentMatch == null){                    
                    cmp.set("v.noRecs",true);
                    cmp.set("v.accsearchRec", currentMatch);
                    cmp.set('v.PaginationList', currentMatch);
                }else{
                    cmp.set("v.accsearchRec",currentMatch);
                    // get size of all the records and then hold into an attribute "totalRecords"
                    var totalRecords = cmp.get("v.accsearchRec").length;
                    cmp.set("v.totalRecords", totalRecords);
                    //Set the current Page as 0
                    cmp.set("v.currentPage",0);
                    // set start as 0
                    cmp.set("v.startPage",0);
                    cmp.set("v.endPage",pageSize-1);
                    cmp.set("v.totalPages", Math.ceil(totalRecords/pageSize));
                    var PaginationList = [];
                    for(var i=0; i< pageSize; i++){
                        if(cmp.get("v.accsearchRec").length> i){
                            PaginationList.push(response.getReturnValue()[i]);
                        }
                    }
                    cmp.set('v.PaginationList', PaginationList);
                    cmp.set("v.noRecs",false);
                }
                cmp.set("v.showAccSearch",false);
                cmp.set("v.showResults",true); 
                cmp.set("v.currentStepName","Account Results");
            }
        });
        $A.enqueueAction(action); 	
    }, 
    accountRequestshelper : function(cmp, status) {         
         var actions = this.getRowActions.bind(this, cmp);      
        cmp.set('v.actColumns', [
            {label: '', type: 'action', typeAttributes: { rowActions: actions, menuAlignment: 'auto'}},   
            //Commented below line for --CMAO-137
            //{label: 'Request No', fieldName: 'ReportedPersonPhNo__c', type: 'url', typeAttributes: { label: { fieldName: 'CaseNumber' }, target: '_blank'}}, 
            {label: 'Request No', fieldName: 'CaseNumber', type: 'text'},
            {label: 'Sales Org', fieldName: 'Sales_Org__c', type: 'text'},
            {label: 'Type of Request', fieldName: 'Type', type: 'text'},            
            {label: 'Account Name', fieldName: 'AccountSite', type: 'url', typeAttributes: { label: { fieldName: 'AccountName' }, target: '_blank'}},            
            {label: 'Street', fieldName: 'ShippingStreet', type: 'text'},
            {label: 'City', fieldName: 'ShippingCity', type: 'text'},
            {label: 'State / Province', fieldName: 'ShippingState', type: 'text'},
            {label: 'Postal Code', fieldName: 'ShippingPostalCode', type: 'text'},     
            {label: 'Status', fieldName: 'Status', type: 'text'}
        ]);
        // var action = cmp.get("c.searchAccountsRequests");                
        var action = cmp.get("c.searchCustomerRequests");                
        //  action.setParams({status : status})
        action.setCallback(this, function(response){            
            var currentMatch = response.getReturnValue();            
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.Spinner",false);
                var pageSize = cmp.get("v.pageSize");                
                if(currentMatch === undefined || currentMatch == '' || currentMatch == null){                    
                    cmp.set("v.noRecs",true);
                    cmp.set("v.accsearchRec", currentMatch);
                    cmp.set('v.PaginationList', currentMatch);
                }else{
                    for (var i = 0; i < currentMatch.length; i++) {
                        var row = currentMatch[i];
                        if (row.Account){
                            row.AccountName = row.Account.Name;
                            row.AccountSite = row.Account.Site;
                            row.ShippingStreet = row.Account.ShippingStreet;
                            row.ShippingCity = row.Account.ShippingCity;
                            row.ShippingState = row.Account.ShippingState;
                            row.ShippingPostalCode = row.Account.ShippingPostalCode;
                            row.Sales_Org__c = row.Account.Sales_Org__c;                             
                        }
                        
                    }
                    cmp.set("v.accsearchRec",currentMatch);
                    // get size of all the records and then hold into an attribute "totalRecords"
                    var totalRecords = cmp.get("v.accsearchRec").length;
                    cmp.set("v.totalRecords", totalRecords);
                    //Set the current Page as 0
                    cmp.set("v.currentPage",0);
                    // set start as 0
                    cmp.set("v.startPage",0);
                    cmp.set("v.endPage",pageSize-1);
                    cmp.set("v.totalPages", Math.ceil(totalRecords/pageSize));
                    var PaginationList = [];
                    for(var i=0; i< pageSize; i++){
                        if(cmp.get("v.accsearchRec").length> i){
                            PaginationList.push(response.getReturnValue()[i]);
                        }
                    }
                    cmp.set('v.PaginationList', PaginationList);
                    cmp.set("v.noRecs",false);
                }
                cmp.set("v.showAccSearch",false);
                cmp.set("v.showResults",true); 
                cmp.set("v.currentStepName","Account Results");
            }
        });
        $A.enqueueAction(action); 	
    }, 
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        var rows = cmp.get('v.accsearchRec');
        var rowIndex = rows.indexOf(row);       
        var selectedActId = rows[rowIndex].Id;        
        switch (action.name) {
            case 'chgshipto':                
                cmp.set("v.currentStepName","Account Creation/Change Request");                
                cmp.set("v.showResults" , false);        
                 cmp.set("v.isMyrequests",false); 
                 cmp.set("v.caseId", null);
                cmp.set("v.actId", selectedActId);
                 cmp.set("v.pageTitle", 'Change Ship-To Account Request');
                 cmp.set("v.showChangeShipToInfo" , true);               
                break;
            case 'peshipto':               
                cmp.set("v.currentStepName","Account Creation/Change Request");
                cmp.set("v.showPartnerExistingShipTo" , true);
                cmp.set("v.showResults" , false);
                cmp.set("v.caseId", null);
                cmp.set("v.isMyrequests",false); 
                 cmp.set("v.pageTitle", 'Partner Ship-To Account Request');  
                cmp.find('peshipto').set('v.accountId', selectedActId);
                break;
            case 'unpsoldto':               
                cmp.set("v.currentStepName","Account Creation/Change Request");
                cmp.set("v.showUnPartnerFromExistingSoldTo" , true);
                cmp.set("v.showResults" , false);
                cmp.set("v.isMyrequests",false); 
                cmp.set("v.caseId", null);
                cmp.set("v.pageTitle", 'Un-Partner Ship-To Account Request');  
                cmp.find('unpfromsoldto').set('v.accountId', selectedActId);
                break;
            case 'deactivate':                                                          
                /* var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been de-activated successfully."
                });
                toastEvent.fire(); */                           
                cmp.set("v.currentStepName","Account Creation/Change Request");
                cmp.set("v.activateInd", false);
                cmp.set("v.showActivateShipTo" , true);
                cmp.set("v.showResults" , false); 
                cmp.set("v.isMyrequests",false); 
                cmp.set("v.caseId", null);
                cmp.set("v.pageTitle", 'Deactivate a Ship-To Account Request');  
                cmp.find('activate_deactivate').set('v.accountId', selectedActId);
                //cmp.find('activate_deactivate').set('v.activateInd', false);                
                break;
            case 'reactivate':                                                         
                cmp.set("v.currentStepName","Account Creation/Change Request");
                cmp.set("v.activateInd", true);
                cmp.set("v.showActivateShipTo", true);
                cmp.set("v.showResults" , false);  
                cmp.set("v.isMyrequests",false); 
                cmp.set("v.caseId", null);
                cmp.set("v.pageTitle", 'Activate a Ship-To Account Request');  
                cmp.find('activate_deactivate').set('v.accountId', selectedActId);
                //cmp.find('activate_deactivate').set('v.activateInd', true);                
                break;
            case 'reopen':
                var csId = rows[rowIndex].Id;
                var action = cmp.get("c.reopenCase");                
                action.setParams({caseId : csId});
                action.setCallback(this, function(response){                                                   
                    var state = response.getState();
                    if (state === "SUCCESS") {       
                        this.accountRequestshelper(cmp, 'Active');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "The request has been re-opened successfully."
                        });
                        toastEvent.fire();
                    }
                });
                $A.enqueueAction(action);	
               
                break;  
            case 'viewrequest':
                var csId = rows[rowIndex].Id;
                var url = location.href;  // entire url including querystring - also: window.location.href;
                var baseURL = url.substring(0, url.indexOf('/', 14));				
                window.open(baseURL + "/" + csId, "_blank");
                break;
            case 'change':
                var actId = rows[rowIndex].AccountId;
                var csId = rows[rowIndex].Id;
                var chgActId = rows[rowIndex].Change_Info_Account__c;               
                if(rows[rowIndex].Type==="Deactivate a Ship-To Account Request"){
                    cmp.set("v.currentStepName","Account Creation/Change Request");
                    cmp.set("v.activateInd", false);
                    cmp.set("v.caseId", csId);
                    cmp.set("v.showActivateShipTo" , true);
                    cmp.set("v.showResults" , false);
                    //cmp.set("v.isMyrequests",false); 
                    cmp.set("v.pageTitle", 'Deactivate a Ship-To Account Request');  
                    cmp.find('activate_deactivate').set('v.accountId', actId);                
                }
                else if(rows[rowIndex].Type==="Activate a Ship-To Account Request"){
                    cmp.set("v.currentStepName","Account Creation/Change Request");
                    cmp.set("v.activateInd", true);
                    cmp.set("v.caseId", csId);
                    cmp.set("v.showActivateShipTo" , true);
                    cmp.set("v.showResults" , false);  
                   // cmp.set("v.isMyrequests",false); 
                    cmp.set("v.pageTitle", 'Activate a Ship-To Account Request');  
                    cmp.find('activate_deactivate').set('v.accountId', actId);                    
                }
                    else if(rows[rowIndex].Type==="Partner Ship-To Account Request"){                                      
                        cmp.set("v.currentStepName","Account Creation/Change Request");                       
                        cmp.set("v.caseId", csId);                         
                       	cmp.set("v.showPartnerExistingShipTo" , true);
                        cmp.set("v.showResults" , false);   
                       // cmp.set("v.isMyrequests",false); 
                        cmp.set("v.pageTitle", 'Partner Ship-To Account Request');  
                        cmp.find('peshipto').set('v.accountId', actId);
                    }
                        else if(rows[rowIndex].Type==="Un-Partner Ship-To Account Request"){
                            cmp.set("v.currentStepName","Account Creation/Change Request");                              
                            cmp.set("v.caseId", csId);                             
                            cmp.set("v.showUnPartnerFromExistingSoldTo" , true);
                            cmp.set("v.showResults" , false);   
                           // cmp.set("v.isMyrequests",false); 
                            cmp.set("v.pageTitle", 'Un-Partner Ship-To Account Request');  
                            cmp.find('unpfromsoldto').set('v.accountId', actId);                    
                        }
                            else if(rows[rowIndex].Type==="New Ship-To Account Request"){                    
                                cmp.set("v.actId", actId);
                                cmp.set("v.caseId", csId);                             
                                cmp.set("v.currentStepName","Account Creation/Change Request");                
                                cmp.set("v.showResults" , false);
                               // cmp.set("v.isMyrequests",false); 
                                cmp.set("v.createNewAccount",true);   
                                cmp.set("v.pageTitle", 'New Ship-To Account Request');
                                break;
                            }
                			else if(rows[rowIndex].Type==="Change Ship-To Account Information Request"){                    
                                cmp.set("v.actId", actId);
                                cmp.set("v.changeaccountId", chgActId); 
                                cmp.set("v.caseId", csId); 
                                cmp.set("v.currentStepName","Account Creation/Change Request");                
                                cmp.set("v.showResults" , false);
                               // cmp.set("v.isMyrequests",false); 
                                cmp.set("v.showChangeShipToInfo",true); 
                                cmp.set("v.pageTitle", 'Change Ship-To Account Request');
                                break;
                            }
                
        }
    },
    saveorsubmitActivateorDeactivate : function(component, event, isSubmitted){       
        var activateordeactivateAccount = component.find('activate_deactivate');		
        activateordeactivateAccount.savesubmitActivateorDeactivate(isSubmitted); 
        var requiedeErr = activateordeactivateAccount.get('v.requiredError');
       /* Added addtional condition && isSubmitted to stay on the same page when user clicks on Save Request button*/
        if(requiedeErr != true && isSubmitted){ 
            component.set("v.currentStepName","Request Created");
            //component.set("v.showRequestCreated",true);    
            this.accountRequestshelper(component,'Active');  
            component.set("v.pageTitle", 'My Customer Requests'); 
			component.set("v.showResults",true);    
            component.set("v.isMyrequests",true);
            component.set("v.createNewAccount",false);
            component.set("v.showActivateShipTo",false);
        }
    },
    saveorsubmitPartnerShiptoRequest : function(component, event, isSubmitted){
        var partnerShipto = component.find('peshipto');		
        partnerShipto.saveorsubmitPartnerShiptoRequest(isSubmitted);
        var requiedeErr = partnerShipto.get('v.requiredError');
          /* Added addtional condition && isSubmitted to stay on the same page when user clicks on Save Request button*/
        if(requiedeErr != true && isSubmitted){          
            component.set("v.currentStepName","Request Created");
            //component.set("v.showRequestCreated",true);  
            this.accountRequestshelper(component,'Active');  
            component.set("v.pageTitle", 'My Customer Requests');
            component.set("v.showResults",true);    
            component.set("v.isMyrequests",true); 
            component.set("v.createNewAccount",false);
            component.set("v.showPartnerExistingShipTo",false);
        }
    },
    saveorsubmitUnPartnerfromSoldToRequest : function(component, event, isSubmitted){
        
        var unPartnerfromSoldTo = component.find('unpfromsoldto');		
        unPartnerfromSoldTo.saveorsubmitUnPartnerfromSoldToRequest(isSubmitted);   
        var requiedeErr = unPartnerfromSoldTo.get('v.requiredError');
         /* Added addtional condition && isSubmitted to stay on the same page when user clicks on Save Request button*/
        if(requiedeErr != true && isSubmitted){ 
            component.set("v.currentStepName","Request Created");
            //component.set("v.showRequestCreated",true);       
            this.accountRequestshelper(component,'Active');            
            component.set("v.pageTitle", 'My Customer Requests');
            component.set("v.showResults",true);     
            component.set("v.isMyrequests",true);
            component.set("v.createNewAccount",false);
            component.set("v.showUnPartnerFromExistingSoldTo",false);
        }
    },
    saveorsubmitChangeShipToInfoRequest : function(component, event, isSubmitted){
        var chgShipTo = component.find('chgShipTo');
        chgShipTo.changeShipToInfoRequest(isSubmitted);   
         var requiedeErr = chgShipTo.get('v.requiredErr');
         /* Added addtional condition && isSubmitted to stay on the same page when user clicks on Save Request button*/
        if(requiedeErr != true && isSubmitted){ 
            component.set("v.currentStepName","Request Created");
            //component.set("v.showRequestCreated",true);     
           this.accountRequestshelper(component,'Active');                         
           component.set("v.pageTitle", 'My Customer Requests');
           component.set("v.showResults",true);     
           component.set("v.isMyrequests",true);
            component.set("v.createNewAccount",false);
            component.set("v.showChangeShipToInfo",false);
       }        
    },
    submitInquiryRequesthelper: function(component, event){
        var inquiryRequest = component.find('inquiryrequest');		
        inquiryRequest.submitInquiryRequest();   
        var requiedeErr = inquiryRequest.get('v.requiredError');
        if(requiedeErr != true){ 
            component.set("v.currentStepName","Request Created");
            //component.set("v.showRequestCreated",true);     
            this.accountRequestshelper(component,'Active');             
            component.set("v.pageTitle", 'My Customer Requests');
            component.set("v.showResults",true);
            component.set("v.isMyrequests",true);
            component.set("v.showInquiry",false);            
        }
    },
    
    next : function(component, event){
        var current = component.get("v.currentPage");           
        current = current +1;
        var pgName = "page" + current;       
        component.set("v.currentPage",current);        
        var sObjectList = component.get("v.accsearchRec");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;        
        for(var i=end+1; i<end+pageSize+1; i++){
            if(sObjectList.length > i){
                Paginationlist.push(sObjectList[i]);
            }
            counter ++ ;            
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);       
    },
    previous : function(component, event){   
        var current = component.get("v.currentPage");        
        current = current - 1; 
        var pgName = "page" + current;
        component.set("v.currentPage",current);       
        var sObjectList = component.get("v.accsearchRec");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                Paginationlist.push(sObjectList[i]);
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);        
    },
    changePageSize : function(component, event){     
        var cmppageSize = component.find("cmppageSize");
        component.set("v.pageSize", cmppageSize.get("v.value"));       
        var pageSize = component.get("v.pageSize");        
        var sObjectList = component.get("v.accsearchRec");
        var totalRecords = sObjectList.length;        
        component.set("v.totalRecords", totalRecords);
        //Set the current Page as 0
        component.set("v.currentPage",0);
        // set start as 0
        component.set("v.startPage",0);        
        var counter = 0;
        if(totalRecords >= pageSize){
            component.set("v.totalPages", Math.ceil(totalRecords/pageSize));
            counter = pageSize;
            component.set("v.endPage",pageSize-1);
        }
        else{
            component.set("v.totalPages", 1);
            counter = totalRecords;
            component.set("v.endPage",pageSize-1);
        }                
        var PaginationList = [];
        for(var i=0; i< counter; i++){
            if(sObjectList.length> i){
                PaginationList.push(sObjectList[i]);
            }
        }
        component.set("v.pageSize", parseInt(pageSize));
        component.set('v.PaginationList', PaginationList);
    }
})