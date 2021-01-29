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
global class UpdateUserBatch implements Database.Batchable<sObject> {
    global String sQuery;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<String> includedProfiles = new List<String>();
        if (System.Label.Approval_Chatter_Turn_Off_Profiles != null) {
            includedProfiles = String.valueOf(System.Label.Approval_Chatter_Turn_Off_Profiles).split(',');
        }
        sQuery='select Id,UserPreferencesReceiveNoNotificationsAsApprover,Profile.Name from User Where Profile.Name IN :includedProfiles' ;
      //  sQuery = 'Select Id,Phone,Email,MobilePhone,ManagerId from User Where UserRole.Name = :roleName' ;
        return Database.getQueryLocator(sQuery);
    }

    global void execute(Database.BatchableContext BC, List<sObject> listRecord) {
        List<User> userList = new List<User>();
        for (User usr : (List<User>) listRecord) {
            if(usr.Profile.Name != 'System Administrator' && !usr.UserPreferencesReceiveNoNotificationsAsApprover){
                usr.UserPreferencesReceiveNoNotificationsAsApprover = true ;
                userList.add(usr);
            }
        }
        if (userList.size() > 0) {
            TriggerHandler.bypass('UserTriggerHandler');
            update userList;
            TriggerHandler.clearbypass('UserTriggerHandler');
            

        }
    }
    global void finish(Database.BatchableContext BC) {
        system.debug('finish');
    }
}