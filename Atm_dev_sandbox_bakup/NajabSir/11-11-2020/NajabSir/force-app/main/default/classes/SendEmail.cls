//Class to send the mail
//
//
public class SendEmail {
    
    //Method to send mail
    public static void sendSingleMail(map<string,blob> dataToSendMap, DateTime StartDateTime , DateTime EndDateTime){
        
        list<Messaging.EmailFileAttachment> csvAttachmentList = new list<Messaging.EmailFileAttachment>();
        for(string key : dataToSendMap.keySet()){
            if(dataToSendMap.containskey(key)){
                Messaging.EmailFileAttachment mailtoSend = new Messaging.EmailFileAttachment();
                String csvName = key+'_Extract'+'-'+StartDateTime.format('HH:mm:ss') +'-'+EndDateTime.format('HH:mm:ss')+'.csv';
                mailtoSend.setFileName(csvName);
                mailtoSend.setBody(dataToSendMap.get(key));
                csvAttachmentList.add(mailtoSend);
                
            }
        }
        
        
        if(csvAttachmentList.size()>0){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            // String[] toAddresses = new String[]{Label.Data_Extract_Recipients != Null ? Label.Data_Extract_Recipients.split(',') : new List<string>()};
            List<String> toAddresses = Label.Data_Extract_Recipients != Null ? Label.Data_Extract_Recipients.split(',') : new List<string>();
            String subject = 'File Extract-'+StartDateTime.format('HH:mm:ss')+'-'+EndDateTime.format('HH:mm:ss');
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            email.setPlainTextBody('Hi Sir \nBelow is the attached document related to file extraction');
            email.setFileAttachments(csvAttachmentList);
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
           
        }
    }
}