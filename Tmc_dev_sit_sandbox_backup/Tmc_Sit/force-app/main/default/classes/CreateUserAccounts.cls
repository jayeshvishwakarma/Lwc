/**
    * @Autho:- Anuj Kumar
    * @Company-: Techmatrix Consulting
    * @Description-: Create User Account for Each Dealer User Record
    * =============================================================
    * Version   Date            Author      Modification
    * =============================================================
    * 1.0       12 Mar 2020    Anuj Kumar     Intial Version
    **/

public class CreateUserAccounts implements Queueable { 
    
    public List<String> userIdList = new List<String>();
    public CreateUserAccounts(List<string> userIdList){
        this.userIdList = userIdList;
    }
    
    public void execute (QueueableContext context) { 
    
        if(userIdList != null && userIdList.size() > 0){
            List<Account> accountList = new List<Account>();
            
            List<Account> userAccountList = TestDataFactory.createBusinessAccount(userIdList.size(), 'User Account');
            
            for(Integer i=0; i<userIdList.size(); i++){
                Account acc = userAccountList[i];
                acc.User__c = userIdList[i];
                
                accountList.add(acc);
            }
            
            insert accountList;    
        }
    
    }  

}