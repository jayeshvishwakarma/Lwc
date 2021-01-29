/**
 * @File Name          : OpenProfilingSurveyApex.cls
 * @Description        : This class is used to insert the profiling survey details.
 * @Author             : Saloni Gupta
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   :
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0       10/11/2020                Saloni Gupta          Initial Version
**/
public without sharing class OpenProfilingSurveyApex {

    @AuraEnabled

    public static string  createProfiling(String refrencedDPSId){
        List<Survey_Taker_CTI__c> takerList = new List<Survey_Taker_CTI__c>([select Id, DPS_ID__c from Survey_Taker_CTI__c where DPS_ID__c=:refrencedDPSId limit 1]);
        if(!takerList.isEmpty()){
            return takerList[0].Id;
        }
        return null;
    }

}