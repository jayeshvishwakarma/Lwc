({
    doInit : function(component, event, helper) {        
        
        component.set("v.showResults",true);
        //component.set("v.currentStepName","Search Account Informtion"); 
       helper.getUserDetails(component, event);       
        helper.initRec(component);    
        helper.accountRequestshelper(component,'Active'); 
    },
    searchAccounts : function(component, event, helper) {
        var currentProspect=component.get("v.accRec");       
        var zipCode=component.get("v.accRec.ShippingPostalCode"); 
        var actNo=component.get("v.accRec.BPCS_Account_ID__c"); 			          
        component.set("v.Spinner",true);
        component.set("v.isMyrequests", false);
        component.set("v.pageTitle", 'Account Search Results');   
        helper.searchAccountshelper(component,currentProspect);  
    },
    accountRequests : function(component, event, helper) { 
        var actions = helper.getRowActions.bind(this, component);       
       component.set('v.actColumns', [
            {label: '', type: 'action', typeAttributes: { rowActions: actions, menuAlignment: 'auto'}},
           //Commented below line for --CMAO-137
           // {label: 'Request No', fieldName: 'ReportedPersonPhNo__c', type: 'url', typeAttributes: { label: { fieldName: 'CaseNumber' }, target: '_blank'}},             
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
       		component.set("v.Spinner",true);
        	component.set("v.isMyrequests", true);
        	component.set("v.pageTitle", 'My Customer Requests');
            helper.accountRequestshelper(component,'Active');                            
    },
    inquiryRequest : function(component, event, helper){
        component.set("v.currentStepName","Account Creation/Change Request");
        component.set("v.showAccSearch",false);      
        component.set("v.showResults",false);
        component.set("v.showInquiry",true); 
        component.set("v.pageTitle", 'Inquiry Request');
    },
    backToSearch : function(component, event, helper) {
        helper.initRec(component);            
        component.set("v.showAccSearch",true);
        component.set("v.showResults",false);  
        component.set("v.isMyrequests",false); 
         component.set("v.showInquiry",false); 
        //component.set("v.showerror",false);        
        component.set("v.currentStepName","Search Account Informtion");
		component.set("v.pageTitle", 'Account Search');        
    },     
    newAccount : function(component, event, helper) {
        //component.set("v.showerror",false);        
        component.set("v.currentStepName","Account Creation/Change Request");
        component.set("v.pageTitle", 'New Ship-To Account Request'); 
        component.set("v.showResults",false);
        component.set("v.actId",null);   
         component.set("v.caseId",null);   
        component.set("v.createNewAccount",true);    
       // component.set("v.isMyrequests",false); 
    },
    backToSearchResults : function(component, event, helper) {
     //   var newAccount = component.find('newAccount'); 
      //  if((!$A.util.isEmpty(newAccount) && newAccount !=undefined))
     //   		newAccount.set("v.newActRec", null);
      	var  isMyrequests = component.get("v.isMyrequests"); 
        if(isMyrequests){
            component.set("v.pageTitle", 'My Customer Requests');  
        }else{            
            component.set("v.pageTitle", 'Account Search Results');  
        }
        component.set("v.createNewAccount",false);
        component.set("v.showChangeShipToInfo",false);
        component.set("v.showPartnerExistingShipTo",false);
        component.set("v.showUnPartnerFromExistingSoldTo",false);                
        component.set("v.showResults",true);                
        component.set("v.showInquiry",false); 
        component.set("v.showRequestCreated",false);          
        component.set("v.showActivateShipTo",false);          
        component.set("v.currentStepName","Account Results");                
    },
    rowAction : function(component, event, helper){
        helper.handleRowAction(component, event, helper);
    },     
  	saveAccount : function(component, event, helper){     
        var newAccount = component.find('newAccount');		
        newAccount.saveAccount();     
        var requiredErr = newAccount.get('v.requiredErr');
        component.set("v.disableSubmit",true);        
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.disableSubmit",false)
            }), 4000
        );
        /*Commented below if block, to stay on the same page when user clicks on Save Request button
      	if(requiredErr != true){
            component.set("v.currentStepName","Request Created");
            //component.set("v.showRequestCreated",true);                 
            component.set("v.createNewAccount",false);
            component.set("v.showResults",true);   
             component.set("v.accRec",null);   
             helper.accountRequestshelper(component,'Active'); 
            component.set("v.pageTitle", 'My Customer Requests');
            component.set("v.isMyrequests",true);
        }*/
    },
    submitAccount : function(component, event, helper){     
        var newAccount = component.find('newAccount');       
        newAccount.submitAccount();        
        var requiredErr = newAccount.get('v.requiredErr');
        if(requiredErr != true){            
            component.set("v.currentStepName","Request Created");
           // component.set("v.showRequestCreated",true);                 
            component.set("v.createNewAccount",false);
            component.set("v.showResults",true);    
            helper.accountRequestshelper(component,'Active'); 
            component.set("v.pageTitle", 'My Customer Requests');
            component.set("v.isMyrequests",true);
        }        
    },
   saveActivateorDeactivate : function(component, event, helper){     
       helper.saveorsubmitActivateorDeactivate(component, event,false);       
    },
   submitActivateorDeactivate : function(component, event, helper){     
       helper.saveorsubmitActivateorDeactivate(component, event,true);
    },
    savePartnerShiptoRequest : function(component, event, helper){             
       helper.saveorsubmitPartnerShiptoRequest(component, event,false);       
    },
   	submitPartnerShiptoRequest : function(component, event, helper){     
       helper.saveorsubmitPartnerShiptoRequest(component, event,true);
    },
    saveUnPartnerfromSoldToToRequest : function(component, event, helper){     
       helper.saveorsubmitUnPartnerfromSoldToRequest(component, event,false);       
    },
   	submitUnPartnerfromSoldToToRequest : function(component, event, helper){     
       helper.saveorsubmitUnPartnerfromSoldToRequest(component, event,true);
    },
    saveChangeShipToInfoRequest : function(component, event, helper){
        helper.saveorsubmitChangeShipToInfoRequest(component, event,false);
    }, 
    submitChangeShipToInfoRequest : function(component, event, helper){
        helper.saveorsubmitChangeShipToInfoRequest(component, event,true);
    }, 
    submitInquiryRequest : function(component, event, helper){         
        helper.submitInquiryRequesthelper(component, event);
    }, 
    next: function (component, event, helper) {
        helper.next(component, event);
    },
    previous: function (component, event, helper) {
        helper.previous(component, event);
    },
    changePageSize: function (component, event, helper){
        helper.changePageSize(component, event);
    },
	clearSerach: function (component, event, helper){
        helper.initRec(component);
    }    
})