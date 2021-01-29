/**
* @File Name          : CaseComplaintTriggerServiceImpl.cls
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
public without sharing class CaseComplaintTriggerServiceImpl implements CaseTriggerService{
   

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
        
        //The standard account field will be updated based on the user account record defined for partner users
        //This will enable the visibility of Case records based on the Account team defined under the user Account
        caseStrat.updateUserAccountonCase();

        //Update CCP and Case Resolution Fields on Cae
        caseStrat.updateEscalationDetails();

        //Method to filter out queries/cases which are marked as spam as Mobile or Email
        caseStrat.markOrFilterQueryAsSpam();

        // populate the CCP Calling Time once an update comes from agent as well as dialer disposition
        caseStrat.updateCCPOutboundCallingTime();

        //Detect the CCP Campaign basis Channel, Case Type and Business Area. 
        //The CCP campaign Details are stored in Custom Metadata CCP Matrix
        caseStrat.ccpCampaignDetection();

        //When QC makes an update, the L3 and L4 needs to be notified, this method populates the ID of
        //L3 and L4 on the Case record or marks the Case as QA Discard
        caseStrat.populateL3AL4AndStatus();

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
        
       

        //This method will create bulk hold object record whenever a Bulk Hold for Cases is initiated
        caseStrat.caseBulkHoldRequest();

        // Updates the Case resolution time on Case record once case is marked as Closed from assigned date
        caseStrat.updateCaseResolutionTime();

        //Case Assignment Logic basis Category Grid
        CaseAssignmentService.assignCasesToStakeHolders(newCaseList, oldCasemap);

         //The standard account field will be updated based on the user account record defined for partner users
        //This will enable the visibility of Case records based on the Account team defined under the user Account
        caseStrat.updateUserAccountonCase();

        //Method to update the Case to the previous owner
        caseStrat.updatePreviousOwner();

        //Update Escalation Fields based on Escalation Matrix
        caseStrat.updateEscalationDetails();

        //Changes the Queue assignment of Cases basis Queue assignment matrix for Email Cases and MSIL Query cases
        caseStrat.updateEmailQueueAndTimeAssignedToAgent();

        //When QC makes an update, the L3 and L4 needs to be notified, this method populates the ID of
        //L3 and L4 on the Case record or marks the Case as QA Discard
        caseStrat.populateL3AL4AndStatus(); 

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
        *    Description - Create MC Communication records for Case Escalations.
        */
        caseStrat.postChatterAndMCRecordsEscalation();
        
        /*
        *    Description - Method is used to mark MSIL Query as spam.
        */
        caseStrat.markQueryAsSpam();
        
        /*
        *    Description - Create MC Communication records for SMS and Email notifications 
        */
        caseStrat.createMCRecordsForATM();
        caseStrat.suzukiConnectParentCaseOnHold();//Added by Nitin Ghai
       
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
        *    Description - Create MC Communication records for Case Escalations.
        */
        caseStrat.postChatterAndMCRecordsEscalation();
        
        /*
        *    Description - create chatter notification when QC Users makes an update on the Case record
        */
        caseStrat.sendChatterNotificationOnQC();
        
        /*
        *    Description - Mark status of MC Communication records(Escalations) as Cancelled once case is resolved 
        */
        caseStrat.markMcCommunicationCancelled();
		caseStrat.createMCRecordsForATM();
        caseStrat.updateParentSuzukiInspectionDone(); //Added by Nitin on 9th Nov
        
    }

}