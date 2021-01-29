/**
 * @File Name          : listViewFilterApex.cls
 * @Description        : List view logic for mass update list views
 * @Author             : Mahith Madwesh
 * @Group              :
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 7/2/2020, 2:00:11 PM
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0    10/06/2020, 2:45:00 PM         Mahith                Initial Version
 * 2.0    21/06/2020, 1:12:00 PM         Mahith                Updated methods to check In Progress tasks
 * 3.0    23/06/2020, 10:00:00 PM        Nitin                 Updated getUserProfileName to get List<Campaign>
 **/
public with sharing class listViewFilterApex{

    static map<id,string> caseOwnerIds  = new Map<Id,String>();
    static set<id> taskOwnerIds  = new set<Id>();



    /**
     Author: Mahith Madwesh
     Company: Salesforce
     Description: To get the users with Manager Id as the current User
     Inputs:
     Returns:
     History:
     ================
     1.0     10 JUN 2020      Mahith     Initial Version
     */
    @AuraEnabled
    public static list<user> getCurrentTeamUsers(string searchTerm){
	   // String key = '%' + searchTerm + '%';
	   String key = searchTerm + '%';
        list<user> userRecords = new list<User>();
        user currentUserInfo = [SELECT 
                      Id, 
                      Name
                      
                FROM User
                WHERE Id = :userInfo.getUserId()];
                userRecords.add(currentUserInfo);
        list<user> subordinateUsers =  [SELECT 
                      Id, 
                      Name, 
                      ManagerId,IsActive 
                FROM User
                WHERE Name LIKE :key AND ManagerId = :userInfo.getUserId() AND IsActive = true 
                WITH SECURITY_ENFORCED
                LIMIT 100];
        
        for(user u: subordinateUsers){
            userRecords.add(u);
        }
        return userRecords;
    }



    /**
     Author: Mahith Madwesh
     Company: Salesforce
     Description: To save Task change owners selected
     Inputs:
     Returns:
     History:
     ================
     1.0     10 JUN 2020      Mahith     Initial Version
     */
        @AuraEnabled
    public static map<string,string> saveTaskChangeOwners(list<task> tasksList, string newOwnerId,Boolean saveCaseChange){
          BasicReturn br=new BasicReturn();
    
        list<id> newCasesIds = new list<id>();
        Set<Id> taskChangedOwner = new Set<Id>();
        list<Id> caseChangedOwnerSuccess = new list<Id>();
        set<Id> caseChangedOwnerFail = new set<Id>();
         string logErrors = '';
        list<task> taskOwnerTobeChanged = new List<task>();
        map<string,string> finalResult = new map<string,string>();
        list<task> nonCompleteTask = new list<task>();
        list<case> caseList = new list<case>();
        list<task> newTasksList = new list<task>();
            set<Id> removeCase = new set<Id>();
            try{
        for(task tl: tasksList){
            if(tl.Status != 'Completed'|| tl.Status != 'In Progress'){
                nonCompleteTask.add(tl);// To store only open tasks
            }else {
                finalResult.put(tl.Subject + '-' + tl.id,'Task is already Closed/In Progress. Please select only open tasks');
            }
        }

        if(saveCaseChange == true){
            for (task l : nonCompleteTask){
                if(l.case__c!=null){
                    newCasesIds.add(l.case__c);
                }else{
                    newTasksList.add(l);
                }
            
        }
        list<case> relatedCases = [SELECT 
                                     Id, 
                                     IsClosedOnCreate,ClosedDate,Status,CaseNumber  
                               FROM Case
                               WHERE Id in :newCasesIds];// To get all the related cases linked to current selected tasks

        //Get all related tasks and eliminate the case containing in-progress task
    
        list<task> inProgressTasks = [SELECT Id,Status,Case__c FROM Task WHERE Case__c IN:relatedCases];// To get Other related tasks link to case of current selected tasks


        for(task t1:inProgressTasks){
            if(t1.Status=='In Progress'){
                removeCase.add(t1.Case__c);// To collect all case Ids with In progress tasks
            }
        }

        for(case cl:relatedCases){
            if(!removeCase.contains(cl.Id)){
                caseList.add(cl);// For owner to be changed
            }else{
                caseChangedOwnerFail.add(cl.Id);// To not update the case and tasks linked to the stored case Ids
            }
        }
    }
        
                if(!caseList.isEmpty() && saveCaseChange == true){
                map<string,string> finalResult1 = listViewFilterApex.saveCaseChangeOwner(caseList, newOwnerId,false);

                //To get the success Case Owner Changed
                    for(Id caseId: caseOwnerIds.keySet()){
                        if( caseOwnerIds.get(caseId).contains('sucess')){
                            caseChangedOwnerSuccess.add(caseId);
                        }
                    }
                }
                if(saveCaseChange == true){
                    taskOwnerTobeChanged = [SELECT Id FROM Task WHERE Case__c IN:caseList and case__r.ownerid = :newOwnerId and status = 'Open']; //To get all the tasks to which previously the case owner was changed
                        for (task tl : taskOwnerTobeChanged){
                            tl.OwnerId = newOwnerId;
                            newTasksList.add(tl);
                    }
                }else if(saveCaseChange == false){
                    for(task rt:nonCompleteTask){
                        rt.OwnerId = newOwnerId;
                        newTasksList.add(rt);
                    }
                    
                }
                    

                if(!newTasksList.isEmpty() ){

                Database.SaveResult[] savedRecordsList = Database.update( newTasksList, false );
                for (Integer i = 0; i < savedRecordsList.size(); i++){
                    if (savedRecordsList.get(i).isSuccess()){
                        System.debug('Records are updated Successfully');
                        taskChangedOwner.add(savedRecordsList.get(i).Id);
                     }
                    
                }
                

                }

                for(task t: nonCompleteTask){
                    if (taskChangedOwner.contains(t.Id)){
                        finalResult.put(t.Subject + '-' + t.Id,'Task Owner Successfully changed');
                        taskOwnerIds.add(t.Id);
                    }else{
                        finalResult.put(t.Subject + '-' + t.id,'Task Owner Could not be changed. Please reach out to support team if needed');
                    }    
                    if(removeCase.contains(t.Case__c)){
                        finalResult.put(t.Subject + '-' + t.Id,'A task linked to the current parent case is \''+'In Progress'+'\'. Hence cannot change the owner of task.');
                    }
                }
            
            
        }
         catch(Exception ex)
        {
            System.enqueueJob(new AsyncExceptionHandler('task owner: ','',ex.getMessage(), '',UserInfo.getUserId(), 'saveTaskChangeOwner'));
            ex.getStackTraceString();
            br.code=0;
            br.message=ex.getMessage();
            br.status='Error';
            
        }
            return finalResult;
    }

    /**
     Author: Mahith Madwesh
     Company: Salesforce
     Description: To save Case change owners selected
     Inputs:
     Returns:
     History:
     ================
     1.0     10 JUN 2020      Mahith     Initial Version
     */
     @AuraEnabled
    public static map<string,string> saveCaseChangeOwner(list<case> caseList, string newOwnerId,boolean taskChange){

        BasicReturn br=new BasicReturn();
    
        
        set<Id> changedCasesList = new set<Id>();
        set<Id> caseChangedOwner = new set<Id>();
        string logErrors = '';
        set<Id> taskChangedOwnerSuccess = new set<Id>();
        list<case> finalCases = new list<case>();
        list<task> relatedTasks = new List<task>();
        set<Id> removeCase = new set<Id>();
        set<Id> tempCaseList = new set<Id>();
        
        map<string,string> finalResult = new map<string,string>();
        list<case> nonClosedCases = new list<case>();
        try{
        for(case cl: caseList){
            if(( cl.ClosedDate != null ) || ( cl.Status == 'Lost' || cl.Status == 'Converted' || cl.Status == 'Closed' )){
                finalResult.put(cl.CaseNumber,'Case is already closed. Please select only open Cases');
            }else{
                nonClosedCases.add(cl);
            }
        }

        if(taskChange == true){
        list<task> tempTasks = new list<task>();
        list<task> currentRelatedTasks = [SELECT Id,Subject,Status,Case__c FROM Task WHERE Case__c IN:nonClosedCases and Status!='Completed'];// Fetch all related Tasks for the current selected case
        for(task rt: currentRelatedTasks){
            if(rt.Status=='In Progress'){
                tempCaseList.add(rt.Case__c);
            }else if(rt.Status!='Completed' && rt.Status!='In Progress'){
                tempTasks.add(rt);
            }
        }

        for(task t1:tempTasks){
            if(!tempCaseList.contains(t1.Case__c) && t1.Status!='Completed'){
                relatedTasks.add(t1);
            }else{
                removeCase.add(t1.Case__c);
            }
        }

        list<Case> casesWithCompletedTasks = [SELECT Id, (SELECT Id FROM Tasks WHERE Status = 'Open' OR Status = 'In Progress') FROM case WHERE Id IN :nonClosedCases];
        for(case c2: casesWithCompletedTasks){
                if (c2.Tasks.size() ==0){
                changedCasesList.add(c2.Id);
                }
        }

        }

        
        
        
            // update changedCasesList;
            if(!relatedTasks.IsEmpty() && taskChange == true){
                map<string,string> finalResult1 = listViewFilterApex.saveTaskChangeOwners(relatedTasks, newOwnerId, false);
                for(string str: finalResult1.keySet()){
                    finalResult.put(str, finalResult1.get(str));
                }

                    taskChangedOwnerSuccess = taskOwnerIds;

                     list<task> changedOwnerOfTasks = [SELECT Id,Subject,Status,Case__c FROM Task WHERE Id IN:taskChangedOwnerSuccess and OwnerId=:newOwnerId ];
                
                    for(task t: changedOwnerOfTasks){
                        if(!removeCase.contains(t.Case__c)){
                            changedCasesList.add(t.Case__c);
                        }
                        
                    }
            }
             
            if(!changedCasesList.isEmpty() && taskChange ==true ){

                for(case c:nonClosedCases){
                    if(changedCasesList.contains(c.Id)){
                    c.OwnerId = newOwnerId;
                    finalCases.add(c);
                    }
                }
                
            }else{
                for(case cs: nonClosedCases){
                    if(!tempCaseList.isEmpty()){
                    if(!tempCaseList.contains(cs.Id)){
                        cs.OwnerId = newOwnerId;
                    finalCases.add(cs);
                    }
                    }else{
                        cs.OwnerId = newOwnerId;
                    finalCases.add(cs);
                    }
                }
            }

                if(!finalCases.isEmpty()){
                Database.SaveResult[] savedRecordsList = Database.update( finalCases, false );
                for (Integer i = 0; i < savedRecordsList.size(); i++){
                    if (savedRecordsList.get(i).isSuccess()){
                        System.debug('Records are updated Successfully');
                        caseChangedOwner.add(savedRecordsList.get(i).Id);
                        // FinalResultMap.put(savedRecordsList.get(i).Id,'Task Succesfully Created');
                    }else if (!savedRecordsList.get(i).isSuccess()){
                         // DML operation failed
                        Database.Error error = savedRecordsList.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        finalCases.get(i);//failed record from the list
                    }
                }
                }

                for(case c: nonClosedCases){
                
                    if(caseChangedOwner.contains(c.Id)){
                        finalResult.put(c.CaseNumber,'Case Owner Successfully changed');
                        caseOwnerIds.put(c.Id,'sucess');
                    }else{
                            finalResult.put(c.CaseNumber,'Case Owner Could not be changed.Please reach out to support team if needed');
                            caseOwnerIds.put(c.Id,'failed');
                    }
                
                }
            
            if(taskChange == true){
            for(case c: nonClosedCases){
                if(removeCase.contains(c.Id)){
                    finalResult.put(c.CaseNumber,'Case has In-Progress Task. Owner Cannot be changed for Cases with In-Progress Tasks.');
                }
            }
            }
            

        }
         catch(Exception ex)
        {
            System.enqueueJob(new AsyncExceptionHandler('task owner: ','',ex.getMessage(), '',UserInfo.getUserId(), 'saveTaskChangeOwner'));
            ex.getStackTraceString();
            br.code=0;
            br.message=ex.getMessage();
            br.status='Error';
            
        }
     return    finalResult;
    }

    /**
     Author: Mahith Madwesh
     Company: Salesforce
     Description: To get the cases based on the filters entered in the list view
     Inputs:
     Returns:
     History:
     ================
     1.0     10 JUN 2020      Mahith     Initial Version
     */
     @AuraEnabled
    public static list<case> getCases(string campaignName, string campaignType, string startMIExpiryDate,string endMIExpiryDate, string status, string OwnerId,string startDate,string endDate){
        list<string> paramString = new list<string>();
        if (string.isNotBlank(campaignName)){
            string string1 = 'campaignId__c = \'' + campaignName + '\'';
            paramString.add(string1);
        }
        if (string.isNotBlank(campaignType)){
            string string2 = 'Type = \'' + campaignType + '\'';
            paramString.add(string2);
        }
        if (string.isNotBlank(startMIExpiryDate)){
            string string3 = 'Expiry_Date__c >=' + startMIExpiryDate;
            paramString.add(string3);
        }
        if (string.isNotBlank(endMIExpiryDate)){
            string string4 = 'Expiry_Date__c <=' + endMIExpiryDate;
            paramString.add(string4);
        }
        if (string.isNotBlank(status)){
            string string5 = 'Status =\'' + status + '\'';
            paramString.add(string5);
        }
        if (string.isNotBlank(OwnerId)){
            string string6 = 'OwnerId =\'' + OwnerId + '\'';
            paramString.add(string6);
        }
        if (string.isNotBlank(startDate)){
            string string7 = 'Pickup_Date__c >=' + startDate ;
            paramString.add(string7);
        }
        if (string.isNotBlank(endDate)){
            string string8 = 'Pickup_Date__c <=' + endDate ;
            paramString.add(string8);
        }
        Id InsuranceRenewalRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MI_Renewal').getRecordTypeId();


        // To be continued....
        string CaseQuery = 'Select Id,Type,CaseNumber,Customer__r.Name,RecordType.Name,Expiry_Date__c,Policy_No__c,Vehicle_Registration_Number__c,Status,Owner.Name,CampaignId__r.Name,ClosedDate,Pickup_Date__c FROM Case WHERE recordTypeId =' + '\'' + InsuranceRenewalRecordType + '\'';
        for (string s : paramString){
            if (string.isNotBlank(s)){
                CaseQuery += ' and ' + s;
            }
        }
        CaseQuery = CaseQuery + ' LIMIT 100';
        list<case> casesList = ( list<Case> )Database.query(CaseQuery);
        return casesList;
    }

    /**
     Author: Mahith Madwesh
     Company: 
     Description: To get picklist values based on sobject and field
     Inputs:
     Returns:
     History:
     ================
     1.0     09 JUL 2020      Mahith     Initial Version
     */
     @AuraEnabled
    public static Map<string, string> getpicklistValues(string sobjectApiName,string picklistfiledName){
        map<string, string> objectMaps = new map<string, string>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(sobjectApiName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map<String, Schema.SObjectField> fields = r.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(picklistfiledName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple){
            System.debug(pickListVal.getLabel() + ' ' + pickListVal.getValue());
            objectMaps.put(pickListVal.getLabel(), pickListVal.getValue());
        }
    
        return objectMaps;
    }


    /**
     Author: Mahith Madwesh
     Company: Salesforce
     Description: To create tasks for the selected case records
     Inputs:
     Returns:
     History:
     ================
     1.0     10 JUN 2020      Mahith     Initial Version
     */
     @AuraEnabled
    public static map<string, string> createDailingList(list<case> caseIds){
        map<string, string> FinalResultMap = new map<string, string>();// To show in a table for the user for Success and Error for cases.
        list<Id> taskCreated = new list<Id>();
        // list<case> selectedCases = caseIds;
        List<Case> allCasesList = new List<Case>();
        list<case> currentSelectedRecords = new list<case>();
        set<Id> currentSelectedSet = new set<Id>();
        set<id> tempset = new set<id>();
        List<Task> newTaskList = new List<Task>();
        String logErrors = '';
        Id InsuranceRenewalCaseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MI_Renewal').getRecordTypeId();
        try{
        allCasesList = [SELECT 
                              Id, 
                              CaseNumber,     
                              recordTypeId, 
                              CampaignId__c, 
                              Customer__c, Type, Vehicle_Registration_Number__c, 
                              OwnerId, 
                              ClosedDate, isClosed,
                              Status
                        FROM Case
                        WHERE Id IN :caseIds];
        for (case c : allCasesList){
            if (c.recordTypeId == InsuranceRenewalCaseRecordType){
                if (( c.ClosedDate != null ) || ( c.Status == 'Lost' || c.Status == 'Converted' || c.Status == 'Closed' ) || (c.isClosed != false)){
                
                    FinalResultMap.put(c.CaseNumber, 'Case is Already Closed. Please Select only Open Cases!');
                }
                else if (c.ClosedDate == null && ( c.Status != 'Lost' || c.Status != 'Converted' || c.Status != 'Closed' )){
                    currentSelectedRecords.add(c);// For creation of tasks for MI Renewal Record Type Only
                }
            }
            else{
                FinalResultMap.put(c.CaseNumber, 'Case is not of type MI Renewal. Please Select only MI Renewal - Open Cases!');
            }
        }
        
        if (!currentSelectedRecords.isEmpty()){
            Id InsuranceRenewalRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('MI_Renewal_Call').getRecordTypeId();
            
            for (case cs1 : currentSelectedRecords){
                Task newTask = new task();
                newTask.status = 'Open';
                newTask.CampaignId__c = cs1.CampaignId__c;
                newTask.recordTypeId = InsuranceRenewalRecordType;
                newTask.Service_Type__c = cs1.Type;
                newTask.OwnerId = cs1.OwnerId;
                newTask.Vehicle_Registration_Number__c = cs1.Vehicle_Registration_Number__c;
                newTask.Contact_ID__c = cs1.Customer__c;
                newTask.Case__c = cs1.Id;//To relate the task to the current Case
                newTask.WhatId = cs1.Id;//To relate the task to the current Case
                newTask.Priority = 'Low';
                newTask.ActivityDate = Date.today();
                currentSelectedSet.add(cs1.Id);
                newTaskList.add(newTask);
            }


        }
            
                if(!newTaskList.IsEmpty()){
                Database.SaveResult[] savedRecordsList = Database.insert( newTaskList, false );
                for (Integer i = 0; i < savedRecordsList.size(); i++){
                    if (savedRecordsList.get(i).isSuccess()){
                        System.debug('Records are updated Successfully');
                        taskCreated.add(savedRecordsList.get(i).Id);
                    }
                    
                }

                list<task> createdTasks = [SELECT Id,WhatId,Case__c FROM Task WHERE Id IN:taskCreated ];
                for (task t : createdTasks){
                    
                        if (currentSelectedSet.contains(t.Case__c)){
                            tempset.add(t.Case__c);
                        }
                    
                }

                for(case c: currentSelectedRecords){
                    if(tempset.contains(c.Id)){
                        FinalResultMap.put(c.CaseNumber+' - '+c.Id, 'Task Successfully Created for the case');
                    }else{
                        FinalResultMap.put(c.CaseNumber+' - '+c.Id, 'Task Could not be Created for the Case');
                    }
                }
                
                }
            }
            catch (Exception e){
                ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();
                ehst.componentName = 'listViewFilterApex';
                ehst.userId = UserInfo.getUserId();
                ExceptionHandler.LogError('listViewFilterApex', logErrors, 'createDailingList', '', ehst);
            }
        
        return FinalResultMap;
    }

    /**
     Author: Mahith Madwesh
     Company: Salesforce
     Description: To get the current user profile name
     Inputs:
     Returns:
     History:
     ================
     1.0     10 JUN 2020      Mahith     Initial Version
     1.1     23 JUN 2020      Nitin      Converted it to Return Type Wrapper for Campaign List and User Profile
     */
    @AuraEnabled
    public static CampaignUserWrapper getUserProfileName(){
         Id callCampaignRectypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Call_Campaign').getRecordTypeId();
        CampaignUserWrapper cmpUserWrap =  new CampaignUserWrapper();
        List<User> lsUser = [Select Contact.Account.Parent_Workshop_Code__c,AccountId,Profile.Name 
                               FROM User where Id=:UserInfo.getUserId() AND Contact.Account.Parent_Workshop_Code__c!=NULL];
                            
        if(lsUser.size()>0){
            cmpUserWrap.userRec = lsUser.get(0);
        }
        
        List<Campaign> lsCamp = [Select Id,Name,Dealership__c FROM Campaign 
                                    WHERE Dealership__r.Parent_Workshop_Code__c=:cmpUserWrap.userRec.Contact.Account.Parent_Workshop_Code__c
                                    AND isActive=True AND Status!='Paused' AND Dealership__c!=NULL AND RecordTypeId=:callCampaignRectypeId];
        if (lsCamp.size()>0){
            cmpUserWrap.campaignList = lsCamp;
        }
        
        return cmpUserWrap;
    }

    /**
     Author: Mahith Madwesh
     Company: Salesforce
     Description: To get tasks based on the filter fields entered
     Inputs:
     Returns:
     History:
     ================
     1.0     10 JUN 2020      Mahith     Initial Version
     1.1     06 JUL 2020      Mahith     Added Start and End Date for ActivityDate
     */
    @AuraEnabled
    public static List<task> getTasks(string campaignName, list<string> campaignType, string startDate,string endDate, list<string> OwnerId, string taskPriority,string dealerName,string startSaleDate,string endSaleDate,list<string> model,string campSubType){
        list<string> paramString = new list<string>();
        if (string.isNotBlank(campaignName)){
            string string1 = 'campaignId__c =\'' + campaignName + '\'';
            paramString.add(string1);
        }
        if (campaignType.size()>0){
            list<string> tempString = new list<string>();
            for(Integer i=0;i<campaignType.size();i++){
                tempString.add('\''+campaignType[i]+'\'' );
            }
            string string2 = 'Service_Type__c IN ' + tempString;
            paramString.add(string2);
        }
        if (string.isNotBlank(startDate)){
            string string3 = 'ActivityDate >=' + startDate;
            paramString.add(string3);
        }
        if (string.isNotBlank(endDate)){
            string string4 = 'ActivityDate <=' + endDate;
            paramString.add(string4);
        }
        if (OwnerId.size()>0){
            list<string> tempString1 = new list<string>();
            for(Integer i=0;i<OwnerId.size();i++){
                tempString1.add('\''+OwnerId[i]+'\'' );
            }
            string string5 = 'OwnerId IN ' + tempString1 ;
            paramString.add(string5);
        }else{
            string string5 = 'OwnerId = \'' + UserInfo.getUserId()+'\'' ;
            paramString.add(string5);
        }
        if (string.isNotBlank(taskPriority)){
            string string6 = 'Priority =\'' + taskPriority + '\'';
            paramString.add(string6);
        }
        if (string.isNotBlank(dealerName)){
            string string7 = 'Case__r.Dealer_Name__c =\'' + dealerName + '\'';
            paramString.add(string7);
        }
        if (string.isNotBlank(startSaleDate)){
            string string8 = 'Case__r.Vehicle_Sale_Date__c >=' + startSaleDate ;
            paramString.add(string8);
        }
        if (string.isNotBlank(endSaleDate)){
            string string9 = 'Case__r.Vehicle_Sale_Date__c <=' + endSaleDate ;
            paramString.add(string9);
        }

        if (model.size()>0){
            list<string> tempString1 = new list<string>();
            for(Integer i=0;i<model.size();i++){
                tempString1.add('\''+model[i]+'\'' );
            }
            string string10 = 'Case__r.Vehicle_Model_Description__c IN ' + tempString1;
            paramString.add(string10);
        }

        if (string.isNotBlank(campSubType)){
            string string11 = 'Case__r.Call_Campaign_Subtype__c =\'' + campSubType +'\'';
            paramString.add(string11);
        }

        string taskQuery = 'Select Id,Priority,Subject,Contact_ID__r.Name,RecordType.Name,ActivityDate,Owner.Name,CampaignId__r.Name,Service_Type__c,Vehicle_Model__c,Status,Case__c,WhatId,Case__r.Vehicle_Sale_Date__c FROM Task WHERE (Status !=' + '\'Completed' + '\''+ ' AND Status != \'In Progress'+'\') ';
        for (string s : paramString){
            if (string.isNotBlank(s)){
                taskQuery += ' and ' + s;
            }
        }
        taskQuery = taskQuery + ' LIMIT 100';
        System.debug('task query'+taskQuery);
        list<task> tasksList = (list<task>)Database.query(taskQuery);
        return tasksList;
    }

    /**
     Author: Mahith Madwesh
     Company: Salesforce
     Description: To get update cases based to the appointment date inserted
     Inputs:
     Returns:
     History:
     ================
     1.0     23 JUN 2020      Mahith     Initial Version
     */
    @AuraEnabled
    public static Map<string,string> updateAppointmentDates(list<case> casesList,string updatedateTime){
        list<case> nonCompleteCases = new list<case>();
        set<Id> caseUpdated = new Set<Id>();
        Map<string,string> finalResult = new Map<string,string>();
        
        try{
        
        for(case cl:casesList){
        if(( cl.ClosedDate != null ) || ( cl.Status == 'Lost' || cl.Status == 'Converted' || cl.Status == 'Closed' )){
                finalResult.put(cl.CaseNumber,'Case is already closed. Please select only open Cases');
            }else{
                if(string.isNotBlank(updatedateTime)){
                list<string> dateTimeString = updatedateTime.split('T');
                cl.Pickup_Date__c = Datetime.valueOfGmt(dateTimeString[0]+' '+dateTimeString[1]);
                nonCompleteCases.add(cl);
                }
            }
        }
                if(!nonCompleteCases.isEmpty()){
                Database.SaveResult[] savedRecordsList = Database.update( nonCompleteCases, false );
                for (Integer i = 0; i < savedRecordsList.size(); i++){
                    if (savedRecordsList.get(i).isSuccess()){
                        System.debug('Records are updated Successfully');
                        caseUpdated.add(savedRecordsList.get(i).Id);
                    } else if (!savedRecordsList.get(i).isSuccess()){
                         // DML operation failed
                        Database.Error error = savedRecordsList.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        nonCompleteCases.get(i);//failed record from the list
                        finalResult.put('failed',failedDML);
                    }
                }
                }

                for(case c1: nonCompleteCases){
                    if(caseUpdated.contains(c1.Id)){
                        finalResult.put(c1.CaseNumber, 'Appointment Date Successfully Updated to the case');
                    }else{
                        finalResult.put(c1.CaseNumber, 'Appointment Date could not be Updated for the case. Please reach out to the support team if needed');
                    }
                }


            }catch(Exception e){
                ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();
                ehst.componentName = 'listViewFilterApex';
                ehst.userId = UserInfo.getUserId();
                ExceptionHandler.LogError('listViewFilterApex', e.getMessage()+' ' +e.getLineNumber(), 'updateAppointmentDates', '', ehst);
            }
            return finalResult;

    }

    public class CampaignUserWrapper{
        @AuraEnabled
        public List<Campaign> campaignList {get;set;}
        @AuraEnabled
        public User userRec {get;set;}
    }

    
}