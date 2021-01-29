public class ServerAccContoller {

     @AuraEnabled(cacheable = true)
    public static List<Account> getAccounts(String recName){

      
      List<Account> lstAccounts = [ SELECT Id, Name, CreatedDate, Phone, AccountNumber 
                                    FROM Account WHERE Name LIKE :'%' + recName +'%'
                                  ];
        if(lstAccounts.size()>0){
        return lstAccounts;
        }else{
            return null;
        }

    }
}