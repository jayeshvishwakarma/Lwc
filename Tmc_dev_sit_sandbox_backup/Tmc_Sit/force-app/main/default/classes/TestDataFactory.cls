/**
 * @File Name          : TestDataFactory.cls
 * @Description        :
 * @Author             : Rajesh Ramachandran
 * @Group              :
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 10-20-2020
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    12/29/2019   Rajesh Ramachandran     Initial Version
**/
@isTest
public class TestDataFactory {
      // CREATE ContentVersion
      public static List<ContentVersion> createContentVersion(integer noOfRec, String FileUniqueName) {
        List<ContentVersion> ContentVersionLists = new List<ContentVersion>();
          for (Integer i = 0; i < noOfRec; i++) {
              ContentVersion cv = new ContentVersion();
              cv.Title = 'Test Document'+i;
              cv.PathOnClient = 'TestDocument.pdf';
              cv.VersionData = Blob.valueOf('Test Content');
              cv.IsMajorVersion = true;
              cv.FileUniqueName__c=FileUniqueName;
              ContentVersionLists.add(cv);
          }
          return ContentVersionLists;
      }
      // CREATE ContentDocumentLink
      public static ContentDocumentLink createContentDocumentLink(String contentdocId, String relatedObjectid) {
         ContentDocumentLink cdl = New ContentDocumentLink();
         cdl.LinkedEntityId = relatedObjectid;
         cdl.ContentDocumentId = contentdocId;
         cdl.shareType = 'V';
          return cdl;
      }

   // CREATE OTHER AMOUNT VALIDATION CUSTOM SETTING
    public static Approval_Notification_Setting__c createApprovalNotificationSetting(String approvalType, Boolean isActive) {
        Approval_Notification_Setting__c notificationSetting = new Approval_Notification_Setting__c();
        notificationSetting.Name = 'Test Setting';
        notificationSetting.Approval_Type__c = approvalType;
        notificationSetting.isActive__c = isActive;
        notificationSetting.Approved_Template__c = 'With with ref. no {caseNumber} is approved.';
        notificationSetting.Rejected_Template__c = 'With with ref. no {caseNumber} is rejected and sent back for clarification. ';
        return notificationSetting;
    }
    //Create StakeHolder JSON
    public static String createStakeHolderJSON(String objectType) {
        return CreateStakeHolderJson.createJson(objectType);
    }
    //Create Complaint_Coordinator__c
    public static List<Complaint_Coordinator__c> createComplaintCoordinator(String channel, String type, String model, Integer noOfRec) {
        List<Complaint_Coordinator__c> complaintCoordinators = new List<Complaint_Coordinator__c>();
        for (Integer i = 0; i < noOfRec; i++) {
            Complaint_Coordinator__c coordinator = new Complaint_Coordinator__c();
            coordinator.Channel__c = channel;
            coordinator.Type__c = type;
            coordinator.Model__c = model;
            complaintCoordinators.add(coordinator);
        }
        return complaintCoordinators;
    }

    // CREATE EmailMessage
    public static EmailMessage createEmailMessage(string parentId, string toAddress, string fromAddress, boolean inComming) {
        EmailMessage newEmail = new EmailMessage();
        newEmail.FromAddress = fromAddress;
        newEmail.Incoming = inComming == true ? true : false;
        newEmail.ToAddress = toAddress;
        newEmail.Subject = 'Subject';
        newEmail.TextBody = 'TextBody ';
        newEmail.ParentId = parentId;
        return newEmail;
    }

    //Create Recipient_Master__c
    public static List<Recipient_List__c> createRecipientList(String categoryId, String recipientMasterId, String region, Integer noOfRec) {
        List<Recipient_List__c> recipientLists = new List<Recipient_List__c>();
        for (Integer i = 0; i < noOfRec; i++) {
            Recipient_List__c recipientList = new Recipient_List__c();
            recipientList.Recipient_Master__c = recipientMasterId;
            recipientList.Category__c = categoryId;
            recipientList.Region__c = region;
            recipientLists.add(recipientList);
        }
        return recipientLists;
    }

    //Create Recipient_Master__c
    public static Recipient_Master__c createRecipientMaster(String ownerType, String ownerShip, String hierarchyType, String msilJson) {
        Recipient_Master__c recipientMaster = new Recipient_Master__c();
        recipientMaster.Owner_Type__c = ownerType;
        recipientMaster.Case_Ownership__c = ownerShip;
        recipientMaster.Hierarchy_Type__c = hierarchyType;
        recipientMaster.MSIL_Stakeholder_JSON__c = msilJson;
        return recipientMaster;
    }
    public static List<Recipient_Master__c> createRecipientMaster(integer numOfRec, String HierarchyType) {
        List<Recipient_Master__c> repMasterList = new List<Recipient_Master__c>();
        for (Integer i = 0; i < numOfRec; i++) {
            Recipient_Master__c repMaster = new Recipient_Master__c();
            repMaster.Hierarchy_Type__c = HierarchyType;
            repMaster.Owner_Type__c = 'User';
            repMaster.Case_Ownership__c = 'L1;L2A';
            repMaster.Level_1_To__c = 'L1;L2A';
            repMaster.Level_1_cc__c = 'L1;L3';
            repMaster.Level_2_To__c = 'L1;L4';
            repMaster.Level_2_cc__c = 'L1';
            repMasterList.add(repMaster);
        }
        return repMasterList;
    }
    //Create custom setting Implementation_Strategy__c
    public static Implementation_Strategy__c createImplementation(string strategyImplementation, string strategyKey) {
        Implementation_Strategy__c ImplementationStrategyRecord = new Implementation_Strategy__c();
        ImplementationStrategyRecord.Name = strategyKey;
        ImplementationStrategyRecord.Identifier_Type__c = 'Record Type';
        ImplementationStrategyRecord.Strategy_Implementation__c = strategyImplementation;
        ImplementationStrategyRecord.Strategy_Key__c = strategyKey;
        ImplementationStrategyRecord.Use_Case__c = 'CaseTriggers';
        return ImplementationStrategyRecord;
    }

    // CREATE FileUpload CUSTOM SETTING
      public static FileUtility__c createFileUtilitySetting(String processName, String fieldsetname) {
          FileUtility__c Setting = new FileUtility__c();
          Setting.Name = processName;
          Setting.Can_Current_Approver_Edit__c = true;
          Setting.Document_Section_Header__c = processName;
          Setting.Field_Name_Of_Stakeholder__c = 'L3A_Stakeholder__c;L4_Stakeholder__c';
          Setting.Field_Section_Header__c = processName;
          Setting.Field_Set_API_Name__c = fieldsetname;
          Setting.Fields_To_be_Excluded__c = 'Counter_Measure_at_Dealer_Level__c,Timeline_For_Implementation__c,Counter_Measure_at_RO_Level__c,Timeline_For_Implementation_RO__c';
          Setting.Label__c = processName;
          Setting.Mandatory_Document__c = 'Others';
          Setting.Non_Mandatory_Documents__c = 'Others';
          Setting.Pick_List_Doc_Values_with_Action__c = 'Resolution Code;otp,Clarification Note;upload,Satisfaction Note;upload';
          Setting.Pick_List_Doc_Name__c = 'Closure Mode';
          return Setting;
      }
    //Method to create Category
    public static List<Category__c> createCategory(Integer numCat){
        List<Category__c> catList = new List<Category__c> ();
        for(Integer i=0;i<numCat;i++) {
            Category__c ct = new category__c();
            ct.name = 'Legal';
            ct.Type__c = 'Primary';
            ct.channel__c = 'Nexa';
            ct.Case_Type__c = 'Dealer Internal Feedback';
            ct.Business_Area__c = 'Sales';
            catList.add(ct);
        }
        return catList;
    }
    //Custom Setting
    public static Implementation_Strategy__c implmentationSetting(String triggerServiceImpl,string recordType,string name){
        Implementation_Strategy__c stratagyComplaint = new Implementation_Strategy__c();
        stratagyComplaint.Name = name;
        stratagyComplaint.Identifier_Type__c = 'Record Type';
        stratagyComplaint.Strategy_Implementation__c = triggerServiceImpl;
        stratagyComplaint.Strategy_Key__c = recordType;
        stratagyComplaint.Use_Case__c = 'CaseTriggers';
        return stratagyComplaint;
    }

    // CREATE Category BASED ON type
    public static List<Category__c> createCategories(Integer numOfRec, String type) {
        List<Category__c> categories = new List<Category__c>();
        for (Integer i = 0; i < numOfRec; i++) {
            Category__c category = new Category__c();
            category.Type__c = type ;
            category.Active__c = true ;
            category.Name = 'Test';
            categories.add(category);
        }
        return categories;
    }

    // CREATE BUSINESS ACCOUNT BASED ON RECORDTYPE
    public static List<Account> createBusinessAccount(Integer numAccts,String accRecTypeName){
        System.debug('Inside createBusinessAccount');
        List<Account> accts = new List<Account>();
        Id AccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(accRecTypeName).getRecordTypeId();

        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(Name='TestAccount' + i,RecordTypeId=AccRecTypeId,Parent_Group__c='premMotors');
            accts.add(a);
        }
        System.debug(accts);
        return accts;
    }


    // CREATE CONTACTS BASED ON ACCOUNTID
    public static List<Contact> createTestContact(Integer numOfRec, String accountId) {
        List<Contact> contactList = new List<Contact>();

        for( Integer i = 0; i < numOfRec; i++ ) {

            Contact con = new Contact(LastName = 'John '+i,
                                    accountId = accountId);
            contactList.add(con);
        }

        return contactList;
    }


    // CREATE PERSON ACCOUNTS
    public static List<Account> createPersonAccount(Integer numAccts){
        List<Account> accts = new List<Account>();
        Id AccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();

        for(Integer i=0;i<numAccts;i++){
            Account a = new Account(recordTypeId=AccRecTypeId ,FirstName='test',LastName='account',MiddleName='pro',PersonMobilePhone = '9888585565',PersonBirthdate=date.parse('05/11/2012'));
            accts.add(a);
        }

        return accts;
    }
    // CREATE Case Action BASED ON type
    public static List<Case_Actions__c> createCaseActions(Integer numOfRec, String name, String recordTypeId, String caseId) {
        List<Case_Actions__c> caseActions = new List<Case_Actions__c>();
        for (Integer i = 0; i < numOfRec; i++) {
            Case_Actions__c caseAction = new Case_Actions__c();
            caseAction.Name = name;
            caseAction.Case_Number__c = caseId;
            caseAction.RecordTypeId = recordTypeId ;
            caseActions.add(caseAction);
        }
        return caseActions;
    }
    // CREATE FOR CODE
    public static List<For_Code__c> createTestForCode(Integer numOfRec) {
        List<For_Code__c> forCode = new List<For_Code__c>();

        for( Integer i = 0; i < numOfRec; i++ ) {

            For_Code__c fcode = new For_Code__c(Name = 'Central For Code '+i,
                                                Zone_Code__c = 'Central',
                                                Region_Code__c = 'C2',
                                                For_Code__c = 'FC-1234'+string.valueOf(system.now()));
            forCode.add(fcode);
        }

        return forCode;
    }


    // CREATE PORTAL/INTERNAL USERS BASED ON PROFILE NAME
    public static List<User> createUserData(String Type, String profileName, List<Contact> contactList){
        List<User> userData = new List<User>();

        if(Type == 'Portal'){
            for(contact con : contactList){
                userData.add(generateUserData(con, queryProfileInfo(profileName), profileName));
            }
        }else if(Type == 'Internal'){
            userData.add(generateUserData(new Contact(), queryProfileInfo(profileName), profileName));
        }

        return userData;
    }

    //CALLED FROM createUserData METHOD
    public static User generateUserData(Contact con, string profileId, string profileName){

        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                  Title=ProfileName=='Dealer Sales Executive' ? label.Sales_Executive : 'Team Lead',
                  LocaleSidKey='en_US', ProfileId = profileId,Phone='9090909090',
                  TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'+String.valueOf(Math.random()));
        if(con.LastName != null){
            u.ContactId = con.Id;
        }
        return u;
    }

    //QUERY PROFILE NAME BASED ON PASSED STRING
    public static String queryProfileInfo(String ProfileName){
        String profileId = '';
        List<Profile> profileList = new List<Profile>([Select Id from Profile Where Name =: ProfileName]);
        if(profileList != Null && profileList.size() > 0){
            profileId = profileList[0].Id;
        }
        return profileId;
    }


    // CREATE EVENT VIST PLANS
    public static list<Event_Visit_Plan__c> createEventsPlans(integer numOfRec){
        list<Event_Visit_Plan__c> eventList = new list<Event_Visit_Plan__c>();
        for(integer i =0;i<numOfRec;i++){
            Event_Visit_Plan__c ev =new Event_Visit_Plan__c();
            ev.Name = 'Test';
            eventList.add(ev);
        }
        return eventList;
    }



    // CREATE ACCOUNT TEAM MEMBERS
    public static list<AccountTeamMember> createAccountTeamMember(Integer numOfRec,string userIdd){
        list<AccountTeamMember> AccountTeamMemberList = new list<AccountTeamMember>();
        for(integer i=0;i<numOfRec;i++){
            AccountTeamMember acmember = new AccountTeamMember();
            acmember.UserId = userIdd;
            AccountTeamMemberList.add(acmember);
        }
        return AccountTeamMemberList;
    }


    // CREATE CAMPAIGNS
    public static list<Campaign> createCampaign(integer numOfRec){
        list<Campaign> CampaignList = new list<Campaign>();
        for(integer i =0;i<numOfRec;i++){
            Campaign ev =new Campaign();
            ev.Name = 'Test';
            CampaignList.add(ev);
        }
        return CampaignList;
    }


    // CREATE TEST DRIVE
    public static list<test_drive__c> createTestDriveRecords(integer numOfRec){
        list<test_drive__c> testDriveList = new list<test_drive__c>();
        for(integer i=0 ;i<numOfRec;i++){
            test_drive__c td = new test_drive__c();
            td.Signature__c = true;
            testDriveList.add(td);
        }
        return testDriveList;
    }

    // CREATE ASSETS
    public static list<Asset> CreateAssetsRecords(List<Product2> prodList){

        list<Asset> assetList = new list<Asset>();
        for(Product2 prod :  prodList){
            Asset a = new Asset();
            a.name = 'Ciaz';
            a.Product2Id = prod.Id;
            assetList.add(a);
        }
        return assetList;
    }


    // CREATE OPPORTUNITY BASED ON RECORDTYPE
    public static List<Opportunity> createTestOpportunity(Integer numOfRec,String recordTypeName) {
        List<Opportunity> opportunityList = new List<Opportunity>();
        System.debug(recordTypeName);
        System.debug(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vehicle Sales').getRecordTypeId());
        System.debug(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId());
        Id oppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();



        String dataList = '{"addSchemes":"{"objROfferId":"00k0k000005IDDHAA4","offersText":null,"schemeCode":"SS000000AK0319190472","cashPaymentData":92850,"financeAmountData":"450000","otherDiscountData":null,"ruralDiscountData":3500,"corporateDiscountData":null,"exchangeBonusData":0,"exchangeData":null,"OfferData":null,"otherDiscountValue":false,"ruralOffersValue":true,"exchangeValue":false,"exchangeBonusValue":false,"corporateDiscountValue":false}","registrationAmountVariant":"{"priceBookEntryId":"01u0k000003KnLzAAK","UnitPrice":"5000","Quantity":1,"opporrtunityId":"0060k000008g9I0AAI","registerId":"00k0k000005IDD7AAO"}","exShowRoomVariant":"{"priceBookEntryId":"01u0k000003KnLzAAK","UnitPrice":"537850.00","Quantity":1,"opporrtunityId":"0060k000008g9I0AAI","exShowId":"00k0k000005IDD5AAO"}","selectedColorVariant":{"Variant__r":{"Id":"01t0k0000051AVRAA2","ProductCode":"ER4CD4"},"Color_Type__c":"NM","Variant__c":"01t0k0000051AVRAA2","Color_Code__c":"26U","Name":"SUPERIOR WHITE","Id":"a070k000008D4O7AAK"},"selectedVariant":{"Loyalty_Amount__c":500,"Extended_Warranty_3_year__c":2000,"Extended_Warranty_2_year__c":1500,"Extended_Warranty_1_year__c":1000,"Name":"BALENO ALTURA M","Id":"01t0k0000051AVRAA2"},"addAccessories":"[{"priceBookEntryId":"01u0k000003KoxEAAS","unitPrice":2000,"price":4000,"Maximum_Quantity__c":5,"Minimum_Quantity__c":1,"Id":"01t0k000005R2QpAAK","quantity":"2","Name":"Car Stereo 4","accId":"00k0k000005IDD6AAO"}]","addComponent":"[{"isDisabled":true,"showLabel":false,"isExchangedWarrenty":true,"isChecked":true,"value":"1000","label":"Extended Warranty","comId":"00k0k000005IDDGAA4"},{"isDisabled":true,"showLabel":true,"isChecked":true,"value":500,"label":"Loyalty","comId":"00k0k000005IDD8AAO"},{"isDisabled":false,"showLabel":true,"isChecked":true,"value":"2500","label":"Insurance","comId":"00k0k000005IDD9AAO"},{"isDisabled":false,"showLabel":true,"isChecked":false,"value":"","label":"Municipal Charges"},{"isDisabled":false,"showLabel":true,"isChecked":false,"value":"","label":"Number Plate Charges"},{"isDisabled":false,"showLabel":true,"isChecked":false,"value":"","label":"Road Tax"},{"validityValue":"2 Yrs - 20000 KMs","packageValue":"Economy","isDisabled":false,"showLabel":true,"isMCP":true,"isChecked":true,"value":"2000","label":"MCP","comId":"00k0k000005IDDAAA4"}]","headerValue":["Customer Name : ADNAN F DANE","DMS Enquiry Number : ENQ 00012","Variant Name : BALENO ALTURA M"]}';

        for( Integer i = 0; i < numOfRec; i++ ) {
            Integer x = Math.round((Math.random() * (900000) + 100000));
            String DMSEnq = 'ENQ'+String.valueOf(x);
            Opportunity opp = new Opportunity(Name = 'John '+i,
                                              recordTypeId = oppRecTypeId,
                                              CloseDate=System.today().addMonths(1),
                                              First_Name__c='John',Middle_Name__c='Brook',Last_Name__c='Wright',
                                              Line_Item_Summary__c=dataList,
                                              Line_Of_Business__c ='Nexa',
                                              DMS_Enquiry_Name__c=DMSEnq);
            opportunityList.add(opp);
        }

        return opportunityList;
    }

    public static List<Opportunity> createMSDSTestOpportunity(Integer numOfRec) {
        List<Opportunity> opportunityList = new List<Opportunity>();
        Id oppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MSDS').getRecordTypeId();

        for( Integer i = 0; i < numOfRec; i++ ) {

            Opportunity opp = new Opportunity(Name = 'John '+i,
                                              recordTypeId = oppRecTypeId,
                                              CloseDate=System.today().addMonths(1),
                                              First_Name__c='John',Middle_Name__c='Brook',Last_Name__c='Wright',
                                             Enquiry_Mode__c ='MSDS');
            opportunityList.add(opp);
        }

        return opportunityList;
    }

    // CREATE QUOTES
    public static List<Quote> generateQuoteData(Integer numOfRec,String opportunityId){

        List<Quote> quoteList = new List<Quote>();
        String dataList = '{"addSchemes":"{"objROfferId":"00k0k000005IDDHAA4","offersText":null,"schemeCode":"SS000000AK0319190472","cashPaymentData":92850,"financeAmountData":"450000","otherDiscountData":null,"ruralDiscountData":3500,"corporateDiscountData":null,"exchangeBonusData":0,"exchangeData":null,"OfferData":null,"otherDiscountValue":false,"ruralOffersValue":true,"exchangeValue":false,"exchangeBonusValue":false,"corporateDiscountValue":false}","registrationAmountVariant":"{"priceBookEntryId":"01u0k000003KnLzAAK","UnitPrice":"5000","Quantity":1,"opporrtunityId":"0060k000008g9I0AAI","registerId":"00k0k000005IDD7AAO"}","exShowRoomVariant":"{"priceBookEntryId":"01u0k000003KnLzAAK","UnitPrice":"537850.00","Quantity":1,"opporrtunityId":"0060k000008g9I0AAI","exShowId":"00k0k000005IDD5AAO"}","selectedColorVariant":{"Variant__r":{"Id":"01t0k0000051AVRAA2","ProductCode":"ER4CD4"},"Color_Type__c":"NM","Variant__c":"01t0k0000051AVRAA2","Color_Code__c":"26U","Name":"SUPERIOR WHITE","Id":"a070k000008D4O7AAK"},"selectedVariant":{"Loyalty_Amount__c":500,"Extended_Warranty_3_year__c":2000,"Extended_Warranty_2_year__c":1500,"Extended_Warranty_1_year__c":1000,"Name":"BALENO ALTURA M","Id":"01t0k0000051AVRAA2"},"addAccessories":"[{"priceBookEntryId":"01u0k000003KoxEAAS","unitPrice":2000,"price":4000,"Maximum_Quantity__c":5,"Minimum_Quantity__c":1,"Id":"01t0k000005R2QpAAK","quantity":"2","Name":"Car Stereo 4","accId":"00k0k000005IDD6AAO"}]","addComponent":"[{"isDisabled":true,"showLabel":false,"isExchangedWarrenty":true,"isChecked":true,"value":"1000","label":"Extended Warranty","comId":"00k0k000005IDDGAA4"},{"isDisabled":true,"showLabel":true,"isChecked":true,"value":500,"label":"Loyalty","comId":"00k0k000005IDD8AAO"},{"isDisabled":false,"showLabel":true,"isChecked":true,"value":"2500","label":"Insurance","comId":"00k0k000005IDD9AAO"},{"isDisabled":false,"showLabel":true,"isChecked":false,"value":"","label":"Municipal Charges"},{"isDisabled":false,"showLabel":true,"isChecked":false,"value":"","label":"Number Plate Charges"},{"isDisabled":false,"showLabel":true,"isChecked":false,"value":"","label":"Road Tax"},{"validityValue":"2 Yrs - 20000 KMs","packageValue":"Economy","isDisabled":false,"showLabel":true,"isMCP":true,"isChecked":true,"value":"2000","label":"MCP","comId":"00k0k000005IDDAAA4"}]","headerValue":["Customer Name : ADNAN F DANE","DMS Enquiry Number : ENQ 00012","Variant Name : BALENO ALTURA M"]}';

        for( Integer i = 0; i < numOfRec; i++ ) {

            Quote qu = new Quote(
                                    Name = 'John '+i,
                                    Line_Item_Summary__c=dataList,
                                    opportunityId = opportunityId
                                    );
            quoteList.add(qu);
        }

        return quoteList;
    }


    // MAP FIELDS ON USER RECORD -
    public static User generateUserData(String ProfileName, string ContactId, string titleName){

        Profile p = [SELECT Id FROM Profile WHERE Name=:ProfileName];

        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              title = titleName,
                              LocaleSidKey='en_US', ProfileId = p.Id,ContactId = ContactId,
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'+DateTime.now().millisecond());


        return u;
    }




    // CREATE COLOR VARIANT MASTER
    public static List<Color_Variant_Master__c> createColorVarientRealetdToProduct(Integer numOfRec, String productId) {
        List<Color_Variant_Master__c> colorList = new List<Color_Variant_Master__c>();

        for( Integer i = 0; i < numOfRec; i++ ) {

            Color_Variant_Master__c cv = new Color_Variant_Master__c(
                                    Name = 'PRL.SNOW WHITE 3 '+i,
                                    Variant__c = productId,
                                    Color_Code__c = 'ZQM',
                                    Color_Type__c = 'M');
            colorList.add(cv);
        }

        return colorList;
    }



    // CREATE MCP MASTER
    public static List<MCP_Master__c> createMCPMaster(Integer numOfRec) {
        List<MCP_Master__c> mcpList = new List<MCP_Master__c>();

        for( Integer i = 0; i < numOfRec; i++ ) {

            MCP_Master__c mcp = new MCP_Master__c(
                                    Package_Description__c = 'Economy',
                                    Package_Validity__c = '2Yrs or 20000 KMs',
                                    From_Date__c = system.today().addDays(-1),
                                    To_Date__c = system.today().addDays(1),
                                    Fuel_Type__c = 'Petrol',
                                    Amount__c = 1200
                                    );
            mcpList.add(mcp);
        }

        return mcpList;
    }



    // CREATE PRODUCTS BASED ON RECORDTYPE
    public static List<Product2> createProducts(string recordTypeName, integer count){

        String productRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();

        List<Product2> pro = new List<Product2>();
        if(count > 0){
            for(Integer i=0; i<count; i++) {
                Product2 a = new Product2(RecordTypeId= productRecordTypeId, Name='Ciaz '+i, ProductCode = 'Ciaz', Fuel_Type__c='Petrol',Channel__c='EXC',Family='Ciaz', Scheme_Code__c= 'Ciaz', Dealer_Code__c= 'EMP001', Scheme_Description__c= 'Test Drive', Minimum_Quantity__c= 1, Discount_Price__c= 120, Start_Date__c= system.today(), End_Date__c= system.today().addDays(5), Model__c= 'CIAZ', isActive= true);
                pro.add(a);
            }
            return pro;
        }
        return null;
    }

    // CREATE TASKS BASED ON RECORDTYPE
    public static List<Task> createTask(Integer numOfRec, string recordtypId) {
        List<Task> taskList = new List<Task>();

        for( Integer i = 0; i < numOfRec; i++ ) {

            Task tsk = new Task(ActivityDate = system.today(),
                                IsReminderSet = True,

                                Priority = 'Normal',
                                recordTypeId = recordtypId,
                                Status = 'Open',
                                Subject = 'Service PSF Follow-Up',


                                Customer_Mobile__c = '9560128909');
            taskList.add(tsk);
        }

        return taskList;
    }

    // CREATE TASKS BASED ON RECORDTYPE with Opportunity
    public static List<Task> createTask(Integer numOfRec, Opportunity opp, string recordtypId) {
        List<Task> taskList = new List<Task>();

        for( Integer i = 0; i < numOfRec; i++ ) {

            Task tsk = new Task(ActivityDate = system.today(),
                                IsReminderSet = True,
                                OwnerId = opp.ownerId,
                                Priority = 'Normal',
                                recordTypeId = recordtypId,
                                Status = 'Open',
                                Subject = 'Pre Booking Follow-up',
                                Type = 'Telephone',
                                WhatId = opp.Id,
                                Customer_Mobile__c = '9560128909');
            taskList.add(tsk);
        }

        return taskList;
    }

    // CREATE TASKS BASED ON RECORDTYPE FOR CUSTOMER(Account)
    public static List<Task> createTask(Integer numOfRec, Account acc, string recordtypId) {
        List<Task> taskList = new List<Task>();

        for( Integer i = 0; i < numOfRec; i++ ) {

            Task tsk = new Task(ActivityDate = system.today(),
                                IsReminderSet = True,
                                Priority = 'Normal',
                                recordTypeId = recordtypId,
                                Status = 'Open',
                                Subject = 'PSF Follow-up',
                                Type = 'Telephone',
                                Contact_ID__c = acc.Id,
                                whatId= acc.Id,
                                Customer_Mobile__c = '9560128909');
            taskList.add(tsk);
        }

        return taskList;
    }


    // CREATE CONTENT VERSIONS
    public static list<Contentversion> createContentversion(integer numOfRec){
        list<Contentversion> Contentversionlist = new list<Contentversion>();
        for(integer i=0;i<numOfRec;i++){
            ContentVersion cv=new Contentversion();
            cv.title='ABC';
            cv.PathOnClient ='test';
            Blob b=Blob.valueOf('Unit Test Attachment Body');
            cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
            Contentversionlist.add(cv);
        }
        return Contentversionlist;
    }


    // CREATE PRICE MASTER
    public static List<Price_Master__c> createPriceMaster(Integer numOfRec, String variantCodeId, String forCodeId) {
        List<Price_Master__c> priceMasterList = new List<Price_Master__c>();

        for( Integer i = 0; i < numOfRec; i++ ) {

            Price_Master__c price = new Price_Master__c(
                                Name = 'Base Price',
                                From_Date__c = system.today().addYears(-1),
                                To_Date__c = system.today().addYears(1),
                                Amount__c =  537850,
                                Active__c = True,
                                External_ID__c = 'ER4CD4-AJ-NM',
                                Color_Type__c = 'NM',
                                Variant_Code__c = variantCodeId,
                                For_Code__c = forCodeId
                                   );
            priceMasterList.add(price);
        }

        return priceMasterList;
    }


    // CREATE SRUVEY TAKEN
    public static list<SurveyTaker__c> createSurveyTaken(integer numOfRec){
        list<SurveyTaker__c> surveyTakenList = new list <SurveyTaker__c>();

        for(integer i=0;i<numOfRec;i++){
            SurveyTaker__c sr = new SurveyTaker__c(Taken__c='test');
            surveyTakenList.add(sr);
        }
        return surveyTakenList;
    }


    // CREATE SRUVEY
    public static list<Survey__c> createSurvey(integer numOfRec){
        list<Survey__c> sclist= new list<Survey__c>();
        for(integer i= 0 ;i<numOfRec;i++){
            Survey__c sc = new Survey__c();
            sc.Name='Test Drive Feedback';
            sclist.add(sc);
        }
        return sclist;
    }


    // CREATE SRUVEY
    public static list<Survey__c> createSurveyPerformance(integer numOfRec,string Name){
        list<Survey__c> svPlist= new list<Survey__c>();
        for(integer i= 0 ;i<numOfRec;i++){
            Survey__c sc = new Survey__c();
            sc.Name=Name;
            svPlist.add(sc);
        }
        return svPlist;
    }


    // CREATE SRUVEY QUESTIONS
    public static list<Survey_Question__c> createSurveyQuestion(integer numOfRec){
        list<Survey__c> surveylist = new list<Survey__c>();
        surveylist = createSurvey(1);
        insert surveylist;
        list<Survey_Question__c> sclist= new list<Survey_Question__c>();
        for(integer i= 0 ;i<numOfRec;i++){
            Survey_Question__c sc = new Survey_Question__c();
            sc.Name = 'test';
            sc.Type__c = 'Single Select--Vertical';
            sc.OrderNumber__c = 1;
            sc.Question__c ='How was your experience of Test Drive';
            sc.survey__c = surveylist[0].id;
            sclist.add(sc);
        }
        return sclist;
    }


    // CREATE SRUVEY QUESTIONS RESPONSE
    public static list<SurveyQuestionResponse__c> createSurveyQuestionAnswer(integer numOfRec){
        list<Survey_Question__c> sqlist = new list<Survey_Question__c>();
        list<SurveyTaker__c> surveyTakenList = new list <SurveyTaker__c>();
        surveyTakenList = createSurveyTaken(1);
        sqlist = createSurveyQuestion(1);
        insert surveyTakenList;
        insert sqlist;
        list<SurveyQuestionResponse__c> sclist= new list<SurveyQuestionResponse__c>();
        for(integer i= 0 ;i<numOfRec;i++){
            SurveyQuestionResponse__c sc = new SurveyQuestionResponse__c();
            sc.Remarks__c = 'test';
            sc.Date_Expected__c = System.today();
            sc.Response__c = 'No';
            sc.Survey_Question__c = sqlist[0].id;
            sc.SurveyTaker__c = surveyTakenList[0].id;
        }
        return sclist;
    }

    // CREATE PRICEBOOKENTRY
    public static List<PricebookEntry> createPricebookEntry(Integer numOfRec, String productId) {
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();

        for( Integer i = 0; i < numOfRec; i++ ) {

            PricebookEntry priceEntry = new PricebookEntry(
                                                unitprice = 1,
                                                Product2Id = productId,
                                                Pricebook2Id = Test.getStandardPricebookId(),
                                                isActive = true,
                                                UseStandardPrice = false);
            pricebookEntryList.add(priceEntry);
        }

        return pricebookEntryList;
    }


    // CREATE OPPORTUNITY LINE ITEMS
    public static List<OpportunityLineItem> createOpportunityLineItem(Integer numOfRec, String opportunityId, String priceBookEntryId) {
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();

        for( Integer i = 0; i < numOfRec; i++ ) {

            OpportunityLineItem oli = new OpportunityLineItem(
                                                quantity = 1,
                                                UnitPrice = 1,
                                                priceBookEntryId = priceBookEntryId,
                                                opportunityId = opportunityId
                                                );
            oliList.add(oli);
        }

        return oliList;
    }

    // CREATE CITY MASTER ADDRESS DATA
    public static list<City__c> createCityAddressMasterData(Integer numOfRec){
        list<city__c> cityList = new list<city__c>();
        for(integer i=0;i<numOfRec;i++){
            City__c c = new City__c();
            c.City_Code__c = '1234';
            c.State__c = 'UP';
            c.Name='Noida';
            cityList.add(c);
        }
        return cityList;
    }

    // CREATE TEHSIL MASTER ADDRESS DATA
    public static list<Tehsil__c> createTehsilAddressMasterData(Integer numOfRec){
        list<Tehsil__c> tList = new list<Tehsil__c>();
        for(Integer i=0;i<numOfRec;i++){
            Tehsil__c t = new Tehsil__c();
            t.Name = 'Nanded';
            t.Tehsil_Code__c = '4100';
            t.District__c = 'Nanded';
            tList.add(t);
        }
        return tList;

    }

    // CREATE VILLAGE MASTER ADDRESS DATA
    public static list<Village__c> createVillageAddressMasterData(Integer numOfRec){
        list<Village__c> vlgList = new list<Village__c>();
        for(Integer i=0;i<numOfRec;i++){
            Village__c v = new Village__c();
            v.Name = 'Forest Block';
            v.Village_Code__c = 'VIL160077';
            v.Name='Noida';
            vlgList.add(v);
        }
        return vlgList;
    }

    // CREATE PINCODE MASTER ADDRESS DATA
    public static list<Pincode__c> createPinAddressMasterData(Integer numOfRec){
        list<Pincode__c> pinList = new list<Pincode__c>();
        for(integer i=0;i<numOfRec;i++){
            Pincode__c p = new Pincode__c();
            p.Name='Noida';
            pinList.add(p);
        }
        return pinList;
    }

    // CREATE QUOTE LINE ITEMS
    public static List<QuoteLineItem> createQuoteLineItem(Integer numOfRec, String quoteId, String priceBookEntryId) {
        List<QuoteLineItem> oliList = new List<QuoteLineItem>();

        for( Integer i = 0; i < numOfRec; i++ ) {

            QuoteLineItem oli = new QuoteLineItem(
                                                quantity = 1,
                                                UnitPrice = 1,
                                                priceBookEntryId = priceBookEntryId,
                                                quoteId = quoteId
                                                );
            oliList.add(oli);
        }

        return oliList;
    }


    // CREATE CORPORATE OBJECT RECORDS
    public static List<Corporate__c> createCorporate(Integer numOfRec) {

        List<Corporate__c> corList = new List<Corporate__c>();

         for( Integer i = 0; i < numOfRec; i++ ) {
            Corporate__c cor = new Corporate__c();
            cor.Corporate_Code__c = '120'+i;

            corList.add(cor);
        }
        return corList;
    }


    // CREATE SCHEME MASTER
    public static List<Scheme_Master__c> createSchemeMaster(Integer numOfRec, String recordTypeName) {

        string recordTypeId = Schema.SObjectType.Scheme_Master__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        List<Scheme_Master__c> smList = new List<Scheme_Master__c>();

         for( Integer i = 0; i < numOfRec; i++ ) {
            Scheme_Master__c sm = new Scheme_Master__c();
            sm.recordTypeId = recordTypeId;
            sm.Discount_Amount__c = 1200;
            sm.Active__c = true;
            sm.status__c = 'A';
            sm.From_Date__c = system.today().addDays(-1);
            sm.To_Date__c = system.today().addDays(1);

            smList.add(sm);
        }
        return smList;
    }


    // CREATE OTHER AMOUNT VALIDATION CUSTOM SETTING
    public static OtherAmountValidation__c createQuoteAmountValidation(Integer Amount) {
        OtherAmountValidation__c oAmount = new OtherAmountValidation__c();
        oAmount.Offer_Discount_Amount__c = Amount;
        oAmount.Accessories_Discount_Amount__c = Amount;

        return oAmount;
    }


    // CREATE CUSTOMER PROFILE
    public static list<Customer_Profile__c> createCustomerProfile(Integer num){
        list<Customer_Profile__c> customerProfileList = new list<Customer_Profile__c>();
        for(integer i = 0 ;i< num ;i++){
            Customer_Profile__c cp = new Customer_Profile__c();
            cp.Preferred_Social_Media__c = 'Facebook';
            cp.Preferred_Video_Content__c = 'Youtube';
            cp.Avg_spend_on_e_commerce_websites_a_month__c = 'Less than 5k';
            cp.Facebook_Handle__c = 'Raj';
            cp.Insta_Handle__c = 'Raj Rockerz';
            cp.Twitter_Handle__c = 'test';
            cp.Degree_of_preference_for_Maruti_car__c = 'High';
            cp.Maruti_service_is_value_for_money__c = 'Yes';
            cp.Preference_for_MGA_or_non_MGA__c= 'MGA';
            cp.Maruti_Insurance_better_than_competition__c = 'Yes';
            cp.Did_you_even_buy_a_Non_Maruti_Insurance__c ='Yes';
            cp.Reason_s_for_churn_out_from_Maruti__c ='Service';
            cp.Personal_Annual_Income_in_Lacs__c = '5 - 10';
            cp.PIN__c = 110086;
            cp.Languages_Known__c = 'HINDI, ENGLISH';
            cp.Year_of_1st_job_after_graduation_YYYY__c = 2017;
            cp.Graduation_year_of_the_individual_YYYY__c = 2008;
            cp.Auto_Journals__c = 'Good';
            cp.Degree_Of__c='Features';
            cp.Parking_Space_at__c = 'Y';
            cp.Purpose_Of_Vehicle__c ='Long Distance';
            cp.Age_Of_Two_Wheeler_Owned__c = 'test';
            cp.Models_Enquired_From_Competitors__c = 'very bad';
            cp.Number_Of_Two_Wheelers_Owned__c = 2;
            cp.Who_drives_the_car__c = 'driver';
            cp.Distance_Of_Home_From_Office_In_Kms__c = 'test';
            cp.Average_Household_Savings__c = 'Less than 5';
            cp.Number_Of_Children__c = 2;
            cp.Did_You_Become_A_Parent_In_Last_1_Year__c= 'Yes';
            cp.Date_Of_Birth_Of_Child_1__c = date.valueof(System.today());
            cp.Date_Of_Birth_Of_Child_2__c = date.valueof(System.today());
            cp.Parents_Marriage_Anniversary__c = date.valueOf(System.today());
            cp.Type_Of_Two_Wheeler_Owned__c = 'Bike';
            cp.Has_Anyone_In_The_Family_Of_The_Individu__c= 'Yes';
            cp.Number_Of_Dependents__c =2;
            customerProfileList.add(cp);
        }
        return customerProfileList;
    }


    // CREATE ENQUIRY ESCALATIONS CUSTOM SETTING
    public static list<Enquiry_Escalations__c> CreateEnqEscalation(String Leadsource,String Dealership,
                                                                   String EscalationType,list<String> notifersList
                                                                  ,list<integer> timeList){
        list<Enquiry_Escalations__c> esclist = new list<Enquiry_Escalations__c>();
        for(integer i =1 ; i<=4; i++){
            Enquiry_Escalations__c esc13= new Enquiry_Escalations__c();
            esc13.Source__c = Leadsource;
            esc13.Name = Dealership+' Level '+i;
            esc13.Type_of_Escalation__c = EscalationType;
            esc13.Level_of_Escalation__c='Level '+i;
            esc13.Time_to_Escalation__c = timeList[i];
            esc13.Notifiers__c =notifersList[i];
            esclist.add(esc13);

        }
        return esclist;
    }


   //CREATE CITY MASTR
   public static List<City__c> createAddressMasterData(Integer count, String obj){

       List<City__c> cityList = new list<City__c>();
       for(Integer i=0;i<count;i++){
           City__c cityObj = new City__c();
           cityObj.Name = 'Noida';
           cityObj.City_Code__c = 'ND';
           cityObj.State__c = 'UP';
           cityObj.Region__c = 'N1';
           cityList.add(cityObj);
       }
       return cityList;
   }
    // CREATE SMS URL
    public static List<SMS_URL__c> createSMSURL(Integer smsURLCount)
    {
        List<SMS_URL__c> smsURLList=new List<SMS_URL__c>();
        for(Integer i=0;i<smsURLCount;i++)
        {
            SMS_URL__c sms=new SMS_URL__c();
            sms.Redirect_URL__c='www.salesforce.com';
            sms.Expiry_Date__c=System.today()+1;
            sms.Mobile__c='90909090';
            smsURLList.add(sms);
        }
        return smsURLList;
    }


    // CREATE CUSTOM VALIDATION EXCEPTION SETTING
     public static Custom_Validation_Exception_Setting__c createCustomValidation(Boolean isInsert){
        Custom_Validation_Exception_Setting__c valid = new Custom_Validation_Exception_Setting__c();
            valid.Name = 'Bypass';
            valid.Bypass_Validation_Rules__c=true;
        If(isInsert){
            insert valid;
            return valid;
        }
        else{
            return valid;
        }
    }


    // CREATE PRODUCT RECORDS
    public static List<Product2> createProduct2(Integer num)
    {
         List<Product2> productList=new List<Product2>();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );

        // Run an update DML on the Pricebook2 record
        // This is the weird workaround that enables IsStandard to become true
        // on the PricebookEntry record
        update standardPricebook;

        // Re-Query for the Pricebook2 record, for debugging
        standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];

        // This should return true now
        system.assertEquals(true, standardPricebook.IsStandard, 'The Standard Pricebook should now return IsStandard = true');

        // Create the Product
        for(Integer i=0;i<num;i++)
        {
        Product2 testProduct = new Product2();
        testProduct.Name = 'Test Product';
        testProduct.IsActive = true;
        testProduct.Channel__c='EXC';
        testProduct.Fuel_Type__c='Petrol';
        testProduct.Start_Date__c=System.today();
        testProduct.End_Date__c=System.today()+2;
        testProduct.Model__c='test';
        productList.add(testProduct);
        }
        return productList;

    }


    // CREATE PRICEBOOKENTRY
    public static list<PriceBookEntry> createPriceBookEntryList(integer totalNum,string productId){
        list<PriceBookEntry> PriceEntryList = new List<PriceBookEntry>();
        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );

        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;

        //Query for the Pricebook2 record, to check IsStandard field
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];


        //Create the PricebookEntry
        for(integer i=0; i< totalNum;i++){
            PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = productId,
                UnitPrice = 1020,
                IsActive = true
            );
           PriceEntryList.add(pbe);
        }

        return PriceEntryList;
    }

    //CREATE Tehsil MASTR
   public static List<City__c> createTehsiMasterData(Integer count){

       List<City__c> cityList = new list<City__c>();
       for(Integer i=0;i<count;i++){
           City__c cityObj = new City__c();
           cityObj.Name = 'Noida';
           cityObj.City_Code__c = 'ND';
           cityObj.State__c = 'UP';
           cityObj.Region__c = 'N1';
           cityList.add(cityObj);
       }
       return cityList;
   }

    // CREATE MC COMMUNICATION
    public static list<MC_Communication__c> createMCCommData(integer totalNum, Id enquiryId){
        list<MC_Communication__c> mcList = new list<MC_Communication__c>();

        for(integer i=0; i< totalNum;i++){
            MC_Communication__c mc = new MC_Communication__c();
            mc.Type__c = 'Escalation';
            mc.Escalation_Date_Time__c = DateTime.newInstance(2019, 11, 15, 11, 25, 33);
            mc.General_Field_1__c = 'DSE Allocation Time';
            mc.Enquiry_MD__c = enquiryId;
            mcList.add(mc);
        }


        return mcList;
    }

    //CREATE PUBLIC GROUP
    public static List<GROUP> createPublicGroup(integer totalNum){
      List<Group> lstGroup=new List<Group>();
      String sGroupNameToken='Grp';
     for(integer i=0; i< totalNum;i++){
            Group grpVar=new Group(Type='Regular');
            grpVar.DeveloperName=sGroupNameToken+i;
            grpVar.Name=sGroupNameToken+i;
            lstGroup.add(grpVar);

        }
     return lstGroup;
    }

    //CREATE CUSTOMER VISIBILITY RECORD FOR GROUP
    public static List<Customer_visibility__c> createCustomerVisibilityRecordsForGroup(integer totalNum,List<Account> lstCustomerAccount){
      List<Customer_visibility__c> lstCV=new List<Customer_visibility__c>();
      String sGroupNameToken='Grp';
      String sInteruserDMSUsernameToken='usr';
     for(integer i=0; i< totalNum;i++){
         for(Account accVar: lstCustomerAccount){
           Customer_visibility__c cvVar=new Customer_visibility__c();
           cvVar.Access_Processing_Status__c='Pending';
           cvVar.Customer_Account__c=accVar.Id;
           cvVar.Dealer_Public_Group_Name__c=sGroupNameToken+i;
           cvVar.End_Datetime__c=System.now().addDays(-2);
          // cvVar.MSIL_User_ID__c=
           cvVar.Start_Datetime__c=System.now();
           lstCV.add(cvVar);
         }
        }
     return lstCV;
    }
    //CREATE CUSTOMER VISIBILITY RECORD FOR GROUP
    public static List<Customer_visibility__c> createCustomerVisibilityRecordsForUser(integer totalNum,List<Account> lstCustomerAccount){
      List<Customer_visibility__c> lstCV=new List<Customer_visibility__c>();

      String sInteruserDMSUsernameToken='usr';
     for(integer i=0; i< totalNum;i++){
         for(Account accVar: lstCustomerAccount){
           Customer_visibility__c cvVar=new Customer_visibility__c();
           cvVar.Access_Processing_Status__c='Pending';
           cvVar.Customer_Account__c=accVar.Id;
           cvVar.MSIL_User_ID__c=sInteruserDMSUsernameToken+i;
           cvVar.End_Datetime__c=System.now().addDays(-2);

           cvVar.Start_Datetime__c=System.now();
           lstCV.add(cvVar);
         }
        }
     return lstCV;
    }
    //CREATE DEALER ACCOUNT
    public static List<Account> createDealerAccount(integer totalNum) {
        List<Account> lstAccount=new List<Account>();
        String sGroupNameToken='Grp';
        Id rectypeId=[select Id from Recordtype where DeveloperName='Dealer'].Id;
        for(integer i=0; i< totalNum;i++){
            Account accVar=new Account();
            accVar.Name='test'+i;
            accVar.recordTypeId=rectypeId;
            accVar.Parent_Group__c=sGroupNameToken+i;
            lstAccount.add(accVar);

        }
        return lstAccount;
    }
    //CREATE DEALER CONTACT
    public static List<Contact> createDealerContact(integer totalNum,List<Account> lstAccount ){
        List<Contact> lstContact=new List<Contact>();

        for(Account accVar:lstAccount){
            for(integer i=0; i< totalNum;i++){
                Contact conVar=new Contact();
                conVar.FirstName='test';
                conVar.LastName='test'+i;
                conVar.accountId=accVar.Id;

                lstContact.add(conVar);

            }
        }
        return lstContact;
    }

    // This method is used create Users//
    public static List<User> createUsers(String ProfileName){
        // Insert Users
        Id AccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();

        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        Insert forCodeList;

        Account acc = new Account(Name='TestAccount',RecordTypeId=AccRecTypeId, For_Code__c = forCodeList[0].Id);
        insert acc;

        List<Contact> conlist = new list<Contact>();
        List<User> userlist = new list<User>();

        Profile p = [SELECT Id FROM Profile WHERE Name=:ProfileName];

        for(Integer i=1;i<=2 ;i++){
            Contact con = new Contact(LastName='TestAcc'+i, AccountId=acc.Id);
            conlist.add(con);
        }
        insert conlist;

        //Create another user for the managerId in other user.

        system.debug('== conlist '+ conlist);

        //Insert Portal user
        for(Contact cont : conlist){
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',Title=ProfileName=='Dealer Sales Executive' ? label.Sales_Executive : 'Team Lead',
                              LocaleSidKey='en_US', ProfileId = p.Id,ContactId=cont.Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'+String.valueOf(Math.random()));

            userlist.add(u);
        }
        System.debug('== userlist '+userlist);
        return userlist;
    }

    //This method is used to create Assets Records
    public static list<Asset> CreateAssetsRecords(integer numOfRec){
        list<Asset> assetList = new list<Asset>();
        for(integer i=0 ;i<numOfRec;i++){
            Asset a = new Asset();
            a.name = 'Ciaz';
            assetList.add(a);
        }
        return assetList;
    }

    // Added by Nitin on 17th Feb 2020 - This method is used to Create Work Order Records
    public static List<WorkOrder> CreateWorkOrderRecords(integer numberofRec,String recordTypeName,String assetId,String customerRecId,String workshopId){
        list<WorkOrder> workOrderList = new list<WorkOrder>();
        Id woRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        for(integer i=0 ;i<numberofRec;i++){
            WorkOrder work = new WorkOrder();
            work.Status = 'New';
            work.AssetId=assetId;
            work.Mileage__c=23;
            work.Service_Type__c='FR1';
            work.Appointment_Type__c='WI';
            work.Appointment_Datetime__c=datetime.now();
            work.SA_Code__c='1044';
            work.Slot_Code__c='0900-1100';
            work.Slot_Time__c='10:00-10:15';
            work.Pickup_Type__c='PU';
            work.AccountId=customerRecId;
            work.Pickup_Datetime__c=datetime.now();
            work.Pickup_Address__c='Test Record';
            work.Drop_Datetime__c=datetime.now();
            work.Drop_Address__c='Test Record';
            work.Description='Rec';
            work.Service_Number__c='';
            work.Workshop__c=workshopId;
            work.RecordTypeId=woRecordTypeId;
            workOrderList.add(work);
        }
        return workOrderList;
    }

    // Added by Nitin on 20th March 2020 - This method is used to Public Groups
    public static List<Group> CreateGroupRecords(integer numberofRec,String groupName){
        List<Group> grpRec = new List<Group>();
         for(integer i=0 ;i<numberofRec;i++){
             Group grp = new Group();
             grp.Name=groupName;
             grp.DeveloperName =groupName;
             grpRec.add(grp);
         }
        return grpRec;
    }

    // Added by Nitin on 20th March 2020 - This method is used to add Members to Public Group

    public static List<GroupMember> CreateGroupMemberRecords(integer numberofRec,String userId,String groupId){
        List<GroupMember> grpMemRec = new List<GroupMember>();
         for(integer i=0 ;i<numberofRec;i++){
             GroupMember grpMem = new GroupMember();
             grpMem.GroupId=groupId;
             grpMem.UserorGroupId =userId;
             grpMemRec.add(grpMem);
         }
        return grpMemRec;
    }

    // CREATE INFLUENCER BASED ON Hierarchy
    public static List<Influencer__c> createTestInfluencer(Integer numOfRec, String HierarchyId) {
        List<Influencer__c> influencerList = new List<Influencer__c>();

        for( Integer i = 0; i < numOfRec; i++ ) {

            Influencer__c inf = new Influencer__c(Name = 'John '+i,
                                    Hierarchy__c  = HierarchyId);
            influencerList.add(inf);
        }

        return influencerList;
    }

    // Added by Nitin on 14th April 2020 - This method is used to create MMS Vehicle

    public static List<MMS_Vehicle__c> CreateMMSVehicleRecords(integer numberofRec,String dealer,String dealerMapCode,String locationCode){
        List<MMS_Vehicle__c> mmsRec = new List<MMS_Vehicle__c>();
        for(integer i=0 ;i<numberofRec;i++){
            MMS_Vehicle__c mms = new MMS_Vehicle__c();
            mms.Name='Test MMS vehicle';
            mms.Dealer__c=dealer;
            mms.Dealer_Map_Code__c =dealerMapCode;
            mms.Location_Code__c=locationCode;
            mmsRec.add(mms);
        }
        return mmsRec;
    }

    public static List<UserEvaluatorFlag__c> createUserEvaluatorFlagRec(integer numberofRec,String Name){
        List<UserEvaluatorFlag__c> createRec = new List<UserEvaluatorFlag__c>();
        for(integer i=0 ;i<numberofRec;i++){
            UserEvaluatorFlag__c userEval = new UserEvaluatorFlag__c();
            userEval.Name=Name;
            createRec.add(userEval);
        }
        return createRec;
    }

    public static List<Pickup_Location__c> createPickupLocation(integer numberofRec,String dealerId){
        List<Pickup_Location__c> createLoc = new List<Pickup_Location__c>();
        for(integer i=0 ;i<numberofRec;i++){
            Pickup_Location__c locRec = new Pickup_Location__c();
            locRec.Dealer__c=dealerId;
            createLoc.add(locRec);
        }
        return createLoc;
    }
    // CREATE Cases BASED ON RECORDTYPE
    public static List<Case> createCase(Integer numOfRec, Id recordtypId) {
        createCaseMetaDataRecords(); //Added by Anuj (07/01/2021)
        List<Case> caseList = new List<Case>();

        for( Integer i = 0; i < numOfRec; i++ ) {

            Case cs = new Case(
                                recordTypeId = recordtypId,
                                Status = 'Open',
                                Subject = 'Service PSF Follow-Up'

                                );
            caseList.add(cs);
        }

        return caseList;
    }

     // CREATE Bulk hold case
    public static List<Bulk_Hold_Cases__c> createBulkHoldCase(integer numOfRec) {
        List<Bulk_Hold_Cases__c> BulkHolds = new List<Bulk_Hold_Cases__c>();
        for (Integer i = 0; i < numOfRec; i++) {
            Bulk_Hold_Cases__c BulkHold = new Bulk_Hold_Cases__c();
            BulkHold.Approval_Status__c = 'In Progress';
            BulkHolds.add(BulkHold);
        }
        return BulkHolds;
    }

    //Method to create case(Added by Prashant Gahlaut : 16/9/2020)
    public static List<Case> createCase(Integer numCases,String caseRecTypeName){
        createCaseMetaDataRecords(); //Added by Anuj (07/01/2021)
        list<Case> csList = new list<Case>();
        Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(caseRecTypeName).getRecordTypeId();
        String casetype = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(caseRecTypeName).getName();
        for(Integer i=0;i<numCases;i++) {
            Case cs = new case();
            cs.RecordTypeId=caseRecTypeId;
            cs.First_Name__c = 'Test'+i;
            cs.Last_Name__c = 'Joy'+i;
            cs.Email__c = 'test@gmail.com';
            cs.Mobile_SFMC__c = '9876543210';
            cs.Channel__c = 'Nexa';
            cs.Business_Area__c = 'Sales';
            system.debug(casetype);
            cs.Case_Type__c = casetype;
            if(caseRecTypeName=='Dealer_Internal_Request'){
               cs.Channel__c = 'MI';
               cs.Business_Area__c = 'MIBPL (Insurance)';
            }

            cs.Primary_Category__c = 'Legal';
            cs.Mode__c = 'Phone';
            cs.Origin = 'Dealer Inbound';
            cs.Subject = 'Test';
            cs.Description = 'Test';
            csList.add(cs);
        }
        return csList;
    }
    // CREATE CustomSetting Implementation_Strategy__c
    public static Implementation_Strategy__c createIS(string Name, String identifierType, String impltn, String strtKey, String useCase) {
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = Name;
        IS.Identifier_Type__c = identifierType;
        IS.Strategy_Implementation__c = impltn;
        IS.Strategy_Key__c = strtKey;
        IS.Use_Case__c = useCase;

        return IS;
    }

    // CREATE Case Comments
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

     // Added by Najab Maghribi 16-October-2020
    public static List<Survey_Question_CTI__c> createSurveyQuestionCTI(String campaignRecId){
        List<Survey_Question_CTI__c> surveyQuestionCTIList = new List<Survey_Question_CTI__c>();
        if(String.isNotBlank(campaignRecId)){
            Survey_Question_CTI__c surveyQuestionCTI =  new Survey_Question_CTI__c();
            surveyQuestionCTI.Question_Name__c = 'Test Record';
            surveyQuestionCTI.Survey__c = campaignRecId;
            surveyQuestionCTI.Language_Type__c = 'English';
            surveyQuestionCTI.Pre_Question_Script__c = '{{!User.Name}} {{!Greeting}} Test Pre Script';
            surveyQuestionCTI.Post_Question_Script__c = '{{!User.Name}} {{!Greeting}} Test Post Script';
            surveyQuestionCTIList.add(surveyQuestionCTI);
        }
        return surveyQuestionCTIList;
    }

    // Added by Najab Maghribi 16-October-2020
    public static List<Survey_Answer_CTI__c> createSurveyAnswerCTI(String questionRecId){
        List<Survey_Answer_CTI__c> surveyAnswersList = new List<Survey_Answer_CTI__c>();
        if(String.isNotBlank(questionRecId)){
            Survey_Answer_CTI__c surveyAnswersRecord = new Survey_Answer_CTI__c();
            surveyAnswersRecord.Parent_Question__c = questionRecId;
            surveyAnswersList.add(surveyAnswersRecord);
        }
        return surveyAnswersList;
    }

    // Added by Najab Maghribi 16-October-2020
    public static List<Survey_Taker_CTI__C> createSurveyTaker(String accountId, String campaignId){
        List<Survey_Taker_CTI__C> surveyTakerList = new List<Survey_Taker_CTI__C>();
        if(String.isNotBlank(accountId) && String.isNotBlank(campaignId)){
            Survey_Taker_CTI__C surveyTakerCTI = new Survey_Taker_CTI__C();
            surveyTakerCTI.customer__c = accountId;
            surveyTakerCTI.Survey__c = campaignId;
            surveyTakerList.add(surveyTakerCTI);
        }
        return surveyTakerList;
    }

    // Added by Najab Maghribi 23-October-2020
    public static List<For_Code__c> createForCodeRecord(){
        List<For_Code__c> forCodeList = new List<For_Code__c>();
        For_Code__c forCodeRec = new For_Code__c();
        forCodeRec.Name = 'Delhi';
        forCodeRec.For_Code__c = '08';
        forCodeRec.Region_Code__c = 'C1';
        forCodeRec.Zone_Code__c = 'Central';
        forCodeList.add(forCodeRec);
        return forCodeList;
    }

    //Added by Najab Maghribi 26-October-2020
    public static List<Account> createCustomerAccount(Integer numAccts, String accRecTypeName) {
        List<Account> accts = new List<Account>();
        Id AccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(accRecTypeName).getRecordTypeId();

        for (Integer i = 0; i < numAccts; i++) {
            Account a = new Account(Name = 'TestAccount', RecordTypeId = AccRecTypeId);
            accts.add(a);
        }
        return accts;
    }
    //Added by Najab Maghribi 21-12-2020
    public static List<Survey_Taker_CTI__c> createSurveyTakerCTI() {
        List<Survey_Taker_CTI__c> lstSurveyTakers = new List<Survey_Taker_CTI__c>();
        Survey_Taker_CTI__c surveyTakerCTI = new Survey_Taker_CTI__c();
        surveyTakerCTI.DPS_ID__c = '12345';
        lstSurveyTakers.add(surveyTakerCTI);
        return lstSurveyTakers;
    }
    public static List<Case_Picklist_Field_Filters__c> createCasePicklistFilters(){
        List<Case_Picklist_Field_Filters__c> lstCasePickLists = new List<Case_Picklist_Field_Filters__c>();
        Case_Picklist_Field_Filters__c objCasePickList = new Case_Picklist_Field_Filters__c();
        objCasePickList.Channel__c = 'Channel';
         objCasePickList.Name = 'Name Case Picklist';
        objCasePickList.Case_Type__c = 'CaseType';
        objCasePickList.Business_Area__c = 'BuisnessArea';
        lstCasePickLists.add(objCasePickList);
        return lstCasePickLists;
    }
    
    
    //Added by Anuj : To create the Case_Escalations_Matrix_MDT__c, MOS_Escalation_MDT__c
    public static void createCaseMetaDataRecords(){
        
        Case_Escalations_Matrix_MDT__c escalations_matrix = new Case_Escalations_Matrix_MDT__c();
        escalations_matrix.Name = 'Transfer Escalation Level 1';
        escalations_matrix.Escalation_Type__c = ConstantsUtility.ESCALATION_TYPE_TRANSFER;
        escalations_matrix.Case_Type__c = ConstantsUtility.SALES_CASE_BUSINESS_AREA;
        escalations_matrix.Escalation_Level__c = 'Level 1';
        escalations_matrix.Time_to_Next_Escalation__c = 1;
        escalations_matrix.Notifiers__c = 'L5';
        escalations_matrix.highest_level_escalation__c='Level 4';
        
        insert escalations_matrix;
        
        
        MOS_Escalation_MDT__c mos = new MOS_Escalation_MDT__c();
        mos.Name = 'Accidental_CC_MOS_Amber_Follow_Up';
        mos.Case_Action_Record_Id_Field__c = 'Escalation_Follow_up__c';
        mos.Channel__c = 'Nexa';
        mos.Duration__c = 900;
        mos.Condition__c = 'Task_Completed__c';
        mos.Escalation_Audience__c = 'AM- MOS';
        mos.Escalation_Type__c = 'Follow-up';
        mos.Escalation_Level__c = 'Amber';
        mos.Escalation_Update__c = 'LastModifiedDate';
        mos.MOS_Case_Stage__c = 'Customer Cancelled';
        mos.Job_Type__c = 'Accidental';
        mos.MOS_Case_Type__c = 'MOS';
        mos.Notification_Type__c = 'MOS Follow Up SLA Breach';
        mos.Value__c = 'Stage Changed1,Stage Changed2';
        
        insert mos;
        
    }
    
}