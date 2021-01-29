/*
        Name            :    Jayesh Vishwakarma
        Author          :    iBirds Services
        Date            :    26 August 2020
        Description     :    Using for GlasvezelRequest Vf Page
*/

public class GlasvezelRequestPdfController {
    
    public String glasvezelId {get;set;}
    
    public Glasvezel_Request__c objGlasvezelRequest {get;set;}
    
    public Attachment objAttachment{get;set;}
    
    public GlasvezelRequestPdfController(){
        glasvezelId = ApexPages.currentPage().getParameters().get('id');
        //glasvezelId = 'a7r1l0000008h46AAA';
        getAccount();
        getAttachment();
    }
    
    public Glasvezel_Request__c getAccount(){
        List<Glasvezel_Request__c> lstGlasvezelRequests;
        
        lstGlasvezelRequests=[SELECT Bedrijfsnaam__c,FttHbeschikbaar__c, KvK_nummer__c, Straat__c, Huisnummer__c, Huisnummer_toevoeging__c, 
                             Postcode__c, ShippingCity__c, Voornaam_CP__c, Achternaam_CP__c, E_mailadres_bedrijf__c, Phone__c,
                             Bankrekeningnummer__c,Bedrijfsnummer__c,Cources__c,Fox_Sports__c,Ziggo_Sports__c,Aantal__c,Account__c,Account__r.Qr_Code__c
                             FROM Glasvezel_Request__c
                             WHERE id=:glasvezelId
                            ];
        //objGlasvezelRequest.Fox_Sports__c = true;
        //objGlasvezelRequest.Ziggo_Sports__c = true;
        if(lstGlasvezelRequests.size()>0){
            objGlasvezelRequest = lstGlasvezelRequests[0];
        }
        return objGlasvezelRequest;
        
    }
    
    private Attachment getAttachment(){
        List<Attachment> lstAttachments;
        lstAttachments = [SELECT id 
                         FROM Attachment 
                         WHERE parentId=:glasvezelId
                        ];
        if(lstAttachments.size()>0){
            objAttachment = lstAttachments[0];
        }
        return objAttachment;
        
    }
    
}