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

    public static string  createProfiling(Id recordId){
        List<Campaign> profilingCamp = new List<Campaign>();
        profilingCamp = [select id from Campaign where type='Profiling' limit 1];

        List<Survey_Taker_CTI__c> surveyList = new List<Survey_Taker_CTI__c>();

        if(recordId != null && (!profilingCamp.isEmpty())){
            Survey_Taker_CTI__c recordData = new Survey_Taker_CTI__c();
            recordData = [select id,Customer__c,Customer_Address_Line_1__c, Customer_Address_Line_2__c, Customer_Address_Line_3__c, Customer_City__c, Customer_Pincode__c,Customer_State__c,
                            Dealership__c,First_Name__c,Last_Name__c,Middle_Name__c,Reg_Number__c,Model__c,Generic__c,Generic3__c,Generic7__c,Generic8__c,Generic9__c,VIN_No__c,Generic_Date__c,Mobile_Number__c,
                            Variant__c, Title__c from Survey_Taker_CTI__c where Id=:recordId limit 1];

            Survey_Taker_CTI__c profilingSurvey = new Survey_Taker_CTI__c();
            profilingSurvey.Customer__c = recordData.Customer__c;
            profilingSurvey.Customer_Address_Line_1__c = recordData.Customer_Address_Line_1__c;
            profilingSurvey.Customer_Address_Line_2__c = recordData.Customer_Address_Line_2__c;
            profilingSurvey.Customer_Address_Line_3__c = recordData.Customer_Address_Line_3__c;
            profilingSurvey.Customer_City__c = recordData.Customer_City__c;
            profilingSurvey.Customer_Pincode__c = recordData.Customer_Pincode__c;
            profilingSurvey.Customer_State__c = recordData.Customer_State__c;
            profilingSurvey.Dealership__c = recordData.Dealership__c;
            profilingSurvey.First_Name__c = recordData.First_Name__c;
            profilingSurvey.Last_Name__c = recordData.Last_Name__c;
            profilingSurvey.Middle_Name__c = recordData.Middle_Name__c;
            profilingSurvey.Reg_Number__c = recordData.Reg_Number__c;
            profilingSurvey.Model__c = recordData.Model__c;
            profilingSurvey.Generic__c = recordData.Generic__c;
            profilingSurvey.Generic1__c = recordData.Generic3__c;
            profilingSurvey.Generic7__c = recordData.Generic7__c;
            profilingSurvey.Generic8__c = recordData.Generic8__c;
            profilingSurvey.Generic9__c = recordData.Generic9__c;
            profilingSurvey.VIN_No__c = recordData.VIN_No__c;
            profilingSurvey.Generic_Date__c = recordData.Generic_Date__c;
            profilingSurvey.Mobile_Number__c = recordData.Mobile_Number__c;
            profilingSurvey.Variant__c = recordData.Variant__c;
            profilingSurvey.Title__c = recordData.Title__c;
            profilingSurvey.Survey__c = profilingCamp[0].Id;
            surveyList.add(profilingSurvey);

        }

        system.debug('surveyList===' + surveyList);
        if(!surveyList.isEmpty()){
            insert surveyList;
            return surveyList[0].Id;
        }
        return null;
    }

}