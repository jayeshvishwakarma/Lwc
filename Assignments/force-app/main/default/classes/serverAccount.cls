public with sharing class serverAccount {
    public serverAccount() {

    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts()
    {
        return [SELECT id,name,phone
                FROM Account LIMIT 10
               ];
    }
}