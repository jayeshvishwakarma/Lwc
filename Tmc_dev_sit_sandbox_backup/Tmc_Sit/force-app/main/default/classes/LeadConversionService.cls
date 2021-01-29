/**
* @File Name          : LeadConversionService.cls
* @Description        : Lead Conversion Service Class
* @Author             : Rajesh Ramachandran
* @Group              :
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 08-03-2020
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0         17/01/2020               Mahith Madwesh         Initial Version
*/
public without sharing class LeadConversionService {

    static Id vehicleSalesRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsUtility.OPPORTUNITY_VEHICLE_SALES_RECORDTYPE).getRecordTypeId();

    //update
    public static void convertLead(List<Lead> newLeadList, Map<Id, Lead> oldLeadMap){
        List<Opportunity> oppsToCreate  = new List<Opportunity>();
        for(Lead newLead : newLeadList){
            Lead oldLead = oldLeadMap.get(newLead.Id);
            if(newLead.Status != oldLead.Status && newLead.Status == 'Converted_won'){
                Opportunity newOpp = new Opportunity();
                newOpp.First_Name__c = newLead.FirstName;
                newOpp.Middle_Name__c = newLead.MiddleName;
                newOpp.Last_Name__c = newLead.LastName;
                newOpp.Mobile__c = newLead.MobilePhone;
                newOpp.Email__c = newLead.Email;
                newOpp.Title__c = newLead.Salutation;
                newOpp.Dealership_Channel__c = newLead.Dealership_Channel__c;
                newOpp.Name = newLead.FirstName + newLead.LastName + '(Car)';
                if(newOpp.Dealership_Channel__c == ConstantsUtility.COMMERCIAL_LINEOFBUSINESS){
                    newOpp.Name = newOpp.Name.replace(ConstantsUtility.NEWCAR_ENQ, ConstantsUtility.NEW_Vehicle_ENQ);
                }
                newOpp.RecordTypeId = vehicleSalesRecordTypeId;
                newOpp.Line_Of_Business__c = newLead.Line_Of_Business__c;
                newOpp.Ad_Details__c = newLead.AdEventName__c;
                newOpp.Buyer_Type__c = newLead.Buyer_Type__c;
                newOpp.Model_Code__c = newLead.Enq_Model__c;
                newOpp.Variant__c = newLead.Variant__c;
                newOpp.Color__c = newLead.Color__c;
                newOpp.Exchange_Color__c = newLead.Exchange_Color__c;
                newOpp.Exchange_Vehicle_x__c = newLead.Exchange_Vehicle__c;
                newOpp.Gender__c = newLead.Gender__c;
                newOpp.Customer_Type__c = newLead.Customer_Type__c ;
                newOpp.LeadSource  = newLead.LeadSource ;
                newOpp.Test_Drive_Given__c =newLead.Test_Drive_Given__c;
                newOpp.StageName = 'New';
                newOpp.CloseDate = System.today().addDays(90);
				//added by Rajesh for lead conversion error in prod
                newOpp.CampaignId = newLead.AdEventName__c;
                oppsToCreate.add(newOpp);
            }
        }
       if(!oppsToCreate.isEmpty()){
            //code change to show error on UI if lead conversion is being done from UI
            if (oppsToCreate.size() == 1 && newLeadList.size() == 1){
                try {
                    insert oppsToCreate;
                }
                catch(Exception ex){
                    newLeadList[0].addError(ex.getDmlMessage(0));
                    ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace(); ehst.componentName='LeadConversionService'; ehst.userId=UserInfo.getUserId(); ExceptionHandler.LogError('LeadConversionService', ex.getMessage(), 'LeadConversionservice', '', ehst);
                }
            }
            else {
                List<Database.SaveResult> saveResultList = Database.insert(oppsToCreate, false);
                for (Integer i = 0; i < saveResultList.size(); i++) {
                    Database.SaveResult sr = saveResultList.get(i);
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted opporutnity. Account ID: ' + sr.getId());
                    } else {
                        List<String> errors = new List<String>();
                        // Operation failed, so get all errors
                        for(Database.Error err : sr.getErrors()) {
                            errors.add(err.getStatusCode() + ': ' + err.getMessage());
                        }
                        oppsToCreate.get(i).addError(String.join(errors, ';'));
                    }
                }

            }
        }
    }
}