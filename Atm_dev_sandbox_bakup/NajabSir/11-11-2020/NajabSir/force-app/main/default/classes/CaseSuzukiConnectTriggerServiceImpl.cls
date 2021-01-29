/**
* @File Name          : CaseDIRTriggerServiceImpl.cls
* @Description        : Strategy, Implementation class for Complaints Record Type.
* @Author             : Sunit Kumar Chand
* @Group              :
* @Last Modified By   : Sunit Kumar Chand
* @Last Modified On   : 05-11-2020
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    05/11/2020, 1:14:54 PM     Sunit Chand            Initial Version

**/
public with sharing class CaseSuzukiConnectTriggerServiceImpl implements CaseTriggerService {
    CaseTriggerStrategyHelper caseStrat;
    public void beforeInsert(List < Case > newCaseList) {
        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records
        ----------------------------------------------------------------------------------------------*/
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList, null, null, null);
        CaseAssignmentService.assignCasesToStakeHolders(newCaseList, null);
        caseStrat.updateEscalationDetails(); //Update Escalation Details
    }
    public void beforeUpdate(List < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {
        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/
        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList, null, newCaseMap, oldCaseMap);
        CaseAssignmentService.assignCasesToStakeHolders(newCaseList, oldCasemap);
        caseStrat.updateEscalationDetails(); //Update Escalation Details
        caseStrat.suzukiConnectUpdate();
     }
    public void afterInsert(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {

        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/

        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null, newCaseMap, oldCaseMap);
        /*
        *    Description - Create MC Communication records for Case Escalations.
        *    Parameters - 1 = After Insert, 2 = After Update
        */
        caseStrat.postChatterAndMCRecordsEscalation();
        
        
        if(newCaseList.size()==1){
            Case cs=newCaseList[0];
            String middleName=cs.Middle_Name__c==null?'':cs.Middle_Name__c;
            CaseTriggerStrategyHelper.PanaCRMRecordCreation panaCRM=new CaseTriggerStrategyHelper.PanaCRMRecordCreation(cs.VIN_No__c,cs.IMEI_No__c,cs.TCU_No__c,cs.Sim_No__c,
                                                                                                                        cs.TCU_Dealer_Name__c,cs.TCU_Dealer_Address__c,
                                                                                                                        cs.Dealer_Phone__c,String.valueOf(cs.TCU_Sale_Date__c),String.valueOf(cs.TCU_Expiry_Date__c),
                                                                                                                        cs.First_Name__c+' '+middleName+' '+cs.Last_Name__c,
                                                                                                                        cs.Mobile_Number__c,cs.Customer_Address__c,cs.TCU_Customer_State__c,
                                                                                                                        cs.TCU_Customer_City__c,cs.TCU_Customer_Country__c,cs.Pin_Code__c,
                                                                                                                        cs.CaseNumber,cs.Model__c,String.valueOf(cs.Service_Activation_Date__c),
                                                                                                                        cs.TCU_Service_Status__c,cs.Mobile_Number__c,String.valueOf(cs.Odometer_Reading__c),'');
            CaseTriggerStrategyHelper.panaCRMRecordCreation(JSON.serialize(panaCRM),cs.Id);
            caseStrat.createMCRecordsForSuzukiConnect();
        }
        
        caseStrat.updateSalesforceExternalId();//Added by Nitin to Update Salesforce_External_Id__c 
        CaseSharingService.shareCaseToMembers(newCaseList); //Added by Nitin 18/12/2020
    }
    public void afterUpdate(list < Case > newCaseList, Map < Id, Case > newCaseMap, Map < Id, Case > oldCaseMap) {


        /*---------------------------------------------------------------------------------------------
        Description     To create a new instance/getInstance of OpportunityTriggerStrategyHelper class
        params          New List of Opportunity Records, Map of new Opps, Map of Old Opps records
        ----------------------------------------------------------------------------------------------*/

        caseStrat = CaseTriggerStrategyHelper.getInstance(newCaseList,null, newCaseMap, oldCaseMap);
        /*
        *    Description - Create MC Communication records for Case Escalations.
        *    Parameters - 1 = After Insert, 2 = After Update
        */
        caseStrat.postChatterAndMCRecordsEscalation();
        caseStrat.sendChatterNotificationOnQC();
        caseStrat.updateSuzukiConnectMCrecords();
        MCCommunicationService.suzukiConnectMcRecCreation(newCaseList,oldCaseMap); //Method to create MC record post 4 hr of Case creation
        caseStrat.suzukiConnectOnHoldChatterNotifications(); //Chatter notification when Case is on Hold
        caseStrat.markMcCommunicationCancelled(); // Mark MC records to Cancelled when Case is closed
        caseStrat.updateMileStonetoCloseforSuzukiConnect(); //Update Milestone to Closed 
     }
}