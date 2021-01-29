public class CustomerOnboardingController {
    /*This method is to get a new instance of account object*/
    @AuraEnabled    
    public static Account getAccount(){ 
        Account newRec= new Account();
        return newRec;
    }
    /*This method is to search for the accounts for the given criteria on the search form*/
    @AuraEnabled    
    public static List<Account> searchAccountsData(String prospectData){ 
        List<Account> searchResults= new List<Account>();                
        String accountNo;
        String businessname;
        String street;
        String city;
        String state;
        String zip;
        Account currentProspect= (Account) JSON.deserialize(prospectData, Account.class);
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Indirect Accounts').getRecordTypeId();
        Id recTypeIdShipTo = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Ship-To').getRecordTypeId();
        Id recTypeIdSoldTo = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sold-To').getRecordTypeId();
        Id recTypeIdPayer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payer').getRecordTypeId();
        
        if(currentProspect!=null){            
            accountNo = currentProspect.SAP_ACCOUNT__c;
            businessname=currentProspect.name;
            street=currentProspect.ShippingStreet;
            city=currentProspect.ShippingCity;
            state=currentProspect.ShippingState;
            zip=currentProspect.ShippingPostalCode;
            if(businessname != ''  && businessname != null)
                businessname = '\'%'+businessname+'%\'';
            string shipTo = '3-Ship To';
            //string query = 'Select Id,Name,SAP_ACCOUNT__c,RecordType.Name,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,Type,Site,Status_Code_BPCS__c,Sales_Org__c from Account WHERE RecordTypeId = \'' + string.valueOf(recordTypeId) + '\' AND  Hierarchy_Level_BPCS__c =\'' + shipTo + '\'';
            string query = 'Select Id,Name,SAP_ACCOUNT__c,RecordType.Name,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,Type,Site,Status__c,Sales_Org__c from Account WHERE (RecordTypeId = \'' + string.valueOf(recordTypeId) + '\' OR RecordTypeId = \'' + string.valueOf(recTypeIdShipTo) + '\' OR RecordTypeId = \'' + string.valueOf(recTypeIdSoldTo) + '\' OR RecordTypeId = \'' + string.valueOf(recTypeIdPayer) + '\') AND  Hierarchy_Level_BPCS__c =\'' + shipTo + '\'';
            string condition = '';
            string strb = '\'%b%\'';
            string stro = '\'%o%\'';
            string str = '\'%-%\'';
            query = query + ' AND (NOT SAP_ACCOUNT__c like ' + strb + ')';
              query = query + ' AND (NOT SAP_ACCOUNT__c like ' + stro+ ')';
              query = query + ' AND (NOT SAP_ACCOUNT__c like ' + str+ ')';
           
            if(accountNo != '' && accountNo != null){
                accountNo = accountNo.trim();
                accountNo = '\'%'+accountNo+'%\'';                  
                query = query + ' AND SAP_ACCOUNT__c like ' + accountNo;
            }
            else{               
                if(businessname != '' && businessname != null){
                    // condition = (condition == '' ? (condition + 'WHERE Name like ' + businessname) : (condition + ' AND Name like ' + businessname));
                    condition = condition + ' AND Name like ' + businessname;
                }
                if(street != '' && street != null){                                       
                    condition = condition + ' AND ShippingStreet like \'%' + street + '%\'';
                }
                if(city != '' && city != null){  
                    city = city.trim();
                    condition = condition + ' AND ShippingCity = \'' + city + '\'';
                }
                if(state != '' && state != null){                                        
                    condition = condition + ' AND ShippingState = \'' + state + '\'';
                }
                if(zip != '' && zip != null){                                        
                    condition = condition + ' AND ShippingPostalCode like \'' + zip + '%\'';
                }                
            }            
            query = query + condition;  
            system.debug('query==>' + query);
            searchResults = Database.query(query);
            for(Account act : searchResults){
                act.Site = URL.getSalesforceBaseUrl().toExternalForm() + '/' + act.id;                
            }          
        }
        return searchResults;        
    }  
    /*This method is to get the customer master requests of the logged in user*/
    @AuraEnabled    
    public static List<Account> searchAccountsRequests(){ 
        List<Account> searchResults= new List<Account>();                                           
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Master Request').getRecordTypeId();
        string query = 'Select Id,ReportedPersonPhNo__c,CaseNumber,Name,SAP_ACCOUNT__c,RecordType.Name,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,Phone,' + 
            'No_of_deliveries_Accepted_per_day__c,BrokerID__c,Logistic_and_Ship_to_Notes__c,Cont_setup_with_SAP_already_existing__c,' + 
            'Will_Customer_Use_EDI__c,Solar__c,Job_Site__c,Price_Sheet__c,Delete_all_notes__c,Type,Site,Status__c,' + 
            'Sales_Org__c,Freight_Type__c,Order_Type__c, Last_4_digits_could_not_be_found_on_USPS__c, Customer_Origin__c, Customer_Group__c, AEB_Check_Completed__c from Account WHERE  Hierarchy_Level_BPCS__c = \'3-Ship To\' AND RecordTypeId = \'' + string.valueOf(recordTypeId) + '\'';
        
        
        
        //   string condition = '';
        //   if(string.isNotBlank(status)){                
        //       condition = condition + ' AND Status_Code_BPCS__c = \'' + status + '\'';                
        //   }                
        // query = query + condition;           
        system.debug('Query==>' + query);
        searchResults = Database.query(query);
        for(Account act : searchResults){
            act.Site = URL.getSalesforceBaseUrl().toExternalForm() + '/' + act.id;                
        }                  
        system.debug('searchResults==>' + searchResults);
        return searchResults;        
    }
    /*This method is to get the customer master requests of the logged in user*/
    @AuraEnabled    
    public static List<Case> searchCustomerRequests(){ 
        List<Case> searchResults= new List<Case>();                                           
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Master Request').getRecordTypeId();
        
        /*
        string query = 'Select Id, ReportedPersonPhNo__c,CaseNumber,Type,Status, RecordType.Name,AccountId,Account.Name,Account.SAP_ACCOUNT__c,Account.RecordType.Name,Account.ShippingStreet,Change_Info_Account__c,' +
            'Account.ShippingCity,Account.ShippingState,Account.ShippingPostalCode,Account.ShippingCountry, Account.Site,Account.Type,Account.Status_Code_BPCS__c,Account.Sales_Org__c ' +
            ' from Case WHERE CreatedById = \'' + userInfo.getUserId() + '\' AND RecordTypeId = \'' + string.valueOf(recordTypeId) + '\' ORDER BY CreatedDate DESC';
        */
        
        string query = 'Select Id, ReportedPersonPhNo__c,CaseNumber,Type,Status, RecordType.Name,AccountId,Account.Name,Account.SAP_ACCOUNT__c,Account.RecordType.Name,Account.ShippingStreet,Change_Info_Account__c,' +
            'Account.ShippingCity,Account.ShippingState,Account.ShippingPostalCode,Account.ShippingCountry, Account.Site,Account.Type,Account.Status__c,Account.Sales_Org__c ' +
            ' from Case WHERE (CreatedById = \'' + userInfo.getUserId() + '\' OR OwnerId = \'' + userInfo.getUserId() + '\' OR CSR__c = \'' + userInfo.getUserId() + '\' OR Sales_Rep__c = \'' + userInfo.getUserId() + '\') AND RecordTypeId = \'' + string.valueOf(recordTypeId) + '\' ORDER BY CreatedDate DESC';        
                
        system.debug('Query==>' + query);
        searchResults = Database.query(query);
        for(Case objCs : searchResults){
            if(objCs.AccountId != null)
                objCs.Account.Site = URL.getSalesforceBaseUrl().toExternalForm() + '/' + objCs.Account.Id;   
             objCs.ReportedPersonPhNo__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + objCs.Id; 
        }                  
        system.debug('searchResults==>' + searchResults.size());
        return searchResults;        
    }
    /*This method is to get the Account details*/
    @AuraEnabled
    public static Account getAccountDetails(Id accountId){
        string query = 'Select Id,Name,SAP_ACCOUNT__c,RecordType.Name,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,Phone,' + 
            'No_of_deliveries_Accepted_per_day__c,BrokerID__c,Logistic_and_Ship_to_Notes__c,Cont_setup_with_SAP_already_existing__c,' + 
            'Will_Customer_Use_EDI__c,Solar__c,Job_Site__c,Price_Sheet__c,Delete_all_notes__c,Type,Site,Status__c,' + 
            'Order_For_Account__c, Order_For_Account__r.Name, Order_For_Account__r.ShippingCity, Order_For_Account__r.SAP_ACCOUNT__c,Order_For_Account__r.Res_TM__c,Order_For_Account__r.Res_TM__r.Email,' +
            'Default_Warehouse__c, Default_Warehouse__r.Name, Default_Warehouse__r.Warehouse_Description__c,' +
            'EDPAR__c, Delete_all_notes_and_add_notes__c, Keep_existing_notes_and_add_notes__c,Sales_Rep__c,Territory_Manager__r.Name,Territory_Manager__r.Role__c,Territory_Manager__r.Email,' +
            'Sales_Org__c,Freight_Type__c,Order_Type__c, Last_4_digits_could_not_be_found_on_USPS__c, Sales_office__c, Customer_Origin__c, Customer_Group__c, AEB_Check_Completed__c from Account WHERE Id = \'' + string.valueOf(accountId) + '\'';
        
        Account actDetails = Database.query(query);
        system.debug('actDetails==>'+ actDetails);
        uppercaseText(actDetails);
        return actDetails;
    }
    /*This method is to get the case/request details*/
    @AuraEnabled
    public static Case getCaseDetails(Id caseId){
        string query = 'Select Id,CaseNumber,Description,Origin,Sales_Rep__c, AccountId,Account.Name,Account.SAP_ACCOUNT__c,Account.Phone, Reason, Comments__c, Status,PartnerTo_UnPartner_from_Sold_To_Account__c,Change_Info_Account__c,PartnerTo_UnPartner_from_Sold_To_Account__r.Name,PartnerTo_UnPartner_from_Sold_To_Account__r.SAP_ACCOUNT__c,PartnerTo_UnPartner_from_Sold_To_Account__r.ShippingCity,Type, CreatedBy.Profile.Name,CreatedById,CreatedDate from Case WHERE Id = \'' + string.valueOf(caseId) + '\'';        
        Case  csDetails = Database.query(query);    
        system.debug('csDetails==>' + csDetails);
        return csDetails;
    }
    /*This method is to create the New Ship-To Account request/Change ship-To inofrmation*/
    @AuraEnabled
    public static string createAccount(String accountDetails,Id csId,Boolean isSubmitted, Id acctId, String region, boolean isActSave, boolean isCSRSubmitted){
        Account newAccount= (Account) JSON.deserialize(accountDetails, Account.class);
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Master Request').getRecordTypeId();
        string strCaseId;
        if(newAccount!=null){
            newAccount.RecordTypeId = recordTypeId;             
            newAccount.Hierarchy_Level_BPCS__c = '3-Ship To';
            if(isSubmitted){
                newAccount.Status__c = 'Submitted';    
            }
            else{
                newAccount.Status__c = 'Saved';
            }              
            uppercaseText(newAccount);
            upsert newAccount;            
            if(!isActSave){
                if(acctId == null){
                  strCaseId =  createCase(newAccount.Id, csId,isSubmitted,newAccount.Request_Type__c,null,null,null,null, region);
                }else{
                  strCaseId =  createCase(acctId, csId,isSubmitted,newAccount.Request_Type__c,null,null,null,newAccount.Id, region);                  
                }
            }    
            if(csId != null){
                strCaseId =csId;
            }
                
            if(isCSRSubmitted != null && isCSRSubmitted && csId != null){                   
                submitApprovalRequest(csId);
            }            
            
        }  
        return strCaseId;
    }
    /*This method is to Activate/De-Activate the accounts*/
    @AuraEnabled
    public static Id  createActivateorDeactivateAccountRequest(Id actId,Id csId, Boolean isSubmitted, string requestType, string reason, string reasonText){
        system.debug('csId==>' + csId);
       return createCase(actId, csId,isSubmitted, requestType,reason,reasonText,null,null, null);
    }
    /*This method is to partner shipto account with Sold to account*/
    @AuraEnabled
    public static Id createPartnerShipToRequest(Id actId,Id csId, Boolean isSubmitted, string requestType, Id partnerTo){
        return createCase(actId, csId,isSubmitted, requestType,null,null,partnerTo,null, null);
    }
    /*This method is to unpartner shipto account from Sold to account*/
    @AuraEnabled
    public static Id createUnPartnerfromSoldToRequest(Id actId, Id csId,Boolean isSubmitted, string requestType, Id unpartnerFrom){
        return createCase(actId, csId,isSubmitted, requestType,null,null,unpartnerFrom,null, null);
    }
    /*This method is to create a case for Inquiry requests*/
    @AuraEnabled
    public static void createInquiryRequest(string requestType, string inquiryText){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Master Request').getRecordTypeId();
        Case newCase = new Case();           
        newCase.RecordTypeId = recordTypeId;
        newCase.Status = 'New';                                
        newCase.Subject = 'REQUEST TYPE : ' + requestType.toUpperCase();
        newCase.Description = inquiryText;
        newCase.Origin = 'Customer Request';
        newCase.Type = requestType;
        newCase.isSubmitted__c = true;
        insert newCase;
    }
    /*This method is to create/update the case for all types of customer master requests*/
    private static Id createCase(Id actId,Id csId, Boolean isSubmitted, string requestType, string reason, string reasonText, Id partner_unpartnerAccount, Id changeAccountId, String region){        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Master Request').getRecordTypeId();
        User usr = [SELECT Id, Name, Profile.Name, Role__c FROM User Where Id =: userInfo.getUserId()];
        Account act;
        string requestTypeSubject;
        if(requestType == 'Change Ship-To Account Information Request'){
             act = [SELECT Id, name, Customer_Origin__c, Territory_Manager__c FROM Account Where Id =: changeAccountId];
        }else{
             act = [SELECT Id, name, Customer_Origin__c, Territory_Manager__c FROM Account Where Id =: actId];
        }
        if(String.isBlank(region)){
            region = 'Customer Request';
        }
       system.debug('region==>' + region);
        if(csId != null){
            List<Case> lst_Cases = [SELECT Id, AccountId, RecordTypeId, Status,Type FROM Case Where Id =: csId];   
             lst_Cases[0].isSubmitted__c = isSubmitted;
           
                lst_Cases[0].Origin = region; 
                lst_Cases[0].Reason = reason;
                lst_Cases[0].Comments__c = reasonText;
                lst_Cases[0].PartnerTo_UnPartner_from_Sold_To_Account__c= partner_unpartnerAccount;
                lst_Cases[0].Change_Info_Account__c =changeAccountId;
                lst_Cases[0].Sales_Rep__c = act.Territory_Manager__c;
                system.debug('lst_Cases==>' + lst_Cases);
                update lst_Cases[0];
          //  }            
        }else{
             if(requestType != 'New Ship-To Account Request'){
                 Account actToChnage = [SELECT Id, SAP_ACCOUNT__c FROM Account Where Id =: actId];
                  if(requestType == 'Change Ship-To Account Information Request'){
                      requestTypeSubject = 'CHANGE SHIP-TO (SAP Account # ' + actToChnage.SAP_ACCOUNT__c + ')';
                  }else{
                      requestTypeSubject = requestType + ' (SAP Account # ' + actToChnage.SAP_ACCOUNT__c + ')';     
                  }
                 
             }            
            else{
                 requestTypeSubject = 'NEW SHIP-TO (' + act.Name + ')';
             }                
            requestTypeSubject = requestTypeSubject.toUpperCase();
            Case newCase = new Case();
            newCase.AccountId = actId;
            newCase.RecordTypeId = recordTypeId;
            newCase.isSubmitted__c = isSubmitted;            
            newCase.Status = 'New';
            newCase.Origin = region;            
            newCase.Reason = reason;
            newCase.Comments__c = reasonText;
            newCase.PartnerTo_UnPartner_from_Sold_To_Account__c= partner_unpartnerAccount;
            newCase.Change_Info_Account__c =changeAccountId;
            newCase.Subject = 'REQUEST TYPE : ' + requestTypeSubject;
            newCase.Description = 'REQUEST TYPE : ' + requestTypeSubject;
            newCase.Type = requestType;
            newCase.Sales_Rep__c = act.Territory_Manager__c;
            system.debug('newCase==>' + newCase);
            insert newCase;   
            csId = newCase.Id;
        } 
        return csId;
    }
    /* This method is to re-open the closed Customer Master requests*/
    @AuraEnabled
    public static void reopenCase(Id caseId){
        Case reopenCase = [SELECT Id, Status FROM Case Where Id=:caseId];
        reopenCase.Status = 'Re-Opened';
        update reopenCase;
    }
    /* This method is to check, is there any other pending request is there on the same account*/
    @AuraEnabled
    public static List<case> checkforInprogressRequestsOnAccount(Id actId){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Master Request').getRecordTypeId();
        List<Case> lst_Cases = [SELECT ID FROM Case Where RecordTypeId =:recordTypeId AND AccountId =:actId AND Status != 'Closed'];     
        return lst_Cases;
    }
    /* This method is to get the logged in user profile name*/
    @AuraEnabled
    public static User getLoggedinUserDetails(){
        return [SELECT Id, Name, Profile.Name FROM User WHERE Id=:userInfo.getUserId()];
    }
    @AuraEnabled
    public static User getTMUserDetails(String email){
        try{
            return [SELECT Id, Name, Role__c FROM User WHERE email=:email AND isActive = true AND Role__c='TM'];    
        }
        catch(Exception ex){
            return null;
        }
        
    }
    /* This method is to change all the text/picklist field values to upper case*/
    private static sObject uppercaseText(Account sObj){            
        Schema.DescribeSObjectResult acctDesc= Account.sObjectType.getDescribe();        
        for(string apiName : acctDesc.fields.getMap().keySet()){               
            try{     
                Schema.DisplayType fielddataType = acctDesc.fields.getMap().get(apiName).getDescribe().getType();
                if(fielddataType == Schema.DisplayType.TextArea || fielddataType == Schema.DisplayType.String 
                   || fielddataType == Schema.DisplayType.PICKLIST) {                          
                       string val = (String)sObj.get(apiName);
                       sObj.put(apiName, val.toUpperCase()); 
                   }              
            }
            catch(Exception ex){
                 
            }                           
        }
        return sobj;
    }
      private static void submitApprovalRequest(Id caseId) {  
        User loggedInUser = getLoggedinUserDetails();
        System.Debug('The User:' + loggedInUser);
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
       // req1.setComments('Submitting request for approval.');
        req1.setObjectId(caseId);      
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(UserInfo.getUserId()); 
           
        req1.setSkipEntryCriteria(false);
        
        // Submit the approval request for the customer onboarding request
        Approval.ProcessResult result = Approval.process(req1);                
    }   
    
     @AuraEnabled
    public static String getUIThemeDescription() {
        String theme = UserInfo.getUiThemeDisplayed();
        return theme;
    }

}