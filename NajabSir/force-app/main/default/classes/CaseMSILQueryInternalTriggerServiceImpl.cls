/**
* @File Name          : CaseMOSCaseTriggerServiceImpl.cls
* @Description        : Strategy, Implementation class for MSIL Query Internal Type.
* @Author             : Anas Yar Khan
* @Group              :
* @Last Modified By   : Anas Yar Khan
* @Last Modified On   : 06/07/2020, 1:14:54 PM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    01/07/2020, 1:14:54 PM     Prabhat Sharma            Initial Version

**/
public without sharing class CaseMSILQueryInternalTriggerServiceImpl implements CaseTriggerService{
	CaseTriggerStrategyHelper caseStrat;


    public void beforeInsert(List < Case > newCaseList) {

        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records
        ----------------------------------------------------------------------------------------------*/
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList, null, null, null);


        caseStrat.udpateEntitlementDetails();

        CaseAssignmentService.assignCasesToStakeHolders(newCaseList, null);

        //The standard account field will be updated based on the user account record defined for partner users
        //This will enable the visibility of enquiry records based on the Account team defined under the user Account
        caseStrat.markOrFilterQueryAsSpam();


        //execute this as last method of event. It will update Enquiry Stage time field to ensure field value goes as part of CDC
        caseStrat.updateEmailQueueAndTimeAssignedToAgent();

        //Run the method to ensure that the Enquiry Name is always Customer Name _ RecordType
        caseStrat.updateExternalStakeHolder();
    }

    public void beforeUpdate(List < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {
        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList, null, newCaseMap, oldCaseMap);

        // populateExchangeVehicleEvaluator
        caseStrat.updateCaseResolutionTime();

        //Populate Previous owner on Enquiry
        CaseAssignmentService.assignCasesToStakeHolders(newCaseList, oldCasemap);

        //Prevent mulesoft user from changing status back to New
        caseStrat.updatePreviousOwner();

        //This method will check BookingCancellationReason field and update opportunity stage to New if BookingCancellationReason is Post-Pone and previous value of BookingCancellationReason is blank.
        caseStrat.updateEmailQueueAndTimeAssignedToAgent();

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
        caseStrat.createMCRecordsForATM();
       
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
        system.debug('createMCRecordsForATMcalled');
        caseStrat.createMCRecordsForATM();
        
    }
}