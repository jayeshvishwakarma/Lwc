/**
* @File Name          : SurveyQuestionsLWCController.cls
* @Description        : Apex class for generating Delivery checklist survey questionnaire
* @Author             : 
* @Group              : 
* @Last Modified By   : Prabhat Sharma
* @Last Modified On   : 16/9/2019, 3:12:16 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    16/09/2019, 9:14:54 PM                                Initial Version 
**/

public without sharing class GenerateDeliveryChecklistController {

    
     
    private static Boolean isValidUser = isTLorManagerOrAdmin();
    
    
    
    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method creates a wrapper of delivery checklist wrapper and show 
        Returns: void
        History:
        ================
        1.0     16 Sept 2019      Prabhat Sharma    Initial Version
    **/
    @AuraEnabled
    public static list<GenerateDeliveryChecklistController.deliverChecklistSurveyWrapper> deliveryCheckListQuestions(String enquiryId){
        
        //List of wrapper class
        list<GenerateDeliveryChecklistController.deliverChecklistSurveyWrapper> surveyQuestionWrapList = new list<GenerateDeliveryChecklistController.deliverChecklistSurveyWrapper>();
        
        //Map of Id of Survey Question Resposne
        Map<String,SurveyQuestionResponse__c> existingSurveyMap = new Map<String,SurveyQuestionResponse__c>();
        //Fill in the already answered
        existingSurveyMap = checkExistingSurvey(enquiryId);
        
        //Counter to show sr no on LWC
        Integer counter = 1;
        
        String userChannel = [SELECT Id,Channel__c FROM User WHERE Id=:UserInfo.getUserId()].Channel__c;
        
        String surveyName = (userChannel == ConstantsUtility.COMMERCIAL_LINEOFBUSINESS) ? label.Commercial_Delivery_Checklist : label.DeliveryChecklistSurvey;
        
        if(isValidUser || (!isValidUser && existingSurveyMap!=null && existingSurveyMap.size()>0)){
            //Loop thorugh all survey questions and create wrapper 
            for(Survey_Question__c  survey : [Select id,Choices__c,OrderNumber__c,Question__c from 
                                                Survey_Question__c where Survey__r.Name=: surveyName
                                                ORDER BY OrderNumber__c ASC]){

                    GenerateDeliveryChecklistController.deliverChecklistSurveyWrapper swrap = new GenerateDeliveryChecklistController.deliverChecklistSurveyWrapper();
                    swrap.questionName = survey.Question__c;
                    swrap.questionId = survey.Id;
                    
                    if(String.isNotBlank(survey.Choices__c)){
                        for(String str : survey.Choices__c.split('\n')){
                            GenerateDeliveryChecklistController.optionMappingWrapper optWrap = new GenerateDeliveryChecklistController.optionMappingWrapper();
                            optWrap.dataValue = str;
                            optWrap.dataId = survey.Id+str;
                            optWrap.dataId = optWrap.dataId.trim(); // Trim to remove any white spaces
                            
                            //Mark radio buttons checked
                            if(existingSurveyMap!=null && existingSurveyMap.size()>0){ 
                                if(existingSurveyMap.containsKey(swrap.questionId) && existingSurveyMap.get(swrap.questionId).Response__c!=null && str.trim()==existingSurveyMap.get(swrap.questionId).Response__c){
                                    optWrap.isChecked = true;
                                }
                            } 

                            swrap.optionSet.add(optWrap);
                        }
                    } 
                    
                    //Check existing surveys and map the ID of the response to the attribute in wrapper
                    if(existingSurveyMap!=null && existingSurveyMap.size()>0){
                        if(existingSurveyMap.containsKey(swrap.questionId) && existingSurveyMap.get(swrap.questionId)!=null){
                            swrap.answer = existingSurveyMap.get(swrap.questionId).Response__c;
                            swrap.dateExpected = existingSurveyMap.get(swrap.questionId).Date_Expected__c;
                            swrap.surveyResponseId = existingSurveyMap.get(swrap.questionId).Id;
                            swrap.remarks = existingSurveyMap.get(swrap.questionId).Remarks__c;
                        }
                        swrap.isDisabled = !isValidUser ? true : false;
                    }
                    //Add the srno to the questions
                    swrap.srno=counter; 
                    
                    surveyQuestionWrapList.add(swrap);
                    counter++;

            }
        }
        
        //Return list of survey wrapper questions
        return surveyQuestionWrapList;
    }



    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to check current user's profile name
        Returns: void
        History:
        ================
        1.0     30th Oct 2019      Prabhat Sharma    Initial Version
    **/
    public static Boolean  isTLorManagerOrAdmin(){
        Boolean result = false;
        set<String> validProfiles = new set<String>();
        validProfiles.addAll(label.Delivery_Checklist_Survey_Users.split(';'));
        //Query Profile Name of the User
        String profileName = [SELECT Id,Profile.Name FROM User WHERE Id=:UserInfo.getUserId()].Profile.Name;
        
        //Check if the user's profile is allowed to create Delivery Checklist
        if(validProfiles.contains(profileName)){
            result = true;
        }
        //Return result
        return result;
    }


    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method creates a wrapper of delivery checklist wrapper and show 
        Returns: void
        History:
        ================
        1.0     16 Sept 2019      Prabhat Sharma    Initial Version
    **/
    public static map<String,SurveyQuestionResponse__c> checkExistingSurvey(String enquiryId){
        map<String,SurveyQuestionResponse__c> surveyResponseMap = new map<String,SurveyQuestionResponse__c>();
        
        String userChannel = [SELECT Id,Channel__c FROM User WHERE Id=:UserInfo.getUserId()].Channel__c;
        
        String surveyName = (userChannel == ConstantsUtility.COMMERCIAL_LINEOFBUSINESS) ? label.Commercial_Delivery_Checklist : label.DeliveryChecklistSurvey;
        
        //query only on Delivery Checklist Survey
        List<SurveyTaker__c> existingSurvey = new list<SurveyTaker__c>([SELECT Id FROM SurveyTaker__c WHERE Survey__r.Name=:surveyName and EnquiryID__c=:enquiryId]);
        if(existingSurvey.size()>0){
            for(SurveyQuestionResponse__c resp : [SELECT Id,Response__c,Date_Expected__c,Survey_Question__c,Remarks__c FROM  SurveyQuestionResponse__c
                                                  WHERE SurveyTaker__c=:existingSurvey[0].Id]){
                                                      surveyResponseMap.put(resp.Survey_Question__c,resp);
                                                  }
            return surveyResponseMap;
        } 
        else{
            return null;
        }
    }



    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to create/update Delivery Checklist
        Returns: void
        History:
        ================
        1.0     16 Sept 2019      Prabhat Sharma    Initial Version
    **/
    @AuraEnabled
    public static string saveSurveyResponse(String enquiryId, String data, String btnLabel){
        try{
            if(isValidUser){
                
                // R1.2 Commercial Development
                String userChannel = [SELECT Id,Channel__c FROM User WHERE Id=:UserInfo.getUserId()].Channel__c;
                String surveyId = (userChannel == ConstantsUtility.COMMERCIAL_LINEOFBUSINESS) ? label.Commercial_Delivery_Checklist_Survey_Id : label.Deliver_Checklist_Survey_ID;
                
                //Deserializing JSON
                List<GenerateDeliveryChecklistController.deliverChecklistSurveyWrapper> listwrap = (List<GenerateDeliveryChecklistController.deliverChecklistSurveyWrapper>)System.JSON.deserialize(data,List< GenerateDeliveryChecklistController.deliverChecklistSurveyWrapper>.class);
                
                //Query Existing Survey if exists
                List<SurveyTaker__c> existingSurvey = new list<SurveyTaker__c>([SELECT Id FROM SurveyTaker__c WHERE EnquiryID__c=:enquiryId]);
                
                //Insert Survey taker record
                SurveyTaker__c st = new SurveyTaker__c(); 
                st.Survey__c = surveyId;
                st.Taken__c = 'true';
                st.EnquiryID__c=enquiryId; 
                st.User__c = UserInfo.getUserId();
                
                //Check existing survey
                if(existingSurvey.size()>0){
                    st.Id = existingSurvey[0].Id;
                }
                
                //Upsert the details on Survey Taker record
                upsert st Id;  
                
                
                List<SurveyQuestionResponse__c> surveyResponseToUpsert = new list<SurveyQuestionResponse__c>();
                
                for(GenerateDeliveryChecklistController.deliverChecklistSurveyWrapper wrap : listwrap){
                    SurveyQuestionResponse__c response = new SurveyQuestionResponse__c();
                    response.SurveyTaker__c = st.Id;
                    response.Survey_Question__c = wrap.questionId;
                    response.Response__c = String.isNotBlank(wrap.answer) ? wrap.answer :'';
                    response.Date_Expected__c = wrap.dateExpected!=null ? wrap.dateExpected : null;
                    response.Remarks__c = String.isNotblank(wrap.remarks)? wrap.remarks : '';
                    response.Id = String.isNotBlank(wrap.surveyResponseId) ? wrap.surveyResponseId : null;
                    surveyResponseToUpsert.add(response);
                }
                
                if(surveyResponseToUpsert.size()>0){
                    upsert surveyResponseToUpsert Id;
                }
            }

            //Check if Save and Send Button has been clicked
            if(btnLabel==ConstantsUtility.BTN_LABEL_CONST){
                generateChecklistPDF(enquiryId,Network.getNetworkId());
            }
            
            return 'SUCCESS';
        }catch(Exception e){ExceptionHandler.LogError('GenerateDeliveryChecklist', e.getMessage(),'Opportunity',enquiryId, null); return 'An unexpected error has occurred. Please contact your Salesforce Administrator';
        }
    }
    
    
    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to create Delivery Checklist pdf
        Returns: void
        History:
        ================
        1.0     16 Sept 2019      Prabhat Sharma    Initial Version
    **/
    @future(callout = true)
    public static void generateChecklistPDF(String enquiryId, String networkId){
        
        //Creata a PDF file as an attachment for the enquiry
        BookingBCRFormPDFController.downloadBCRDocument(enquiryId,
                                                        ConstantsUtility.BTN_LABEL_CONST,
                                                        ConstantsUtility.DELIVERY_PAGE_CONST,
                                                        ConstantsUtility.FILE_NAME_CONST,
                                                        ConstantsUtility.FIELD_CONST,
                                                        networkId
                                                        );
        
        
    }

    //Wrapper class to capture survey response and also show survey questions
    public class deliverChecklistSurveyWrapper{
        @AuraEnabled public String questionName;
        @AuraEnabled public String questionId;
        @AuraEnabled public String surveyResponseId;
        @AuraEnabled public String answer;
        @AuraEnabled public Date dateExpected;
        @AuraEnabled public String remarks;
        @AuraEnabled public List<GenerateDeliveryChecklistController.optionMappingWrapper> optionSet;
        @AuraEnabled public Integer srno; 
        @AuraEnabled public Boolean isDisabled; 
        

        public deliverChecklistSurveyWrapper(){ 
            optionSet = new list<GenerateDeliveryChecklistController.optionMappingWrapper>();
            srno = 0;
            answer='';
            surveyResponseId ='';
            isDisabled = false;
        }
    }

    //Wrapper class to show options 
    public class optionMappingWrapper{
        @AuraEnabled public String dataId;
        @AuraEnabled public String dataValue;
        @AuraEnabled public Boolean isChecked = false;
    }
}