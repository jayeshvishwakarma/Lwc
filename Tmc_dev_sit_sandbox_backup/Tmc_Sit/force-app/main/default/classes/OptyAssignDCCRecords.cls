/**
 * @description       : 
 * @author            : Rajesh Ramachandran
 * @group             : 
 * @last modified on  : 09-08-2020
 * @last modified by  : Rajesh Ramachandran
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   09-08-2020   Rajesh Ramachandran   Initial Version
**/
public without sharing class OptyAssignDCCRecords {

        /**
            Author: Rajesh Ramachandran
            Company: Techmatrix
            Description: Method to assign Ownership of Enquiry(Opportunity) to MDS FDE at outlet or accessory manager at outlet if created by dealer callcenter
            Inputs: None
            Returns: void
            History:
            ====================================================
            1.0     16 Jul 2019  Prabhat Sharma  Initial Version
    **/
    public static void assignDCCCreatedEnquiry(List<Opportunity> newOppList) {
        System.debug('DCC created enquiry');

        //get profile Ids of Dealer CallCenter Users
        String dccProfileIds = Label.DealerCCProfiles;
        boolean isDCCCreated = dccProfileIds.contains(UserInfo.getProfileId());
        
        if (newOppList.size() == 1 && isDCCCreated == true){
            Id MSDSSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MSDS').getRecordTypeId(); 
            Id vehicleSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsUtility.OPPORTUNITY_VEHICLE_SALES_RECORDTYPE).getRecordTypeId();
            Id accessoriesSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsUtility.ACCESSORIES_SALES_CONST).getRecordTypeId();
        
            //Set to add Dealership from Enquiry(Opportunity).
            Set<Id> dealerAccountIds = new Set<Id>();

            // Map to add Account Id and Sales SPOC(s) User Ids.
            Map<Id, set<String>> accountSalesSpocUserIdsMap = new Map<Id, set<String>>();
            Map<Id, set<String>> accountAccSpocUserIdsMap = new Map<Id, set<String>>();

            //Dealer Channel Account Map
            Map<Id, Account> accountChannelMap = new Map<Id, Account>();
            //This to randomly assign the SPOCs for Opportunities
            Integer counter = 0;

            //Loop through all new Opportunities
            for (Opportunity opp : newOppList) {
                if (opp.Dealership__c != null) //Removed vehile sales record type Id condition for Accessories Enquiries
                    dealerAccountIds.add(opp.Dealership__c);
            }
            // Set to add  SPOC(s) User Ids.
            set<String> tempSpocIds;
            set<String> tempAccSpocIds;

            //Query Sales SPOCs on Dealer(Account)
            if (dealerAccountIds.size() > 0) {
                for (Account acc : [
                    SELECT Id,Sales_SPOC_1__c,Sales_SPOC_2__c,Sales_SPOC_3__c,Sales_SPOC_4__c,Sales_SPOC_5__c,Channel__c,Accessories_SPOC_1__c,Accessories_SPOC_2__c
                    FROM Account
                    WHERE Id IN:dealerAccountIds
                ]) {

                    //Adding channel as value and Dealership ID as key
                    accountChannelMap.put(acc.Id, acc);

                    tempSpocIds = new Set<String>();
                    tempAccSpocIds = new Set<String>();
                    if (acc.Sales_SPOC_1__c != null)
                        tempSpocIds.add(acc.Sales_SPOC_1__c);
                    if (acc.Sales_SPOC_2__c != null)
                        tempSpocIds.add(acc.Sales_SPOC_2__c);
                    if (acc.Sales_SPOC_3__c != null)
                        tempSpocIds.add(acc.Sales_SPOC_3__c);
                    if (acc.Sales_SPOC_4__c != null)
                        tempSpocIds.add(acc.Sales_SPOC_4__c);
                    if (acc.Sales_SPOC_5__c != null)
                        tempSpocIds.add(acc.Sales_SPOC_5__c);
                    if (acc.Accessories_SPOC_1__c != null)
                        tempAccSpocIds.add(acc.Accessories_SPOC_1__c);
                    if (acc.Accessories_SPOC_2__c != null)
                        tempAccSpocIds.add(acc.Accessories_SPOC_2__c);

                    //Fill the Map with Dealer(Account) and Sales SPOC(s) User Ids.
                    accountSalesSpocUserIdsMap.put(acc.Id, tempSpocIds);
                    accountAccSpocUserIdsMap.put(acc.Id, tempAccSpocIds);
                }

                map<String, String> channelMap = new map<String, String>(ConstantsUtility.channelModelMap);
                List<Opportunity> tempOpty = new list<Opportunity>();
                //Assign Enquiry(Opportunity) Owner from Integration user to Sales SPOC(s)
                for (Opportunity opty : newOppList) {
                    //ignoring the owner update which orginally consist of owner id other than  DMS Admin. ---@Satish
                    if (opty.RecordTypeId == vehicleSalesId || opty.RecordTypeId == MSDSSalesId){
                        List<String> spocUserList = new List<String>(accountSalesSpocUserIdsMap.get(opty.Dealership__c));

                        //Added check for size because Random Utility was failing to size =1
                        if (spocUserList.size() > 1) {
                            opty.OwnerId = RandomUtility.findRandomStringFromList(spocUserList);
                        } else if (spocUserList.size() == 1) {
                            opty.OwnerId = spocUserList[0];
                        }

                        tempOpty.add(opty);
                    }
                    else if (opty.RecordTypeId == accessoriesSalesId){
                        List<String> accSpocUserList = new List<String>(accountAccSpocUserIdsMap.get(opty.Dealership__c));

                        //Added check for size because Random Utility was failing to size =1
                        if (accSpocUserList.size() > 1) {
                            opty.OwnerId = RandomUtility.findRandomStringFromList(accSpocUserList);
                        } else if (accSpocUserList.size() == 1) {
                            opty.OwnerId = accSpocUserList[0];
                        }

                        tempOpty.add(opty);                
                    }
                    //Default LOB and Dealership Channel
                    if (accountChannelMap.containsKey(opty.Dealership__c) && accountChannelMap.get(opty.Dealership__c).Channel__c != null) {
                        if (channelMap.containsKey(accountChannelMap.get(opty.Dealership__c).Channel__c)) {
                            opty.line_of_business__c = channelMap.get(accountChannelMap.get(opty.Dealership__c).Channel__c);
                            opty.Temporary_LOB_Admin_use__c = channelMap.get(accountChannelMap.get(opty.Dealership__c).Channel__c);
                            opty.dealership_channel__c = channelMap.get(accountChannelMap.get(opty.Dealership__c).Channel__c);
                        }
                    }
                }
             /*   //Assign the list to a static variable for trigger after event to get the Enquiry Ids and create MC records
                if (tempOpty.size() > 0) {
                    OpportunityTriggerHelper.spocOptyList = tempOpty;
                }*/
            }

            system.debug('== assignDCC Enquiry to SPOC ');
        }
    }

}