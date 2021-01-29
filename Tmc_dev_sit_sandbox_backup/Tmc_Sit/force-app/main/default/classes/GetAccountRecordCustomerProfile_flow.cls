/**
* @File Name          : GetAccountRecordCustomerProfile_flow.cls
* @Description        : Flow Apex plugin class to locate account
* @Author             : 
* @Group              : 
* @Last Modified By   : Subhojit Chakraborty
* @Last Modified On   : 10/12/2019, 9:14:54 PM 
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    10/12/2019, 9:14:54 PM                                Initial Version
 
**/

public without sharing class GetAccountRecordCustomerProfile_flow {
    @InvocableMethod(Label='Get Account Without Sharing')
    public static List<GetAccountCustomerProfileWrp> getAccount(List<String> lstRecordIds){
        List<Account> lstAccount=new List<Account>();
        List<String> lstFields = new List<String>();
         GetAccountCustomerProfileWrp flowrp=new GetAccountCustomerProfileWrp();
        if(lstRecordIds!=null && lstRecordIds.size()>0){
            Id RecordId=lstRecordIds[0];
            String oppSVOCID='';
            string oppId=null;
           /* String sQuery='SELECT {0} FROM ACCOUNT WHERE ID=:RecordId';

                for(Schema.SObjectField f: Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().values()){

                            DescribeFieldResult fr = f.getDescribe();

                            if(fr.isCreateable ())
                            lstFields.add(fr.getLocalName() );
                        }


                
            List<object> lstQueryFields=new List<Object>{String.join(lstFields, ',')};
            sQuery=String.format(sQuery,lstQueryFields);*/
            Schema.sObjectType entityType = RecordId.getSObjectType();
            if(entityType == Opportunity.sObjectType){
                Opportunity oppVar=[select Id,Customer__c,SVOC_ID__c from Opportunity where Id=:RecordId];
                if(oppVar.Customer__c!=null){
                    RecordId=oppVar.Customer__c;
                    oppSVOCID=oppVar.SVOC_ID__c;
                    oppId=oppVar.Id;

                }
                
            }
           lstAccount=[select Id,SVOC_ID__c,FirstName,Gender__pc,Aadhaar__pc,PAN__pc,Preferred_Social_Media__c,Preferred_Video_Content__c,Avg_spend_on_e_commerce_websites_a_month__c,
           Facebook_Handle__c,Twitter_Handle__c,Insta_Handle__c,Degree_of_preference_for_Maruti_car__c,Maruti_service_is_value_for_money__c,
           Preference_for_MGA_or_non_MGA__c,Maruti_Insurance_better_than_competition__c,Did_you_even_buy_a_Non_Maruti_Insurance__c,Attempt_Screen_1__c,
           Attempt_Screen_2__c,Attempt_Screen_3__c,Attempt_Screen_4__c,Attempt_Screen_5__c,Attempt_Screen_6__c,Attempt_Screen_7__c,
           Reason_s_for_churn_out_from_Maruti__c,PIN__c,Languages_Known__c,Year_of_1st_job_after_graduation_YYYY__c,Graduation_year_of_the_individual_YYYY__c,
           Auto_Journals__c,Degree_Of__c,Parking_Space_at__c,Purpose_Of_Vehicle__c,Age_Of_Two_Wheeler_Owned__c,Models_Enquired_From_Competitors__c,
           Number_Of_Two_Wheelers_Owned__c,Who_drives_the_car__c,Distance_Of_Home_From_Office_In_Kms__c,Type_Of_Two_Wheeler_Owned__c,
           Number_Of_Children__c,Did_You_Become_A_Parent_In_Last_1_Year__c,Date_Of_Birth_Of_Child_1__c,Date_Of_Birth_Of_Child_2__c,Average_Household_Savings__c,
           Parents_Marriage_Anniversary__c,Anniversary_Date__pc,Has_Anyone_In_The_Family_Of_The_Individu__c,Number_Of_Dependents__c,PersonBirthdate,
           Score_Overall__c,Score_Screen_1__c,Score_Screen_2__c,Score_Screen_3__c,Score_Screen_4__c,Score_Screen_5__c,Score_Screen_6__c,Score_Screen_7__c,
           Personal_Annual_Income_in_Lacs__c,Profession_Type__c,Number_Of_Maruti_Cars_Owned_In_Immediate__c from account where
           Id=:RecordId];
            //lstAccount=(List<Account>)Database.query(sQuery);
           
          
            flowrp.recId=lstAccount[0].Id;
            flowrp.FirstName=lstAccount[0].FirstName;
            flowrp.Gender=lstAccount[0].Gender__pc;
            flowrp.Aadhaar=lstAccount[0].Aadhaar__pc;
            flowrp.PAN=lstAccount[0].PAN__pc;
            flowrp.Preferred_Social_Media=lstAccount[0].Preferred_Social_Media__c;
            flowrp.Preferred_Video_Content=lstAccount[0].Preferred_Video_Content__c;
            flowrp.Avg_spend_on_e_commerce_websites_a_month=lstAccount[0].Avg_spend_on_e_commerce_websites_a_month__c;
            flowrp.Facebook_Handle=lstAccount[0].Facebook_Handle__c;
            flowrp.Twitter_Handle=lstAccount[0].Twitter_Handle__c;
            flowrp.Insta_Handle=lstAccount[0].Insta_Handle__c;
            flowrp.Degree_of_preference_for_Maruti_car=lstAccount[0].Degree_of_preference_for_Maruti_car__c;
            flowrp.Maruti_service_is_value_for_money=lstAccount[0].Maruti_service_is_value_for_money__c;
            flowrp.Preference_for_MGA_or_non_MGA=lstAccount[0].Preference_for_MGA_or_non_MGA__c;
            flowrp.Maruti_Insurance_better_than_competition=lstAccount[0].Maruti_Insurance_better_than_competition__c;
            flowrp.Did_you_even_buy_a_Non_Maruti_Insurance=lstAccount[0].Did_you_even_buy_a_Non_Maruti_Insurance__c;
            flowrp.Attempt_Screen_1=lstAccount[0].Attempt_Screen_1__c;
            flowrp.Attempt_Screen_2=lstAccount[0].Attempt_Screen_2__c;
            flowrp.Attempt_Screen_3=lstAccount[0].Attempt_Screen_3__c;
            flowrp.Attempt_Screen_4=lstAccount[0].Attempt_Screen_4__c;
            flowrp.Attempt_Screen_5=lstAccount[0].Attempt_Screen_5__c;
            flowrp.Attempt_Screen_6=lstAccount[0].Attempt_Screen_6__c;
            flowrp.Attempt_Screen_7=lstAccount[0].Attempt_Screen_7__c;
            flowrp.Reason_s_for_churn_out_from_Maruti=lstAccount[0].Reason_s_for_churn_out_from_Maruti__c;
            flowrp.PIN=lstAccount[0].PIN__c;
            flowrp.Languages_Known=lstAccount[0].Languages_Known__c;
            flowrp.Year_of_1st_job_after_graduation_YYYY=lstAccount[0].Year_of_1st_job_after_graduation_YYYY__c;
            flowrp.Graduation_year_of_the_individual_YYYY=lstAccount[0].Graduation_year_of_the_individual_YYYY__c;
            flowrp.Auto_Journals=lstAccount[0].Auto_Journals__c;
            flowrp.Degree_Of=lstAccount[0].Degree_Of__c;
            flowrp.Parking_Space_at=lstAccount[0].Parking_Space_at__c;
            flowrp.Purpose_Of_Vehicle=lstAccount[0].Purpose_Of_Vehicle__c;
            flowrp.Age_Of_Two_Wheeler_Owned=lstAccount[0].Age_Of_Two_Wheeler_Owned__c;
            flowrp.Models_Enquired_From_Competitors=lstAccount[0].Models_Enquired_From_Competitors__c;
            flowrp.Number_Of_Two_Wheelers_Owned=lstAccount[0].Number_Of_Two_Wheelers_Owned__c;
            flowrp.Who_drives_the_car=lstAccount[0].Who_drives_the_car__c;
            flowrp.Distance_Of_Home_From_Office_In_Kms=lstAccount[0].Distance_Of_Home_From_Office_In_Kms__c;
            flowrp.Type_Of_Two_Wheeler_Owned=lstAccount[0].Type_Of_Two_Wheeler_Owned__c;
            flowrp.Number_Of_Children=lstAccount[0].Number_Of_Children__c;
            flowrp.Did_You_Become_A_Parent_In_Last_1_Year=lstAccount[0].Did_You_Become_A_Parent_In_Last_1_Year__c;
            flowrp.Date_Of_Birth_Of_Child_1=lstAccount[0].Date_Of_Birth_Of_Child_1__c;

            flowrp.Date_Of_Birth_Of_Child_2=lstAccount[0].Date_Of_Birth_Of_Child_2__c;
            flowrp.Average_Household_Savings=lstAccount[0].Average_Household_Savings__c;
            flowrp.Parents_Marriage_Anniversary=lstAccount[0].Parents_Marriage_Anniversary__c;
            flowrp.Anniversary_Date=lstAccount[0].Anniversary_Date__pc;
            flowrp.Has_Anyone_In_The_Family_Of_The_Individu=lstAccount[0].Has_Anyone_In_The_Family_Of_The_Individu__c;
            flowrp.Number_Of_Dependents=lstAccount[0].Number_Of_Dependents__c;
            flowrp.PersonBirthdate=lstAccount[0].PersonBirthdate;
            flowrp.Score_Overall=lstAccount[0].Score_Overall__c;
            flowrp.Score_Screen_1=lstAccount[0].Score_Screen_1__c;
            flowrp.Score_Screen_2=lstAccount[0].Score_Screen_2__c;
            flowrp.Score_Screen_3=lstAccount[0].Score_Screen_3__c;
            flowrp.Score_Screen_4=lstAccount[0].Score_Screen_4__c;
            flowrp.Score_Screen_5=lstAccount[0].Score_Screen_5__c;
            flowrp.Score_Screen_6=lstAccount[0].Score_Screen_6__c;
            flowrp.Score_Screen_7=lstAccount[0].Score_Screen_7__c;
            flowrp.Personal_Annual_Income_in_Lacs=lstAccount[0].Personal_Annual_Income_in_Lacs__c;
            flowrp.Profession_Type=lstAccount[0].Profession_Type__c;
            flowrp.Number_Of_Maruti_Cars_Owned_In_Immediate=lstAccount[0].Number_Of_Maruti_Cars_Owned_In_Immediate__c;
            flowrp.accSVOCID=lstAccount[0].SVOC_ID__c;
            flowrp.oppSVOCID=oppSVOCID;
            flowrp.accountId=lstAccount[0].Id;
            flowrp.OpportunityId=oppId;
            
           

        }
        return new List<GetAccountCustomerProfileWrp>{flowrp};
    }
    public  class GetAccountCustomerProfileWrp {
  @invocableVariable
   public string recId;
   @invocableVariable
   public string FirstName;
   @invocableVariable
   public string Gender;
   @invocableVariable
   public string Aadhaar;
   @invocableVariable
   public string PAN;
   @invocableVariable
   public String Preferred_Social_Media;
   @invocableVariable
   public String Preferred_Video_Content;
   @invocableVariable
   public String Avg_spend_on_e_commerce_websites_a_month;
   @invocableVariable
   public string Facebook_Handle;
   @invocableVariable
   public string Twitter_Handle;
   
   @invocableVariable
   public string Insta_Handle;
   @invocableVariable
   public string Degree_of_preference_for_Maruti_car;
   @invocableVariable
   public string Maruti_service_is_value_for_money;
   @invocableVariable
   public string Preference_for_MGA_or_non_MGA;
   @invocableVariable
   public string Maruti_Insurance_better_than_competition;
   @invocableVariable
   public string Did_you_even_buy_a_Non_Maruti_Insurance;
   @invocableVariable
   public Decimal Attempt_Screen_1;
   @invocableVariable
   public Decimal Attempt_Screen_2;
   @invocableVariable
   public Decimal Attempt_Screen_3;
   @invocableVariable
   public Decimal Attempt_Screen_4;
   @invocableVariable
   public Decimal Attempt_Screen_5;
   @invocableVariable
   public Decimal Attempt_Screen_6;
   @invocableVariable
   public Decimal Attempt_Screen_7;
   @invocableVariable
   public string Reason_s_for_churn_out_from_Maruti;
   @invocableVariable
   public Decimal PIN;
   @invocableVariable
   public string Languages_Known;
   @invocableVariable
   public Decimal Year_of_1st_job_after_graduation_YYYY;
   @invocableVariable
   public Decimal Graduation_year_of_the_individual_YYYY;
   @invocableVariable
   public string Auto_Journals;
   @invocableVariable
   public string Degree_Of;
   @invocableVariable
   public string Parking_Space_at;
   @invocableVariable
   public string Purpose_Of_Vehicle;
   @invocableVariable
   public string Age_Of_Two_Wheeler_Owned;
   @invocableVariable
   public string Models_Enquired_From_Competitors;
   @invocableVariable
   public Decimal Number_Of_Two_Wheelers_Owned;
   @invocableVariable
   public string Who_drives_the_car;
   @invocableVariable
   public string Distance_Of_Home_From_Office_In_Kms;
   @invocableVariable
   public string Type_Of_Two_Wheeler_Owned;
   @invocableVariable
   public Decimal Number_Of_Children;
   @invocableVariable
   public string Did_You_Become_A_Parent_In_Last_1_Year;
   @invocableVariable
   public Date Date_Of_Birth_Of_Child_1;
   @invocableVariable
   public Date Date_Of_Birth_Of_Child_2;
   @invocableVariable
   public string Average_Household_Savings;
   @invocableVariable
   public Date Parents_Marriage_Anniversary;
   @invocableVariable
   public Date Anniversary_Date;
   @invocableVariable
   public string Has_Anyone_In_The_Family_Of_The_Individu;
   @invocableVariable
   public Decimal Number_Of_Dependents;
   @invocableVariable
   public Date PersonBirthdate;
 @invocableVariable
   public Decimal Score_Overall;

@invocableVariable
   public Decimal Score_Screen_1;
@invocableVariable
   public Decimal Score_Screen_2;
@invocableVariable
   public Decimal Score_Screen_3;
@invocableVariable
   public Decimal Score_Screen_4;
@invocableVariable
   public Decimal Score_Screen_5;
@invocableVariable
   public Decimal Score_Screen_6;
@invocableVariable
   public Decimal Score_Screen_7;
@invocableVariable
   public String Personal_Annual_Income_in_Lacs;
@invocableVariable
   public String Profession_Type;
@invocableVariable
   public String Number_Of_Maruti_Cars_Owned_In_Immediate;
@invocableVariable
   public String accSVOCID;
@invocableVariable
   public String oppSVOCID;
   @invocableVariable
   public String opportunityId;
    @invocableVariable
   public String accountId;



        
           
        
    public GetAccountCustomerProfileWrp() {

    }
}

}