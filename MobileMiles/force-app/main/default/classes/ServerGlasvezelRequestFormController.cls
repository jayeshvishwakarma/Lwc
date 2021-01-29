public without sharing class ServerGlasvezelRequestFormController {
   
    @AuraEnabled(cacheable = true)
    public static Account getAccount(String recordId){
        
        
        List<Account> lstAccounts = [SELECT id,Accountnumber__c,Name,FttHbeschikbaar__c, KvK_nummer__c, Straat__c, Huisnummer__c, Huisnummer_toevoeging__c, Postcode__c, ShippingCity,
                                     Voornaam_CP__c, Achternaam_CP__c, E_mailadres_bedrijf__c, Phone, Bankrekeningnummer__c,Bedrijfsnummer__c
                                     FROM Account 
                                     WHERE id = :recordId
                                    ];
        if(lstAccounts.size() > 0){
            return lstAccounts[0];
        }
        return null;
        
    }

    @AuraEnabled
    public static Account getAccountByNumber(String accountNumber){
        
        
        List<Account> lstAccounts = [SELECT Id
                                     FROM Account 
                                     WHERE Accountnumber__c = :accountNumber
                                    ];
        System.debug(lstAccounts);
        if(lstAccounts.size() > 0){
            return lstAccounts[0];
        }
        return null;
        
    }
    
    @AuraEnabled
    public static String createRecord(Glasvezel_Request__c objGlasvezelRequest , String signUrl){
        System.debug(objGlasvezelRequest);
        insert objGlasvezelRequest;
        System.debug('Inserted....');
        
        Attachment objAttach = new Attachment();       
        objAttach.parentId = objGlasvezelRequest.Id;
        objAttach.contentType = 'image/png';
        objAttach.Name = 'Signature.png';
        objAttach.body = EncodingUtil.base64Decode(signUrl);
        Database.insert(objAttach);
        
        objGlasvezelRequest.Signature_File_Id__c = objAttach.id;
        update objGlasvezelRequest;
        
        return objGlasvezelRequest.id;
        
    }   
    
       /*@AuraEnabled
        public static void sendPdf(String id,String emailId){
        if(id!=null){
            System.debug('sendPdf if runs');
            PageReference pdf = new PageReference(system.label.glasvezel_request_pdf_url +  'glasvezel_request_pdf'); 
            system.debug('URL PDF: ' + pdf.getUrl());
            pdf.getParameters().put('id',id); 
            
            Blob body;        
            try {            
                // returns the output of the page as a PDF
                body = pdf.getContent();            
                
            } catch (VisualforceException e) {
                body = Blob.valueOf('Some Error: ' + e.getMessage());
                system.debug('Some Error: ' + e.getMessage());
            }catch(Exception ex){
                system.debug('Some Error: ' + ex.getMessage());
            }
            String orgWideEmailAddress = System.label.Glasvezel_org_wide_address;
            List<EmailTemplate> templates = [SELECT Id, Name from EmailTemplate where developername = 'glasvezel_form_email'];
            List<OrgWideEmailAddress> lstEmailAddress=[select Id from OrgWideEmailAddress WHERE id = :orgWideEmailAddress ];
            
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            
            attach.setContentType('application/pdf');
            attach.setFileName('Aanvraag KPN Zakelijk Glas.pdf');
            attach.setInline(false);
            attach.Body = body;        
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(templates.size() > 0){
                mail.setTemplateId(templates[0].Id);
            }
            
            Id userId = system.label.glasvezel_default_email_user;
            mail.setTargetObjectId(userId);
            mail.setWhatId(id);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(false);
            mail.setOrgWideEmailAddressId(System.label.Glasvezel_org_wide_address);
            mail.setToAddresses(new String[] { emailId });
            mail.setBccAddresses(new String[] {System.label.Glasvezel_Request_Email });
            //mail.setCCAddresses(new String[] {System.label.Glasvezel_Request_Email });
  
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
            
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
            
        }else{
            System.debug('Some errors');
        }
    }*/
}