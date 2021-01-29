trigger twod_AccountCreationWarrantyTransferTrigger on Warranty_Transfer__c (before insert) {
    
    /* Author: Sunny Singh (Capgemini)
     * Description: Added check against Custom Setting "Automation Controller", to see if trigger should run
     * Date: 10 December 2020
     */
    if(!Test.isRunningTest() && !Automation_Controller__c.getOrgDefaults().All_Triggers_enabled__c)  return;
    
    if(!Test.isRunningTest() && !Automation_Controller__c.getOrgDefaults().twod_AccountCreationWarrantyTransferTrig__c)  return;
    
    twod_TriggerControl__c mc = twod_TriggerControl__c.getInstance( userinfo.getProfileId());
    if(mc.twod_AccountCreationWarrantyTransferTrig__c){
        
        List<Warranty_Transfer__c> wrList=new List<Warranty_Transfer__c>();
        String BL_address1;
        String BL_address2;
        String BL_city;
        String BL_state;
        String BL_country;
        String BL_postalcode;
        String accName;    
        Map<String,Warranty_Transfer__c> wrMap=new Map<String,Warranty_Transfer__c>();    
        for(Warranty_Transfer__c wr:Trigger.new)
        {        
            BL_address1=wr.Address_1_BL__c;
            BL_address2=wr.Address_2_BL__c;
            BL_city=wr.City_BL__c;
            BL_state=wr.State_BL__c;
            BL_country=wr.Country_BL__c;
            BL_postalcode=wr.Postal_Code_BL__c;
            if(BL_postalcode !=null && BL_postalcode !=''){
                if(BL_postalcode.contains('-')){
                    String[] zip=BL_postalcode.split('-');
                    BL_postalcode=zip[0];
                }
            }
            accName=BL_address1+','+BL_city+','+BL_state+','+BL_postalcode;                       
            System.debug(accName+'---->>>'+wr);        
            wrMap.put(accName,wr);
        }
        List<Account> accList=new List<Account>();
        try{
            accList=[select Id,Name from Account where Name in:wrMap.keySet() ];    
        }
        catch(exception e){}
        set<String> accountPre=new set<String>();
        for(Account a:accList){
            accountPre.add(a.Name);
        }    
        
        system.debug('accList--'+accList.size());
        system.debug('wrMap.keySet()--'+wrMap.keySet().size());
        List<Account> newAccount=new List<Account>();
        Id accId=[select Id,DeveloperName from recordtype where DeveloperName='Warranty_Account' and SobjectType='Account' limit 1].Id;
        
        set<String> accNameList=wrMap.keySet();
        for(String s:accNameList){
            if(!accountPre.contains(s)){
                Warranty_Transfer__c wr=wrMap.get(s);
                BL_address1=wr.Address_1_BL__c;
                BL_address2=wr.Address_2_BL__c;
                BL_city=wr.City_BL__c;
                BL_state=wr.State_BL__c;
                BL_country=wr.Country_BL__c;
                BL_postalcode=wr.Postal_Code_BL__c;
                Account acc=new Account();
                acc.put('RecordtypeId',accId);
                acc.Name=s;
                acc.BillingCity=BL_city;        
                acc.BillingCountry=BL_country;        
                if(BL_address2!=null)
                {
                    acc.BillingStreet= BL_address1 +','+ BL_address2;       
                }else{
                    acc.BillingStreet= BL_address1;
                }
                acc.BillingState=BL_state;                 
                if(BL_postalcode!=null && BL_postalcode!='' )
                {
                    acc.BillingPostalCode=string.valueof(BL_postalcode);
                }            
                acc.twod__Warranty_Account_Type__c='Customer';
                newAccount.add(acc);      
                if(!wrMap.keySet().contains(acc.Name)){
                    wrMap.put(acc.Name,wr);
                }
                System.debug(acc.Name+'---->>>'+wr);
            }
        }
        
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true; 
        Database.SaveResult[] sr = Database.insert(newAccount, dml);    
        
        
        
        accList=new List<Account>(); 
        accList=[select Id,Name from Account where Name in:wrMap.keySet()];
        Map<String,Id> accMap=new Map<String,Id>();
        for(Account a:accList){
            accMap.put(a.Name, a.Id);
        }
        
        for(Warranty_Transfer__c wr:Trigger.new)
        {        
            BL_address1=wr.Address_1_BL__c;
            BL_address2=wr.Address_2_BL__c;
            BL_city=wr.City_BL__c;
            BL_state=wr.State_BL__c;
            BL_country=wr.Country_BL__c;
            BL_postalcode=wr.Postal_Code_BL__c;
            if(BL_postalcode !=null && BL_postalcode !=''){
                if(BL_postalcode.contains('-')){
                    String[] zip=BL_postalcode.split('-');
                    BL_postalcode=zip[0];
                }
            }
            accName=BL_address1+','+BL_city+','+BL_state+','+BL_postalcode;         
            if(wr.Account__c==null)
                wr.Account__c=accMap.get(accName);
        }    
    }
}