public without sharing class listViewFilterApexV1{

    @AuraEnabled
    public static list<user> getCurrentTeamUsers(string searchTerm){
     // String key = '%' + searchTerm + '%';
     String key = searchTerm + '%';
        list<user> userRecords = new list<User>();
        user currentUserInfo = [SELECT 
                      Id, 
                      Name
                      
                FROM User
                WHERE Id = :userInfo.getUserId()];
                userRecords.add(currentUserInfo);
        list<user> subordinateUsers =  [SELECT 
                      Id, 
                      Name, 
                      ManagerId,IsActive 
                FROM User
                WHERE Name LIKE :key AND ManagerId = :userInfo.getUserId() AND IsActive = true                 
                LIMIT 30];
        
        for(user u: subordinateUsers){
            userRecords.add(u);
        }
        return userRecords;
    }
}