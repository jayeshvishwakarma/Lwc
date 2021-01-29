/*
ClassName    : twod_ModifyClaimDupUpdateFlag
CreatedOn    : 05/17/18
ModifiedBy   : Balaji
Description  : Resetting the flag in claim
*/
public class twod_ModifyClaimDupUpdateFlag {
  
    /*
    MethodName : RevertValue
    Param      : List of customer Ids
    Description: Resetting the flaf for old claims
    */
    @InvocableMethod
    public static void RevertValue(List<String> custIds)
    {        
        List<twod__claim__c> lstClm = new List<twod__claim__c>();
        List<twod__claim__c> lstClmUpdated = new List<twod__claim__c>();
        lstClm = [select id, name, UpdFrmDiffRec__c from twod__claim__c where customer__c =: custIds];
        for(twod__claim__c eachClm : lstClm){            
            if(eachClm.UpdFrmDiffRec__c == 'Updated'){
                eachClm.UpdFrmDiffRec__c = 'Reverted';     
                lstClmUpdated.add(eachClm);       
            }           
        }
        upsert lstClmUpdated;
    }
}