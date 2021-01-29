/**
* @File Name          : SurveyTakerCTITriggerHandler.cls
* @Description        : Trigger handler class for SurveyTakerCTITrigger
* @Author             :
* @Group              :
* @Last Modified By   : Saloni Gupta
* @Last Modified On   : 26-11-2020
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0      26-11-2020                  Saloni               Initial Version
*/
public without sharing class SurveyTakerCTITriggerHandler extends TriggerHandler {


    private list<Survey_Taker_CTI__c> newTakerList; //Used to store the list of new Cases
    private map<id, Survey_Taker_CTI__c> oldTakerMap; //Used to store the map of old Cases
    private Map<Id, Survey_Taker_CTI__c> newTakerMap; //Used to store the map of new Case Actions
    private static Map<String,list<Survey_Config__mdt>> mapOfTypeVsFieldMapping ;// used to store all the config values


    public SurveyTakerCTITriggerHandler() {
        this.newTakerList = (List<Survey_Taker_CTI__c>) Trigger.new;
        this.oldTakerMap = (map<id, Survey_Taker_CTI__c>) Trigger.oldmap;
        this.newTakerMap = (Map<Id, Survey_Taker_CTI__c>) Trigger.newMap;

        mapOfTypeVsFieldMapping = new Map<String,list<Survey_Config__mdt>>();
        //Populate the config value only once.
        for (Survey_Config__mdt surveyConfig : [SELECT MasterLabel, Destination_Field__c, Source_Field__c ,Type__c 
                    FROM Survey_Config__mdt where Object_Name__c = 'Survey_Taker_CTI__c']) {
            if(!mapOfTypeVsFieldMapping.containsKey(surveyConfig.Type__c.toLowerCase())){
                mapOfTypeVsFieldMapping.put(surveyConfig.Type__c.toLowerCase(),new list<Survey_Config__mdt>());
            }
            mapOfTypeVsFieldMapping.get(surveyConfig.Type__c.toLowerCase()).add(surveyConfig);
        }


    }

    public override void beforeInsert() {
        recordTypeMapping();
        fieldMapping();
    }
    public override void beforeUpdate() {
     //   fieldMapping();
    }
    public override void afterInsert() {
    }
    public override void afterupdate() {
    }

    /**
        Author: Saloni Gupta
        Company: Techmatrix
        Description: Method to update Recordtype of the survey taker based on Survey's Type
        Returns: void
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        26/11/2020                Saloni                  Initial Version
    **/
    public void recordTypeMapping(){
        Map<Id,String> surveyIdVsType = new Map<Id,String>();
        Map<String,String> rtNameVsId = new Map<String,String>();

        Id surveyRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Survey').getRecordTypeId();
        system.debug('surveyRecordTypeId@== '+surveyRecordTypeId);
        System.debug('====++++++++++'+[select Id, Name, Type from Campaign where RecordTypeId =:surveyRecordTypeId]);
        for(Campaign survey : [select Id, Name, Type from Campaign where RecordTypeId =:surveyRecordTypeId]){
            System.debug('===========================>>>>>>>>>>>>>>>>>>>>>>>>>'+survey);
            if(survey.Type != null){
                surveyIdVsType.put(survey.Id, (survey.Type).toLowerCase());
            }
        }

        for(RecordType rtObj : [select Id,Name from RecordType where sObjectType='Survey_Taker_CTI__c']){
            rtNameVsId.put((rtObj.Name).toLowerCase(),rtObj.Id);
        }

        for(Survey_Taker_CTI__c taker : newTakerList){
            if(surveyIdVsType.containsKey(taker.Survey__c) && rtNameVsId.containsKey(surveyIdVsType.get(taker.Survey__c))){
                taker.RecordTypeId = rtNameVsId.get(surveyIdVsType.get(taker.Survey__c));
            }
        }
    }

    /**
        Author: Saloni Gupta
        Company: Techmatrix
        Description: Method to update fields of the survey taker based on Survey_Config__mdt's source and target field
        Returns: void
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        26/11/2020                Saloni                  Initial Version
    **/
    public void fieldMapping(){

        Map<Id,String> surveyIdVsType = new Map<Id,String>();

        Id surveyRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Survey').getRecordTypeId();

        for(Campaign survey : [select Id, Name, Type from Campaign where RecordTypeId =:surveyRecordTypeId]){
            if(survey.Type != null){
                surveyIdVsType.put(survey.Id, (survey.Type).toLowerCase());
            }
        }


        for(Survey_Taker_CTI__c taker : newTakerList){
            String surveyName = '';
            System.debug('---------------'+ taker);
            if(surveyIdVsType.containsKey(taker.Survey__c)){
                surveyName = surveyIdVsType.get(taker.Survey__c);
                populateReportingFields(taker, mapOfTypeVsFieldMapping.get(surveyName));
            }
        }
    }

    public void populateReportingFields(Survey_Taker_CTI__c taker,list<Survey_Config__mdt> configData ){
        if(configData != null){
            for(Survey_Config__mdt config :configData){
                    if(taker.get(config.Source_Field__c) != null){
                        taker.put(config.Destination_Field__c,taker.get(config.Source_Field__c));
                    }
            }
        }

    }


}