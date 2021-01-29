/**
     * @File Name          : updateUserBatc.cls
     * @Description        : updates  field UserPreferencesReceiveNoNotificationsAsApprover as True. 
     * @Author             : Mohd Zakir 
     * @Last Modified By   : Mohd Zakir 
     * @Last Modified On   : 15-10-2020
     * @Modification Log   :
     *==============================================================================
    * Ver         Date                     Author                    Modification
    *==============================================================================
    * 1.0        13-10-2020                Zakir               Initial Version
**/ 
global class updateUserBatch implements Database.Batchable<sObject> {
    global  String sQuery;
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        sQuery='select Id,UserPreferencesReceiveNoNotificationsAsApprover,Profile.Name from User' ;
        return Database.getQueryLocator(sQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> listRecord){
        List<User> userList = new List<User>();
        for(User usr : (List<User>)listRecord){ 
            If(usr.Profile.Name != 'System Administrator'){
                usr.UserPreferencesReceiveNoNotificationsAsApprover = True ;
                userList.add(usr);
            }
        }
        if(userList.size() > 0){
            update userList;
         }
    }
    global void finish(Database.BatchableContext BC){
     system.debug('finish');  
   }
}