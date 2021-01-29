/**
 * @Autho:- Mahith Madwesh
 * @Company-: Salesforce
 * @Description-: APEX Trigger Handler class of BrochureRequestTrigger
 * =============================================================
 * Version   Date            Author      Modification
 * =============================================================
 * 1.0       13 Aug 2020    Mahith     Intial Version
 * 2.0       17 Aug 2020    Mahith     Added the logic to get the records created in 10min
 link or throw error
 **/
public with sharing class BrochureRequestTriggerHandler {
	//    private list<Brochure_Request__c> brochureItems;
	// public BrochureRequestTriggerHandler() {
	//     this.brochureItems= (list<Brochure_Request__c>) Trigger.new;
	// }
	//  public override void beforeInsert(){
	//     SendBrochure(this.brochureItems);
	// }
	/**
	 @Author:                  Mahith Madwesh
	 @Created Date :           12 Aug 2020
	 @Discription:             Brouchure Request task to create MC Communication records
	 */
	public static void sendBrochure(List<Brochure_Request__c> tasks) {
		List<Opportunity> enquiryCreatedByUserInLast10Mins = new List<Opportunity>();
		// Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(ConstantsUtility.SEND_BROCHURE).getRecordTypeId();
		if ( Opportunity.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.Contact.fields.Id.isAccessible() && Schema.SObjectType.Contact.fields.CreatedById.isAccessible() ) {
			enquiryCreatedByUserInLast10Mins = [SELECT 
			                                          Id, 
			                                          CreatedById
			                                    FROM Opportunity
			                                    WHERE SystemModstamp > :Datetime.now(  ).addMinutes( - 10) and CreatedById = :UserInfo.getUserId()];
		}
		for ( Brochure_Request__c br4 : tasks ) {
			if ( br4.Enquiry__c == null ) {
				list<Brochure_Request__c> tempTasksList = new List<Brochure_Request__c>();
				if ( enquiryCreatedByUserInLast10Mins.size() == 0 || enquiryCreatedByUserInLast10Mins.size() > 1 ) {
					br4.addError('Please select an Enquiry');
				}
				else if ( enquiryCreatedByUserInLast10Mins.size() == 1 ) {
					br4.Enquiry__c = enquiryCreatedByUserInLast10Mins.get(0).Id;
				}
			}
		}
		Set<Id> enquiryIdSet = new Set<Id>();
		map<Id, String> taskModelmap = new Map<Id, String>();
		map<String, Brochure_Request__c> taskPhonemap = new Map<String, Brochure_Request__c>();
		for ( Brochure_Request__c tsk : tasks ) {
			// && tsk.RecordTypeId == recordTypeId
			if ( tsk.Enquiry__c != null && String.ValueOf(( tsk.Enquiry__c ).getSobjectType()) == ConstantsUtility.OPPORTUNITY ) {
				enquiryIdSet.add(tsk.Enquiry__c);
				taskModelmap.put(tsk.Enquiry__c, tsk.Model__c);
				taskPhonemap.put(tsk.Enquiry__c, tsk);
			}
		}
		if(enquiryIdSet.size()>0){
		    OpportunityTriggerHelper.esclationLevels=taskModelmap;
		    OpportunityTriggerHelper.sendBrochureRequestPhone=taskPhonemap;
		    BrochureRequestGenerateFilePublicURL.CreateMCRecord(ConstantsUtility.SEND_BROCHURE_METADATA,enquiryIdSet,ConstantsUtility.OPPORTUNITY,'');
		}
	}
}