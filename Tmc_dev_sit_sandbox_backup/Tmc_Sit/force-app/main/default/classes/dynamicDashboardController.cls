public with sharing class dynamicDashboardController {

	@AuraEnabled
	public static list<Report_Configuration__c> getConfigs(){
		string profileName = [select Id,Name from profile where Id=:UserInfo.getProfileId()].get(0).Name;
		list<Report_Configuration__c> configs = new list<Report_Configuration__c>();

		list<Report_Configuration__c> userConfig =  [SELECT Id, Report_Conf__c,Profile_Id__c,Report_Name__c,User__c FROM Report_Configuration__c WHERE (User__c = :UserInfo.getUserId()) AND My_Reports__c = false ORDER BY Sort_order__c ASC];

		if(userConfig.size()==0){
			
		 configs =  [SELECT Id, Report_Conf__c,Profile_Id__c,Report_Name__c,User__c FROM Report_Configuration__c WHERE (Profile_Id__c=:profileName) AND My_Reports__c = false ORDER BY Sort_order__c ASC];
		}else{
			configs = userConfig;
		}

		return configs;
	}

	@AuraEnabled
	public static map<integer,Id> getReportQueryCount(string reportId,string day){
		map<integer,Id> finalResult = new map<integer,Id>();
		Integer recCount;
		string query = '';
		Report_Conf__c queryies = [SELECT Id,Report_ID__c,Report_Query__c FROM Report_Conf__c where Id =: reportId];

		if(queryies.Report_Query__c.contains('GROUP')){
			recCount = dynamicDashboardController.getRecordCount(queryies.Report_Query__c);
			
		}else{
			if(string.isBlank(day)){
		 query += queryies.Report_Query__c;
		}else{
			query += queryies.Report_Query__c + day;
		}
		list<sobject> objQuery = Database.query(query);
		recCount = objQuery.size();
		}
	
		finalResult.put(recCount,queryies.Report_ID__c);

		return finalResult;

	}

	public static Integer getRecordCount(string soqlQuery){
		List<SObject> sObjectRecords = Database.query(soqlQuery);
		Integer recordCount = 0;
		for ( SObject s : sObjectRecords ) {
			recordCount += Integer.valueOf(s.get('c'));
		}
		return recordCount;
	}

	@AuraEnabled
	public static list<Report_Configuration__c> getMyReportConfigs(){
		return [SELECT Id, Report_Conf__c,Report_Name__c,User__c FROM Report_Configuration__c WHERE User__c = :UserInfo.getUserId() AND My_Reports__c = true ORDER BY Sort_order__c ASC];
	}



}