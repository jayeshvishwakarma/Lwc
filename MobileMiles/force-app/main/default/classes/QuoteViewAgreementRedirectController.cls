public class QuoteViewAgreementRedirectController {
    private Quote qt;
    public boolean recFound {Get;set;}
    public QuoteViewAgreementRedirectController(ApexPages.StandardController sc){
		qt = (Quote) sc.getRecord();
        recFound = true;
		
        
    }
    
    
    public PageReference redirect(){
        qt = [select id, Signature_Key__c from quote where id=: qt.Id];
        List<EZSign__Signature__c> lstSigs = [SELECT Id, Name FROM EZSign__Signature__c WHERE EZSign__Signature_Key__c =: qt.Signature_Key__c limit 1];
        if(lstSigs.size() > 0){
            PageReference pg = new PageReference('/apex/cloudeen_overeenkomst?id=' + lstSigs[0].Id);
            return pg;
        }  else{
            recFound = false;
        }
        return null;
    }
}