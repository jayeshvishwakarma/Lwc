/*
        Name        :    AccountDetailController
        Date        :
        Author      :
        Descriptio  :    This controller is  used to display the account detail and its related list data.
*/
public class AccountDetailController{
    public String selectedAccount{get;set;}
    public Account accObj {get;set;}
    public List<Contact> contactList {get;set;}
    public List<Porteringen_mobiel__c> porteringList {get;set;}
    public List<Attachment> attachmentList {get;set;}
    public String isSuccess {get;set;}
    public String selectedBetalingscondities {get;set;}
    public String successMsg{get;set;}
    private Account accClone;
    private List<Porteringen_mobiel__c> porteringCloneList;
    private List<Contact> contactCloneList;
    public List<Mobile_Miles_Dienst__c> listOfDienst{get;set;}
    public List<Verbinding__c> listOfVerbinding{get;set;}
    public Map<String,Integer> mapOfVOIPSum{get;set;}
    public Map<String,Integer> mapOfVOIPSumPrijs{get;set;}
    public List<String> listOfVOIPNames{get;set;}
    private Id accId;
    public Map<String,Porteringen_mobiel__c> mapOfVOIPCurrency{get;set;}
    
    // @aslam 10/04/2019
    public Porteringen_mobiel__c sumForMobiele{get;set;}
    public Porteringen_mobiel__c sumForCloud{get;set;}
    public Porteringen_mobiel__c sumForVerbind{get;set;}
    public Porteringen_mobiel__c sumForKPN {get;set;}
    
    public AccountDetailController(){
        selectedBetalingscondities  = '';
        Set<String> attNameSet = new Set<String>{'%SIN%','%PIN%'};
        accObj = new Account();
        contactList = new List<Contact>();
        porteringList = new List<Porteringen_mobiel__c>();
        attachmentList = new List<Attachment>();
        
        isSuccess = 'null';
        contactList = new List<Contact>();
        listOfDienst = new List<Mobile_Miles_Dienst__c>();
        listOfVerbinding = new List<Verbinding__c>();
        mapOfVOIPSum = new Map<String,Integer>(); 
        mapOfVOIPSumPrijs = new Map<String, Integer>();
        mapOfVOIPCurrency = new Map<String, Porteringen_mobiel__c>();
        listOfVOIPNames = new List<String>();
        String accParam = ApexPages.currentPage().getParameters().get('accId');
        system.debug('@@@ accParam ' + accParam);
        if(String.isNotBlank(accParam)){
            accId = [select id from account where id =: accParam].Id;
        }else{
            accId = [select id, contact.accountid from user where id =: Userinfo.getUSerID()].contact.accountid  ;
        }        
        selectedAccount = accId;
        system.debug('@@accId'+accId);
        
        //@aslam 10/04/2019 
        sumForMobiele= new Porteringen_mobiel__c(Aangepaste_abonnementskosten__c=0); 
        sumForCloud = new Porteringen_mobiel__c(Aangepaste_abonnementskosten__c=0); 
        sumForVerbind = new Porteringen_mobiel__c(Aangepaste_abonnementskosten__c=0); 
        sumForKPN = new Porteringen_mobiel__c(Aangepaste_abonnementskosten__c=0); 
        
        //accid = '0010E00000GWfWJ';
        /* User u = [select id,accountid from user where id=:userinfo.getuserId()];
        accId = u.accountid;
        */
        if(accId != null){
            accObj = [SELECT Id,owner.name,owner.Email,owner.Extension,owner.pasfoto__c,Name,Straat__c,Huisnummer__c,Huisnummer_toevoeging__c,Shippingpostalcode,Shippingcity,Billingaddress, 
                      Phone,Uitkeren_MobileMiles__c,E_mail_factuuradres__c,Bankrekeningnummer__c,Betalingscondities__c,Totaal_MobileMiles_gespaard__c,Verzilverd_MM__c,
                      Saldo_MobileMiles__c,BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,Geslacht__c,Voornaam_CP__c,Achternaam_CP__c,E_mailadres_bedrijf__c,
                      (SELECT Id, ParentId, Title FROM CombinedAttachments WHERE FileType ='pdf' and Title Like : attNameSet)
                      FROM Account 
                      WHERE Id = :accId];
                      
                      
        }
        
        if(accObj.Id != null){          
            contactList = [SELECT Id,Name,Email FROM Contact WHERE AccountId =: accObj.Id];
            listOfDienst = [SELECT Id, Name,Totaal_prijs_per_maand__c, Datum_actief__c,Hoeveelheid__c FROM Mobile_Miles_Dienst__c WHERE Account__c =: accObj.id AND Stagename__c = 'Actief'];
            listOfVerbinding = [SELECT Id, name, Datum_actief__c, Prijs_per_maand__c FROM Verbinding__c WHERE Account__c =: accObj.id AND Stagename__c = 'Actief'];
            
            AggregateResult[] result = [SELECT name, sum(Totaal_prijs_per_maand__c) Prijs, sum(Prijs_per_maand__c) , sum(Aantal__c) total FROM VOIP__c WHERE Account__c =: accObj.id AND Stagename__c = 'Actief' group by name];
            if(result != null){
                for(AggregateResult objAgr : result){
                    listOfVOIPNames.add(String.valueOf(objAgr.get('Name')));
                    mapOfVOIPSum.put(String.valueOf(objAgr.get('Name')), Integer.valueOf(objAgr.get('total'))); 
                    mapOfVOIPSumPrijs.put(String.valueOf(objAgr.get('Name')), Integer.valueOf(objAgr.get('Prijs')));
                    mapOfVOIPCurrency.put(String.valueOf(objAgr.get('Name')), new Porteringen_mobiel__c(Afwijkende_prijs_actie__c = (Decimal)objAgr.get('Prijs')));
                    
                    //@aslam 10/04/2019 , to show sum for each section
                    sumForKPN.Aangepaste_abonnementskosten__c +=(Decimal)objAgr.get('Prijs'); 
                }
            }
            System.debug('@@mapOfVOIPSum'+mapOfVOIPSum);
            
        }
        
        if(accObj.Id != null){
            porteringList = [SELECT Id,Name,X06_097_nummer__c,Profielnaam__c,Overige_landen_buiten_EU_bundel_100MB__c,Voordeellanden_buiten_EU_bundel_250MB__c 
                             ,Mobiel_bellen_naar_buiten_EU__c,Nieuw_SIM_kaart_nummer__c,PUK_code__c ,Datum_actief__c, Netto_prijs_per_maand__c, Label__c 
                             FROM Porteringen_mobiel__c
                             WHERE Actief__c = true and Account__c =: accObj.Id order by X06_097_nummer__c];
            //@aslam 10/04/2019 ,to show sum for each section
            for(Porteringen_mobiel__c portMblData : porteringList){
                 sumForMobiele.Aangepaste_abonnementskosten__c +=portMblData.Netto_prijs_per_maand__c;       
            }
            
                             
        }
        if(accObj.Id  != null){
            attachmentList = [SELECT Id,ParentId,Name FROM Attachment WHERE ParentId=:accObj.Id AND CONTENTTYPE='application/pdf' AND Name like :attNameSet ORDER BY NAME DESC];
        }
        accClone = accObj.clone(true);
        porteringCloneList = porteringList.deepClone();
        contactCloneList = contactList.deepClone();
        
        //@aslam 10/04/2019 , to show sum for each section
        for(Mobile_Miles_Dienst__c mblMiles : listOfDienst ){
            sumForCloud.Aangepaste_abonnementskosten__c +=mblMiles.Totaal_prijs_per_maand__c; 
        }
        
        for(Verbinding__c verbindings : listOfverbinding){
            sumForVerbind.Aangepaste_abonnementskosten__c +=verbindings.Prijs_per_maand__c; 
        }
    }
    
    public List<Contact> getContactList(){
        system.debug('@@gettercontact'+ accObj.id);
        if(String.isNotBlank(accObj.id)){
            return [SELECT Id,Name,Email FROM Contact WHERE AccountId =: accObj.Id];
        }else{
            return new List<Contact>();
        }
    }
    public void updateAccountDetail(){
        try{
            update accObj;
            update contactList;
            update porteringList;
            sendChangesNotificationEmail();
            isSuccess = 'Success';
            successMsg = accObj.name +' Wijzigingen verwerkt!';
        }catch(Exception e){
            isSuccess  = e.getMessage();
        }
    }
    
    Private void sendChangesNotificationEmail(){
        String bodyTable ='<table border="1" style="border-collapse: collapse;width: 100%;"><thead style="background-color: lightgrey;font-weight: 600;font-size: 17px;text-align: center;"><tr>';
            bodyTable +='<td style="text-align: center;">Object Name</td>';
            bodyTable +='<td style="text-align: center;">Record Name</td>';
            bodyTable +='<td style="text-align: center;">Field Name</td>';
            bodyTable +='<td style="text-align: center;">Old Value</td>';
            bodyTable +='<td style="text-align: center;">New Value</td>';
            bodyTable +='</tr></thead>';
            bodyTable +='<tbody>';
            
            // Account writable fields details
            Map<string,string> accountWritableFieldMap = new Map<string,string>{'Straat__c'=>'Straat','Huisnummer__c'=>'Huisnummer',
                                                                                'Huisnummer_toevoeging__c'=>'Huisnummer toevoeging',
                                                                                'ShippingPostalCode'=>'ShippingPostalCode','ShippingCity'=>'ShippingCity',
                                                                                'BillingStreet'=>'BillingStreet','BillingCity'=>'BillingCity',
                                                                                'BillingState'=>'BillingState','BillingPostalCode'=>'BillingPostalCode',
                                                                                'BillingCountry'=>'BillingCountry','Phone'=>'Phone',
                                                                                'E_mail_factuuradres__c'=>'E-mail factuuradres',
                                                                                'Bankrekeningnummer__c'=>'IBAN','Betalingscondities__c'=>'Betalingscondities',
                                                                                'Geslacht__c'=>'Geslacht','Voornaam_CP__c'=>'Voornaam CP','Achternaam_CP__c'=>'Achternaam CP',
                                                                                'E_mailadres_bedrijf__c'=>'E-mailadres bedrijf'};
            // Porteringen writable fields details
            Map<string,string> PorteringenWritableFieldMap = new Map<string,string>{'Overige_landen_buiten_EU_bundel_100MB__c'=>'Overige landen buiten EU bundel 100MB','Voordeellanden_buiten_EU_bundel_250MB__c'=>'Voordeellanden buiten EU bundel 250MB','Mobiel_bellen_naar_buiten_EU__c'=>'Mobiel bellen naar buiten EU','PUK_code__c'=>'PUK-CODE','Nieuw_SIM_kaart_nummer__c'=>'NIEUW SIM KAART NUMMER'};
            
            Boolean isChangesDetect = false;
            // Detecting to Account changes and create table body 
            for(string fieldApi : accountWritableFieldMap.keySet()){
                    if(accObj.get(fieldApi)!=accClone.get(fieldApi)){
                        String oldValue = accClone.get(fieldApi) != null ? accClone.get(fieldApi) + '' : '&nbsp;';
                        String newValue = accObj.get(fieldApi) != null ? accObj.get(fieldApi) + '' : '&nbsp;';
                        
                        bodyTable +='<tr>';
                        bodyTable +='<td>Account</td>';
                        bodyTable +='<td>'+accObj.Name+'</td>';
                        bodyTable +='<td>'+accountWritableFieldMap.get(fieldApi)+'</td>';
                        bodyTable +='<td>'+oldValue +'</td>';
                        bodyTable +='<td>'+newValue+'</td>';
                        bodyTable +='</tr>';
                        
                        isChangesDetect = true;
                    }
            }
            
            // Detecting to Contact changes and create table body 
            for(Integer index = 0;index<contactList.size();index++){
                if(contactList[index].get('email')!=contactCloneList[index].get('email')){
                        String oldValue = contactCloneList[index].get('email') != null ? contactCloneList[index].get('email') + '' : '&nbsp;';
                        String newValue = contactList[index].get('email') != null ? contactList[index].get('email') + '' : '&nbsp;';
                        
                        bodyTable +='<tr>';
                        bodyTable +='<td>Contact</td>';
                        bodyTable +='<td>'+contactList[index].get('Name')+'</td>';
                        bodyTable +='<td>Email</td>';
                        bodyTable +='<td>'+oldValue +'</td>';
                        bodyTable +='<td>'+newValue+'</td>';
                        bodyTable +='</tr>';
                        
                        isChangesDetect = true;
                }       
            }
            
            // Detecting to Portering changes and create table body 
            for(Integer index = 0;index<porteringCloneList.size();index++){
                for(string fieldApi : PorteringenWritableFieldMap.keySet()){
                    if(porteringList[index].get(fieldApi)!=porteringCloneList[index].get(fieldApi)){
                        String oldValue = porteringCloneList[index].get(fieldApi) != null ? porteringCloneList[index].get(fieldApi) + '' : '&nbsp;';
                        String newValue = porteringList[index].get(fieldApi) != null ? porteringList[index].get(fieldApi) + '' : '&nbsp;';
                        
                        bodyTable +='<tr>';
                        
                        bodyTable +='<td>Portering mobiel</td>';
                        bodyTable +='<td>'+porteringList[index].get('Name')+'</td>';
                        bodyTable +='<td>'+PorteringenWritableFieldMap.get(fieldApi)+'</td>';
                        bodyTable +='<td>'+oldValue +'</td>';
                        bodyTable +='<td>'+newValue+'</td>';
                        bodyTable +='</tr>';
                        isChangesDetect = true;
                    }
                }
            }
            
            if(isChangesDetect){
                bodyTable +='</tbody></table>';
                // refreshing to clone object again.
                accClone = accObj.clone(true);
                porteringCloneList = porteringList.deepClone();
                contactCloneList = contactList.deepClone();
                
                sendEmail(bodyTable);
            }
    }
    
    private void sendEmail(string tableBody){
        string body = 'Hello Support,';
               body += '<br/><br/>'; 
               body += 'Here are following changes on account details, Please check below,';
               body += '<br/><br/>';  
               body += tableBody;
               body += '<br/><br/>'; 
               body += 'Thank You';
               
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new list<string>{label.SupportEmailId}); 
        mail.setSubject('Updated Account Details On Cloud EEE Community');  
        mail.setHtmlBody(body);   
        List<OrgWideEmailAddress> orgWideAddress = [select id from OrgWideEmailAddress where Address =: Label.community_service_email];  
        if(orgWideAddress.size() > 0){
            mail.setOrgWideEmailAddressId(orgWideAddress.get(0).id); 
        }
        // Sending emails
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail}); 
    }
    public void updateAccountDetailCheckbox(){
        try{
            accObj.Uitkeren_MobileMiles__c = true;
            update accObj;
            isSuccess = 'Success';
            successMsg = 'Uw MobileMiles tegoed zal aan u worden uitgekeerd.';
        }catch(Exception e){
            isSuccess  = e.getMessage();
        }
    } 
    public void updatePorteringList(){
        try{
            upsert porteringList;
        }catch(Exception ex){
            system.debug('Error'+ex.getMessage());
        }
    }
    public void updateDetail(){       
        try{
            upsert accObj;            
        }catch(Exception ex){
            system.debug('Error'+ex.getMessage());
        }
    }
    public List<SelectOption> getChildAccounts(){
        List<SelectOption> options = new List<SelectOption>();
        User usr = [select id, contact.accountid, contact.account.name from user where id =: Userinfo.getUSerID()];
        options.add(new SelectOption(usr.contact.accountid, usr.contact.account.name));        
        for(Account acc : [select id, name from account where parentId =: usr.contact.accountid]){
            options.add(new SelectOption(acc.Id, acc.Name));
        }
        return options;
    }    
}