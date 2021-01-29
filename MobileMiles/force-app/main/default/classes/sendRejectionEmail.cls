public with sharing class sendRejectionEmail {
	@future
	public static void sendEmail(Id oppId, Id etId){
		//Query database for opportunity
		list<Opportunity> o = [SELECT Id, Name, Rejected__c, OwnerId FROM Opportunity WHERE Id = :oppId LIMIT 1];
		//Reset rejected field
		if(!o.isEmpty()){
			o[0].Rejected__c = false;
			//Set up email
			//New instance of a single email message
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			//Send email to opportunity owner
   			mail.setTargetObjectId(o[0].OwnerId);
			//Set email template
			mail.setTemplateId(etId);
			//Set opportunity record
			mail.setWhatId(oppId);   
			//Set save as activity to false
			mail.setSaveAsActivity(false);
			//Send email
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			//Update opportunity
			update o;
		}
	}
	
	@isTest(seeAllData=true)
	public static void testSendRejectionEmail(){
		//Setup test data
		Account a = new Account(Name='Test');
		insert a;
		Opportunity o = new Opportunity(Name='Test',AccountId=a.Id,StageName='Open',CloseDate=System.now().date());
		insert o;
		//Update rejected field on opportunity to fire trigger and asynchronous method
		o.Rejected__c = true;
		update o;
	}
}