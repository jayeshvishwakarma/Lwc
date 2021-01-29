/**
 * @File Name          : ChangeOwnerFunctionality.cls
 * @Description        : This class is used for Enquiry Change Owner functionality
 * @Author             : Sunit Kumar Chand
 * @Group              : 
 * @Last Modified By   : Sunit Kumar Chand
 * @Last Modified On   : 08/11/2019, 11:37:23 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    08/11/2019, 11:37:23 AM   Sunit Kumar Chand     Initial Version
 **/
public without sharing class ChangeOwnerCase {
 /**
   Author: Sunit kumar chand
   Company: Techmatrix
   Description: This funcion is used to get user list as per search key and dealer Id
   Inputs: DealerId String,UserName string
   Returns: BasicReturn with a List of User
   History:
   ================
   1.0     08/11/2019     Sunit     Initial Version
*/
    @AuraEnabled(cacheable=true)
    public static BasicReturn getUserList(String name)
    {
        System.debug('name-->'+name);
        BasicReturn br=new BasicReturn();
        try
        {
            String var='%'+name+'%';
            List<User> userList=[SELECT Id,Name from User WHERE isActive=true and Name like:var];
            br.dataList=userList;
            br.message='Success';
            br.status='Success';
            br.code=200;
        }
        catch(Exception e){br.message=e.getMessage();br.status='Error';br.code=0;
        }
        System.debug(br);
        return br;
    }
/**
   Author: Sunit kumar chand
   Company: Techmatrix
   Description: This funcion is used check logged in user type(It is a partner user or not)
   Inputs: 
   Returns: BasicReturn with a List of User
   History:
   ================
   1.0     08/11/2019     Sunit     Initial Version
*/    
    @AuraEnabled
    public static BasicReturn checkLoggedinUserType(String recordId)
    {
        BasicReturn br=new BasicReturn();
        System.debug('Inside checkLoggedinUserType');
        try
        {    
            List<String> profileNameList = system.label.Allow_Change_Owner_Profile_Names != null ?
            system.label.Allow_Change_Owner_Profile_Names.split(';') : new List<String>();
            
            List<Opportunity> enquiryList = [Select id, OwnerId from Opportunity Where Id =:recordId];
            
            List<User> userList = [select Id, Name, contact.accountId, profile.name from User 
                        where IsPortalEnabled=true and Id=:UserInfo.getUserId()];
            
            if(userList != Null && userList.size() > 0){
                    br.dataList = new List<User>();
                    br.message = 'Success';
                    br.status = 'Success';
                    br.code = 200;
                if(!profileNameList.isEmpty() && profileNameList.contains(userList[0].profile.name)){      // PROFILE_NAME = 'Dealer Team Leads/Managers'   == ConstantsUtility.PROFILE_NAME
                    br.dataList = userList;
                }
                if(enquiryList != Null && enquiryList.size() > 0 && enquiryList[0].ownerId == UserInfo.getUserId()){
                    br.dataList = userList;
                }
            }
            
        }
        catch(Exception e){
            br.message=e.getMessage();br.status='Error';br.code=0;
        }
        System.debug(br);
        return br;
    }
/**
   Author: Sunit kumar chand
   Company: Techmatrix
   Description: This funcion is used change owner of a particular Enquiry
   Inputs: EnquiryId String,UserId string
   Returns: BasicReturn with a List of User
   History:
   ================
   1.0     08/11/2019     Sunit     Initial Version
*/   
    @AuraEnabled
    public static BasicReturn changeOwner(String id,String ownerId)
    {
        BasicReturn br=new BasicReturn();
        
        try
        {
           Opportunity op=new Opportunity();
           op.Id=id;
           op.OwnerId=ownerId;
           update op;
            br.message='Success';
            br.status='Success';
            br.code=200;
        }
        catch (DmlException de) {
            Integer numErrors = de.getNumDml();
            string errorMsg = '';
            for(Integer i=0;i<numErrors;i++) {
                errorMsg += de.getDmlMessage(i);
            }
            br.message = errorMsg;
            br.status = 'Error';
            br.code = 0;
        }
        return br;
    }

}