/*------------------------------------------------------------------------------------
Author:        Sumit Gupta
Description:   Custom Account Search Controller

History
Date            Author             Comments
--------------------------------------------------------------------------------------
02-12-2019      Sumit Gupta        Initial Release
------------------------------------------------------------------------------------*/
public without sharing class CustomAccountSearchCtrl { 

    private static String ACCOUNT_BASE_QUERY = 'FIND {0} IN ALL FIELDS RETURNING Account(Id, Name, PersonMobilePhone, PersonEmail, PersonBirthdate, Customer_Mood__c, Service_Mobile__c, toLabel(Customer_Type__c) {1} LIMIT 200)';
    private static String ASSET_BASE_QUERY = 'FIND {0} IN ALL FIELDS RETURNING Asset(Account.Id, Account.Name, Account.PersonMobilePhone, Account.PersonEmail, Account.PersonBirthdate, Account.Customer_Mood__c, Account.Service_Mobile__c, toLabel(Account.Customer_Type__c)  {1} LIMIT 200)';
    
    @AuraEnabled(Cacheable=true)
    public static List<SearchResult> searchAccounts(AccountFilter filter){
        List<String> filters = new List<String>();
        List<String> keywords = new List<String>();

        if(String.isNotBlank(filter.name)) {
            keywords.add(getKeyword(filter.name));
        }
        if(String.isNotBlank(filter.phone)) {
            filters.add(getFilter('PersonMobilePhone', filter.phone));
            keywords.add(getKeyword(filter.phone));
        }
        if(String.isNotBlank(filter.email)) {
            filters.add(getFilter('PersonEmail', filter.email));
            keywords.add(getKeyword(filter.email));
        }
        if(String.isNotBlank(filter.aadhaar)) {
            filters.add(getFilter('Aadhaar__pc', filter.aadhaar));
            keywords.add(getKeyword(filter.aadhaar));
        }
        if(String.isNotBlank(filter.pan)) {
            filters.add(getFilter('PAN__pc', filter.pan));
            keywords.add(getKeyword(filter.pan));
        }

        String whereClause = !filters.isEmpty() ? ' WHERE IsPersonAccount = true AND SVOC_ID__c!=null AND ' + String.join(filters, ' AND ') : '';
        String searchTerm = '\'' + String.join(keywords, ' AND ') + '\'';

        List<Object> formatOptions = new List<Object>{ searchTerm, whereClause };
        List<Account> accounts = (List<Account>) Search.query(String.format(ACCOUNT_BASE_QUERY, formatOptions)).get(0);
        return prepareSearchResults(accounts);
    }

    @AuraEnabled
    public static List<SearchResult> searchAccountsByAsset(AssetFilter filter){
        List<String> filters = new List<String>();
        List<String> keywords = new List<String>();

        if(String.isNotBlank(filter.model)) {
            filters.add('Product2Id = \'' + filter.model + '\'');
        }
        if(String.isNotBlank(filter.vin)) {
            filters.add(getFilter('VIN__c', filter.vin));
            keywords.add(getKeyword(filter.vin));
        }
        if(String.isNotBlank(filter.regnum)) {
            filters.add(getFilter('Registration_Number__c', filter.regnum));
            keywords.add(getKeyword(filter.regnum));
        }
        if(String.isNotBlank(filter.polnum)) {
            filters.add(getFilter('SerialNumber', filter.polnum));
            keywords.add(getKeyword(filter.polnum));
        }
        if(String.isNotBlank(filter.loynum)) {
            filters.add(getFilter('SerialNumber', filter.loynum));
            keywords.add(getKeyword(filter.loynum));
        }
        if(String.isNotBlank(filter.engnum)) {
            filters.add(getFilter('Engine_No__c', filter.engnum));
            keywords.add(getKeyword(filter.engnum));
        }
        if(String.isNotBlank(filter.chanum)) {
            filters.add(getFilter('Chassis_Number__c', filter.chanum));
            keywords.add(getKeyword(filter.chanum));
        }

        String whereClause = !filters.isEmpty() ? ' WHERE Account.IsPersonAccount = true AND ' + String.join(filters, ' AND ') : '';
        String searchTerm = '\'' + String.join(keywords, ' AND ') + '\'';

        List<Object> formatOptions = new List<Object>{ searchTerm, whereClause };
        List<Asset> assets = (List<Asset>) Search.query(String.format(ASSET_BASE_QUERY, formatOptions)).get(0);

        List<Account> accounts = new List<Account>();
        for(Asset asset : assets){
            accounts.add(asset.Account);
        }

        return prepareSearchResults(accounts);
    }

    @AuraEnabled
    public static void sendOTPAccSearch(String recordId,Boolean isServiceProfile){
        String otp = String.valueOf(Integer.valueOf(Math.random()*1000000));
        Map<String, Object> params = new Map<String, Object>{ 'CUSOTOMER_VISIBILITY_OTP' => true };
        GenerateOTPValidation.saveOtpAccSearch(otp, recordId, params,isServiceProfile);
    }

    @AuraEnabled
    public static void sendOTP(String recordId){
        String otp = String.valueOf(Integer.valueOf(Math.random()*1000000));
        Map<String, Object> params = new Map<String, Object>{ 'CUSOTOMER_VISIBILITY_OTP' => true };
        GenerateOTPValidation.saveOtp(otp, recordId, params);
    }

    @AuraEnabled
    public static Boolean verifyOTP(String recordId, String otp){
        return [
            SELECT Count() FROM Account 
            WHERE Id =: recordId 
            AND OTP_Base_Value__c =: otp 
            AND OTP_Generated_Time__c >: Datetime.now().addMinutes(-Integer.valueOf(System.Label.CAS_OTP_Expire_Time))
        ] == 1;
    }

    @AuraEnabled
    public static void shareCustomerRecord(String recordId){
        Account customer = [SELECT Id, SVOC_ID__c FROM Account WHERE Id =: recordId];
        Account userAccount = [SELECT Id, Account.Parent_Group__c FROM User WHERE Id =: UserInfo.getUserId()].Account;
        insert new Customer_Visibility__c(
            Dealer_Public_Group_Name__c = userAccount != null ? userAccount.Parent_Group__c : null,
            Related_User__c = (userAccount==null ) ?UserInfo.getUserId():null,
            Transaction_Type__c = System.label.Transaction_Type_OTP,
            Transaction_Date__c = System.now(),
            Start_Datetime__c = System.now(),
            Customer_Account__c = customer.Id,
            SVOC_ID__c = customer.SVOC_ID__c,
            Access_Processing_Status__c = System.label.Access_Process_Status_Success,
            Sync_Status__c = System.label.Access_Sync_Status
        );
    }

    private static List<SearchResult> prepareSearchResults(List<Account> accounts){
        Set<Id> accountIds = new Set<Id>();
        for(Account acc : accounts){
            accountIds.add(acc.Id);
        }
        Map<Id, Boolean> accessMap = CustomerRecordVisibilityUtility.checkIfCustomerRecordAccessExsists(accountIds);
        List<SearchResult> results = new List<SearchResult>();
        for(Account acc : accounts){
            results.add(new SearchResult(acc, accessMap.get(acc.Id)));
        }
        return results;
    }

    private static String getFilter(String field, String value){
      return field + ' = \'' + value + '\'';
    }

    private static String getKeyword(String value){
        return value + '*';
    }

    public class AccountFilter {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String phone { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String aadhaar { get; set; }
        @AuraEnabled public String pan { get; set; }
    }

    public class AssetFilter {
        @AuraEnabled public String vin { get; set; }
        @AuraEnabled public String regnum { get; set; }
        @AuraEnabled public String polnum { get; set; }
        @AuraEnabled public String loynum { get; set; }
        @AuraEnabled public String engnum { get; set; }
        @AuraEnabled public String chanum { get; set; }
        @AuraEnabled public String model { get; set; }
    }

    public class SearchResult{
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String mobile { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String birthday { get; set; }
        @AuraEnabled public String mood { get; set; }
        @AuraEnabled public String customerType { get; set; }
        @AuraEnabled public Boolean accessible { get; set; }
        @AuraEnabled public String serviceMobile { get; set; } //Added variable for Dealer Inbound
        @AuraEnabled public String loggedinProfileName { get; set; } //Added variable for Dealer Inbound

        public SearchResult(Account acc, Boolean accessible){
            id = acc.Id;
            name = acc.Name;
            mobile = acc.PersonMobilePhone != null ? String.valueOf(acc.PersonMobilePhone) : '';
            email = acc.PersonEmail;
            birthday = acc.PersonBirthdate != null ? String.valueOf(acc.PersonBirthdate) : '';
            mood = acc.Customer_Mood__c;
            customerType = acc.Customer_Type__c;
            serviceMobile = acc.Service_Mobile__c; //Added variable for Dealer Inbound
            this.accessible = accessible;
            if(!accessible){
                maskValues();
            }
            loggedinProfileName=ProjectUtility.getCurrentUserProfile();//Added variable for Dealer Inbound
        }

        private void maskValues(){
            if(String.isNotBlank(name)){
                List<String> unmaskedList = name.split(' ');
                List<String> maskedList = new List<String>();
                for(String item : unmaskedList){
                    maskedList.add(item.substring(0, 1) + getMaskedValue(item.substring(1)));
                }
                name = String.join(maskedList, ' ');
            }
            if(String.isNotBlank(mobile) && mobile.length() > 4){
                Integer ind = mobile.length() - 4;
                mobile = getMaskedValue(mobile.substring(0, ind)) + mobile.substring(ind);
            }
            if(String.isNotBlank(email) && email.indexOf('@') > 1){
                Integer ind = email.indexOf('@');
                email = email.substring(0, 2) + getMaskedValue(email.substring(2, ind)) + email.substring(ind);
            }
            if(String.isNotBlank(birthday)){
                Integer find = birthday.indexOf('-'), lind = birthday.lastIndexOf('-');
                birthday = getMaskedValue(birthday.substring(0, find)) + '-' + getMaskedValue(birthday.substring(find+1, lind)) + '-' + birthday.substring(lind + 1);
            }
            //Added variable for Dealer Inbound
            if(String.isNotBlank(serviceMobile) && serviceMobile.length() > 4){
                Integer ind = serviceMobile.length() - 4;
                serviceMobile = getMaskedValue(serviceMobile.substring(0, ind)) + serviceMobile.substring(ind);
            }
            //Added variable for Dealer Inbound
        }

        private String getMaskedValue(String value){
            String maskedValue = '';
            for(Integer i = 0; i < value.length(); i++){
                maskedValue += '*';
            }
            return maskedValue;
        }
    }
}