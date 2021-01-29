/**
 * @File Name          : SendEmailwithAttachment.cls
 * @Description        : This class is used for Sending Email with Attachment
 * @Author             : Sunit Kumar Chand
 * @Group              : 
 * @Last Modified By   : Sunit Kumar Chand
 * @Last Modified On   : 02/01/2020, 11:37:23 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    02/01/2020			  Sunit Kumar Chand    	  Initial Version
 * 
**/
public class  SendEmailwithAttachment {
    public void sendMail(String sObjectType, Id recordId, String communicationType,String channel,Id field, string toAddress)
    {
        System.debug(communicationType);
        System.debug(channel);
        channel=channel=='Arena'?'NRM':channel=='Nexa'?'EXC':channel;
        try{
            Email_Template_Detail__mdt	[] emailDetails= [SELECT Email_Template_Id__c,ContactId__c,Attachment_Name__c  FROM Email_Template_Detail__mdt WHERE Channel__c=: channel and Communication_Type__c=: communicationType];
            System.debug(emailDetails);
            if(emailDetails.size()>0)
            {
                List<User> lstUser = [Select Id,ContactId from User where Id =: Userinfo.getuserid()];
                ContentVersion cv=[SELECT title, PathOnClient, FileType,versiondata FROM contentversion WHERE ContentDocumentId=:field];//'0690k000000tWpaAAE'];
                blob pdfbody = cv.versiondata;
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setBody(pdfbody);
                efa.setContentType('application/pdf');
                efa.setInline(false);
                efa.setFileName(emailDetails[0].Attachment_Name__c+'.pdf');
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(lstUser[0].ContactId==null?emailDetails[0].ContactId__c:lstUser[0].ContactId); 
                message.setUseSignature(false);  
                message.setSaveAsActivity(false);
                message.setTemplateID(emailDetails[0].Email_Template_Id__c); 
                //message.setWhatId('a0t0k000002oc7zAAA'); //This is important for the merge fields in template to work
                message.setWhatId(recordId);
                message.toAddresses = new String[] {toAddress};
               // Create the email attachment    
                
              
              message.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
              Messaging.SendEmailResult[] results = Messaging.sendEmail(
                                         new Messaging.SingleEmailMessage[] { message });
            }
            
        }
        catch(Exception e)
        {
            System.debug(e.getStackTraceString());
        }     
    }

}