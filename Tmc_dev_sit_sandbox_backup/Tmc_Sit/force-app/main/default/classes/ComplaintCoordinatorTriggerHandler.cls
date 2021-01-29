/**
* @File Name          : CategoryTriggerHandler.cls
* @Description        : Trigger handler class for Category Object
* @Author             :
* @Group              :
* @Last Modified By   :
* @Last Modified On   : 14/07/2020
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    14/07/2020                              Initial Version
**/
public without sharing class ComplaintCoordinatorTriggerHandler extends TriggerHandler {
    //List variable for trigger.new records
    private list<Complaint_Coordinator__c> newLComplaintCoordinators;
    //Constructor
    public ComplaintCoordinatorTriggerHandler() {
        this.newLComplaintCoordinators = (List<Complaint_Coordinator__c>) Trigger.new;
    }

    //Method to run on Before Insert
    public override void beforeInsert() {
        //method to update the external Id fields on the Object
        updateExternalId();
    }

    //Method to run on Before Insert
    public override void beforeUpdate() {
        //method to update the external Id fields on the  Object
        updateExternalId();
    }
    /**
       Author: Deepak
       Company: Techmatrix
       Description: Method to update the external Id fields on records to maintain uniqueness of each record.
       Returns: void
       History:
       * Ver         Date                     Author                    Modification
       *==============================================================================
       * 1.0       14/07/2020              Deepak                   Initial Version
   **/
    public void updateExternalId() {
        try {
            //Loop through all the new List
            for (Complaint_Coordinator__c complaintCoordinator : this.newLComplaintCoordinators) {
                //Variable to store the unique external Id
                String external_Id = '';
                //If category type is not blank
                if (complaintCoordinator.Channel__c != null) {
                    external_Id += complaintCoordinator.Channel__c;
                }
                //If category type is not blank
                if (complaintCoordinator.Type__c != null) {
                    external_Id += ConstantsUtility.UNDER_SCORE + complaintCoordinator.Type__c;
                }
                //If category type is Model blank
                if (complaintCoordinator.Model__c != null) {
                    external_Id += ConstantsUtility.UNDER_SCORE + complaintCoordinator.Model__c;
                }
                //If category type is Model blank
                if (complaintCoordinator.Region__c != null) {
                    external_Id += ConstantsUtility.UNDER_SCORE + complaintCoordinator.Region__c;
                }

                //Populate Unique External ID field
                complaintCoordinator.External_ID__c = external_Id;
                complaintCoordinator.Name = external_Id;
            }
        }catch (Exception exp){
            ExceptionHandler.LogError('ComplaintCoordinatorTriggerHandler', exp.getMessage(), 'Complaint_Coordinator__c', '', null);
        }
    }

}