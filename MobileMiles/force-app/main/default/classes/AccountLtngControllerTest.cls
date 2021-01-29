@IsTest
private class AccountLtngControllerTest {
    @isTest static void unitTest() {
        account acc= new account(name='test');
        insert acc;
        AccountLtngController.updateDirectOrderKpnEENMobiel(acc.id);
        AccountLtngController.updateKPNSmallQuote(acc.id);
        AccountLtngController.updateKPNOneOffer(acc.id);
        AccountLtngController.updateTMobileQuotation(acc.id);
    }
    @isTest static void unitTest1() {
        AccountLtngController.updateDirectOrderKpnEENMobiel(Null);
        AccountLtngController.updateKPNSmallQuote(Null);
        AccountLtngController.updateKPNOneOffer(Null);
        AccountLtngController.updateTMobileQuotation(Null);
    }
}