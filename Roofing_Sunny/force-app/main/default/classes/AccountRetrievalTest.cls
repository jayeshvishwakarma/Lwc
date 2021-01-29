@isTest
public class AccountRetrievalTest {
    @isTest
    static void testNewAccount() {
        String cli = '5551231234';
        Contact c = new Contact(LastName='ALEdev test acc', FirstName='Joe', HomePhone=cli, Email='abc@xyz.com');
        insert c;
        String result = AccountRetrieval.getAccounts(cli, '', '()');
        System.debug('result: ' + result);
        List<List<SObject>> sl = (List<List<SObject>>) JSON.deserialize(result, List<List<SObject>>.class);
        System.debug('list size: ' + sl.size());
        System.debug('Contact list size: ' + sl.get(1).size());
        System.assertEquals(2, sl.size());
        
    }
}