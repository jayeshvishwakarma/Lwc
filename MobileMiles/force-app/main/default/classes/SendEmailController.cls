public class SendEmailController{
    public Bestelling_MM__c record {get;set;}
    public SendEmailController(){
        string id = apexpages.currentpage().getparameters().get('id');
        record = [select id, name, E_mail__c from Bestelling_MM__c where id=:id];
    }
    
    public void sendmail(){
        try{
            EmailTemplate templateId = [Select id from EmailTemplate where name = 'Factuur Mobile Miles VF'];
            string uid = UserInfo.getUserId();
    
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();            
            mail.setToAddresses(new string[]{record.E_mail__c});
            mail.setTemplateID(templateId.Id);            
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(uid);
            mail.setWhatId(record.id);
            allmsg.add(mail);
            
            Messaging.sendEmail(allmsg,false);
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Email Sent.');
            ApexPages.addMessage(myMsg);
        }catch(Exception ex){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }

}