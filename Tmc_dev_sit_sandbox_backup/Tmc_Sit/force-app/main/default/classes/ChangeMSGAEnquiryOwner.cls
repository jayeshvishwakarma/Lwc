/**
* @File Name          : ChangeMSGAEnquiryOwner.cls
* @Description        : This class is used for Enquiry Change Owner for Accessory Managers
* @Author             : Rohit Gupta
* @Group              : 
* @Last Modified On   : 
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 
**/
public without sharing class ChangeMSGAEnquiryOwner {
    
    @AuraEnabled(cacheable=true)
    public static BasicReturn getUserList(String dealerId, String name) {
        System.debug('Inside getUserList');
        System.debug(dealerId);
        BasicReturn br=new BasicReturn();
        try
        {
            String var='%'+name+'%';
            List<User> userList=[select Id,Name,toLabel(Designation__c),Profile.Name from User where IsPortalEnabled=true and contact.accountId=:dealerId and isActive=true and Name like:var];
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
    
    @AuraEnabled(cacheable = true)    
    public static WrapperObj fetchDetails(){
        WrapperObj wo =new WrapperObj();
        List<Opportunity> enquiryList;
        System.debug('Inside' + UserInfo.getUserId());
        List<User> userList = [select Id, Name, contact.accountId, Designation__c, profile.name from User 
                               where Id=:UserInfo.getUserId()];//IsPortalEnabled=true and 
        System.debug('Designation '+ userList);
        if(userList[0].Designation__c == 'ACM'){
            enquiryList = new List<Opportunity>();
            enquiryList = [SELECT id, Name, CreatedDate, DMS_Enquiry_Name__c, CloseDate FROM Opportunity WHERE ownerId =: UserInfo.getUserId() and StageName = 'Open'];
            wo.enquiryList = enquiryList;
            wo.userInfo = userList[0];
            wo.message = 'Success';
        }else{
            wo.enquiryList = new List<Opportunity>();
            wo.userInfo = userList[0];
            wo.message = 'False';
        }                
        return wo;
    }
    
    @AuraEnabled
    public static string updateEnqOwner(String stringData,Id ownerId){
        try{
            System.debug('stringData '+stringData);
            System.debug('ownerId '+ownerId);
            list<Id> oppIdList = (list<Id>)JSON.deserialize(stringData, list<Id>.class);
            list<Opportunity> oppToUpdate = new list<Opportunity>();
            list<opportunityTeamMember> oppTeamList = new list<opportunityTeamMember>();
            
            for(opportunity opp : [SELECT id,OwnerId from opportunity where Id in :oppIdList]){
                opp.ownerId = ownerId;
                oppToUpdate.add(opp);
            }
            
            if(oppToUpdate.size()>0)
                update oppToUpdate;
            
            return 'SUCCESS';
        }catch(Exception ex){
            System.debug('Error '+ex.getMessage());
            String err = ex.getMessage();
            return err;
        }
        
    }
    
    public class WrapperObj {
        @AuraEnabled public List<Opportunity> enquiryList;
        @AuraEnabled public User userInfo;
        @AuraEnabled public String message;
    }
}