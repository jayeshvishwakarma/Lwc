/**
* @File Name          : CaseMSILQueryInternalTriggerServiceImpl.cls
* @Description        : Strategy, Implementation class for MSIL Query Internal Type.
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
public without sharing class CaseMSILQueryInternalTriggerServiceImpl implements CaseTriggerService{
	CaseTriggerStrategyHelper caseStrat;


    public void beforeInsert(List < Case > newCaseList) {

        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of CaseTriggerStrategyHelper class
        params          New List of Case Records
        ----------------------------------------------------------------------------------------------*/
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList, null, null, null);

        //Method to update the Entitlement Id on the Case Records
        caseStrat.udpateEntitlementDetails();

        //Case Assignment Logic basis Category Grid
        CaseAssignmentService.assignCasesToStakeHolders(newCaseList, null);

        //Method to filter out queries/cases which are marked as spam as Mobile or Email
        caseStrat.markOrFilterQueryAsSpam();


        //Changes the Queue assignment of Cases basis Queue assignment matrix
        caseStrat.updateEmailQueueAndTimeAssignedToAgent();

        //Method to mark external stakeholder picklist value to true
        caseStrat.updateExternalStakeHolder();

        //Run the method to Copy the customer address to case
        caseStrat.copyCustomerAddressOnCase();
    }


    public void beforeUpdate(List < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {
        
        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of CaseTriggerStrategyHelper class
        params          New List of Case Records
        ----------------------------------------------------------------------------------------------*/
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList, null, newCaseMap, oldCaseMap);

        // Updates the Case resolution time on Case record once case is marked as Closed from assigned date
        caseStrat.updateCaseResolutionTime();

        //Case Assignment Logic basis Category Grid
        CaseAssignmentService.assignCasesToStakeHolders(newCaseList, oldCasemap);

        //Method to update the Case to the previous owner
        caseStrat.updatePreviousOwner();

        //Changes the Queue assignment of Cases basis Queue assignment matrix
        caseStrat.updateEmailQueueAndTimeAssignedToAgent();

        //This method reparents the Case to the customer record when SVOC ID comes back from SVOC system
        caseStrat.populateCustomerBasedOnSVOCId();
        // This Method Will Update QA details
        caseStrat.updateQCInfo();
    }
    


    public void afterInsert(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {


        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of CaseTriggerStrategyHelper class
        params          New List of Case Records
        ----------------------------------------------------------------------------------------------*/

        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null, newCaseMap, oldCaseMap);

        //Method to share the case records with relevant users by adding them to the Case team
        CaseSharingService.shareCaseToMembers(newCaseList);

        /*
        *    Description - Method is used to mark MSIL Query as spam.
        */
        caseStrat.markQueryAsSpam();
        
        /*
        *    Description - Create MC Communication records for SMS and Email notifications 
        */
        caseStrat.createMCRecordsForATM();
       
    }


    public void afterUpdate(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {


        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of CaseTriggerStrategyHelper class
        params          New List of Case Records
        ----------------------------------------------------------------------------------------------*/

        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null, newCaseMap, oldCaseMap);

        //Method to share the case records with relevant users by adding them to the Case team
        CaseSharingService.shareCaseToMembers(newCaseList);

        /*
        *    Description - Mark status of MC Communication records(Escalations) as Cancelled once case is resolved 
        */
        caseStrat.markMcCommunicationCancelled();
        /*
        *    Description - Create MC Communication records for SMS and Email notifications 
        */
        caseStrat.createMCRecordsForATM();
        
    }
}