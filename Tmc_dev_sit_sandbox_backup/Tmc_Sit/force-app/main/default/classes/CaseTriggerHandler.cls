/**
* @File Name          : CaseTriggerHandler.cls
* @Description        : Trigger handler class for case
* @Author             : Rajesh Ramachandran
* @Group              : 
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 10-11-2020
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    7/05/2019, 9:14:54 PM         Nishant                Initial Version
* 1.1A   21/02/2020, 11:15:00 AM        Nitin                 Made changes in Map to store Account instead of ID and 
Made changes in query to fetch Dealer Account
* 1.1A   09/03/2020, 11:15:00 AM        Sunit                 Add shareCustomerRecord method
* 1.1A   12/03/2020, 11:15:00 AM        Sunit                 Add updateSubject method
* 1.1A   18/08/2020, 11:15:00 AM        Nitin                 Updated updateUserAccountonCase method with Dealer Inbound record Types
* 1.1A   19/08/2020, 11:15:00 AM        Nitin                  Added inboundCaseEscalationHierarchy method
* 1.1A   1/9/2020, 5:40:00 PM          Prashant               Added ccpCaseEscalationHierarchy method
**/


/** =============================================================================================================== */
/** =============================================================================================================== */

/** DO NOT USE THIS CLASS, ALL CHANGES MOVED TO CaseTriggerStrategyHelper CLASSS
 *
 */
/** =============================================================================================================== */
/** =============================================================================================================== */



public with sharing class CaseTriggerHandler extends TriggerHandler {
    //commented out for dealer inbound deployment
    boolean check = true;

}