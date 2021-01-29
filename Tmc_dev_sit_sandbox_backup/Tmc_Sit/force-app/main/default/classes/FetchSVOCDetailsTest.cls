@isTest(seeAlldata=False)
public class FetchSVOCDetailsTest {

    static testmethod void test(){

        System.debug('Inside Test');
        // Invoke the continuation by calling the action method
        Continuation conti = (Continuation)FetchSVOCDetails.fetchSelectedSVOCDetails('Car_Details','TESTSVOCID','TESTSVOCID');
        //BasicReturn conti1 = (BasicReturn)FetchSVOCDetails.fetchSelectedSVOCDetails(' Car_Details','','TESTSVOCID');
        // Verify that the continuation has the proper requests
        Map<String, HttpRequest> requests = conti.getRequests();
        system.assert(requests.size() == 1);


        // Perform mock callout
        // (i.e. skip the callout and call the callback method)
        HttpResponse response = new HttpResponse();
        response.setBody('{"messageId":"96c884d3-4339-42a0-b8b8-81ca48101b6c","status":"Success","customerVehiclesList":[{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"},{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"},{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"}]}');
        response.setStatusCode(200);
        // Set the fake response for the continuation
        Test.setContinuationResponse('Continuation-1', response);

        // Invoke callback method

        List<String> strList = new list<String>();
        strList.add('Continuation-1');

        Object neObj = (Object)'Car_Details';

        FetchSVOCDetails.processResponse(strList,neObj);

        // result is the return value of the callback
        //System.assertEquals(null, result);
        // Verify that the controller's result variable
        //   is set to the mock response.

    }
    static testmethod void test1(){

        System.debug('Inside Test1');
        // Invoke the continuation by calling the action method
        Continuation conti = (Continuation)FetchSVOCDetails.fetchSelectedSVOCDetails('Enquiries','TESTSVOCID','');
        //Continuation conti1 = (Continuation)FetchSVOCDetails.fetchSelectedSVOCDetails('Enquiries','','TESTSVOCID');
        // Verify that the continuation has the proper requests
        Map<String, HttpRequest> requests = conti.getRequests();
        system.assert(requests.size() == 1);


        // Perform mock callout
        // (i.e. skip the callout and call the callback method)
        HttpResponse response = new HttpResponse();
        response.setBody('{"messageId":"96c884d3-4339-42a0-b8b8-81ca48101b6c","status":"Success","customerEnquiriesList":[{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"},{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"},{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"}]}');
        response.setStatusCode(200);
        // Set the fake response for the continuation
        Test.setContinuationResponse('Continuation-1', response);

        // Invoke callback method

        List<String> strList = new list<String>();
        strList.add('Continuation-1');

        Object neObj = (Object)'Enquiries';

        FetchSVOCDetails.processResponse(strList,neObj);

        // result is the return value of the callback
        //System.assertEquals(null, result);
        // Verify that the controller's result variable
        //   is set to the mock response.

    }
    static testmethod void test2(){

        System.debug('Inside Test2');
        // Invoke the continuation by calling the action method
        Continuation conti = (Continuation)FetchSVOCDetails.fetchSelectedSVOCDetails('Car_Details','','TESTSVOCID');
        //Continuation conti1 = (Continuation)FetchSVOCDetails.fetchSelectedSVOCDetails('Enquiries','','TESTSVOCID');
        // Verify that the continuation has the proper requests
        Map<String, HttpRequest> requests = conti.getRequests();
        system.assert(requests.size() == 1);


        // Perform mock callout
        // (i.e. skip the callout and call the callback method)
        HttpResponse response = new HttpResponse();
        response.setBody('{"messageId":"96c884d3-4339-42a0-b8b8-81ca48101b6c","status":"Success","customerEnquiriesList":[{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"},{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"},{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"}]}');
        response.setStatusCode(20);
        // Set the fake response for the continuation
        Test.setContinuationResponse('Continuation-1', response);

        // Invoke callback method

        List<String> strList = new list<String>();
        strList.add('Continuation-1');

        Object neObj = (Object)'Enquiries';

        FetchSVOCDetails.processResponse(strList,neObj);

        // result is the return value of the callback
        //System.assertEquals(null, result);
        // Verify that the controller's result variable
        //   is set to the mock response.

    }
    static testmethod void test3(){

        System.debug('Inside Test3');
        // Invoke the continuation by calling the action method
        Continuation conti = (Continuation)FetchSVOCDetails.fetchSelectedSVOCDetails('EW','TESTSVOCID','TESTSVOCID');
        //BasicReturn conti1 = (BasicReturn)FetchSVOCDetails.fetchSelectedSVOCDetails(' Car_Details','','TESTSVOCID');
        // Verify that the continuation has the proper requests
        Map<String, HttpRequest> requests = conti.getRequests();
        system.assert(requests.size() == 1);


        // Perform mock callout
        // (i.e. skip the callout and call the callback method)
        HttpResponse response = new HttpResponse();
        response.setBody('{"messageId":"96c884d3-4339-42a0-b8b8-81ca48101b6c","status":"Success","customerVehiclesList":[{"VIN":"abcde","Penetration":{"EWPenetration":{"3rdYear":false, "4thYear":false, "5thYear":false}},"Source":"abcde","TestDrive":"abcde","Exchange":"abcde"},{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"},{"Stage":"abcde","Model":"abcde","Source":"abcde","TestDrive":"abcde","Exchange":"abcde"}]}');
        response.setStatusCode(200);
        // Set the fake response for the continuation
        Test.setContinuationResponse('Continuation-1', response);

        // Invoke callback method

        List<String> strList = new list<String>();
        strList.add('Continuation-1');

        Object neObj = (Object)'EW';

        FetchSVOCDetails.processResponse(strList,neObj);

        // result is the return value of the callback
        //System.assertEquals(null, result);
        // Verify that the controller's result variable
        //   is set to the mock response.

    }

    static testmethod void test4(){
        //insert opportunity

		// Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';

        Insert IS;

        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;

        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;

        List<Opportunity> oppList = TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        oppList[0].accountId = userAccountList[0].id;
        oppList[0].StageName = 'New';
        oppList[0].Customer__c= personAccountList[0].Id;
        oppList[0].ownerId = userinfo.getUserId();

        insert oppList;

        list<product2> productList = TestDataFactory.createProducts('Variants', 1);
        productList[0].Model__c = 'BA';
        productList[0].Enquiry__c = 'Yes';

        Insert productList;

        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        Insert accList;

        List<Asset> assetList = new List<Asset>();
        Id vehicleRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        for(Asset ast : TestDataFactory.CreateAssetsRecords(productList)){
            ast.accountId  = accList[0].Id;
            ast.VIN__c= 'MBHCZC63SLA562350';
            ast.RecordTypeId= vehicleRecTypeId;
            assetList.add(ast);
        }

        Insert assetList;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new FetchSVOCDetailsMock());
        FetchSVOCDetails.fetchMGAHistoryDetails(oppList[0].id, '', 'MBHCZC63SLA562350', accList[0].id, 'MGA History');

        test.stopTest();
    }
    static testmethod void test5(){
        List<User> dseUser = new List<User>();
        DSE_Report_RUn__c cs = new DSE_Report_RUn__c();
        cs.Name='RUN';
        cs.Daily_End_Time__c = system.now();
        cs.Daily_End_Time_SVOC__c = system.now();
        cs.Daily_Run_Time__c = system.now();
        cs.Month_End_Time__c = system.now();
        cs.Month_End_Time_SVOC__c = system.now();
        cs.Monthly_Run_TIme__c = system.now();
        //cs.Other fiels values
    	insert cs;

        //For Code Creation
        List<For_Code__c> forCodeList = TestDataFactory.createTestForCode(1);
        insert forCodeList;
        //DealerShip Creation
        List<Account> accList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        accList[0].For_Code__c = forCodeList[0].Id;
        //accList[0].channel__c = 'EXC';
        //accList[0].Territory_Sales_Manager__c = userinfo.getUserId();
        insert accList;

        List<Contact> dseConList = TestDataFactory.createTestContact(1, accList[0].Id);
        insert dseConList;

        //DSE Creation
        dseUser = TestDataFactory.createUserData('Portal', 'Dealer Sales Executive', dseConList);
        dseUser[0].Designation__c = 'SAE';
        insert dseUser;
        List<Account> userAccountList = TestDataFactory.createBusinessAccount(1, 'User Account');
        insert userAccountList;

        accList[0].User__c = dseUser[0].Id;
        update accList[0];

        List<Account> personAccountList = TestDataFactory.createPersonAccount(2);
        insert personAccountList;
        system.runAs(dseUser[0]){
            try{
            	FetchSVOCDetails.updateDSEAccountForSVOCCounter();
            }catch(Exception e){

            }
      }
    }

}