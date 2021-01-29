/**
* @File Name          : rfcApprovalCtrl.cls
* @Description        : This class is used for RFC Appprovals
* @Author             : Saloni Gupta
* @Group              :
* @Last Modified By   :
* @Last Modified On   :
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0    14/4/2020, 11:00:23 AM     Saloni Gupta               Initial Version

* **/
public without sharing class rfcApprovalCtrl {

    /**
Author: Saloni Gupta
Company: Techmatrix
Description: It will return the list of MDT based on Dealer_Approver_Role
Inputs: Dealer_Approver_Role string
Returns: List of Approvals_LWC_Configurator__mdt
History:
================
1.0     14 April 2020      Saloni     Initial Version
*/
    @AuraEnabled(cacheable = true)
    public static List<Approvals_LWC_Configurator__mdt> getMDTListData(String fieldType){
        List<Approvals_LWC_Configurator__mdt> approvalMDTList =  new List<Approvals_LWC_Configurator__mdt>();
        approvalMDTList = [select id, MasterLabel, DeveloperName, Dealer_Approver_Role__c, Field_API_Name__c,Is_Lookup__c, Is_Field_Read_Only__c,Is_Mandatory__c,Field_Order__c from Approvals_LWC_Configurator__mdt
                           where Dealer_Approver_Role__c != null AND Field_Order__c != null AND Field_API_Name__c != null AND Dealer_Approver_Role__c =:fieldType order by Field_Order__c asc];

        System.debug('---approvalMDTList---' + approvalMDTList);
        return approvalMDTList;
    }


    /**
        Author: Avaneesh Singh
        Company: Techmatrix
        Description: It will return the string for authorized and non authorized
        Inputs: String roleClick button and rfc objectid
        Returns: authorized || Non authorized
        History:
        ================
        1.2     14 April 2020  Avaneesh Singh Initial Version
    */


    @AuraEnabled(cacheable=true)
    public static List<User> getOwnerDetails(String userId){
        system.debug('== userId '+ userId);
        return [Select id, Name, MobilePhone from User Where Id =: userId];
    }

    /**
        Author: Avaneesh Singh
        Company: Techmatrix
        Description: It will return the string for authorized and non authorized
        Inputs: String roleClick button and rfc objectid
        Returns: authorized || Non authorized
        History:
        ================
        1.2     14 April 2020  Avaneesh Singh Initial Version
    */


    @AuraEnabled(cacheable = true)
    public static String getAccContRelationValidataion(String BtnClickStr,String sobjectId){
        System.debug('BtnClickStr@@@'+BtnClickStr);
        System.debug('sobjectId@@@'+sobjectId);
        String authStr= 'Not Authorized';
        if(BtnClickStr != null && sobjectId != null){
         Map<String,String> rolesValuesMap = new Map<String,String>{
                'FM'=>ConstantsUtility.ACR_FINANCE_MANAGER,
                'TVM'=>ConstantsUtility.True_Value_Manager,
                'ACM'=>ConstantsUtility.Accounts_Manager,
                'SM'=>ConstantsUtility.SHOWROOM_MANAGER
         };

        String loginUserId = UserInfo.getUserId();
        User loginUserdata = [select id,contactId from user where id=:loginUserId
                                and isActive = true];

         RFC__c rfcInfos = [select id , RFC_Status__c,Enquiry__c from RFC__C where id =: sobjectId];
         system.debug('rfcInfos@@@'+rfcInfos);
         if(rfcInfos.Enquiry__c != null && rfcInfos.RFC_Status__c != null){
           opportunity opp = [select id,Dealership__c from opportunity where id=:rfcInfos.Enquiry__c];
         system.debug('opp@@@'+opp);

               if(opp.Dealership__c != null){
                  List<AccountContactRelation> accountContactRoleList = [select id ,roles from AccountContactRelation
                                                                          where accountid=:opp.Dealership__c AND contactid=:loginUserdata.contactId AND roles !=null];
         List<String> rolesStringList = accountContactRoleList.size() > 0 ? accountContactRoleList[0].roles.split(';') : new List<String>();
         if(accountContactRoleList.size() > 0 && rolesStringList.contains(rolesValuesMap.get(BtnClickStr))){
                        authStr = 'Authorized';
                        /*
                        if(rfcInfos.RFC_Status__c.containsIgnoreCase(BtnClickStr)){

                            authStr = 'Authorized';
                          }else if(BtnClickStr == 'SM'){
                             for(String key:rolesValuesMap.keySet()){
                               if(rfcInfos.RFC_Status__c.containsIgnoreCase(key)){
                                authStr = 'Authorized';
                               }
                             }
                        }*/

                      }

               }
         }
        }
        return authStr;
    }

    @AuraEnabled(cacheable = true)
    public static List<Financier__c> getLookupData(String searchKey,String dealerMapCode){

        List<Financier__c> financierList = new List<Financier__c>();
        if(string.isNotBlank(searchKey)){
            //Decalring String Variable
            string nameData = '%'+searchKey.trim()+'%';

            //Null Check
            if(dealerMapCode != null){
                //Fetch the record the from Financier Obj
                financierList = [Select Id, Name
                            from Financier__c
                            where Dealer_Map_Code__c =: dealerMapCode AND Name Like : nameData Limit 20];
            }
        }
        return financierList;

    }
}