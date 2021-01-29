@isTest
public class ReportingWebServicesTest{
    static testmethod void testmethodReportingWebServices(){
        ReportingWebServices ptp = new ReportingWebServices();
        Region__c rn = new Region__c();
        insert rn;
        Territory__c tt = new Territory__c(Region__c = rn.Id);
        insert tt;
        ReportingWebServices.fetchPdf('OpenOrdersReport',tt.Id);
        ReportingWebServices.fetchPdf('OrderIntakeReport',tt.Id);
    }
}