/**
* @File Name          : OpportunityTriggerHandler_Strategy.cls
* @Description        : Trigger handler class for Opportuntiy (Enquiry)
* @Author             : Nitish Bansal
* @Group              :
* @Last Modified By   : Nitish/Anuj
* @Last Modified On   : 11/06/2020, 1:14:54 PM
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    11/06/2020, 1:14:54 PM     Nitish Bansal            Initial Version

**/

public without sharing class OpportunityTriggerHandler_Strategy extends TriggerHandler {


    private map < string, list < opportunity >> channelOpportunityMap;
    private Map < String, Map < Id, Opportunity >> channelOpportunityOldValuesMap;
    private Map < String, Map < Id, Opportunity >> channelOpportunityNewValuesMap;

    private static Id accessoriesSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsUtility.ACCESSORIES_SALES_CONST).getRecordTypeId();
    public static Id partsSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsUtility.PARTS).getRecordTypeId();
    public static Id vehicleSalesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsUtility.OPPORTUNITY_VEHICLE_SALES_RECORDTYPE).getRecordTypeId();
    private static Id msdsRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsUtility.MSDS).getRecordTypeId();

    //Constructor -- assigns all the trigger context variables objects into class variables defined above
    public OpportunityTriggerHandler_Strategy() {

        channelOpportunityMap = new Map < String, List < Opportunity >> ();
        channelOpportunityNewValuesMap = new Map < String, Map < Id, Opportunity >> ();
        channelOpportunityOldValuesMap = new Map < String, Map < Id, Opportunity >> ();

        String pricebook2Id = '';
        StandardPriceBookId__c lsPB = StandardPriceBookId__c.getInstance();

        for (Opportunity opp: (List < Opportunity > ) Trigger.new) {
            /* Added this condition by Shaikh Mufiz 29-10-2020
               This conditions are using for assigning record type after converted lead - Start*/
            if(Trigger.isInsert && Trigger.isBefore && (String.isNotBlank(opp.Interested_in_New_Car__c) || String.isNotBlank(opp.Interested_in_TV__c))){
                if(opp.Interested_in_New_Car__c == 'Yes'){
                   opp.recordtypeid = vehicleSalesId;
                }else if(opp.Interested_in_TV__c == 'No' &&  opp.Upsell_Cross_Sell_Tele_Caller__c.contains('MSGA')){
                    opp.recordtypeid = accessoriesSalesId;
                    //As per the validation stage name should be open for accessories record type
                    opp.StageName = 'Open';
                }
            }/* Added this condition by Shaikh Mufiz 29-10-2020 - END */
            if (lsPB != null && lsPB.SetOptyRecordTypeId__c == true) {
                if (opp.dms_enquiry_name__c != null && (opp.dms_enquiry_name__c.startsWith('SF') || opp.dms_enquiry_name__c.startsWith('WGP')) && opp.recordtypeid != accessoriesSalesId) {
                    opp.recordtypeid = accessoriesSalesId;
                }else if (opp.dms_enquiry_name__c != null && opp.dms_enquiry_name__c.startsWith('ENQM') && opp.recordtypeid != msdsRTId) {
                    opp.recordtypeid = msdsRTId;
                }else if (opp.dms_enquiry_name__c != null && opp.dms_enquiry_name__c.startsWith('ENQP') && opp.recordtypeid != partsSalesId) {
                    opp.recordtypeid = partsSalesId;
                }else if (opp.dms_enquiry_name__c != null && !opp.dms_enquiry_name__c.startsWith('ENQM') && !opp.dms_enquiry_name__c.startsWith('ENQP') && opp.dms_enquiry_name__c.startsWith('ENQ') && opp.recordtypeid != vehicleSalesId) {
                    opp.recordtypeid = vehicleSalesId;
                }
            }

            if (!channelOpportunityMap.containsKey(opp.RecordtypeId))
                channelOpportunityMap.put(opp.RecordtypeId, new List < Opportunity > ());
            channelOpportunityMap.get(opp.RecordtypeId).add(opp);

            if (!channelOpportunityNewValuesMap.containsKey(opp.RecordtypeId))
                channelOpportunityNewValuesMap.put(opp.RecordtypeId, new Map < Id, Opportunity > ());
            channelOpportunityNewValuesMap.get(opp.RecordtypeId).put(opp.Id, opp);

        }

        for (Opportunity opp: trigger.isUpdate ? (List < Opportunity > ) Trigger.old : new List<Opportunity> ()) {
            if (!channelOpportunityOldValuesMap.containsKey(opp.RecordtypeId))
                channelOpportunityOldValuesMap.put(opp.RecordtypeId, new Map < Id, Opportunity > ());
            channelOpportunityOldValuesMap.get(opp.RecordtypeId).put(opp.Id, opp);

        }

    }
    //Methods executions before Insert of Enquiry
    public override void beforeInsert() {
        for (String key: channelOpportunityMap.keyset()) {
            OpportunityTriggerContext opBI = new OpportunityTriggerContext(key);
            opBI.beforeInsert(channelOpportunityMap.get(key));
        }
    }


    //Methods executions before update of Enquiry
    public override void beforeUpdate() {
        for (String key: channelOpportunityMap.keyset()) {
            OpportunityTriggerContext opBI = new OpportunityTriggerContext(key);
            opBI.beforeUpdate(channelOpportunityMap.get(key),channelOpportunityNewValuesMap.get(key), channelOpportunityOldValuesMap.get(key));
        }

    }


    //Method executions after insert of Enquiry
    public override void afterInsert() {
        for (String key: channelOpportunityMap.keyset()) {
            OpportunityTriggerContext opBI = new OpportunityTriggerContext(key);
            opBI.afterInsert(channelOpportunityMap.get(key), channelOpportunityNewValuesMap.get(key), channelOpportunityOldValuesMap.get(key));
        }
    }


    //Methods executions after update of Enquiry
    public override void afterUpdate() {
        for (String key: channelOpportunityMap.keyset()) {
            OpportunityTriggerContext opBI = new OpportunityTriggerContext(key);
            opBI.afterUpdate(channelOpportunityMap.get(key), channelOpportunityNewValuesMap.get(key), channelOpportunityOldValuesMap.get(key));
        }

    }

}