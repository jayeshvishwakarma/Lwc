public with sharing class IBSRelatedAccountsController {
    @AuraEnabled(cacheable=true)
    public static Result getChildAccounts(){
        Result objRes = new Result();
        List<Option> options = new List<Option>();
        User usr = [select id, contact.accountid, contact.account.name from user where id =: Userinfo.getUSerID()];
        objRes.selectedAcc = usr.contact.accountid;
        options.add(new Option(usr.contact.account.name,usr.contact.accountid));        
        for(Account acc : [select id, name from account where parentId =: usr.contact.accountid]){
            options.add(new Option(acc.name,acc.Id));
        }
        objRes.listOfOptions = options;
        System.debug(objRes);
        return objRes;
    }
    
    public class Result{
        @AuraEnabled
        public String selectedAcc;
        @AuraEnabled
        public List<Option> listOfOptions;

    }

    public class Option{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        public Option(String label,String value){
            this.value = value;
            this.label = label;
        }
    }
}