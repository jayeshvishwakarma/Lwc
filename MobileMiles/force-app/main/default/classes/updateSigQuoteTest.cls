/**        
        Name            :    updateSigQuoteTest
        Author          :    
        Date            :    27-Mar-2017
        Description     :    This is a test class for controller class updateSigQuote.
*/

@isTest
public class updateSigQuoteTest{
    @isTest
    public static void unitTest(){
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User usr = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = 'testxyz123@test.com123456',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert usr;
        Account acc = new Account(Name = 'test');
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'TestOpp',
                                          AccountId = acc.id,
                                          CloseDate = System.Today(),
                                          StageName = 'Lopend',
                                          CurrencyIsoCode = 'EUR'
                                        );
        insert opp;
        Quote qt = new Quote(Name = 'TestQuote',
                             status = 'Verzonden',
                             OpportunityId = opp.id
                             );
        insert qt;
        
        EZSign__Signature__c objSign = new EZSign__Signature__c(EZSign__Parent_Id__c = qt.id, EZSign__Signature_Key__c = 'testxyz12345678', CurrencyIsoCode = 'EUR');
        insert objSign;
        
        Task tsk = new Task(OwnerId = usr.id,
                            Subject = 'Test',
                            CurrencyIsoCode = 'EUR',
                            Type = 'Email',
                            status = 'Verzonden'
                            );
        insert tsk;
        PageReference page = new PageReference('/apex/succes_kpn?id='+objSign.id); 
        Test.setCurrentPage(page);
        ApexPages.CurrentPage().getParameters().put('succes_kpn','true');
        ApexPages.currentPage().getParameters().put('key',objSign.EZSign__Signature_Key__c );
        
        ApexPages.currentPage().getParameters().put('senderid',tsk.OwnerId);
        ApexPages.currentPage().getParameters().put('quoteid',qt.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objSign);
        updateSigQuote objClass = new updateSigQuote(sc);
        
        
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Attachment testAttach = new Attachment(name = 'test.pdf', body=bodyBlob, parentid = objSign.id);
        insert testAttach;
        
        objClass.filename = testAttach.name;
        objClass.upfileBody = testAttach.body;
        objClass.uploadAttachment();
        Attachment testAttach1 = new Attachment(name = 'test.txt', body=bodyBlob, parentid = objSign.id);
        insert testAttach1;
        objClass.filename = '';
        objClass.upfileBody = null;
        objClass.filename = testAttach1.name;
        objClass.upfileBody = testAttach1.body;
        objClass.uploadAttachment();
        objClass.updateTheSig();
        objClass.getIsNotEmpty();
        objClass.getQliList();
        objClass.createTask();
        
        
        
    }
}