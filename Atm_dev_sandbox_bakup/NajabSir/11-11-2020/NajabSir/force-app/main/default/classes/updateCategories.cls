public without sharing class updateCategories implements Database.Batchable<sObject>,Database.Stateful{


    public string query = '';
    public string state = '';

    private updateCategoryies serviceHelper = new updateCategoryies();


    public updateCategories(string query, string state){
        this.query = query;
        this.state = state;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Case> scope){
        list<Case> casesToBeUpdated = new list<Case>();

        casesToBeUpdated = serviceHelper.updatePrimaryCategory(scope,state);
        system.debug('>>>>>>>'+casesToBeUpdated[0].Primary_Category_ID__c);
        update scope;

    }

    public void finish(Database.BatchableContext BC){

    }



    //====================================

    // string query = 'select id,Primary_Category__c,Case_Type__c,Case_Stage__c,Dealer_Name__r.Stakeholder_Hierarchy__c,Business_Area__c,Channel__c,Latest_Escalation_Date__c,Latest_Escalation_Level__c ,Secondary_Category__c,Tertiary_Category__c,Primary_Category_ID__c,Secondary_Category_ID__c,Tertiary_Category_Id__c,MSCRM_DM_Error__c, Dealer_Name__r.Nexa_SRV_TSM__c, Dealer_Name__r.Arena_SRV_TSM__c, Dealer_Name__r.Territory_Sales_Manager__c, Dealer_Name__r.DMS_Primaries__c,Dealer_Name__c from case where MSCRM_Complaint_No__c  != null AND Status = \'Open\' ';
    //string state = 'Processed';

    //updateCategories abc = new updateCategories(query,state);
    //database.executebatch(abc, 100);

}