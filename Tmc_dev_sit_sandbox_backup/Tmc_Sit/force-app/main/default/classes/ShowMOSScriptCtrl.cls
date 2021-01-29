/**
 * @File Name          : ShowMOSScriptCtrl.cls
 * @Description        : This class allow us to show or create the part line item records
 * @Author             : Anuj Kumar
 * @Group              : 
 * @Last Modified By   : Anuj Kumar
 * @Last Modified On   : 
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    20/10/2019 11:17 AM          Anuj Kumar            Initial Version
**/
public without sharing class ShowMOSScriptCtrl{
    
    @AuraEnabled
    public static Boolean getCaseDetail(String recId){
        Boolean isValid = false;
        system.debug('== recId '+recId);
        
        String rectyName = 'MOS_Complaints';
        if(String.isNotBlank(recId)){
            List<Case> caseList = [Select id, recordType.DeveloperName from Case where Id =: recId];
            if(!caseList.isEmpty() && caseList[0].recordType.DeveloperName == rectyName){
                isValid = true;
            }
        }
        return isValid;
    }
    
    
}