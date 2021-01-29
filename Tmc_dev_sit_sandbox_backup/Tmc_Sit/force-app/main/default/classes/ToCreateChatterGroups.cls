/**
    * @Autho:- Rohit Gupta
    * @Company-: Techmatrix Consulting
    * @Description-: Apex Class to insert All Chatter Groups in one go
    * =============================================================
    * Version   Date            Author      Modification
    * =============================================================
    * 1.0       10 Jun 2020    Rohit     Intial Version
    **/
public Without Sharing class ToCreateChatterGroups {
    public static void createChatterGroup(){
        try{
            Set<String> cGpSetForPartnerUsers = new Set<String>();
            Set<String> cGpSetForInternalUsers = new Set<String>();        
            List<CollaborationGroup> cGroupList = new List<CollaborationGroup>();
            
            List<String> cGroup2Names = System.label.Chatter_Group_2 != null ? System.label.Chatter_Group_2.split(','): new List<String>();
            List<String> cGroup3Names = System.label.All_RO_Sales_User_Group != null ? System.label.All_RO_Sales_User_Group.split(','): new List<String>();
            List<String> cGroup4Names = System.label.All_Regional_Employees_Group != null ? System.label.All_Regional_Employees_Group.split(','): new List<String>();
            
            for(String str: cGroup2Names){
                cGpSetForPartnerUsers.add(str);
            }
            
            Network nk = [select id from Network where Name like 'Dealer%' limit 1];
            for(String str: cGpSetForPartnerUsers){            
                CollaborationGroup cGroup = new CollaborationGroup();
                cGroup.NetworkId = nk.Id;
                cGroup.Name = str;
                cGroup.CollaborationType = 'Unlisted';
                cGroupList.add(cGroup);            
            }
            
            for(String str: cGroup3Names){
                cGpSetForInternalUsers.add(str);
            }
            for(String str: cGroup4Names){
                cGpSetForInternalUsers.add(str);
            }
            for(String str: cGpSetForInternalUsers){            
                CollaborationGroup cGroup = new CollaborationGroup();            
                cGroup.Name = str;
                cGroup.CollaborationType = 'Unlisted';
                cGroupList.add(cGroup);            
            }
            System.debug('cGroupList '+cGroupList.size());
            if(cGroupList.size() > 0){
                insert cGroupList;
            }
        }catch(Exception ex){
            
        }        
    }            
}