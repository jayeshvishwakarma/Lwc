@isTest
public class LJQ_Resubmital_EmailTest{
    static testmethod void testmethodLJQ_Resubmital_Email(){
        Region__c r = new Region__c();
        insert r;
        Territory__c tt = new Territory__c(Region__c = r.Id);
        insert tt;
        /*Large_Job_Quote__c ljq = new Large_Job_Quote__c(Territory__c = tt.Id);
        insert ljq;
        LJQ_Resubmital_Email lre = new LJQ_Resubmital_Email(); 
        Large_Job_Quote__c ljq1 = lre.ljq;
        lre.objId = ljq.id;*/   
    }
}