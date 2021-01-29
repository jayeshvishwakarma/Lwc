/**
* @Autho:- Rohit Gupta
* @Company-: Techmatrix Consulting
* @Description-:Class to calculate Rank of user according to the Number of posts posted by dealer in chatter Groups
* =============================================================
* Version   Date            Author      Modification
* =============================================================
* 1.0       25 Jun 2020    Rohit     Intial Version
**/
public class CalculateRankByNumberOfPosts {
    Static Decimal temp;
    public static void calculateRank(){
        List<AccountWrapper> aLst = new List<AccountWrapper>();
        for(Account acc: [select id, number_of_posts__c from Account Where number_of_posts__c != null and RecordType.Name = 'User Account' ]){
            alst.add(new AccountWrapper(acc.id, acc.Number_of_posts__c));
        }
        if(alst.size() > 0){
            System.debug('#@ before '+alst);
            alst.sort();
            System.debug('#@ '+alst);
            list<Account> accList = new List<Account>();
            Integer r=1;
            temp = alst[0].Number_of_posts;
            for(AccountWrapper aw: alst){
                
                if(aw.Number_of_posts == temp){
                    //r =1;
                    temp = aw.Number_of_posts ;                                
                } else {
                    r++;
                    temp = aw.Number_of_posts ; 
                }
                accList.add(new Account( Id = aw.Id ,Rank__c = r));
            }
            System.debug('#@accList '+accList);
            if(acclist.size() > 0){
                update acclist;
            }             
        }
        
    }
    
    public class AccountWrapper implements comparable {
        public String Id;
        public Decimal Number_of_posts;
        Public AccountWrapper (String Id, Decimal Number_of_posts){
            This.Id = Id;
            This.Number_of_posts = Number_of_posts;            
        }
        
        Public Integer compareTo (Object compareTo) {
            AccountWrapper oppW = (AccountWrapper)compareTo;
            Integer returnValue = 0;
            If (Number_of_posts < oppW.Number_of_posts) {
                returnValue = 1;
            } else if (Number_of_posts > oppW.Number_of_posts) {
                returnValue = -1;
            }
            Return returnValue; 
        }
    }
}