/**
* @File Name          : InfluencerTriggerHandler.cls
* @Description        : Trigger handler class for Influencer Trigger
* @Author             : Anuj Kumar
* @Group              : 
* @Last Modified By   : 
* @Last Modified On   : 1/16/2020, 9:23:34 AM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    7/05/2019, 9:14:54 PM        Anuj Kumar              Initial Version

**/


public without sharing class InfluencerTriggerHandler extends TriggerHandler{
    private Map<Id, Influencer__c> newInfMap; //Used to store the map of new Influencers
    private list<Influencer__c> newInfList; // Used to store the list of new Influencers
    private Map<Id, Influencer__c> oldInfMap; // Used to store Map of old Influencers 
    
    
    OpportunityTriggerHelper oppHelper;
    
    //Constructor -- assigns all the trigger context variables objects into class variables defined above
    public InfluencerTriggerHandler() {
        this.newInfMap = (Map<Id, Influencer__c>) Trigger.newMap;
        this.newInfList = (List<Influencer__c>) Trigger.new;
        this.oldInfMap = (Map<Id, Influencer__c>) Trigger.oldMap; 
        
        //Instantiate Helper Class
        oppHelper = new OpportunityTriggerHelper();
    }
    
    //Methods executions before Insert of Influencer 
    public override void beforeInsert() {
        // It will update Influencer Details by DealerShip(Account) fields LOC_CD,Parent_Group, Dealer_Map_CD and current user's field MSPIN.
        setInfluencerDetails();
    }   
    
    //Methods executions before update of Influencer 
    public override void beforeUpdate() {
        // It will update Influencer Details by DealerShip(Account) fields LOC_CD,Parent_Group, Dealer_Map_CD and current user's field MSPIN.
        setInfluencerDetails();
    }
    
    //Method executions after insert of Influencer
    public override void afterInsert(){

    }
    
    //Methods executions after update of Influencer 
    public override void afterUpdate() {
    }
    
    
    public void setInfluencerDetails(){
        
        List<User> usrList = [SELECT Id, MSPIN__c, contact.AccountId, contact.Account.Dealer_Location__c, 
                                contact.Account.Parent_Group__c, contact.Account.Dealer_Map_Code__c 
                        FROM User WHERE ID =:userInfo.getUserId() AND UserType = 'PowerPartner'];
    
        //Variable to store Dealership Ids
        set<Id> dealershipIds = new set<Id>();
        
        //Loop through trigger new and get the dealerships Ids
        for (Influencer__c inf : this.newInfList){
            if(inf.Dealership__c == null && !usrList.isEmpty()){
                inf.Dealership__c = usrList[0].contact.AccountId;
                
                String data = ConstantsUtility.OPEN_CURLY_BRACES;
                //Dealer Location code
                data+= oppHelper.createKeyValueStructure('LOC_CD', usrList[0].contact.Account.Dealer_Location__c);
                //Dealer Parent Group
                data+= oppHelper.createKeyValueStructure('Parent_Group', usrList[0].contact.Account.Parent_Group__c);
                //Dealer Map Code
                data+= oppHelper.createKeyValueStructure('Dealer_Map_CD', usrList[0].contact.Account.Dealer_Map_Code__c);
                //Dealer SFDC ID
                data+= oppHelper.createKeyValueStructure('Dealer_SFDC_Id', usrList[0].contact.AccountId);
                //Current User MSPIN
                data+= oppHelper.createKeyValueStructure('MSPIN', usrList[0].MSPIN__c);
                //Current User Id
                data+= oppHelper.createKeyValueStructure('USER_SFDC_ID', usrList[0].Id);
                data = data.removeEnd(ConstantsUtility.COMMA);
                data+= ConstantsUtility.CLOSE_CURLY_BRACES;
                inf.Influence_Details__c = data;
            }else if(inf.Dealership__c != null){
                dealershipIds.add(inf.Dealership__c);
            }
        }
        
        if(dealershipIds.size()>0){
            //Query the dealership details
            Map<Id,Account> dealershipMap = new Map<Id,Account>([SELECT Id, Dealer_Location__c, Parent_Group__c, Dealer_Map_Code__c
                                                                 FROM Account WHERE Id in: dealershipIds]);
           
            //Loop through trigger new
            for(Influencer__c inf :this.newInfList){
                
                if(inf.Dealership__c  <> Null && dealershipMap.containsKey(inf.Dealership__c) && !usrList.isEmpty()){
                    String data = ConstantsUtility.OPEN_CURLY_BRACES;
                    //Dealer Location code
                    data+= oppHelper.createKeyValueStructure('LOC_CD', dealershipMap.get(inf.Dealership__c).Dealer_Location__c);
                    //Dealer Parent Group
                    data+= oppHelper.createKeyValueStructure('Parent_Group', dealershipMap.get(inf.Dealership__c).Parent_Group__c);
                    //Dealer Map Code
                    data+= oppHelper.createKeyValueStructure('Dealer_Map_CD', dealershipMap.get(inf.Dealership__c).Dealer_Map_Code__c);
                    //Dealer SFDC ID
                    data+= oppHelper.createKeyValueStructure('Dealer_SFDC_Id', inf.Dealership__c);
                    //Current User MSPIN
                    data+= oppHelper.createKeyValueStructure('MSPIN', usrList[0].MSPIN__c);
                    //Current User Id
                    data+= oppHelper.createKeyValueStructure('USER_SFDC_ID', usrList[0].Id);
                    data = data.removeEnd(ConstantsUtility.COMMA);
                    data+= ConstantsUtility.CLOSE_CURLY_BRACES;
                    inf.Influence_Details__c = data;
                }
            }
        }
        
    }
    
}