/**
* @File Name          : ChangeOwnerFunctionality.cls
* @Description        : This class is used for Case Change Owner functionality
* @Author             : Sunit Kumar Chand
* @Group              : 
* @Last Modified By   : Shalini Singh
* @Last Modified On   : 27/10/2020, 12:37:23 PM 
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0    08/11/2019, 11:37:23 AM   Sunit Kumar Chand     Initial Version
* 1.1    27/10/2020, 12:37:23 PM   Shalini Singh
* 1.2    28/10/2020, 02:02:35 PM   Shalini Singh
**/
public without sharing class ChangeOwnerCase {
    /**
Author: Sunit kumar chand
Company: Techmatrix
Description: This funcion is used to get user list as per search key 
Inputs: UserName
Returns: BasicReturn with a List of User
Change History Description: This function is used to get users list on basis of profile and queue. 
================
1.0     08/11/2019     Sunit     Initial Version
1.1    27/10/2020, 12:37:23 PM   Shalini Singh
1.2    28/10/2020  02:02:35 PM   Shalini Singh 
*/
    @AuraEnabled(cacheable=true)
    public static BasicReturn getUserList(String name)
    {
        
        BasicReturn br=new BasicReturn();
        try
        {
            
            List<String> profileNameList = system.label.New_Owner_s_Profiles_Name_for_Case != null ?
                system.label.New_Owner_s_Profiles_Name_for_Case.split(';') : new List<String>();
            List<sObject> sObjList = new List<sObject>();
            List<User> userList = new List<User>();
            String var='%'+name+'%';
            List<Group> LisGrp = new List<Group>([select Id,Name from Group where Type = 'Queue' AND Name like:var]);
            if(!LisGrp.isEmpty()){
                sObjList.addAll(LisGrp);
            }
            if(!profileNameList.isEmpty()){
                userList=[select Id,Name,Profile.Name from User where isActive=true and Name like:var AND Profile.Name IN:profileNameList];
                if(!userList.isEmpty())
                    sObjList.addAll(userList);
            }
            
            if(sObjList != Null && sObjList.size() > 0){
                br.dataList=sObjList;
                br.message='Success';
                br.status='Success';
                br.code=200;
            }
        }
        catch(Exception e){br.message=e.getMessage();br.status='Error';br.code=0;
                          }
        System.debug(br);
        return br;
    }
    /**
Author: Sunit kumar chand
Company: Techmatrix
Description: This funcion is used to check logged in user on basis of profile
Inputs: 
Returns: BasicReturn with a List of User
History:
================
1.0     08/11/2019                 Sunit         Initial Version
1.1    27/10/2020,   08:37:23 PM   Shalini Singh
1.2    28/10/2020    02:02:35 PM   Shalini Singh 
*/    
    @AuraEnabled
    public static BasicReturn checkLoggedinUserType(String recordId)
    {
        
        BasicReturn br=new BasicReturn();
        try
        {    
            List<String> profileNameList = system.label.Allow_Change_Owner_ProfileName_for_Case != null ?
                system.label.Allow_Change_Owner_ProfileName_for_Case.split(';') : new List<String>();
            
            List<Case> caseList = [Select id, OwnerId from Case Where Id =:recordId];
            
            List<User> userList = [select Id, Name, contact.accountId, profile.name from User 
                                   where  Id=:UserInfo.getUserId()];
            
            if(userList != Null && userList.size() > 0){
                br.dataList = new List<User>();
                br.message = 'Success';
                br.status = 'Success';
                br.code = 200;
                if(!profileNameList.isEmpty() && profileNameList.contains(userList[0].profile.name)){      
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
Description: This funcion is used change owner of a particular Case
Inputs: EnquiryId String,UserId string
Returns: BasicReturn with a List of User
History:
================
1.0     08/11/2019     Sunit     Initial Version
1.1    27/10/2020,  08:37:23 PM   Shalini Singh
*/   
    @AuraEnabled
    public static BasicReturn changeOwner(String id,String ownerId)
    {
        BasicReturn br=new BasicReturn();
        
        try
        {
            Case cs=new Case();
            cs.Id=id;
            cs.OwnerId=ownerId;
            update cs;
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