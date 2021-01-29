public class GlasvezelRequestFormController {
    private List<Account> lstAccounts {get;set;}
    public String signUrl {get;set;}
    public boolean isShow {get;set;}
    public boolean isShowDetails {get;set;}
    public String AccountNumber {get;set;}    
    public String courceSelection {get;set;}
    public Decimal Anatal {get;set;}
    public String Bedrijfsnaam {get;set;}
    public String kvk_nummer {get;set;}
    public String straat {get;set;}
    public String huisnummer {get;set;}
    public String toevoeging {get;set;}
    public String Postcode {get;set;}
    public String Plaats {get;set;}
    public String Phone {get;set;}
    public String Voornaam {get;set;}
    public String Achternaam {get;set;}
    public String Emailadres {get;set;}
    public String Bankrekeningnummer {get;set;}
    public string FttHbeschikbaar {get;set;}
    public boolean isError {get;set;}
    public string errorMessage {get;set;}
    public boolean foxSports {get;set;}
    public boolean ziggoSports {get;set;}
    public Glasvezel_Request__c objGlasvezelRequest {get;set;}       
    public GlasvezelRequestFormController(){
        objGlasvezelRequest=null;
        isShow=true;
        isShowDetails=false;
        isError = false;
        errorMessage = '';
        
        string id = apexpages.currentpage().getparameters().get('id');
        if(String.isNotBlank(id)){
            lstAccounts=[SELECT Name,FttHbeschikbaar__c, KvK_nummer__c, Straat__c, Huisnummer__c, Huisnummer_toevoeging__c, Postcode__c, ShippingCity,
                     Voornaam_CP__c, Achternaam_CP__c, E_mailadres_bedrijf__c, Phone, Bankrekeningnummer__c,Bedrijfsnummer__c
                     FROM Account 
                     WHERE Id= :id
                    ];
            if(lstAccounts.size() > 0){
                Bedrijfsnaam=lstAccounts[0].Name;
                kvk_nummer=lstAccounts[0].KvK_nummer__c;
                straat=lstAccounts[0].Straat__c;
                huisnummer=lstAccounts[0].Huisnummer__c;
                toevoeging=lstAccounts[0].Huisnummer_toevoeging__c;
                Postcode=lstAccounts[0].Postcode__c;
                Plaats=lstAccounts[0].ShippingCity;
                Phone=lstAccounts[0].Phone;
                FttHbeschikbaar=lstAccounts[0].FttHbeschikbaar__c;            
                isShow=false;
                isShowDetails=true;
            }
        }
    }        
            
    
    public void ShowAccount(){
        system.debug('Account Number'+AccountNumber);
        
        
        lstAccounts=[SELECT Name,FttHbeschikbaar__c, KvK_nummer__c, Straat__c, Huisnummer__c, Huisnummer_toevoeging__c, Postcode__c, ShippingCity,
                     Voornaam_CP__c, Achternaam_CP__c, E_mailadres_bedrijf__c, Phone, Bankrekeningnummer__c,Bedrijfsnummer__c
                     FROM Account 
                     WHERE Accountnumber__c=:AccountNumber
                    ];
        
        if(lstAccounts.size() > 0){			           
            
            Bedrijfsnaam=lstAccounts[0].Name;
            kvk_nummer=lstAccounts[0].KvK_nummer__c;
            straat=lstAccounts[0].Straat__c;
            huisnummer=lstAccounts[0].Huisnummer__c;
            toevoeging=lstAccounts[0].Huisnummer_toevoeging__c;
            Postcode=lstAccounts[0].Postcode__c;
            Plaats=lstAccounts[0].ShippingCity;
            Phone=lstAccounts[0].Phone;
            FttHbeschikbaar=lstAccounts[0].FttHbeschikbaar__c;            
            isShow=false;
            isShowDetails=true; 
        }else{
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.Error,'Invalid Account Number'));
        }
    }   
    
    public PageReference submit() { 
        
        isError = false;
        	
        if(String.isNotBlank(Bedrijfsnaam) && String.isNotBlank(Voornaam) && String.isNotBlank(kvk_nummer) && String.isNotBlank(Achternaam) && String.isNotBlank(Emailadres) && String.isNotBlank(signUrl)){            	            
            objGlasvezelRequest=new Glasvezel_Request__c();
            objGlasvezelRequest.Bedrijfsnaam__c=Bedrijfsnaam;
            objGlasvezelRequest.KvK_nummer__c=kvk_nummer;
            objGlasvezelRequest.Straat__c=straat;
            objGlasvezelRequest.Huisnummer__c=huisnummer;
            objGlasvezelRequest.Huisnummer_toevoeging__c=toevoeging;
            objGlasvezelRequest.ShippingCity__c=Plaats;
            objGlasvezelRequest.Phone__c=Phone;
            objGlasvezelRequest.Voornaam_CP__c=Voornaam;
            objGlasvezelRequest.Achternaam_CP__c=Achternaam;
            objGlasvezelRequest.Postcode__c=Postcode;
            objGlasvezelRequest.E_mailadres_bedrijf__c=Emailadres;
            objGlasvezelRequest.Bankrekeningnummer__c=Bankrekeningnummer;
            objGlasvezelRequest.FttHbeschikbaar__c=FttHbeschikbaar;        
            objGlasvezelRequest.Cources__c=courceSelection;
            objGlasvezelRequest.Fox_Sports__c=foxSports;
           	objGlasvezelRequest.Ziggo_Sports__c=ziggoSports;            
            objGlasvezelRequest.Aantal__c=Anatal;
            objGlasvezelRequest.Bedrijfsnummer__c=lstAccounts[0].Bedrijfsnummer__c;
            objGlasvezelRequest.Account__c=lstAccounts[0].id;
            //child object insert            
            Database.insert(objGlasvezelRequest);
            signUrl=signUrl.replace('image/png;base64,', '');
            Attachment objAttach=new Attachment();       
            objAttach.parentId=objGlasvezelRequest.Id;
            objAttach.contentType = 'image/png';
            objAttach.Name='signature.png';
            objAttach.body=EncodingUtil.base64Decode(signUrl);
            Database.insert(objAttach);
            system.debug('glasvezel Id'+objGlasvezelRequest.Id);
            system.debug(objAttach.body);
            return null;
        }else{
             isError = true;
             errorMessage = 'Please fill the required fields!';
             apexpages.addMessage(new ApexPages.message(Apexpages.Severity.Error,'Please fill the required fields!'));
             return null;
        }
    }
    public PageReference sendPdf(){
        if(objGlasvezelRequest!=null){
            System.debug('sendPdf if runs');
        PageReference pdf = Page.glasvezel_request_pdf;       
        pdf.getParameters().put('id',objGlasvezelRequest.Id); 
        
        Blob body;        
        try {            
            // returns the output of the page as a PDF
            body = pdf.getContent();            
            
        } catch (VisualforceException e) {
            body = Blob.valueOf('Some Text');
        }
        
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setContentType('application/pdf');
        attach.setFileName('GlasvezelRequest.pdf');
        attach.setInline(false);
        attach.Body = body;        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        mail.setToAddresses(new String[] { Emailadres });
        mail.setCCAddresses(new String[] {System.label.Glasvezel_Request_Email });
        mail.setSubject('PDF Email Demo');
        mail.setHtmlBody('Here is the email you requested! Check the attachment!');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
        
            
        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       
        PageReference thankYouPage = Page.glasvezel_request_thanks; 
        thankYouPage.setRedirect(true);
        return thankYouPage;
        }else{
             System.debug('sendPdf else runs');
            
          return null;
        }
    }
}