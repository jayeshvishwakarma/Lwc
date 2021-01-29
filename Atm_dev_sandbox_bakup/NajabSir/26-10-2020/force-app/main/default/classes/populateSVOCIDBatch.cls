//populateSVOCIDBatch bat = new populateSVOCIDBatch('select id, Corporate_Code__c,FirstName,LastName,MiddleName,SVOC_ID__c,LastModified_SVOC_Time_Stamp__c,Employer_Name__c from Account where CREATEDDATE = YESTERDAY');
//Database.executeBatch(bat,5000);
//Sample Execution Query


global with sharing class populateSVOCIDBatch implements Database.Batchable<sObject>{

    //Configurable field to ensure that the query is configrable.
    global final String Query;


    global populateSVOCIDBatch(string q) {
        Query = q;
    }


   global Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator(query);
   }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
            list<Account> accList = (list<Account>) scope; //List to Iterate through
            set<string> corporateCodeSet = new set<string>(); //Set to get all the values
            map<string,Id> corpCodeMap = new map<string,Id>();//Map with COrporCode as the key and Id as value

        //Loop Through account and get the non blank corporate code ones.
            for(Account acc :accList){
                if(String.isNotBlank(acc.Corporate_Code__c)){
                    corporateCodeSet.add(acc.Corporate_Code__c);
                }
            }

        //Populate the map
        for(Corporate__c corp :[select id, Corporate_Code__c 
                                from  Corporate__c
                                Where Corporate_Code__c in :corporateCodeSet]){
            corpCodeMap.put(corp.Corporate_Code__c,corp.id);
        }

        for(Account acc :accList){
            //Captalize the Names
                acc.FirstName = String.isNotBlank(acc.FirstName) ? acc.FirstName.toUpperCase() : '';
                acc.LastName = String.isNotBlank(acc.LastName) ? acc.lastname.toUpperCase() :'';
                acc.MiddleName = String.isNotBlank(acc.MiddleName) ? acc.middlename.toUpperCase() : '';

            //Update the Last Modified Time Stamp
                String data = ConstantsUtility.SVOCID_CONST+ConstantsUtility.COLON+acc.SVOC_ID__c+ConstantsUtility.COMMA;
                data+=ConstantsUtility.TIMESTAMP_CONST+ConstantsUtility.COLON+String.valueOf(Datetime.now());
                acc.LastModified_SVOC_Time_Stamp__c = data;

            //Update the corpCode
                if(String.isNotBlank(acc.Corporate_Code__c)&&corpCodeMap.containsKey(acc.Corporate_Code__c)){
                    acc.Employer_Name__c = corpCodeMap.get(acc.Corporate_Code__c);
                }

        }

        //Update Accounts accList
        //Database.Update(accList,false);
        update accList;

    }

   global void finish(Database.BatchableContext BC){

   }

}