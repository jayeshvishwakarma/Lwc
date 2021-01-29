@isTest
public class TestPageTest{
    static testmethod void testmethodTestPage(){
        Apexpages.currentPage().getParameters().put('Type','Type');
        TestPage ptp = new TestPage();
        Apexpages.currentPage().getParameters().put('ljqId','Type');
        ptp = new TestPage();
        Apexpages.currentPage().getParameters().put('renderAs','Type');
        ptp = new TestPage();
        ptp.emailType = '';
        ptp.ljqId = '';
        ptp.renderAs = '';
    }
}