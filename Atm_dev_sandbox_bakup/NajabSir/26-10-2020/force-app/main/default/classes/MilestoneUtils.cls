/**
* @File Name          : MilestoneUtils.cls
* @Description        : Trigger handler to update the milestones on Cases
* @Author             : 
* @Group              : 
* @Last Modified By   : Prabhat Sharma
* @Last Modified On   : 05/24/2020, 11:26:51 AM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    05/24/2020, 11:26:51 AM                              Initial Version 
**/

public class MilestoneUtils {
    
    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: 
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.0     24 May 2020  Prabhat Sharma  Initial Version
    **/
    public static void completeMilestone(set<Id> caseIds, List<String> milestoneNames, DateTime complDate) {
    
        List<CaseMilestone> cmsToUpdate = [select Id, completionDate
                                                from CaseMilestone cm
                                                where caseId in :caseIds and cm.MilestoneType.Name IN:milestoneNames
                                                and completionDate = null ];
            if (cmsToUpdate.isEmpty() == false){
                for (CaseMilestone cm : cmsToUpdate){
                    cm.completionDate = complDate;
                }
                Database.update(cmsToUpdate,false);
            }
    }
}