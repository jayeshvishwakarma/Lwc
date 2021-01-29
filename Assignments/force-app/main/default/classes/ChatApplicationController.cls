public with sharing class ChatApplicationController {
    @AuraEnabled(Cacheable = true)
    public static List<User> getLoginedUser(){      
        String userId = UserInfo.getUserId();
        List<User> lstUsers = [SELECT Id, FullPhotoUrl, Email, Name 
                               FROM User 
                               WHERE Id =: userId limit 1
                              ];
        if(lstUsers.size() > 0){
            return lstUsers;
        }
        return null;
    }
    
    @AuraEnabled(Cacheable = true)
    public static List<User> getUsers(){
        String userId = UserInfo.getUserId();
        List<User> lstUsers = [SELECT Id, FullPhotoUrl, Email, Name 
                               FROM User
                               WHERE Id !=: userId
                              ];
        if(lstUsers.size() > 0){
            return lstUsers;
        }
        return null;
    }
    
    @AuraEnabled
    public static List<String> getMessages(String currentUserId, String recieverUserId){
        List<ChatApplication__C> lstChats = [SELECT Id, Messages__c, firstUserId__c, secondUserId__c  
                                             FROM ChatApplication__C 
                                             WHERE (firstUserId__c =:currentUserId AND secondUserId__c =:recieverUserId)
                                             OR (firstUserId__c =:recieverUserId AND secondUserId__c =:currentUserId)
                                            ];
        if(lstChats.size() > 0){
            String message = lstChats[0].Messages__c;
            List<String> lstStrings = message.split(',');
            return lstStrings;
        }
        return null;
    }
    
    @AuraEnabled
    public static void setMessages(String messages, String currentUserId, String reciverUserId){
        List<ChatApplication__C> lstChats = [SELECT Id, Messages__c, firstUserId__c, secondUserId__c  
                                             FROM ChatApplication__C 
                                             WHERE (firstUserId__c =:currentUserId AND secondUserId__c =:reciverUserId)
                                             OR (firstUserId__c =:reciverUserId AND secondUserId__c =:currentUserId)
                                            ];
        
        if(lstChats.size() > 0){
            System.debug('IF chala :'+lstChats[0]);
            String mes = lstChats[0].messages__c  + ',' + messages;
            lstChats[0].messages__c = mes;
            update lstChats;
            
        }else{
            
            chatApplication__c objChat = new chatApplication__c();
            objChat.firstUserId__c = currentUserId;
            objChat.secondUserId__c = reciverUserId;
            objChat.Messages__c = messages;
            insert objChat;
            System.debug('inserted');
        }
    }
    
}