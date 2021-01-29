public class twod_zipperFuture {
    
    @future
    public static void sendMail(String formName,String ClaimId){
        String formId;
        system.debug('formName::' + formName);       
        system.debug('ClaimId::' + ClaimId);       
        try{
            formId=[select Id,Name from ZipFile__c where name like: formName limit 1].Id; 
        }
        catch(exception e)
        {
            
        }
        twod_AttachmentChange a=new twod_AttachmentChange();
        system.debug('formId::' + formId);
        Attachment sampleAttachmentNew=a.FaultCodeFunc(ClaimId,formId);
        if(sampleAttachmentNew!=null){
            formName=formName+'.docx';                      
            Attachment sampleAttachment = [SELECT ParentId,Body,Name FROM Attachment WHERE ParentId=:formId and Name=:formName];
            twod_Zippex sampleZip = new twod_Zippex(sampleAttachment.Body);
            //Attachment sampleAttachmentNew = [SELECT ParentId, Body FROM Attachment WHERE ParentId=:formId and Name='word/documentOri.xml'];
            Blob fileData = sampleAttachmentNew.Body;
            sampleZip.addFile('word/document.xml',fileData, null);
            Blob b=sampleZip.getZipArchive();
            Attachment ins=new Attachment();
            ins.Body=b;
            ins.ParentId=ClaimId;
            ins.Name=sampleAttachment.Name;
            insert ins; 
        }
    }
}