public class EmailUtility {
    @AuraEnabled
    public static void sendEmail(String to, String cc, String subject,String htmlBody, String orgwideAddress){
        if(String.isNotBlank(to) && String.isNotBlank(htmlBody)){        
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();           
            message.setToAddresses(new list<String>{ to });            
            message.setSubject(subject);
            if(String.isNotBlank(cc)){
                message.setCcAddresses(new List<String> { cc });
            }
            if(String.isNotBlank(orgwideAddress)){
                message.setOrgWideEmailAddressId(orgwideAddress);
            }
            message.setHtmlBody(htmlBody);
            
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: '
                    + results[0].errors[0].message);
            }
        }
    }
}