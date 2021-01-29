/**
    * @File Name          : SurveyResponseTriggerHandler
    * @Description        : Trigger Handler class for Survey Question Response Trigger
    * @Author             : 
    * @Group              : 
    * @Last Modified By   : Prabhat Sharma
    * @Last Modified On   : 17/10/2019, 12:12:16 PM
    * @Modification Log   : 
    *==============================================================================
    * Ver         Date                     Author                Modification
    *==============================================================================
    * 1.0    17/10/2019, 03:14:54 PM      Prabhat Sharma         Initial Version
    **/
public class SurveyResponseTriggerHandler extends Triggerhandler {
    
    //Variable for trigger new list
    public list<SurveyQuestionResponse__c> surveyQuesResList;
    
    //Constructor -- assigns all the trigger context variables objects into class variables defined above
    public SurveyResponseTriggerHandler(){
        surveyQuesResList = (list<SurveyQuestionResponse__c>)trigger.new;
    }
    
    //Methods executions After Insert
    public override void Afterinsert(){
        //This method is Used to check and create MCCommunication if SurveyQuestionResponse__c response is negative
        CheckResponse();
    }
    
    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to check the response for Test Drive Survey. If negative, create an MC Communicaiton Record to notify the DSE.
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.0     17 Oct 2019  Prabhat Sharma  Initial Version
    **/
    
    public void CheckResponse(){
        //This list stores the data of Test_Drive_Survey_MC_Communication__c Custom Setting 
        Test_Drive_Survey_SFMC__c testDriveList = Test_Drive_Survey_SFMC__c.getInstance();
        //This set stores the Test Drive Id
        set<id> tdIdSet = new set<id>();
        //This map stores the Master-Detail relationship values with Id as key
        map<id,SurveyQuestionResponse__c> surveyQuesMap=new map<id,SurveyQuestionResponse__c>([SELECT id ,SurveyTaker__r.Survey__r.Name,Survey_Question__r.Question__c,SurveyTaker__r.Test_Drive__c from SurveyQuestionResponse__c where id in: surveyQuesResList]);
       
        //loop through Trigger List
        for(SurveyQuestionResponse__c sqr : surveyQuesResList){
            //Contains Check
            if(surveyQuesMap.containskey(sqr.id)){
               if(testDriveList.Survey_Name__c == surveyQuesMap.get(sqr.id).SurveyTaker__r.Survey__r.Name && testDriveList.Question__c == surveyQuesMap.get(sqr.id).Survey_Question__r.Question__c && testDriveList.Response__c == sqr.response__c && string.isNotBlank(surveyQuesMap.get(sqr.id).SurveyTaker__r.Test_Drive__c)){
                    //add the Test Drive Id in set if condition is true
                    tdIdSet.add(surveyQuesMap.get(sqr.id).SurveyTaker__r.Test_Drive__c);
                } 
            }
        }
        //Null and size Check of set
        if(tdIdSet!=null&& tdIdSet.size()>0)
            //Create MC Communication record by calling GenerateFilePublicURL class ConstantsUtility.OPPORTUNITY
            GenerateFilePublicURL.CreateMCRecord(ConstantsUtility.TD_SURVEY_FEEDBACK,tdIdSet,ConstantsUtility.TEST_DRIVE,'');
    }
    
}