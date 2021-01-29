/**
* @File Name          : PreliminaryChecklistCtrl.cls
* @Description        : This class is used for Preliminary Checklist
* @Author             : Saloni Gupta
* @Group              :
* @Last Modified By   :
* @Last Modified On   :
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0    18/5/2020, 11:00:23 AM     Saloni Gupta               Initial Version

* **/
public class PreliminaryChecklistCtrl {

    public class OnloadWrapperCls{
        @AuraEnabled Public String professionType{get;set;}
        @AuraEnabled Public String authUser{get;set;}
        @AuraEnabled Public List<String> professionPicklistValues{get;set;}
        onloadWrapperCls(){
            professionType='';
            professionPicklistValues = new List<String>();
            authUser ='';
        }
    }

    /**
    Author: Saloni Gupta
    Company: Techmatrix
    Description: It will return the current record's Profession_Type__c and the piclist value of Profession_Type__c
    Inputs: RecordId
    Returns: wrapperclass - OnloadWrapperCls
    History:
    ================
    1.0     20 May 2020      Saloni Gupta     Initial Version
    */

    @AuraEnabled
    public static OnloadWrapperCls getProfessionType(Id recordId){
        OnloadWrapperCls wrpcls = new OnloadWrapperCls();
        String professionType='';
        String authUser = getAccContRelationValidataion('Checklist FM',recordId);
        wrpcls.authUser = authUser;
        if(authUser == 'Authorized'){
            professionType = [select id,Profession_Type__c from Preliminary_Checklist__c where Id=:recordId].Profession_Type__c;
            wrpcls.professionType = professionType;

            List<String> professionPicklistValues= new List<String>();
            Schema.DescribeFieldResult fieldResult = Preliminary_Checklist__c.Profession_Type__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                professionPicklistValues.add(pickListVal.getLabel());
            }
            wrpcls.professionPicklistValues = professionPicklistValues;
        }
        return wrpcls;
    }

    /**
    Author: Saloni Gupta
    Company: Techmatrix
    Description: It will return the list of MDT based on Checklist_Role
    Inputs: Checklist_Role string
    Returns: List of Approvals_LWC_Configurator__mdt
    History:
    ================
    1.0     18 May 2020      Saloni     Initial Version
    */
    @AuraEnabled(cacheable = true)
    public static List<Approvals_LWC_Configurator__mdt> getMDTListData(String fieldType,String employeeType){
        System.debug('fieldType@@@'+fieldType);
        System.debug('employeeType@@@'+employeeType);
        List<Approvals_LWC_Configurator__mdt> approvalMDTList =  new List<Approvals_LWC_Configurator__mdt>();
        String query ='select id, MasterLabel, DeveloperName, Dealer_Approver_Role__c, Field_API_Name__c,Is_Lookup__c, Is_Field_Read_Only__c,Is_Mandatory__c,Field_Order__c, '+
                            'Is_Label__c, Custom_Label_Name__c,Is_self_employed__c from Approvals_LWC_Configurator__mdt '+
                            'where Dealer_Approver_Role__c != null AND Field_Order__c != null AND Field_API_Name__c != null AND Dealer_Approver_Role__c =:fieldType';

        if(fieldType =='Checklist FM' && employeeType=='Self employed'){
            query = query +' AND Is_self_employed__c=TRUE ';
        }

        approvalMDTList = Database.query(query + ' order by Field_Order__c asc');

        System.debug('---approvalMDTList---' + approvalMDTList);
        return approvalMDTList;
    }

    /**
        Author: Saloni Gupta
        Company: Techmatrix
        Description: It will return the string for authorized and non authorized
        Inputs: String roleClick button and checklist objectid
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
                'Checklist FM'=>ConstantsUtility.ACR_FINANCE_MANAGER,
                'Checklist ACM'=>ConstantsUtility.Accounts_Manager,
                'MGA Manager Checklist'=>ConstantsUtility.MGA_Manager,
                'PDI Coordinator Checklist' => ConstantsUtility.PDI_Coordinator,
                'RTO Coordinator Checklist' => ConstantsUtility.RTO_Coordinator ,
                'Delivery coordinator Checklist' => ConstantsUtility.DC
         };

        String loginUserId = UserInfo.getUserId();
        User loginUserdata = [select id,contactId from user where id=:loginUserId
                                and isActive = true];

         Preliminary_Checklist__c preCheckObj = [select id,RFC__c,Active__c from Preliminary_Checklist__c where id=: sobjectId];
         system.debug('preCheckObj@@@'+preCheckObj);
         if(preCheckObj.RFC__c != null){
            RFC__c rfcInfos = [select id,Enquiry__c, Enquiry__r.Dealership__c from RFC__C where id =: preCheckObj.RFC__c];
            system.debug('rfcInfos@@@'+rfcInfos);

            if(rfcInfos.Enquiry__r.Dealership__c != null){
               List<AccountContactRelation> accountContactRoleList = [select id ,roles from AccountContactRelation
                                                                        where accountid=:rfcInfos.Enquiry__r.Dealership__c AND
                                                                        contactid=:loginUserdata.contactId AND roles !=null];
                List<String> rolesStringList = accountContactRoleList.size() > 0 ? accountContactRoleList[0].roles.split(';') : new List<String>();
                if(accountContactRoleList.size() > 0 && rolesStringList.contains(rolesValuesMap.get(BtnClickStr))){
                    if(preCheckObj.Active__c == true){
                        authStr = 'Authorized';
                    }else {
                        authStr = 'Inactive_PC';
                    }
                }

            }
         }
        }
        return authStr;
    }

}