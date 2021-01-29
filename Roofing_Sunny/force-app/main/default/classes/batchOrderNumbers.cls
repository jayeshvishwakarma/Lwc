/***************************************************************************************************
Author : Mukesh Bhardwaj.
Company : Threshold Consulting
Description : Batch Class to Update Case with matching Order record Id.
Date On : 3rd May 2013.
Initial Version
****************************************************************************************************/
global class batchOrderNumbers implements Database.Batchable<sObject>
{
    //variable declaration
    global final String query;

    //Constructor to form query to be executed in the start method
    global batchOrderNumbers()
    {
        //this query is for the testclass
        if(test.IsrunningTest())
            query = 'SELECT ID, Order__c, Order_Number__c FROM Case WHERE Order__c = null AND Order_Number__c != null LIMIT 1';
        //this query it to get all Case records where Order__c field does not have any value nad Order_Number__c field has value    
        else
            query = 'SELECT  ID, Order__c, Order_Number__c FROM Case WHERE Order__c = null AND Order_Number__c != null' ;
    }

    //run the above constructor formed query to fetch case records
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }

    //this is execute method where assignment of Order rec id is done in the Case object records
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        //localvariables declarations
        Set<String> caseOrderNumberSet = new Set<String>();
        Map<String,Id> orderNameIdMap = new Map<String,Id>();
        List<Case> caseListToBeUpdate = new List<Case>();
        
        //based on the scope of Case we are getting from start method we prepare a set of Order Number from case
        //get a list of Case to be updated
        for(sObject s : scope)
        {   
            Case c = (Case)s;
            caseOrderNumberSet.add(c.Order_Number__c);
            caseListToBeUpdate.add(c);
        }
        //prepare a map of Order's Id and Name
        if(caseOrderNumberSet.size() > 0)
        {
            for(Order o : [SELECT Name,Id FROM Order WHERE Name IN : caseOrderNumberSet])
            {
                orderNameIdMap.put(o.Name,o.Id);
            }
        }
        //based on the map populated above get the Id of the Order based on the matching Order Name.
        //Update the case records with the Order Ids.   
        if(caseListToBeUpdate.size() > 0)
        {
            for(Case c : caseListToBeUpdate)
            {
                if(orderNameIdMap.containsKey(c.Order_Number__c))
                    c.Order__c = orderNameIdMap.get(c.Order_Number__c);
            }
            update caseListToBeUpdate;
        }
    }

    global void finish(Database.BatchableContext BC)
    {
    }
}