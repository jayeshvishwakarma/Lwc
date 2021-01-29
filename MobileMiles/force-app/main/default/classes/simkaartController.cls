/*
        Name        :    simkaartController
        Date        :
        Author      :
        Descriptio  :    This controller is  used to Insert the case on community for simkaartController.
*/

public class simkaartController{
    public String name{get;set;}
    public String email{get;set;}
    public String mobileNumber{get;set;}
    //public String pukCode{get;set;}
    public String simCardNumber{get;set;}
    public User currentUser{get;set;}
    public List<SelectOption> porteringensList{get;set;}
    
    public simkaartController(){ 
        User currentUser = [SELECT Username, ContactId, Contact.Name, Contact.AccountId, Contact.Account.Name, Contact.Email 
                                FROM User WHERE Id =: UserInfo.getUserId() ];
        system.debug('@@currentUser -'+currentUser );
        name = currentUser.Contact.Name;
        email = currentUser.Contact.Email;
        //id rcTypeId = Schema.SObjectType.Porteringen_mobiel__c.getRecordTypeInfosByName().get('Goedgekeurd KPN ÉÉN').getRecordTypeId();
        //done by ranu on 20th May 2019
        Set<Id> recordTypes = new Set<Id>();
        recordTypes.add(Schema.SObjectType.Porteringen_mobiel__c.getRecordTypeInfosByName().get('Goedgekeurd KPN ÉÉN').getRecordTypeId());
        recordTypes.add(Schema.SObjectType.Porteringen_mobiel__c.getRecordTypeInfosByName().get('Direct order KPN ÉÉN Mobiel').getRecordTypeId());
        
        //Edited on 20 march by Shikha(iBirds)
        //Sorted result by name in Descending order & put 'OR' condition Stage = Opheffen
        List<Porteringen_mobiel__c> porteringens = [select id, Name from Porteringen_mobiel__c 
                                Where Account__c =: currentUser.Contact.AccountId 
                                AND (Stagename__c = 'Actief' OR Stagename__c = 'Opheffen') 
                                AND recordtypeId  IN : recordTypes Order By Name DESC];
        if(porteringens.size() > 0){
            porteringensList = new List<SelectOption>();
            for(Porteringen_mobiel__c porter : porteringens){
                porteringensList.add(new SelectOption(porter.id, porter.name));
            }
        }
    }
    
    public PageReference saveCase(){
        /*if(mobileNumber.length() != 11){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.MobileNumberMessage));
            return null;
        }
        if(pukCode.length() != 8){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.pukcodemessage));
            return null;
        }
        if(simCardNumber.length() != 8){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.simkaartnumber));
            return null;
        }*/
        
        //Commented for community changes on 15/3/2019 By Shikha(iBirds)
        /*Case cs =  new Case(recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Simwissel').getRecordTypeId(),
                        SuppliedName = name, 
                        SuppliedEmail = email, 
                        Mobiel_nummer_06_097__c = mobileNumber, 
                       // PUK_code__c = pukCode,
                        SIM_kaartnummer__c = simCardNumber,
                        ownerid = [SELECT Id, Name, DeveloperName, Type, Email FROM Group where developername = 'Service'].id);
        insert cs;*/
              
        //update Porteringen_mobiel__c record on 15/3/2019  By Shikha(iBirds)
        if((!(String.ISBLANK(simCardNumber)) && !(simCardNumber.isNumeric())) || (!(String.ISBLANK(simCardNumber)) && !(simCardNumber.length()==8) && !(simCardNumber.length()==19))){   
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Een SIM-kaartnummer bestaat uit 8 of 19 cijfers');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        Porteringen_mobiel__c updatePorteringen = [select id, name, Simwissel_uitvoeren__c from Porteringen_mobiel__c 
                                Where id =: mobileNumber];
        system.debug('####updatePorteringen-' + updatePorteringen);                   
        updatePorteringen.Nieuw_SIM_kaart_nummer__c = simCardNumber;
        updatePorteringen.E_mailadres_SIM_activatie__c = email;
        updatePorteringen.Naam_simwissel__c = name;
        updatePorteringen.Simwissel_uitvoeren__c = true;
        update updatePorteringen;
               
        // TODO: Change for Commuynity.
        PageReference pageRef = new PageReference(System.Label.simkartthankyouurl);
        //pageRef.setRedirect(true);
        return pageRef;
    }
}