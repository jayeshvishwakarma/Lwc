/**
 * @File Name          : AddLineItemCtrl.cls
 * @Description        : This class is used to calculate the EMI 
 * @Author             : Anuj Kumar
 * @Group              : 
 * @Last Modified By   : Anuj Kumar
 * @Last Modified On   : 05/08/2019 10:15 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    05/08/2019 11:17 AM          Anuj Kumar            Initial Version
**/

public class EmiCalculatorCtrl {
    
    @AuraEnabled(cacheable=true)
    //This method returns DealerMapCode 
    public static String retrieveEnquiryDetails(String enquiryId){
        String dealerMapCode = '';
        //Null Check
        if(enquiryId != null){
            //Fetching the records based on Enquiry Id
            List<Opportunity> opportunityList = [Select Id, Dealership__c, Dealership__r.Dealer_Map_Code__c
                        from Opportunity
                        where Id =: enquiryId];
            //Passing the value of Dealer Map Code 
            if(opportunityList != Null && opportunityList.size() > 0 && opportunityList[0].Dealership__c != Null){
                dealerMapCode = opportunityList[0].Dealership__r.Dealer_Map_Code__c;
            }
        }
        return dealerMapCode;
    }
    
    @AuraEnabled(cacheable=true)
    //This method is used to fetch and return Financier Records
    public static List<Financier__c> queryFinancierRecords(String name, String dealerMapCode){
        List<Financier__c> financierList = new List<Financier__c>();
        if(string.isNotBlank(name)){
            //Decalring String Variable
            string nameData = '%'+name.trim()+'%';
            
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
    
    @auraEnabled(cacheable=true)
    //This method is used to retrieve the Users
    Public static CheckValidUser RetrieveUser(){
        //This obj is used to check the valid user 
        CheckValidUser obj = new CheckValidUser();
        obj.hideComponent = false;
        
        String userId = Userinfo.getUserId();
        String profileId = Userinfo.getProfileId();
        //null check 
        if(profileId != null){
            //fetching profile
            list<profile> profileList = new list<profile>([SELECT name from profile where id =: profileId]);
            //if profile list is not null than pass the name 
            String ProfileName = (profileList.size()>0)?profileList[0].name : '';
            //Name condition check
            if(ProfileName == system.label.Hostess_Profile_Name){
                obj.hideComponent = true;
            }
            return obj;
        }
        else
            return obj;
     }
    
    public class CheckValidUser{
        @auraEnabled public boolean hideComponent;
    }
}