/**
* @File Name          : CaseRepeatComplaintTriggerServiceImpl.cls
* @Description        : Strategy, Implementation class for Complaints Record Type.
* @Author             : Prabhat Sharma
* @Group              :
* @Last Modified By   : Prabhat Sharma
* @Last Modified On   : 06/07/2020, 1:14:54 PM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    01/07/2020, 1:14:54 PM     Prabhat Sharma            Initial Version

**/
public without sharing class CaseRepeatComplaintTriggerServiceImpl implements CaseTriggerService{
    CaseTriggerStrategyHelper caseStrat;


    public void beforeInsert(List < Case > newCaseList) {

        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records
        ----------------------------------------------------------------------------------------------*/
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList, null, null, null);



        caseStrat.udpateEntitlementDetails();

        CaseAssignmentService.assignCasesToStakeHolders(newCaseList, null);
        caseStrat.updateUserAccountonCase();
        //Update Close date on Enquiry from current plus 3 months date
        caseStrat.updateEscalationDetails();

        //The standard account field will be updated based on the user account record defined for partner users
        //This will enable the visibility of enquiry records based on the Account team defined under the user Account
        caseStrat.markOrFilterQueryAsSpam();

        // populateExchangeVehicleEvaluator
        caseStrat.updateCCPOutboundCallingTime();

        //Change Ownership of Enquiry(Opportunity)to Sales SPOC when Enquiry is of Vehicle Sales Record Type and
        //Enquiry owner is Integration user.
        caseStrat.ccpCampaignDetection();

        //Update Escalation Fields based on Escalation Matrix
        //This will the populate the notifiers for each levels for both allocated and unallocated enquiries
        caseStrat.populateL3AL4AndStatus();

        //execute this as last method of event. It will update Enquiry Stage time field to ensure field value goes as part of CDC
        caseStrat.updateEmailQueueAndTimeAssignedToAgent();

        //Run the method to ensure that the Enquiry Name is always Customer Name _ RecordType
        caseStrat.updateExternalStakeHolder();
        //Run the method to Copy the customer address to case
        caseStrat.copyCustomerAddressOnCase();
    }

    
    public void beforeUpdate(List < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {
        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList, null, newCaseMap, oldCaseMap);
        // Call relevant methods in OpportunityTriggerHelper/Handler


        //The standard account field will be updated based on the user account record defined for partner users
        //This will enable the visibility of enquiry records based on the Account team defined under the user Account
        caseStrat.caseBulkHoldRequest();

        // populateExchangeVehicleEvaluator
        caseStrat.updateCaseResolutionTime();

        //Populate Previous owner on Enquiry
        CaseAssignmentService.assignCasesToStakeHolders(newCaseList, oldCasemap);
        caseStrat.updateUserAccountonCase();

        //Prevent mulesoft user from changing status back to New
        caseStrat.updatePreviousOwner();

        //Update Escalation Fields based on Escalation Matrix
        caseStrat.updateEscalationDetails();

        //This method will check BookingCancellationReason field and update opportunity stage to New if BookingCancellationReason is Post-Pone and previous value of BookingCancellationReason is blank.
        caseStrat.updateEmailQueueAndTimeAssignedToAgent();

        //execute this as last method of event. It will update Enquiry Stage time field to ensure field value goes as part of CDC
        caseStrat.populateL3AL4AndStatus();

        //executes when Reatil Cancellation Date on Enquiry gets populated
        caseStrat.populateL3AL4AndStatus();

        //Run the method to ensure that the Enquiry Name is always Customer Name _ RecordType
        caseStrat.populateCustomerBasedOnSVOCId();
        caseStrat.updateQCInfo();
 
    }
    
    public void afterInsert(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {


        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/

        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null, newCaseMap, oldCaseMap);

        //Send notifications to SPOC
        CaseSharingService.shareCaseToMembers(newCaseList);

        //This method will create Followup Task for an Enquiry
        caseStrat.postChatterAndMCRecordsEscalation();

        caseStrat.markQueryAsSpam();
       
    }


    public void afterUpdate(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {


        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/

        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null, newCaseMap, oldCaseMap);

        //Update SVOC ID on Enquiry and on Account
        CaseSharingService.shareCaseToMembers(newCaseList);

        /*
        *    Description - To add Opportunity team members under an Enquiry
        *    Parameters - 1 = After Insert, 2 = After Update
        */
        caseStrat.postChatterAndMCRecordsEscalation();
        /*
        *    Description - create MC Communication records on DSE Allocation
        *    Parameters - 1 = After Insert, 2 = After Update
        */
        caseStrat.sendChatterNotificationOnQC();
        /*
        *    Description - Post chatter message and notification for Escalated Enquiries
        *    Parameters - 1 = After Insert, 2 = After Update
        */
        caseStrat.markMcCommunicationCancelled();

        
    }
}