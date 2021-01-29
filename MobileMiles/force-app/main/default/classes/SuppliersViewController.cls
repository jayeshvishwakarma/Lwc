public class SuppliersViewController {
    public string accountid{get;set;}
    public String connTypeParam{get; set;}
    
    public SuppliersViewController(ApexPages.StandardController sc){
        accountid = sc.getId();
        connTypeParam = '';
    }
    
    public List<Available_Supplier__c> getSuppliers(){
        return [select id, name, (select id, name, availability__c, technology__c, description__c, Prijs_per_maand_incl_managed_router__c,Selected_Technology__c
                from Available_Speeds__r)
                from Available_Supplier__c where Account__c = :accountid];
        
    }
    
    public void setBusinessType(){
        system.debug('connTypeParam ---'+connTypeParam );
        if(connTypeParam != ''){
            Account acc = [select id, Connectivity_portfolio__c from account where id =: accountid];
            acc.Connectivity_portfolio__c = connTypeParam;
            acc.Check_Beschikbaarheid__c = false;
            update acc;           
        }
    }
    
    public void callZipcodeApi(){
        Set<String> accountIds = new Set<String>{[select id from Account where id =: accountid].id};
        ZipCodeCheck.getAccountDetailsZipCode(accountIds);            
    }
    
    public string getConnectivityType(){
        return [select id, Connectivity_portfolio__c from account where id =: accountid].Connectivity_portfolio__c ;
    }
}