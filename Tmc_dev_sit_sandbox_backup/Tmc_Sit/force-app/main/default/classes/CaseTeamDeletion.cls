/**
 * @description       : Moved case team deletion and insert into a without sharing class
 * @author            : Rajesh Ramachandran
 * @group             : 
 * @last modified on  : 08-04-2020
 * @last modified by  : Rajesh Ramachandran
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   08-03-2020   Rajesh Ramachandran   Initial Version
**/
public without sharing class CaseTeamDeletion {

    public static void caseTeamDelete(List<Case> caseList, List<CaseTeamMember> caseTeamList){
        
        List <CaseTeamMember> ctmList=[Select Id from CaseTeamMember where ParentId IN:caseList];
        delete ctmList;

        if (caseTeamList != null && caseTeamList.size() > 0){
            insert caseTeamList;
        }
     }

}