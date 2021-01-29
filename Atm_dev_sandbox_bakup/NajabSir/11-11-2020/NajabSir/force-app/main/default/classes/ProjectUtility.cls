/**
Author: Sunit Kumar Chand
Company: Techmatrix
Description: Class Used Utility class basically for some common used functions. 
Returns: void
History:
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.1A        15/10/2020                Sunit            Initial Version
**/
public without sharing class ProjectUtility {
    /**
    Author: Sunit Kumar Chand
    Company: Techmatrix
    Description: Method to fetch current user's profile name
    Returns: String
    History:
    * Ver         Date                     Author                    Modification
    *==============================================================================
    * 1.1A      15/10/2020                 Sunit Chand               Initial Version
    **/
    @AuraEnabled
    public static String getCurrentUserProfile(){
		String profileName = '';
        Id profileId = userInfo.getProfileId();
        if(profileId != Null){
            List<Profile> profileInfo = new List<Profile>([Select Id, Name from Profile where Id =: profileId]);    
            profileName = (profileInfo != null && profileInfo.size() > 0) ? profileInfo[0].Name : '';
        }
        return profileName;
    }
    
    /**
    Author: Sunit Kumar Chand
    Company: Techmatrix
    Description: Method to fetch custom setting values of Constant value
    Returns: Constant_Value__c 
    History:
    * Ver         Date                     Author                    Modification
    *==============================================================================
    * 1.1A      15/10/2020                 Sunit Chand               Initial Version
    **/
    @AuraEnabled
    public static Constant_Value__c  getConstantValue(String name){
		Constant_Value__c cv=Constant_Value__c.getValues(name);
        return cv;
    } 
    /**
    Author: Sunit Kumar Chand
    Company: Techmatrix
    Description: Method to fetch all queue avaialable in org
    Returns: map of queue 
    History:
    * Ver         Date                     Author                    Modification
    *==============================================================================
    * 1.2      01/12/2020                 Sunit Chand               Initial Version
    **/
    public static Map<String, Group> getQueueMap() {
        Map<String, Group> developerNameVsQueueMap = new Map<String, Group>();
        for (Group groupObj : [SELECT DeveloperName,Id FROM Group WHERE Type = 'Queue']) {
            developerNameVsQueueMap.put(groupObj.DeveloperName, groupObj);
        }
        return developerNameVsQueueMap;
    }
}