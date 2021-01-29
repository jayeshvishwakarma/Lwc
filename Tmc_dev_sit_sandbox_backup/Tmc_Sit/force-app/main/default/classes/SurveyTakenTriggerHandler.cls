/**
 * @File Name          : SurveyTakenTriggerHandler.cls
 * @Description        : Trigger handler for Survey taken trigger
 * @Author             :  
 * @Group              : 
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 9/15/2019, 9:09:36 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    10/09/2019, 6:52:23 AM       Prabhat Sharma            Initial Version
**/

//CODE REVIEWED BY: Prabhat Sharma

public without sharing class SurveyTakenTriggerHandler extends TriggerHandler{
    
    // Used to store the list of new Survey Takens
    private list<SurveyTaker__c> newSurveyTakerList;
    
    //Constructor -- assigns all the trigger context variables objects into class variables defined above
    public SurveyTakenTriggerHandler(){
        this.newSurveyTakerList = (list<SurveyTaker__c>)trigger.new;
    }
    
    //Methods executions before Insert of Enquiry 
    public override void beforeInsert(){
        //Populate the lookup fields when EnquiryID__c field of SurveyTaken Record is not empty
        assignLookupFields();
    }
     
    /**
       Author: Prabhat Sharma
       Company: Techmatrix
       Description: Method to assign lookup field values on Survey Taken record
       Inputs: none
       Returns: none
       History:
       ================
       1.0     10/09/2019      Prabhat Sharma     Initial Version
    **/
    public void assignLookupFields(){
        //Creating set for containing the EnquiryID__c field value
        set<string> surveytakenSet = new set<string>();
        list<Id> opptysId = new list<Id>();
       Id surveyId = [select Id, Name from Survey__c where Name='Showroom Feedback Survey'].get(0).Id;
        for(SurveyTaker__c st : this.newSurveyTakerList){
            if(string.isNotBlank(st.EnquiryID__c)){
                surveytakenSet.add(st.EnquiryID__c);
            }
            if(st.Survey__c == surveyId){
                opptysId.add(st.EnquiryID__c);
            }
          
        }
        
        //Create a map to fetch the record from opportunity related to EnquiryID__c field value
        map<Id,opportunity> oppmap = new map<Id, opportunity>([SELECT id, Dealership__c, Customer__c,Feedback_Taken__c 
                                                               from opportunity
                                                               Where id in:surveytakenSet]);

        List<Opportunity> opptysList = [SELECT id, Dealership__c, Customer__c,Feedback_Taken__c 
                                                               from opportunity
                                                               Where id in:opptysId];

        for(Opportunity opp: opptysList){
            opp.Feedback_Taken__c = 'Showroom Feedback Survey';
        }                             
       
        //Create or update Lookup Fields using map
        for(SurveyTaker__c st : this.newSurveyTakerList){
            if(oppmap.containsKey(st.EnquiryID__c)){
                st.Enquiry__c = oppmap.get(st.EnquiryID__c).Id;
                st.Dealer__c = oppmap.get(st.EnquiryID__c).Dealership__c;
                st.Customer__c = oppmap.get(st.EnquiryID__c).Customer__c; 
            }
        }
    }

}