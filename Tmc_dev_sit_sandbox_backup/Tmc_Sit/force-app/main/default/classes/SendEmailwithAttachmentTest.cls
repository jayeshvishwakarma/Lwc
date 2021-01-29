@isTest
public class SendEmailwithAttachmentTest {
    @testSetup
    static void CreateMethod(){
        // Custom Setting
        Implementation_Strategy__c IS = new Implementation_Strategy__c();
        IS.Name  = '1';
        IS.Identifier_Type__c = 'Record Type';
        IS.Strategy_Implementation__c = 'OpportunityVehicleTriggerServiceImpl';
        IS.Strategy_Key__c = 'Vehicle_Sales';
        IS.Use_Case__c = 'OpportunityTriggers';

        Insert IS;

        list<Contentversion> cl=TestDataFactory.createContentversion(1);
        insert cl;
    }
    @isTest
    static void test1(){
        list<Contentversion> conlist=[SELECT id,title,ContentDocumentId FROM ContentVersion];
        SendEmailwithAttachment sewa=new SendEmailwithAttachment();
        sewa.sendMail('', 'a0t0k000002oc7zAAA', 'BCR', 'EXC', conlist[0].ContentDocumentId, 'test@test.com');
    }
    @isTest
    static void testSendMail(){

        List<Opportunity> opportunityList=    TestDataFactory.createTestOpportunity(1, 'Vehicle Sales');
        opportunityList[0].stagename = 'Retail';
        Insert opportunityList;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;

        //Get Content Version
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        //System.assertEquals(cvList.size(), 1);

        //Get Content Documents
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        //System.assertEquals(cdList.size(), 2);

        SendEmailwithAttachment sewa=new SendEmailwithAttachment();
        Test.startTest();
        sewa.sendMail('', opportunityList[0].id, 'BCR', 'EXC', cdList[0].id, 'test@test.com');
        sewa.sendMail('', opportunityList[0].id, 'BCR', 'Arena', cdList[0].id, 'test@test.com');
        sewa.sendMail('', opportunityList[0].id, 'BCR', 'Nexa', cdList[0].id, 'test@test.com');
        sewa.sendMail('', opportunityList[0].id, 'BCR', 'Commercial', cdList[0].id, 'test@test.com');
        Test.stopTest();

    }
}