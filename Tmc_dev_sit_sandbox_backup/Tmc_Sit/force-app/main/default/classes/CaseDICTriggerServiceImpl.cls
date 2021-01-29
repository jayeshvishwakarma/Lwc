/**
* @File Name          : CaseDICTriggerServiceImpl.cls
* @Description        : Strategy, Implementation class for Complaints Record Type.
* @Author             : Sunit Kumar Chand
* @Group              :
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 10-27-2020
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.1A    07/09/2020, 1:14:54 PM     Sunit Chand            Initial Version
* 1.1A    22/10/2020, 1:14:54 PM     Sunit Chand            Added updateCaseMileStone call
**/
public with sharing class CaseDICTriggerServiceImpl implements CaseTriggerService {
	CaseTriggerStrategyHelper caseStrat;
    public void beforeInsert(List < Case > newCaseList) {
        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records
        ----------------------------------------------------------------------------------------------*/
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList, null, null, null);
        caseStrat.predefaultCaseFields();
        caseStrat.updateEscalationDetails();
        caseStrat.mobileSFMCUpdate();     
        //Added by Nitin Ghai on 21/09/2020
        caseStrat.updateUserAccountOnCase(); 

        // Added by Sunit update flag on case is created by MI or not
        caseStrat.updateCreatedByFlag();
    }

    public void beforeUpdate(List < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {
        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList, null, newCaseMap, oldCaseMap);
        //Update Escalation Fields based on Escalation Matrix
        caseStrat.updateEscalationDetails();
        caseStrat.mobileSFMCUpdate();
        //Rajesh added for SVOC updates
        caseStrat.populateCustomerBasedOnSVOCId();
        //Added by Nitin Ghai on 21/09/2020
        caseStrat.updateUserAccountOnCase(); 
        caseStrat.updateDealerServiceToClosed();
        caseStrat.restrictInternalCaseStatusEdit();
   }
    public void afterInsert(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {


        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/

        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null, newCaseMap, oldCaseMap);
        caseStrat.caseTeamCreation();
        //Added by Prashant Gahlaut
        caseStrat.ccpCaseEscalationHierarchy();
        /***Added by Nitin Ghai***/
        caseStrat.inboundCaseEscalationHierarchy();
        //Added By Prashant Gahlaut
        caseStrat.inboundChatterNotifications();
        //Added by Rajesh
        caseStrat.createMICommunicationRecords(true);
        //Added by Sunit for milestone update if case is closed
        caseStrat.updateCaseMileStone();
        
    }
    public void afterUpdate(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {


        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/

        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null, newCaseMap, oldCaseMap);
        caseStrat.caseTeamCreation();
        caseStrat.inboundCaseEscalationHierarchy(); //Added by Nitin Ghai
        caseStrat.ccpCaseEscalationHierarchy();//Added by Prashant Gahlaut
        //Added By Prashant Gahlaut
        caseStrat.inboundChatterNotifications();
        //Added by Rajesh
        caseStrat.createMICommunicationRecords(false);  
        //Added by Nitin Ghai on 21/09/2020
        caseStrat.updateParentCasetoClosed();
        caseStrat.markMcCommunicationCancelled();
        //Added by Sunit for milestone update if case is closed
        caseStrat.updateCaseMileStone();
    }

}