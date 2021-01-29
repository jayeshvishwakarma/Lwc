/**
 Author: Deepak Kumar
 Company: Techmatrix
 Description: This Class is made for Stakeholder Hierarchy related utility methods
 Input : Case Object
 History:
 * Version         Date                     Author                    Modification
 *==============================================================================
 * 1.0        07/08/2020                Deepak Kumar              Initial Version
**/

public with sharing class StakeholderUtility {

    /**
      Author : Deepak Kumar
      Company : Techmatrix Consulting
      Description : A generic method to get the List of stakeholder to selected Hierarchy Type
      Parameters : stakeholderHierarchy JSON String and Selected HierarchyType String
      Return Type :  List<StakeholderHierarchy.Sales>
  */
    public static List<StakeholderHierarchy.Sales> getSelectedHierarchyList(String StakeholderHierarchyString, String selectedHierarchyType) {
        List<StakeholderHierarchy.Sales> hierarchyList = new List<StakeholderHierarchy.Sales>(); // List to iterate the list of the stake holders
        if (StakeholderHierarchyString != null && selectedHierarchyType != null) {
            StakeholderHierarchy stakeholderHierarchy = parseStakeholderHierarchyJson(StakeholderHierarchyString);
            if (selectedHierarchyType == ConstantsUtility.SALES_HIERARCHY && stakeholderHierarchy.sales != null && stakeholderHierarchy.sales.size() > 0) {
                hierarchyList = stakeholderHierarchy.sales;
            } else if (selectedHierarchyType == ConstantsUtility.SERVICE_NEXA_HIERARCHY && stakeholderHierarchy.serviceNexa != null && stakeholderHierarchy.serviceNexa.size() > 0) {
                hierarchyList = stakeholderHierarchy.serviceNexa;
            } else if (selectedHierarchyType == ConstantsUtility.SERVICE_ARENA_HIERARCHY && stakeholderHierarchy.serviceArena != null && stakeholderHierarchy.serviceArena.size() > 0) {
                hierarchyList = stakeholderHierarchy.serviceArena;
            }else if (selectedHierarchyType == ConstantsUtility.ACCESSORIES_HIERARCHY && stakeholderHierarchy.accessories != null && stakeholderHierarchy.accessories.size() > 0) {
                hierarchyList = stakeholderHierarchy.accessories;
            } else if (selectedHierarchyType == ConstantsUtility.TRUEVALUE_HIERARCHY && stakeholderHierarchy.trueValue != null && stakeholderHierarchy.trueValue.size() > 0) {
                hierarchyList = stakeholderHierarchy.trueValue;
            } else if (selectedHierarchyType == ConstantsUtility.MSDS_HIERARCHY && stakeholderHierarchy.msds != null && stakeholderHierarchy.msds.size() > 0) {
                hierarchyList = stakeholderHierarchy.msds;
            } else if (selectedHierarchyType == ConstantsUtility.MSGP_HIERARCHY && stakeholderHierarchy.msgp != null && stakeholderHierarchy.msgp.size() > 0) {
                hierarchyList = stakeholderHierarchy.msgp;
            } else if (selectedHierarchyType == ConstantsUtility.LOYALTY_PROGRAM_HIERARCHY && stakeholderHierarchy.loyaltyProgram != null && stakeholderHierarchy.loyaltyProgram.size() > 0) {
                hierarchyList = stakeholderHierarchy.loyaltyProgram;
            } else if (selectedHierarchyType == ConstantsUtility.FINANCE_HIERARCHY && stakeholderHierarchy.finance != null && stakeholderHierarchy.finance.size() > 0) {
                hierarchyList = stakeholderHierarchy.finance;
            } else if (selectedHierarchyType == ConstantsUtility.MSIL_QUERY_HIERARCHY && stakeholderHierarchy.msilQuery != null && stakeholderHierarchy.msilQuery.size() > 0) {
                hierarchyList = stakeholderHierarchy.msilQuery;
            }else if (selectedHierarchyType == ConstantsUtility.SUZUKI_CONNECT_HIERARCHY && stakeholderHierarchy.suzukiConnect != null && stakeholderHierarchy.suzukiConnect.size() > 0) {
                hierarchyList = stakeholderHierarchy.suzukiConnect;
            }
        }
        return hierarchyList;
    }
    /**
     Author: Deepak Kumar
     Company: Techmatrix
     Description: This method is used to parse the JSON String and return the wrapper instance
     Input : Case Object
     History:
     * Version         Date                     Author                    Modification
     *==============================================================================
     * 1.0        05/08/2020                Deepak Kumar              Initial Version
  **/
    public static StakeholderHierarchy parseStakeholderHierarchyJson(String stakeholderHierarchyString) {
    return (StakeholderHierarchy) JSON.deserialize(stakeholderHierarchyString, StakeholderHierarchy.class);
    }
}