/**
    * @Author : Deepak Kumar
    * @Company-: Techmatrix
    * @Description-: To get the information of create case accessiblity.
 */
public with sharing class NewCaseOverrideController {
    @AuraEnabled
    public static String getCurrentUserProfileName() {
        try {
            String userProfile = '';
           // userProfile = ConstantsUtility.PROFILE_SYSTEM_ADMIN;
            User user = [SELECT Id,Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
            userProfile = user.Profile.Name;
            String mosRecordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('MOS Case').getRecordTypeId();
            return userProfile+'#'+mosRecordTypeId;
        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage());
        }
    }
}