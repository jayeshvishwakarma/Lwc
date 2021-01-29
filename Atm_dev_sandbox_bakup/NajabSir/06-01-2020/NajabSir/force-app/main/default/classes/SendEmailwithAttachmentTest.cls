@isTest
public class SendEmailwithAttachmentTest {
	 @testSetup
    static void CreateMethod(){
        list<Contentversion> cl=TestDataFactory.createContentversion(1);
        insert cl;
    }
    @isTest
    static void test1(){
        list<Contentversion> conlist=[SELECT id,title,ContentDocumentId FROM ContentVersion];
        SendEmailwithAttachment sewa=new SendEmailwithAttachment();
        sewa.sendMail('', 'a0t0k000002oc7zAAA', 'BCR', 'EXC', conlist[0].ContentDocumentId, 'test@test.com');
    }
}