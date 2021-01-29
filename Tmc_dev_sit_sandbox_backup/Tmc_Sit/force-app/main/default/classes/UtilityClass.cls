/**
 * @File Name          : UtilityClass.cls
 * @Description        : 
 * @Author             : Rajesh Ramachandran
 * @Group              : 
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 6/6/2020, 3:43:57 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    3/16/2020   Rajesh Ramachandran     Initial Version
**/
public class UtilityClass {
    public static tempWrap LimitInitmthod(){
        tempWrap lw = new tempWrap();
        lw.totalDML=limits.getDMLStatements();
        lw.cpuTimeList=limits.getCpuTime();
        lw.queriesList=limits.getQueries();
        lw.dmlRowsList=limits.getDMLRows();
        lw.heapSizeList = limits.getHeapSize();
        lw.queryRowsList=limits.getQueryRows();
        return lw;
    }
    public static Map<string,Integer> calculateLimit(tempWrap lwBefore, tempWrap lwAfter, integer count){
        Map<string,Integer> limitMap = new Map<string,Integer>(); 
        limitMap.put('Cpu_Time_Limit' , (lwAfter.cpuTimeList - lwBefore.cpuTimeList)/count);
        limitMap.put('Heap_Size_Limit' , (lwAfter.heapSizeList- lwBefore.heapSizeList)/count);
        limitMap.put('DML_Statement_Limit' , (lwAfter.totalDML- lwBefore.totalDML)/count);
        limitMap.put('Query_Rows_Limit' , (lwAfter.queryRowsList - lwBefore.queryRowsList)/count);
        limitMap.put('Queries_Limit' , (lwAfter.queriesList- lwBefore.queriesList)/count);
        limitMap.put('DML_Row_Limit' , (lwAfter.dmlRowsList- lwBefore.dmlRowsList)/count);
        limitMap.put('DML_Statement_Limit_Max' , limits.getLimitDMLStatements());
        limitMap.put('Heap_Size_Limit_Max' ,  limits.getLimitHeapSize() );
        limitMap.put('Queries_Limit_Max' , limits.getLimitQueries() );
        limitMap.put('Query_Rows_Limit_Max' , limits.getLimitQueryRows());
        limitMap.put('Cpu_Time_Limit_Max' , limits.getLimitCpuTime());
        limitMap.put('DML_Row_Limit_Max' , limits.getLimitDmlRows());
        return limitMap;
    }
    
    Public static Performance__mdt fetchMetadata(string name){
        return [SELECT MasterLabel,Category__c FROM Performance__mdt WHERE DeveloperName=:name];
    }
    public class tempWrap{
        public integer totalDML;
        public integer cpuTimeList;
        public integer queriesList;
        public integer dmlRowsList;
        public integer heapSizeList;
        public integer queryRowsList;
    }
    public class LimitWrap{
        public Integer Cpu_Time_Limit;
        public Integer Heap_Size_Limit;
        public Integer DML_Statement_Limit;
        public Integer Query_Rows_Limit ;
        public Integer Queries_Limit;
        public Integer DML_Row_Limit ;        
        public Integer DML_Statement_Limit_Max;
        public Integer Heap_Size_Limit_Max;
        public Integer Queries_Limit_Max;
        public Integer Query_Rows_Limit_Max;
        public Integer Cpu_Time_Limit_Max;
        public Integer DML_Row_Limit_Max;
    }
    // This method is used to create Customer /person Account(s) //
    public static List<Account> createPersonAccount(Integer numAccts){
        Id customerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        List<Account> accts = new List<Account>();
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(FirstName='TEST',LastName='ACCOUNT');
            a.RecordTypeId=customerRecTypeId;
            accts.add(a);
        }
        //insert accts;
        return accts;
    }
    
    // This method is used to create Dealer /Business Account(s) 
    public static List<Account> createBusinessAccount(Integer numAccts){
        Id customerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        
        List<Account> accts = new List<Account>();
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(Name='ACCOUNT');
            a.RecordTypeId=customerRecTypeId;
            accts.add(a);
        }
        //insert accts;
        return accts;
    }
   
    // Added By ....Ravi thi smethod creates the survey of type Post Booking Feedback Survey
    /*public static List<Survey__c> fetchSurveyPostBooking(){
        List<Survey__c> surveyList = new List<Survey__c>();
        surveyList=[select Id from Survey__c where Name='Post Booking Feedback Survey'];
        return surveyList;
    }
*/
 // Added By ....Ravi thi smethod fetch the survey of type Showroom Feedback Survey Test
    public static List<Survey__c> fetchSurvey(){ 
        List<Survey__c> surveyList = new List<Survey__c>();
        surveyList=[select Id from Survey__c where Name='Showroom Feedback Survey'];
        return surveyList;
    }

    public static List<SurveyTaker__c> CreateSurveyTaken(string enquiryId,string surveyId,string personAccount,string BusinessAcc,integer numSurveyTake){
        List<SurveyTaker__c> surveyList = new List<SurveyTaker__c>();
        for(Integer i=0;i<numSurveyTake;i++) {
            SurveyTaker__c a = new SurveyTaker__c(Customer__c=personAccount,Dealer__c=BusinessAcc,Enquiry__c=enquiryId,
                                                  Survey__c=surveyId,Taken__c='Completed');
            surveyList.add(a);
        }
        return surveyList; 
    }
    // Added By ....Ravi this method fetch the record of survey question
    public static List<Survey_Question__c> fetchSurveyQuestion(){
        List<Survey_Question__c> surveyQ = new List<Survey_Question__c>([select Id from Survey_Question__c limit 2]);
        return surveyQ; 
    }
    // Added By ....Ravi this method creates the surve response 
    public static List<SurveyQuestionResponse__c> CreateSurveyRespnse(string surveyTakeId,List<Survey_Question__c> questionList){
        List<SurveyQuestionResponse__c> surveyList = new List<SurveyQuestionResponse__c>();
        for(Survey_Question__c questObj:questionList){
            SurveyQuestionResponse__c a = new SurveyQuestionResponse__c(Survey_Question__c=questObj.Id,SurveyTaker__c=surveyTakeId,Response__c='good');
            surveyList.add(a); 
        }
        return surveyList; 
    }
    // Added By ....Ravi this method Update the surve response 
   public static List<SurveyQuestionResponse__c> updateSurveyRespnse(string surveyTakeId,List<SurveyQuestionResponse__c> answerList){
        List<SurveyQuestionResponse__c> surveyList = new List<SurveyQuestionResponse__c>();
        for(SurveyQuestionResponse__c ansObj:answerList){
            SurveyQuestionResponse__c a = new SurveyQuestionResponse__c(Id=ansObj.Id,Response__c='Excellent');
            surveyList.add(a); 
        }
        return surveyList; 
    }
    
    // this method is used to create enquiry vehicle
    public static List<Opportunity> createEnquiryVehicle(String customerId, String DealerId,Integer numOpptys){
        Id enquiryVerhicleRecord = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vehicle Sales').getRecordTypeId();
        
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=0;i<numOpptys;i++) {
            Opportunity enqObj= new Opportunity(Name='TEST',First_Name__c='Test',Customer__c=customerId, CloseDate=system.today(),Line_Of_Business__c='Nexa',
                                                StageName='New', Last_Name__c = 'TestLast', LeadSource='Business Associates',Dealership__c =DealerId);
            enqObj.RecordTypeId=enquiryVerhicleRecord;
            oppList.add(enqObj);
        }
        //insert oppList;
        return oppList;
    }

    //Added by Anas Yar Khan on 7th July 2020
    // this method is used to create enquiry vehicle with referral details
    public static List<Opportunity> createEnquiryVehicleWithReferralDetails(String customerId, String DealerId,Integer numOpptys){
        Id enquiryVerhicleRecord = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vehicle Sales').getRecordTypeId();
        
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=0;i<numOpptys;i++) {
            Opportunity enqObj= new Opportunity(Name='TEST',First_Name__c='Test',Customer__c=customerId, CloseDate=system.today(),Line_Of_Business__c='Nexa',
                                                StageName='New', Last_Name__c = 'TestLast', LeadSource='Business Associates',Dealership__c =DealerId,
                                                Referred_By_Mobile_Number__c='7890987123',Referred_By_Loyalty_Card_Number__c='5441231111');
            enqObj.RecordTypeId=enquiryVerhicleRecord;
            oppList.add(enqObj);
        }
        //insert oppList;
        return oppList;
    }

    // Added by Anas Yar Khan on 06th July 2020
    // this method is used to create enquiry vehicle with Loyalty Information
    public static List<Opportunity> createEnquiryVehicleWithLoyaltyInformation(String customerId, String DealerId,Integer numOpptys){
        Id enquiryVerhicleRecord = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vehicle Sales').getRecordTypeId();
        
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=0;i<numOpptys;i++) {
            Opportunity enqObj= new Opportunity(Name='TEST',First_Name__c='Test',Customer__c=customerId, CloseDate=system.today(),Line_Of_Business__c='Nexa',
                                                StageName='New', Last_Name__c = 'TestLast', LeadSource='Business Associates',Dealership__c =DealerId,
                                                Reason_not_Interested_in_Loyalty__c='Customer not Interested',Interested_In_Loyalty__c='Yes',Email__c='test@gmail.com');
            enqObj.RecordTypeId=enquiryVerhicleRecord;
            oppList.add(enqObj);
        }
        //insert oppList;
        return oppList;
    }

    // Added by Anas Yar Khan on 6th July 2020
    // this method is used to create Loyalty Enquiry
    public static List<Opportunity> createLoyaltyEnrollment(String customerId, String DealerId,Integer numOpptys){
        Id loyaltyEnrolmentRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Loyalty Enrollment').getRecordTypeId();
        
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=0;i<numOpptys;i++) {
            Opportunity enqObj= new Opportunity(Name='TEST',First_Name__c='Test',Customer__c=customerId, CloseDate=system.today(),Line_Of_Business__c='Nexa',
                                                StageName='New', Last_Name__c = 'TestLast', LeadSource='Business Associates',Dealership__c =DealerId);
            enqObj.RecordTypeId=loyaltyEnrolmentRecordId;
            oppList.add(enqObj);
        }
        //insert oppList;
        return oppList;
    }

    

    // this method is used to create enquiry Accessories
    public static List<Opportunity> createEnquiryAccessories(String customerId, String DealerId,Integer numOpptys){
        Id enquiryVerhicleRecord = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Accessories Sales').getRecordTypeId();
        
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=0;i<numOpptys;i++) {
            Opportunity enqObj= new Opportunity(Name='TEST',First_Name__c='Test',Customer__c=customerId, CloseDate=system.today(),Line_Of_Business__c='Nexa',
                                                StageName='Open', Last_Name__c = 'TestLast',LeadSource='Business Associates',Dealership__c =DealerId,
                                                Vehicle_Registration__c='Test',Exchange_Registration__c='Test');
            enqObj.RecordTypeId=enquiryVerhicleRecord;
            oppList.add(enqObj);
        }
        //insert oppList;
        return oppList;
    }
    
    
    
    // Added By @Ravi....This method basically creates the user with title  sales executive
    Public static List<user> getUserSalesExecutive(){
        return [Select Id from User where Title='Sales Executive'];
        
    }
    

    Public static List<user> getEmployees(String name1){
        return [Select Id from User where name LIKE : name1 + '%'];
        
    }
    
    // Added By @Ravi .... This method particularly creates the record of Assets
    Public static List<Asset> createAssets(string accId,integer numAccts){
        List<Asset> astList = new List<Asset>();
        for(Integer i=0;i<numAccts;i++) {
            Asset a = new Asset(Name='Test',AccountId=accId);
            astList.add(a);
        }
        return astList;
    }
    
    // Added By Ravi .... This method update the enquiry Vehicle having user with sales executive
    Public static List<Opportunity> updateVehicleEnquiry(String customerId, String DealerId,String enquiryId,string userId){
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.id =enquiryId;
        opp.OwnerId=userId;
        oppList.add(opp);
        return oppList;
    }
    
  /*  // Added By Ravi .... This Method update the enquiry Accesoris having user with Sales executive 
    Public static List<Opportunity> updateAccesoryEnquiry(String customerId, String DealerId,string enquiryId,string userId){
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.id =enquiryId;
        opp.OwnerId=userId;
        oppList.add(opp);
        
        return oppList;
    }*/
    
    // Added By Ravi .... This Method update the escalation value for the vehicle 
    Public static List<Opportunity> updateEscalationEnquiry(String customerId, String DealerId,string enquiryId){
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.id =enquiryId;
        opp.Escalated__c=true;
        oppList.add(opp);        
        return oppList;
    }
     
    
    public static List<Opportunity> updateInfluencer(string enquiryId,String influen,Integer age,string phone,string test,string occup, String enqSource){
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Reference_Type__c=influen;
        opp.leadSource = enqSource;
        opp.Influencer_Age__c=age;
        opp.Influencer_Name__c=test;
        opp.Influencer_Mobile__c= phone;
        opp.Influencer_Occupation__c=occup;
        opp.id =enquiryId;
        oppList.add(opp);      
        return oppList; 
    }
    
    // Added By Ravi .... This method create the record of task 
    public static List<Task> createTask(Integer numAccts,string oppId){
        List<Task> tskList = new List<Task>();
        for(integer i=0;i<numAccts;i++){
            Task tsk = new Task(Subject = 'Test',Status = 'Open',Priority = 'Normal',whatId=oppId);
            tskList.add(tsk);
        }
        return tskList;
    }
    
    // Added By Ravi .... This method Update the Follow up-task,time,type for the vehicle enquiry 
    public static List<Opportunity> updateTaskTypeVehicleEnquiry(String customerId, String DealerId,string enquiryId,string taskId){
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.id =enquiryId;
        opp.Current_Follow_Up_Time__c=DateTime.now();
        opp.Current_Follow_Up_Type__c='Test';
        opp.Current_Open_Follow_up__c=taskId;
        oppList.add(opp);
        
        return oppList;
    }
    
    // Added By Ravi .... This method Update the Follow up-task,time,type for the Accessories enquiry 
    public static List<Opportunity> updateTaskTypeAccEnquiry(String customerId, String DealerId,string enquiryId,string taskId){
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.id =enquiryId;
        opp.Current_Follow_Up_Time__c=DateTime.now();
        opp.Current_Follow_Up_Type__c='Test';
        opp.Current_Open_Follow_up__c=taskId;
        oppList.add(opp);
        return oppList;
    }
    
    // Added By @Ravi .... This method basically creates the record of test drive 
    Public static List<Test_Drive__c> createTestDrive(Integer k,string vehicleEnquiryId,string assetId,integer numAccts,string BookID,DateTime wrpStart,DateTime wrpEnd){
        List<Test_Drive__c> tskList = new List<Test_Drive__c>();
        for(integer i=0;i<numAccts;i++){
            Test_Drive__c tstObj = new Test_Drive__c();
            tstObj.Enquiry__c=vehicleEnquiryId;
            tstObj.Test_Drive_Vehicle__c=assetId;
            tstObj.Scheduled_Start__c=wrpStart;
            tstObj.Scheduled_End__c=wrpEnd;
            tstObj.DMS_Booking_ID__c=BookID+k;
            tskList.add(tstObj);
        }
        return tskList;
    }
    
  
    
    // Added By @Ravi .... This method basically Create the record of Product 
    public static List<Product2> createProduct(integer numAccts){
        Id variantRecord = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Variants').getRecordTypeId();
        List<Product2> proList = new List<Product2>();
        for(integer i=0;i<numAccts;i++){
            Product2 proObj = new Product2();
            proObj.Name='Test';
            proObj.RecordTypeId=variantRecord;
            proObj.Fuel_Type__c='CNG';
            proObj.Enquiry__c='Yes';
            proObj.Channel__c='EXC';
            proObj.Start_Date__c=system.today();
            proObj.End_Date__c=system.today().addDays(1);
            proObj.Model__c='W';
            proList.add(proObj);
        }
        return proList;
    }
    
//Added By Mahith .... This method basically gets all active users of a public group and who is active
public static list<user> getPowerPartnerUser(){
    list<user> powerPartnerUserIdList = [SELECT Id, Name, Email, Account.Parent_Group__c, isActive, Profile.Name, UserRole.Name, UserType FROM User WHERE UserType='PowerPartner' AND Id IN (SELECT UserorGroupId FROM GroupMember where Group.type = 'Regular') AND isActive = true];
    return powerPartnerUserIdList;
}


    //Added By Mahith .... This method basically Creates Case With Record Type 'MI Renewal'
    public static list<case> createInsuranceRenewalCase(String userAccountId, String ContactId, String AssetsId, String DealerAccountId,String personAccountId,String powerPartnerUserId){
        Id InsuranceRenewalRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MI_Renewal').getRecordTypeId();

        List<case> caseList = new List<case>();
       //Create a case Object to insert e
            case caseObj = new case();
            caseObj.RecordTypeId=InsuranceRenewalRecordType;
            caseObj.AccountId=userAccountId;
            caseObj.ContactId=ContactId;
            caseObj.AssetId=AssetsId;
            caseObj.Customer__c = personAccountId;
            caseObj.Status='New';
            caseObj.Priority='Medium';
            caseObj.Dealer_Name__c=DealerAccountId;
            caseObj.OwnerId=powerPartnerUserId;
            caseList.add(caseObj);
            return caseList;
    }

     //Added By Mahith .... This method basically Update Case With Record Type 'MI Renewal'
    public static list<case> UpdateInsuranceRenewalCase(String InsuranceRenewalcaseId){
        
        List<case> caseList = new List<case>();
       //Create a case Object to insert Record
            case caseObj = new case();
            caseObj.Id=InsuranceRenewalcaseId;
            //caseObj.Closed_Won_Date__c=system.today();
            caseObj.Status='Converted';
            caseList.add(caseObj);
            return caseList;
    }


    //Added By Mahith .... This method basically Update Case Owner With Record Type 'MI Renewal'
    public static list<case> UpdateInsuranceRenewalCaseOwner(String InsuranceRenewalcaseId,String powerPartnerUserId){
        
        List<case> caseList = new List<case>();
       //Create a case Object to update Record owner
            case caseObj = new case();
            caseObj.OwnerId=powerPartnerUserId;
            caseObj.Id=InsuranceRenewalcaseId;
            caseObj.OwnerId=powerPartnerUserId;
            caseList.add(caseObj);
            return caseList;
    }

    //Added By Mahith .... This method basically Creates Case With Record Type 'Do No Call Requests'
    public static list<case> createDoNotCallCase(String userAccountId, String ContactId,String DealerAccountId,String personAccountId,String powerPartnerUserId){
        Id DoNotCallRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Do_No_Call_Requests').getRecordTypeId();
        List<case> caseList = new List<case>();
       //Create a case Object to insert e
            case caseObj = new case();
            caseObj.OwnerId=powerPartnerUserId;
            caseObj.RecordTypeId=DoNotCallRecordType;
            caseObj.AccountId=userAccountId;
            caseObj.ContactId=ContactId;
            caseObj.Customer__c = personAccountId;
            caseObj.Status='New';
            caseObj.Dealer_Name__c=DealerAccountId;
            caseObj.Priority='Medium';
            caseList.add(caseObj);
            return caseList;
    }


    //Added By Mahith .... This method basically Creates Task  With Record Type 'MI Renewal Call'
    public static list<Task> createMIRenewalTask(String personAccountId,String powerPartnerUserId){
        Id TaskRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('MI_Renewal_Call').getRecordTypeId();
        List<Task> taskList = new List<Task>();
            task taskObj = new task();

            taskObj.RecordTypeId=TaskRecordType;
            taskObj.OwnerId=UserInfo.getUserId();
           // taskObj.WhoId=;//Name (Not nec)
            taskObj.WhatId = personAccountId;//Related to (Person account)
            taskObj.Status='Open';
            taskObj.Priority='Normal';
            taskObj.Disposition__c = 'Other';
            taskObj.OwnerId=powerPartnerUserId;
            taskList.add(taskObj);
            return taskList; 

    }

    //Added By Mahith .... This method basically Creates Task  With Record Type 'SMR Appointment'
    public static list<Task> createSMRTask(String personAccountId,String powerPartnerUserId){
        Id TaskRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SMR_Appointment').getRecordTypeId();
        List<Task> taskList = new List<Task>();
            task taskObj = new task();
            taskObj.RecordTypeId=TaskRecordType;
            taskObj.OwnerId=powerPartnerUserId;
            taskObj.WhatId = personAccountId;
            taskObj.Status='Open';
            taskObj.Priority='Normal';
            taskObj.Disposition__c = 'Stolen';
            taskList.add(taskObj);
            return taskList;
    }

    //Added By Mahith .... This method basically Creates Task  With Record Type 'Service PSF Follow-Up'
    public static list<Task> createServicePSFTask(String personAccountId,String powerPartnerUserId){
        Id TaskRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('PSF_Follow_Up').getRecordTypeId();
        List<Task> taskList = new List<Task>();
            task taskObj = new task();
            taskObj.RecordTypeId=TaskRecordType;
            taskObj.OwnerId=powerPartnerUserId;
            taskObj.WhatId = personAccountId;
            taskObj.Status='Open';
            taskObj.Priority='Normal';
            taskObj.Disposition__c = 'Phone not available';
            taskList.add(taskObj);
            return taskList;
    }


    //Added By Mahith .... This method basically Creates Customer Visibility Record and inserts it into Customer_Visibility__c Object
    public static List<Customer_Visibility__c> createCustomerVisibilityRecord(String dealerUserId, String personAccountId, String publicGroupName){
    List<Customer_Visibility__c> customerVisibilityRecordList = new List<Customer_Visibility__c>();
            Customer_Visibility__c customerVisibilityRecordObj = new Customer_Visibility__c();
                customerVisibilityRecordObj.Dealer_Public_Group_Name__c = publicGroupName;
                        customerVisibilityRecordObj.Related_User__c = dealerUserId;
                        customerVisibilityRecordObj.Transaction_Type__c = System.label.Transaction_Type_DATA;
                        customerVisibilityRecordObj.Transaction_Date__c = System.now();
                        customerVisibilityRecordObj.Start_Datetime__c = System.now();
                        customerVisibilityRecordObj.End_Datetime__c = System.now().addDays(3);
                        customerVisibilityRecordObj.Customer_Account__c = personAccountId;
                        customerVisibilityRecordObj.Access_Processing_Status__c = System.label.Access_Process_Status_Success;
                        customerVisibilityRecordObj.Do_Not_Sync__c = true;
                      customerVisibilityRecordList.add(customerVisibilityRecordObj);
                      return  customerVisibilityRecordList; 
 }

//Added By Mahith .... This method basically Creates WorkOrder that has to be fetched for create appointment
    public static list<WorkOrder> createWorkderForAppointment(String personAccountId,String businessUserId,String powerPartnerUserId){
        List<WorkOrder> workOrderList = new List<WorkOrder>();
            WorkOrder workOrderObj = new WorkOrder();
            workOrderObj.AccountId=personAccountId; 
            workOrderObj.Status='New' ;
            workOrderObj.Description='TESTING'; 
            workOrderObj.Service_Type__c='FR2'; 
            workOrderObj.Appointment_Datetime__c=datetime.newInstance(2020, 01, 10, 06, 30, 00);
            workOrderObj.Due_Date__c=date.newInstance(2020, 02, 06);
            workOrderObj.Pickup_Datetime__c=datetime.newInstance(2020, 01, 03, 06, 30, 00);
            workOrderObj.Pickup_Address__c='Golf Course'; 
            workOrderObj.Drop_Datetime__c=datetime.newInstance(2020, 01, 02, 06, 30, 00);
            workOrderObj.Drop_Address__c='Dwarka'; 
            workOrderObj.SA_Id__c=businessUserId; 
            workOrderObj.Slot_Time__c='12:45-13:00'; 
            workOrderObj.Service_Number__c='SN002';
            workOrderObj.ownerId = powerPartnerUserId;
            workOrderList.add(workOrderObj);
            return workOrderList;
    }

    
    // Added By @Ravi .... This method basically Create the record of Pricebook 
    public static List<Pricebook2> createPriceBook(){
        List<Pricebook2> priList = new List<Pricebook2>();
        priList=[select Id from Pricebook2 where isStandard=true];
        return priList;
    }
    
    // Added By @Ravi .... This method basically Create the record of Quote 
    public static List<Quote> createQuote(string enquiryId,integer numAccts){
        List<Quote> quoteList = new List<Quote>();
        for(integer i=0;i<numAccts;i++){
            Quote quoteObj = new Quote();
            quoteObj.Status='Draft';
            quoteObj.Name='Test';
            quoteObj.OpportunityId=enquiryId;
            quoteList.add(quoteObj);
        }
        return quoteList;
    }
    
    //Added By @Karan kumar... This method is basically create to WorkOrder record
    public static List<WorkOrder> createWorkOrder(integer numAccts){
        List<WorkOrder> WorkOrderlist = new List<WorkOrder>();
        for(integer i=0;i<numAccts;i++){
            WorkOrder workobj = new WorkOrder();
            workobj.Appointment_Datetime__c=system.now();
            workobj.City='Delhi';
            WorkOrderlist.add(workobj);
        }
        return WorkOrderlist;
    }
     //Added By @Karan kumar... This method is basically create to User record
    public static List<User> createUser(integer numAccts){
        List<User> Userlist = new List<User>();
        for(integer i=0;i<numAccts;i++){
            User u = new User();
            u.AboutMe='Disaster';
            u.Dealer_Employee_Code__c='ABC';
            u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
                u.LastName = 'last';
                u.Email = 'puser000@amamama.com';
                u.Username = 'puser000@amamama.com' + System.currentTimeMillis();
                u.CompanyName = 'TEST';
                u.Title = 'title';
                u.Alias = 'alias';
                u.TimeZoneSidKey = 'America/Los_Angeles';
                u.EmailEncodingKey = 'UTF-8';
                u.LanguageLocaleKey = 'en_US';
                u.LocaleSidKey = 'en_US';
                Userlist.add(u);
        }
        return Userlist;
    }
    
    // Added By @Ravi .... This method basically update the record of Quote 
    public static List<Quote> updateQuote(string enquiryId,string quoteId){
        List<Quote> quoteList = new List<Quote>();
        Quote quoteObj = new Quote();
        quoteObj.Id=quoteId;
        quoteObj.Status='Draft';
        quoteObj.Name='Test';
        quoteObj.Status='Approved';
        quoteObj.OpportunityId=enquiryId;
        quoteList.add(quoteObj);
        return quoteList;
    }
    // Added By ....Ravi this method update enquiry with quote ID for Sycnhing of Quote
    public static List<Opportunity> synchQuote(string enquiryId,string quoteId){
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.id =enquiryId;
        opp.SyncedQuoteId=quoteId;
        opp.Escalated__c=true;
        oppList.add(opp);        
        return oppList;
    }
    
    // Added By @Ravi .... This method basically Create the record of OpportunityLineItem 
    public static List<OpportunityLineItem> createOppLineItem(string productId,string enquiryId,string priceBookEntryId,integer numAccts){
        List<OpportunityLineItem> oppLineList = new List<OpportunityLineItem>();
        for(integer i=0;i<numAccts;i++){
            OpportunityLineItem oppObj = new OpportunityLineItem();
            oppObj.UnitPrice=1;
            oppObj.PriceBookEntryId=priceBookEntryId;
            oppObj.OpportunityId=enquiryId;
            oppObj.Product2Id=productId;
            oppObj.Quantity=21;
            oppLineList.add(oppObj);
        }
        return oppLineList;
    }
    // Added By @Ravi .... This method basically Create the record of PriceBookEntry 
    public static List<PriceBookEntry> createPriceBookEntry(string productId,string priceBookEntryId,integer numAccts){
        List<PriceBookEntry> priceBookList = new List<PriceBookEntry>();
        //oppLineList= [select ID from PriceBookEntry where Product2Id=:productId and  PriceBook2Id=:priceBookEntryId];
        for(integer i=0;i<numAccts;i++){
            PriceBookEntry oppObj = new PriceBookEntry();
            oppObj.Product2Id=productId;
            oppObj.PriceBook2Id=priceBookEntryId;
            oppObj.isActive=true;
            oppObj.UnitPrice=1;
            priceBookList.add(oppObj);
        }
        return priceBookList;
    }
    // Added By Ravi .... This method update with Pre Booking when Vehicle Enquiry
    Public static List<Opportunity> updatePreBookingEnquiry(String customerId, String DealerId,String enquiryId){
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.id =enquiryId;
        opp.StageName ='Pre-Booking';
        opp.Dealership__c =DealerId;
        opp.Customer__c=customerId;
        oppList.add(opp);
        return oppList;
    }
    
   
    
    // Added By Ravi .... This method Creating the VIllage 
    Public static List<Village__c> createVillage(integer numVillage,string TehsilId){
        List<Village__c> villageList = new List<Village__c>();
        for(integer i=0;i<numVillage;i++){
            Village__c villageObj = new Village__c();
            villageObj.Name='TestVillage';
            villageObj.Tehsil__c=TehsilId;
            villageObj.Village_Code__c='VI160089'+i;
            villageList.add(villageObj);
        }
        return villageList;
    }
    // Added By Ravi .... This method Creating the Tehsil 
    Public static List<Tehsil__c> createTehsil(integer numtehsil){
        List<Tehsil__c> tehsilList = new List<Tehsil__c>();
        for(integer i=0;i<numtehsil;i++){
            Tehsil__c tehsilObj = new Tehsil__c();
            tehsilObj.Name='Test';
            tehsilObj.District__c='dist';
            tehsilObj.State__c='MH';
            tehsilObj.Tehsil_Code__c='TI50265';
            tehsilList.add(tehsilObj);
        }
        return tehsilList;
    }
    
    // Added By Ravi .... This method Creating the Tehsil record thats sums up to 200 
    Public static List<Tehsil__c> createTehsilList(integer numtehsil){
        List<Tehsil__c> tehsilList = new List<Tehsil__c>();
        for(integer i=0;i<numtehsil;i++){
            Tehsil__c tehsilObj = new Tehsil__c();
            tehsilObj.Name='TestTehsil';
            tehsilObj.District__c='dist';
            tehsilObj.State__c='MH';
            tehsilObj.Tehsil_Code__c='TI50265'+i;
            tehsilList.add(tehsilObj);
        }
        return tehsilList;
    }
    // Added By Ravi .... This method Creating the VIllage 
    Public static List<Village__c> getVillageList(string villageName){
        List<Village__c> villageList = new List<Village__c>();
        villageList= [select Id from Village__c where Name like:villageName];
        return villageList;
    }
    // Added By Ravi .... This method retrieving list of the tehsil 
    Public static List<Tehsil__c> getTehsilList(string NameData){
        List<Tehsil__c> tehsilList = new List<Tehsil__c>();
        tehsilList= [select Id from Tehsil__c where Name like :NameData];
        return tehsilList;
    }
    // Added By Ravi .... This method Creating the Color record 
    Public static List<Color_Variant_Master__c> createColorVariant(integer numCOlor,string variantId){
        List<Color_Variant_Master__c> variantList = new List<Color_Variant_Master__c>();
        for(integer i=0;i<numCOlor;i++){
            Color_Variant_Master__c variantObj = new Color_Variant_Master__c();
            variantObj.Name='Tesing';
            variantObj.Variant__c=variantId;
            variantObj.Color_Type__c='NM';
            variantObj.Color_Code__c='NM';
            variantList.add(variantObj);
        }
        return variantList;
    }
    
   
     public static string saveTimeSlot(){
         string BookingId;
         decimal timeAfterFetchSlot = Datetime.now().getTime();
         string enqId=string.valueOf(timeAfterFetchSlot).substring(6,13);
         
          string BodyTest='{ "optType":"C", "mspin": "769316", "model": "DR", "variant": "DRRDCD2", "location": "Showroom", "status": "COMPLETED", "owner": "1", "enquiryId": "'+enqId+'", "salesPersonId": "EMP2096", "scheduleStartTime": "2019-10-03T10:00:00.090Z", "scheduleEndTime": "2019-10-03T10:30:00.090Z" , "duration": 30, "signature": false, "vin": "MA3EWDE1S00968267", "drivenKM":30, "orgId": 1, "salesforceId": "SF123" }';
             //'{"mspin":"76935","model":"BA","variant":"DRRDCD2","location":"Showroom","status":"APPROVED","owner":"1","enquiryId":"'+enqId+'","salesPersonId":"EMP2096","scheduleStartTime":"2019-10-16T09:30:00.090Z","scheduleEndTime":"2019-10-16T10:00:00.090Z","duration":30,"signature":false,"vin":"TESTVEHILCE001","orgId":1,"salesforceId":"SF123"}';
            Map<String, Object> results = new Map<String, Object>();
         // Creating end Point Url
         MuleSoft_API_Details__mdt[] svocMappings= [SELECT MasterLabel, QualifiedApiName, Endpoint__c, TimeOut_Value__c, x_channel_id__c, x_channel_token__c,
                                                    x_transaction_id__c,Authorization__c FROM MuleSoft_API_Details__mdt WHERE MasterLabel ='Create Booking'];
         string longRunningServiceUrl= svocMappings[0].Endpoint__c;
         longRunningServiceUrl=longRunningServiceUrl;
         System.HttpRequest request= MSILMuleSoftIntegration.createHttpRequest('POST',longRunningServiceUrl,svocMappings[0],BodyTest);
         Http http = new Http();
         HttpResponse response = http.send(request);
         // If the request is successful, parse the JSON response.
         if (response.getStatusCode() == 200) {
             // Deserialize the JSON string into collections of primitive data types.
             results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
             system.debug('====>'+ results);
         }
         for(string str:results.keyset()){
             if(results.containsKey('bookingId')){
                 BookingId=string.valueOf(results.get(str));
             }
         }
         return BookingId;
    }
    
    // Added By Ravi ... This method Return Date And Time of Booking 
    public Static List<wrapperDateTime> fetchDateTime(){
        list<wrapperDateTime> wrapDateList = new List<wrapperDateTime>();
        string vin='MA3EWDE1S00968267'; 
        string dateRange='30';
        string enquiryId ='ENQ17012824';
        string mspin='76935';
        string orgId='1';
        Map<String, Object> results = new Map<String, Object>();
        // Creating end Point Url
        MuleSoft_API_Details__mdt[] svocMappings= [SELECT MasterLabel, QualifiedApiName, Endpoint__c, TimeOut_Value__c, x_channel_id__c, x_channel_token__c,
                                                   x_transaction_id__c,Authorization__c FROM MuleSoft_API_Details__mdt WHERE MasterLabel ='Test Drive Slots'];
        string longRunningServiceUrl= svocMappings[0].Endpoint__c+'?vin='+vin+'&dateRange='+dateRange+'&enquiryId='+enquiryId+'&mspin='+mspin+'&orgId='+orgId;
        System.HttpRequest request= MSILMuleSoftIntegration.createHttpRequest('GET',longRunningServiceUrl,svocMappings[0],'');
        Http http = new Http();
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        system.debug(response.getBody());
        
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            //system.debug(response.getBody()+'====>'+ results);
            JSON2Apex jsObj= (JSON2Apex) JSON.deserialize(response.getBody(),JSON2Apex.Class);
            system.debug('jsObj'+jsObj);
            for(availableslots avslot:jsObj.availableslots){
                if(Date.valueOf(avslot.bookingDate)> system.today() && Date.valueOf(avslot.bookingDate) < system.today().addDays(2)){
                    // system.debug('===='+avslot.bookingDate); 
                    for(TimeSlots strTime:avslot.TimeSlots){
                        wrapperDateTime wrapObj = new wrapperDateTime();
                        List<string> strDate=avslot.bookingDate.split('-');
                        //system.debug('strDate'+integer.valueOf(strTime.fromTime.split(':')[1]));
                        
                        DateTime startT = DateTime.newInstanceGMT(Integer.valueOf(strDate[0]), Integer.valueOf(strDate[1]), Integer.valueOf(strDate[2]), Integer.valueOf(strTime.fromTime.split(':')[0]), Integer.valueOf(strTime.fromTime.split(':')[1]), 00);
                        DateTime endT = DateTime.newInstanceGMT(Integer.valueOf(strDate[0]), Integer.valueOf(strDate[1]), Integer.valueOf(strDate[2]), Integer.valueOf(strTime.toTime.split(':')[0]), Integer.valueOf(strTime.toTime.split(':')[1]), 00);
                        wrapObj.StartbookDate=startT;
                        wrapObj.EndbookDate=endT;
                        wrapDateList.add(wrapObj);
                        system.debug('strTime'+startT +'==='+endT);
                        //system.debug('strTime'+strTime.fromTime) + '---?'+ Time.ValueOf(strTime.toTime));
                    }
                }
                //system.debug('avslot'+ avslot.bookingDate);
            }
        }
        return wrapDateList;
    }
    public class wrapperDateTime{
        public DateTime StartbookDate;
        public DateTime EndbookDate;
    }
    public class availableslots {
        public String bookingDate;
        public List<TimeSlots> timeSlots;
    }

    public class TimeSlots {
        public String fromTime;
        public String toTime;
    }

    public class JSON2Apex {
    
    public List<availableslots> availableslots;
    public String messageId;
        public String status;
    }
    
    // Added By Ravi .... this method fetch Content contentDistribution
    public static list<contentDistribution> fetchContentDistribution(){
        list<contentDistribution> contentDistributionList = new list<contentDistribution>([SELECT id,DistributionPublicUrl from contentDistribution]);
        return contentDistributionList;
    }
    
    
    
     // this method is used to create enquiry vehicle
    public static set<Id> fetchEnquiryId(String customerId, String DealerId,Integer numOpptys){
        Id enquiryVerhicleRecord = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vehicle Sales').getRecordTypeId();
        set<Id>  oppIdSet = new set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=0;i<numOpptys;i++) {
            Opportunity enqObj= new Opportunity(Name='TEST',First_Name__c='Test',Customer__c=customerId, CloseDate=system.today(),Line_Of_Business__c='Nexa',
                                                StageName='New',  Last_Name__c = 'TestLast', LeadSource='Business Associates',Dealership__c =DealerId);
            enqObj.RecordTypeId=enquiryVerhicleRecord;
            oppList.add(enqObj);
        }
        insert oppList;
        for(Opportunity oppId:oppList){
            oppIdSet.add(oppId.Id);
        }
       return oppIdSet;
    }
    
    
    // Added By @Ravi .... This method basically Create the record of Product having record type name is  Offer
    public static List<Product2> createOfferProduct(integer numAccts){
        Id offerRecord = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Offer').getRecordTypeId();
        List<Product2> proList = new List<Product2>();
        for(integer i=0;i<numAccts;i++){
            Product2 proObj = new Product2();
            proObj.Name='ExchangeOffer';
            proObj.RecordTypeId=offerRecord;
            proObj.Fuel_Type__c='CNG';
            proObj.Channel__c='NRC';
            proObj.Start_Date__c=system.today();
            proObj.End_Date__c=system.today().addDays(1);
            proObj.Model__c='Test';
            proList.add(proObj);
        }
        return proList;
    }
    
    // Added By Ravi .... This method return the Report ID and Set the filter value
    public static List<Reports.ReportMetadata> getReportMetadata(String reportId){
       List<Reports.ReportMetadata> reportMeta = new List<Reports.ReportMetadata>();
        
        // Get the report metadata
        Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportId);
        Reports.ReportMetadata reportMd = describe.getReportMetadata();
        // Override filter and run report
        if(reportMd.getReportFilters().size()>0){
        Reports.ReportFilter filter = reportMd.getReportFilters()[0];
        filter = reportMd.getReportFilters()[0];
         //   filter.setValue('Enquiry');
        }
        reportMeta.add(reportMd);
        return reportMeta;
        
    } 
    
    // Added By Ravi .... This method eturn the Report ID
    public static string getReport(){
        // Get the report ID
        List <Report> reportList = [Select Id,DeveloperName,Owner.Name  from Report where  DeveloperName='Performance_Logger_1_vGv'];
        String reportId = (String)reportList.get(0).get('Id');
        return reportId;
        
    } 
    
    // Added By Ravi .... This method run the report 
    public static void runReport(Reports.ReportMetadata reportMd,string reportId){
        Reports.ReportResults results = Reports.ReportManager.runReport(reportId, reportMd);
       results = Reports.ReportManager.runReport(reportId, reportMd);
        
    } 
    
    // this method is used to create enquiry vehicle for Loading all offers 
    public static List<Opportunity> createEnquiryOffer(String customerId, String DealerId,string colorId,string variantId,Integer numOpptys,String EvalCon){
        Id enquiryVerhicleRecord = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vehicle Sales').getRecordTypeId();
        
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=0;i<numOpptys;i++) {
            Opportunity enqObj= new Opportunity(Name='TEST',Sales_Type__c='IND',Buyer_Type__c='01',First_Name__c='Test',Model_Code__c='CI',Exchange_Offered_Price__c=30,Exchange_Offer_Expiry_Date__c=system.today().addDays(1),Customer__c=customerId,
                                                Exchange_Vehicle_x__c='N-K',Exchange_Color__c='Blue',Exchange_Vehicle_Evaluator_Contact__c=EvalCon,CloseDate=system.today(),Color__c=colorId,Variant__c=variantId,Line_Of_Business__c='Nexa',Model_of_Interest__c='BA',
                                                StageName='New', Last_Name__c = 'TestLast', LeadSource='Business Associates',Dealership__c =DealerId);
            enqObj.RecordTypeId=enquiryVerhicleRecord;
            enqObj.Dealership_Channel__c = 'Nexa';
            oppList.add(enqObj);
        }
        //insert oppList;
        return oppList;
    }
    
     // this method is used to create price master for Loading all offers 
    public static List<Price_Master__c> createPriceMaster(string variantId,Integer numOpptys){
        List<Price_Master__c> priceList = new List<Price_Master__c>();
        for(Integer i=0;i<numOpptys;i++) {
            Price_Master__c priceObj= new Price_Master__c(Name='TEST',Amount__c=20,From_Date__c=system.today(),To_Date__c=system.today().addDays(1),External_ID__c='123TEST',
                                               Color_Type__c='NM',Variant_Code__c=variantId);
            priceList.add(priceObj);
        }
        //insert oppList;
        return priceList;
    }
    
     // this method is used to create price master for Loading all offers 
    public static List<For_Code__c> createforCode(integer numOpptys){
        List<For_Code__c> forCodeList = new List<For_Code__c>();
        for(Integer i=0;i<numOpptys;i++) {
            For_Code__c forCodeObj= new For_Code__c(Name='TEST',City_Code__c='Test',For_Code__c='123Test'+i);
            forCodeList.add(forCodeObj);
        }
        //insert oppList;
        return forCodeList;
    }
      // This method is used to create Dealer /Business Account(s)  with forcode
    public static List<Account> createBusinessAccountForCode(Integer numAccts,string forCodeId){
        Id customerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        
        List<Account> accts = new List<Account>();
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(Name='ACCOUNT');
            a.RecordTypeId=customerRecTypeId;
            a.For_Code__c=forCodeId;
            accts.add(a);
        }
        //insert accts;
        return accts;
    }    
    //Added By Ravi... this method creates the JSON string
    public static string getJsonString(){
        return '[{"answer":"","isDisabled":false,"optionSet":[{"dataId":"a0F0k000002OzwEEASYes","dataValue":"Yes\r","isChecked":false},{"dataId":"a0F0k000002OzwEEASNo","dataValue":"No","isChecked":false}],"questionId":"a0F0k000002OzwEEAS","questionName":"Detailed explanation of features & operating controls of vehicle","srno":1,"surveyResponseId":""},{"answer":"","isDisabled":false,"optionSet":[{"dataId":"a0F0k000002OzwJEASYes","dataValue":"Yes\r","isChecked":false},{"dataId":"a0F0k000002OzwJEASNo","dataValue":"No","isChecked":false}],"questionId":"a0F0k000002OzwJEAS","questionName":"Detailed explanation of service schedule and workshop","srno":2,"surveyResponseId":""},{"answer":"","isDisabled":false,"optionSet":[{"dataId":"a0F0k000002OzwTEASYes","dataValue":"Yes\r","isChecked":false},{"dataId":"a0F0k000002OzwTEASNo","dataValue":"No","isChecked":false}],"questionId":"a0F0k000002OzwTEAS","questionName":"Detailed explanation of invoice","srno":3,"surveyResponseId":""},{"answer":"","isDisabled":false,"optionSet":[{"dataId":"a0F0k000002P099EACYes","dataValue":"Yes\r","isChecked":false},{"dataId":"a0F0k000002P099EACNo","dataValue":"No","isChecked":false}],"questionId":"a0F0k000002P099EAC","questionName":"Detailed explanation of documentation including RC process","srno":4,"surveyResponseId":""},{"answer":"","isDisabled":false,"optionSet":[{"dataId":"a0F0k000002P09EEASYes","dataValue":"Yes\r","isChecked":false},{"dataId":"a0F0k000002P09EEASNo","dataValue":"No","isChecked":false}],"questionId":"a0F0k000002P09EEAS","questionName":"Accessories fitted as per order","srno":5,"surveyResponseId":""},{"answer":"","isDisabled":false,"optionSet":[{"dataId":"a0F0k000002P09JEASYes","dataValue":"Yes\r","isChecked":false},{"dataId":"a0F0k000002P09JEASNo","dataValue":"No","isChecked":false}],"questionId":"a0F0k000002P09JEAS","questionName":"Warrant card","srno":6,"surveyResponseId":""},{"answer":"","isDisabled":false,"optionSet":[{"dataId":"a0F0k000002P09OEASYes","dataValue":"Yes\r","isChecked":false},{"dataId":"a0F0k000002P09OEASNo","dataValue":"No","isChecked":false}],"questionId":"a0F0k000002P09OEAS","questionName":"Invoice","srno":7,"surveyResponseId":""},{"answer":"","isDisabled":false,"optionSet":[{"dataId":"a0F0k000002P09TEASYes","dataValue":"Yes\r","isChecked":false},{"dataId":"a0F0k000002P09TEASNo","dataValue":"No","isChecked":false}],"questionId":"a0F0k000002P09TEAS","questionName":"Temp registration papers","srno":8,"surveyResponseId":""},{"answer":"","isDisabled":false,"optionSet":[{"dataId":"a0F0k000002P0AIEA0Yes","dataValue":"Yes\r","isChecked":false},{"dataId":"a0F0k000002P0AIEA0No","dataValue":"No","isChecked":false}],"questionId":"a0F0k000002P0AIEA0","questionName":"Payment receipts","srno":9,"surveyResponseId":""},{"answer":"","isDisabled":false,"optionSet":[{"dataId":"a0F0k000002P0ANEA0Yes","dataValue":"Yes\r","isChecked":false},{"dataId":"a0F0k000002P0ANEA0No","dataValue":"No","isChecked":false}],"questionId":"a0F0k000002P0ANEA0","questionName":"Gate Pass","srno":10,"surveyResponseId":""},{"answer":"","isDisabled":false,"optionSet":[{"dataId":"a0F0k000002P0ASEA0Yes","dataValue":"Yes\r","isChecked":false},{"dataId":"a0F0k000002P0ASEA0No","dataValue":"No","isChecked":false}],"questionId":"a0F0k000002P0ASEA0","questionName":"Insurance Cover Note","srno":11,"surveyResponseId":""},{"answer":"","isDisabled":false,"optionSet":[{"dataId":"a0F0k000002P0AhEAKYes","dataValue":"Yes\r","isChecked":false},{"dataId":"a0F0k000002P0AhEAKNo","dataValue":"No","isChecked":false}],"questionId":"a0F0k000002P0AhEAK","questionName":"Others","srno":12,"surveyResponseId":""},{"answer":"","isDisabled":false,"optionSet":[{"dataId":"a0F0k000002P0AXEA0Yes","dataValue":"Yes\r","isChecked":false},{"dataId":"a0F0k000002P0AXEA0No","dataValue":"No","isChecked":false}],"questionId":"a0F0k000002P0AXEA0","questionName":"Service coupons if any","srno":13,"surveyResponseId":""},{"answer":"","isDisabled":false,"optionSet":[{"dataId":"a0F0k000002P0AcEAKYes","dataValue":"Yes\r","isChecked":false},{"dataId":"a0F0k000002P0AcEAKNo","dataValue":"No","isChecked":false}],"questionId":"a0F0k000002P0AcEAK","questionName":"Extended Warrant booklet","srno":14,"surveyResponseId":""},{"answer":"","isDisabled":false,"optionSet":[{"dataId":"a0F0k000002P0AmEAKYes","dataValue":"Yes\r","isChecked":false},{"dataId":"a0F0k000002P0AmEAKNo","dataValue":"No","isChecked":false}],"questionId":"a0F0k000002P0AmEAK","questionName":"Visiting Cards of : CCM, Service Advisor, GM","srno":15,"surveyResponseId":""},{"answer":"","isDisabled":false,"optionSet":[{"dataId":"a0F0k000002P0ArEAKYes","dataValue":"Yes\r","isChecked":false},{"dataId":"a0F0k000002P0ArEAKNo","dataValue":"No","isChecked":false}],"questionId":"a0F0k000002P0ArEAK","questionName":"Warranty & Guarantee cards (for  battery, accessories, VAS etc)","srno":16,"surveyResponseId":""},{"answer":"","isDisabled":false,"optionSet":[{"dataId":"a0F0k000002P0BgEAKYes","dataValue":"Yes\r","isChecked":false},{"dataId":"a0F0k000002P0BgEAKNo","dataValue":"No","isChecked":false}],"questionId":"a0F0k000002P0BgEAK","questionName":"Tool kit","srno":17,"surveyResponseId":""},{"answer":"","isDisabled":false,"optionSet":[{"dataId":"a0F0k000002P0BlEAKYes","dataValue":"Yes\r","isChecked":false},{"dataId":"a0F0k000002P0BlEAKNo","dataValue":"No","isChecked":false}],"questionId":"a0F0k000002P0BlEAK","questionName":"Any other pending documents/services","srno":18,"surveyResponseId":""}]';
    }
    //Added by Rajesh(27-11-2020)
    public static List<Case> createCase(Id personAccountId,Id dealerId,Integer numCases){
        List<Case> caseList = new List<Case>();
        Id complaintRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();
        List<Category__c> catList = [select id,name from Category__c where Case_Type__c = 'Complaint' and Channel__c = 'Arena' and Business_Area__c = 'Sales' and Case_Stage__c = 'Post Sales' and Active__c = true limit 1];
        for(integer i=0;i<numCases;i++){
            Case caseObj = new Case();
            caseObj.Customer__c=personAccountId;
            caseObj.Dealer_Name__c=dealerId;
            caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();
            caseObj.origin = 'Inbound';
            caseObj.Subject = 'test case one';
            caseObj.Channel__c = 'Arena';
            caseObj.business_area__c = 'Sales';
            caseObj.Case_Type__c = 'Complaint';
            caseObj.case_stage__c = 'Post Sales';
            caseObj.FCR_Conducted__c = 'Yes';
            caseObj.primary_category__c = catList[0].name;
            caseList.add(caseObj);
        }
        return caseList;
    }
    
    //Added by Nitin(12-02-2020)
    public static List<Case> createQueryCase(Id personAccountId,Id dealerId,Integer numCases,String prodId){
        List<Case> caseList = new List<Case>();
        List<Category__c> catList = [select id,name from Category__c where Case_Type__c = 'Dealer Query' and Channel__c = 'Arena' and Business_Area__c = 'Sales' and Case_Stage__c = 'Post Sales' and Active__c = true limit 1];
        for(integer i=0;i<numCases;i++){
            Case caseObj = new Case();
            caseObj.Customer__c=personAccountId;
            caseObj.Dealer_Name__c=dealerId;
            caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Query_Feedback').getRecordTypeId();
            caseObj.origin = 'Inbound';
            caseObj.Subject = 'Test FCR Yes';
            caseObj.Channel__c = 'Arena';
            caseObj.business_area__c = 'Sales';
            caseObj.Case_Type__c = 'Dealer Query';
            caseObj.case_stage__c = 'Post Sales';
            caseObj.FCR_Conducted__c = 'Yes';
            caseObj.Model__c='W';
            caseObj.Variant__c=prodId;
            caseObj.primary_category__c = catList[0].name;
            caseList.add(caseObj);
        }
        return caseList;
    }
    
    //Added by Nitin(12-01-2020)
    public static List<Problem_Category__c> createProblemCategory(Integer numRecords){
        List<Problem_Category__c> listProgramCategory = new List<Problem_Category__c>();
        for (Integer i = 0; i < numRecords; i++) {
            Problem_Category__c pCategory = new Problem_Category__c(Name = 'Test Category');
            listProgramCategory.add(pCategory);
        }
        return listProgramCategory;
    }    
    
    //Added by Nitin(12-01-2020)
    public static List<Case> createMOSCase(Integer numCases){
        List<Case> caseList = new List<Case>();
        for(integer i=0;i<numCases;i++){
            Case caseObj = new Case();
            caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MOS_Complaints').getRecordTypeId();
            caseObj.Job_Type__c='Breakdown';
            caseObj.Vehicle_Registration_Number__c='TAS012222';
            caseObj.Area__c='Test';
            caseObj.State__c='KL';
            caseObj.Channel__c='Arena';
            caseObj.MOS_Case_Source__c='M-Call';
            caseObj.Mobile_Number__c='9989887876';
            caseObj.Customer_Name__c='Tim Cook';
            caseObj.Warranty_Status__c='Y';
            caseObj.Registered_Contact_Number__c='9989881111';
            caseObj.MOS_Case_Stage__c = 'Out for Service';
            caseList.add(caseObj);
        }
        return caseList;
    }
    
    //Added by Nitin(12-01-2020)
    public static List<Custom_Activity__c> createCustomTask(integer numOfRec,String caseId) {
        list<Custom_Activity__c> customTaskList = new list<Custom_Activity__c>();
        for (Integer i = 0; i < numOfRec; i++) {
            Custom_Activity__c ta = new Custom_Activity__c();
            ta.Subject__c= 'Test'+i;
            ta.Name= 'Test'+i;
            ta.Due_Date_Time__c = DateTime.now().addMinutes(ConstantsUtility.Fifteen_Minutes);
            ta.status__c = 'Open'; 
            ta.Case__c=caseId;
            ta.Call_Origin__c='Customer';
            customTaskList.add(ta);
        }
        return customTaskList;
    }
    
    //this method is used to create the MC record//Added by Nitin(12-01-2020)
    public static List<MC_Communication__c> getMCCommunicationRecord(Case caseObj,String type,integer numOfRec) {
        List<MC_Communication__c> mcRec = new List<MC_Communication__c>();
        for (Integer i = 0; i < numOfRec; i++) {
            MC_Communication__c mcRecord = new MC_Communication__c();
            mcRecord.Case__c = caseObj.Id;
            mcRecord.Status__c = ConstantsUtility.MC_Communication_Status_Queued;
            mcRecord.Type__c = type;
            mcRecord.Escalation_Date_Time__c = System.now().addMinutes(-ConstantsUtility.Five_Minutes);
            mcRecord.Recipient_Phone_Numbers__c ='9811231009';
            mcRec.add(mcRecord);
        }
        return mcRec;
    }
    
    // CREATE Case Comments//Added by Nitin(12-02-2020)
    public static List<CaseComment> createCaseComments(integer numOfRec, Id parentId) {
        List<CaseComment> caseComments = new List<CaseComment>();
        for (Integer i = 0; i < numOfRec; i++) {
            CaseComment caseComment = new CaseComment();
            caseComment.parentId = parentId;
            caseComment.CommentBody = 'Test Data';
            caseComments.add(caseComment);
        }
        return caseComments;
    }
    
    // CREATE Category BASED ON type//Added by Nitin(12-02-2020)
    public static List<Case_Actions__c> createCaseActions(Integer numOfRec, String name, String caseId, String recTypeId) {
        List<Case_Actions__c> caseActions = new List<Case_Actions__c>();
        for (Integer i = 0; i < numOfRec; i++) {
            Case_Actions__c caseAction = new Case_Actions__c();
            caseAction.Name = name;
            caseAction.Legal_Document__c='Legal Notice';
            caseAction.Raised_By__c='Customer';
            caseAction.Date_of_Legal_Document__c=Date.today();
            caseAction.Case_Number__c = caseId;
            caseAction.RecordTypeId = recTypeId;
            caseActions.add(caseAction);
        }
        return caseActions;
    }
    
    // CREATE Attachment//Added by Nitin(12-02-2020)
    public static List<Attachment> createAttachments(Integer numOfRec, String parentId) {
        List<Attachment> attch = new List<Attachment>();
        for (Integer i = 0; i < numOfRec; i++) {
            Blob b = Blob.valueOf('TestDataTestDataTestDataTestDataTestDataTestData');
            Attachment attachment = new Attachment();
            attachment.ParentId = parentId;
            attachment.Name = 'Test Attachment for Parent';
            attachment.Body = b;
            attch.add(attachment);
        }
        return attch;
    }
    
    //Added by Nitin(12-03-2020)
    public static List<Case> createEmailCase(Id personAccountId,Id dealerId,Integer numCases){
        List<Case> caseList = new List<Case>();
        for(integer i=0;i<numCases;i++){
            Case caseObj = new Case();
            caseObj.Customer__c=personAccountId;
            caseObj.Dealer_Name__c=dealerId;
            caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Email_Cases').getRecordTypeId();
            caseObj.Subject = 'Test FCR Yes';
            caseObj.Channel__c = 'MS Corporate';
            caseList.add(caseObj);
        }
        return caseList;
    }
    
    //Added by Nitin(12-07-2020)
    public static List<Adhoc_Campaign_Request__c> createCampaignDatasetRequest(Id crm1,Integer numCases,Id crm2,String Status){
        List<Adhoc_Campaign_Request__c> cmpReq = new List<Adhoc_Campaign_Request__c>();
        for(integer i=0;i<numCases;i++){
            Adhoc_Campaign_Request__c cmpObj = new Adhoc_Campaign_Request__c();
            cmpObj.Status__c=Status;
            cmpObj.CRM_1_Spoc_L1__c=crm1;
            cmpObj.RecordTypeId = Schema.SObjectType.Adhoc_Campaign_Request__c.getRecordTypeInfosByDeveloperName().get('aCRM_Dataset').getRecordTypeId();
            cmpObj.Expected_Delivery_Date__c = Date.today().addDays(10);
            cmpObj.Campaign_Objective__c = 'Test record';
            cmpObj.Omni_Channel_Comm__c='Yes';
            cmpObj.Expected_Business_Outcome__c='Test Data';
            cmpObj.Data_Filter_Requirements__c='Test Data';
            cmpObj.CRM_2_Spoc_L1__c=crm2;
            cmpObj.Expected_Delivery_Timeline__c=Date.today().addDays(15);
            cmpObj.Data_Count_for_Model__c=23;
            cmpObj.Model_Details__c='Test';
            cmpObj.Expected_Campaign_Delivery_Baseline__c='Test';
            cmpObj.Analytics_Effort_Estimation__c='Test';
            cmpReq.add(cmpObj);
        }
        return cmpReq;
    }
    
     //Added by Nitin(12-08-2020) // CREATE CAMPAIGNS
    public static list<Campaign> createCampaign(integer numOfRec) {
        list<Campaign> CampaignList = new list<Campaign>();
        for (integer i = 0; i < numOfRec; i++) {
            Campaign ev = new Campaign();
            ev.Name = 'Test';
            CampaignList.add(ev);
        }
        return CampaignList;
    }
    
    //Added by Nitin(12-08-2020)// CREATE CITY MASTER ADDRESS DATA  
    public static list<City__c> createCityAddressMasterData(Integer numOfRec) {
        list<city__c> cityList = new list<city__c>();
        for (integer i = 0; i < numOfRec; i++) {
            City__c c = new City__c();
            c.City_Code__c = '1234';
            c.Name = 'Noida';
            cityList.add(c);
        }
        return cityList;
    }
    
    //Added by Nitin(12-08-2020) //Lead Creation
    public static List<Lead> createLead(Integer numCases,String recTypeDevname,String campId,String dealerId,String cityId){
        List<Lead> leadList = new List<Lead>();
        for(integer i=0;i<numCases;i++){
            Lead newLead = new Lead();
            newLead.Salutation = 'Dr';
            newLead.FirstName = 'Test';
            newLead.LastName = 'User';
            newLead.MobilePhone = '9123456789';
            newLead.Mobile_1__c= '9123456789';
            newLead.OwnerId = Userinfo.getUserId();
            newLead.AdEventName__c = campId;
            newLead.Status = 'New';
            newLead.RecordTypeId=Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(recTypeDevname).getRecordTypeId();
            newLead.Email = 'test@email.com';
            newLead.Line_Of_Business__c = 'Nexa';
            newLead.Dealership_Channel__c = 'Nexa';
            newLead.Buyer_Type__c = '03';
            newLead.Enq_Model__c = 'BA';
            newLead.Ownership_Age__c=29;
            newLead.Sales_Dealership__c=dealerId;
            newLead.Sales_Model__c='BA';
            newLead.Title__c='Dr';
            newLead.Title_Enquiry__c='Dr';
            newLead.Reg_Num__c='test';
            newLead.Residential_City_Sales__c=cityId;
            newLead.Gender__c = 'M';
            newLead.Customer_Type__c = 'I';
            newLead.Test_Drive_Given__c = 'N';
            newLead.Status = 'New';
            leadList.add(newLead);
        }
        return leadList;
    }
    
    //Create a new survey question CTI record
    public static List<Survey_Question_CTI__c> createQuestion(String parentQuesId, Id campaignId,Integer numCases){
        List<Survey_Question_CTI__c> survyQues = new List<Survey_Question_CTI__c>();
        for(integer i=0;i<numCases;i++){
            Survey_Question_CTI__c ques = new Survey_Question_CTI__c();
            ques.Answer_Type__c = 'Text';
            ques.Sequence_Number__c = String.isNotBlank(parentQuesId)? 1 : 2;
            ques.Question_Name__c = 'First Name of {{!Lead.FirstName__c}}';
            ques.Pre_Question_Script__c = '{{!Greeting}}, SIR/MADAM my name is {{!User.Name}}.I am calling from Maruti Suzuki India Ltd.May I Speak with {{!Lead.FirstName__c}} {{!Lead.LastName__c}}?Do you want to change a Name?';
            ques.Post_Question_Script__c = 'Customer Type : <span class=customer-type>{{!Lead.Lead_Score__c}}</span>';
            ques.Survey__c = campaignId;
            ques.isStart__c = true;
            ques.Is_Required__c  = true;
            ques.Target_Field__c = 'FirstName__c';
            ques.Language_Type__c = 'English';
            survyQues.add(ques);
        }
        return survyQues;
    }
    
    //Create a new survey response CTI record
    public static List<Survey_Response_CTI__c> createResponse(Id leadId, Id questionId, Integer numCases){
        List<Survey_Response_CTI__c> survResp = new List<Survey_Response_CTI__c>();
        for(integer i=0;i<numCases;i++){
            Survey_Response_CTI__c responseObj = new Survey_Response_CTI__c();
            responseObj.Response__c = '3435';
            responseObj.Survey_Question__c = questionId;
            responseObj.Unique_ID__c = leadId+'_-_Expected_Drive_Km__c';
            responseObj.Lead__c = leadId;
            responseObj.ResponseText__c = 'Text';
            survResp.add(responseObj);
        }
        return survResp;
    }
    
    //Create StakeHolder JSON//Added By Nitin
    public static String createStakeHolderJSON(String objectType) {
        return CreateStakeHolderJson.createJson(objectType);
    }
    
    // CREATE CUSTOM VALIDATION EXCEPTION SETTING//Added By Nitin
    public static Custom_Validation_Exception_Setting__c createCustomValidation(Boolean isInsert) {
        Custom_Validation_Exception_Setting__c valid = new Custom_Validation_Exception_Setting__c();
        valid.Name = 'BypassTestUser38488';
        valid.Bypass_Validation_Rules__c = true;
        If (isInsert) {
            insert valid;
            return valid;
        } else {
            return valid;
        }
    }
    
    //Added By Nitin Suzuki Connect Cases
    public static List<Case> createSuzukiConnectCase(Id personAccountId,Integer numCases){
        List<Case> caseList = new List<Case>();
        List<Category__c> pcatList = [select id,name from Category__c where Case_Type__c = 'Complaint' and Channel__c = 'Arena' and Business_Area__c = 'Accessories' and Case_Stage__c = 'Post Sales' and Active__c = true AND Name='Suzuki Connect Product Complaint' limit 1];
        String primaryId='Arena_Complaint_Accessories_Post Sales_Secondary_'+pcatList[0].Id;
        List<Category__c> scatList = [SELECT Name FROM Category__c WHERE Active__c = true AND External_ID_Query__c =:primaryId limit 1];
        for(integer i=0;i<numCases;i++){
            Case caseObj = new Case();
            caseObj.Customer__c=personAccountId;
            caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Suzuki_Connect').getRecordTypeId();
            caseObj.origin = 'Inbound';
            caseObj.Subject = 'test case one';
            caseObj.Channel__c = 'Arena';
            caseObj.business_area__c = 'Accessories';
            caseObj.Case_Type__c = 'Complaint';
            caseObj.case_stage__c = 'Post Sales';
            caseObj.FCR_Conducted__c = 'Yes';
            caseObj.Primary_Category_ID__c=pcatList[0].Id;
            caseObj.primary_category__c = pcatList[0].name;
            caseObj.Secondary_Category_ID__c=scatList[0].Id;
            caseObj.secondary_category__c = scatList[0].name;
            caseObj.Status=ConstantsUtility.STATUS_OPEN;
            caseObj.Job_Status__c='Pending for Device Inspection';
            caseList.add(caseObj);
        }
        return caseList;
    }
    
    //Added by Rajesh(27-11-2020)
    public static List<Case> createChildCase(Id personAccountId,Id dealerId,Integer numCases){
        List<Case> caseList = new List<Case>();
        for(integer i=0;i<numCases;i++){
            Case caseObj = new Case();
            caseObj.Customer__c=personAccountId;
            caseObj.Dealer_Name__c=dealerId;
            caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();
            caseObj.origin = 'Inbound';
            caseObj.Subject = 'test case one';
            caseObj.Channel__c = 'Arena';
            caseObj.business_area__c = 'Accessories';
            caseObj.Case_Type__c = 'Complaint';
            caseObj.case_stage__c = 'Post Sales';
            caseObj.FCR_Conducted__c = 'Yes';
            caseObj.Status='Open';
            caseList.add(caseObj);
        }
        return caseList;
    }

    public static boolean skipInternalCaseActionValidation=false;//Getting used in caseActionsTriggerHandler to skip Case Action Validations for testing.
    public static boolean skipAPICallOut=true; // To skip API callout for NFR Testing
}