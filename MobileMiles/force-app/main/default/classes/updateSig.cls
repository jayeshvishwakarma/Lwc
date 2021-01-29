public class updateSig {

    public EZSign__Signature__c theSig{get;set;}
    public list<Account> accountList{get;set;}
    public Account theAccount{get;set;}
    public list<Offerte_regel_item__c> oriList;
    public Boolean isNotEmpty;
    public Boolean nullGeb{get;set;}
    public Boolean nullBank{get;set;}
    public Boolean nullLegit{get;set;}
    public Boolean nullLoop{get;set;}
    public Map<String, Schema.SObjectField> SigFieldMap;
    public list<String> SigFieldNames;
    public String theSigQuery;
    public Map<String, Schema.SObjectField> AccountFieldMap;
    public list<String> AccountFieldNames;
    public String theAccountQuery;
    public Map<String, Schema.SObjectField> ORIFieldMap;
    public list<String> ORIFieldNames;
    public String theORIQuery;
    public String ip;

    public updateSig(ApexPages.StandardController stdController){
        String theKey='';
        //Build Signature Query
        SigFieldMap = Schema.SObjectType.EZSign__Signature__c.fields.getMap();
        SigFieldNames = new list<String>();
        SigFieldNames.addAll(SigFieldMap.keySet());
        theSigQuery = 'SELECT ';
        for (String s : SigFieldNames){
            theSigQuery = theSigQuery + s;
            if (s!=SigFieldNames.get(SigFieldNames.size()-1)){
                theSigQuery = theSigQuery + ', ';
            }
        }
        
        if (ApexPages.currentPage().getParameters().get('key')!=null){
            theKey = ApexPages.currentPage().getParameters().get('key');
            theKey = String.escapeSingleQuotes(theKey);
            theSigQuery = theSigQuery + ' FROM EZSign__Signature__c WHERE EZSign__Signature_Key__c = \''+theKey+'\' LIMIT 1';
            //this.theSig = [SELECT Id, Name, EZSign__Signature__c, EZSign__Signature_URL__c, EZSign__Signature_Image__c, EZSign__Signature_Name__c, EZSign__Signature_Date__c, EZSign__Signature_Key__c, EZSign__Parent_Id__c, Bankrekeningnummer__c, Geboortedatum__c, Legitimatienummer__c, Looptijd_contract_Telfort_Zakelijk_vt__c FROM EZSign__Signature__c WHERE EZSign__Signature_Key__c = :theKey LIMIT 1];
            this.theSig = Database.Query(theSigQuery);
            if (theSig.Geboortedatum__c==null){
                this.nullGeb = true;
            }
            else{
                this.nullGeb = false;
            }
            if (theSig.Bankrekeningnummer__c==null){
                this.nullBank = true;
            }
            else{
                this.nullBank = false;
            }
            if (theSig.Legitimatienummer__c==null){
                this.nullLegit = true;
            }
            else{
                this.nullLegit = false;
            }
            if (theSig.Looptijd_contract_Telfort_Zakelijk_vt__c==null){
                this.nullLoop = true;
            }
            else{
                this.nullLoop = false;
            }
        }
        else{
            this.theSig = (EZSign__Signature__c)stdController.getRecord();
            theSigQuery = theSigQuery + ' FROM EZSign__Signature__c WHERE Id = \''+theSig.Id+'\' LIMIT 1';
            //this.theSig = [SELECT Id, Name, EZSign__Signature__c, EZSign__Signature_URL__c, EZSign__Signature_Image__c, EZSign__Signature_Name__c, EZSign__Signature_Date__c, EZSign__Signature_Key__c, EZSign__Parent_Id__c, Bankrekeningnummer__c, Geboortedatum__c, Legitimatienummer__c, Looptijd_contract_Telfort_Zakelijk_vt__c FROM EZSign__Signature__c WHERE Id = :theSig.Id LIMIT 1];
            this.theSig = Database.Query(theSigQuery);
            if (theSig.Geboortedatum__c==null){
                this.nullGeb = true;
            }
            else{
                this.nullGeb = false;
            }
            if (theSig.Bankrekeningnummer__c==null){
                this.nullBank = true;
            }
            else{
                this.nullBank = false;
            }
            if (theSig.Legitimatienummer__c==null){
                this.nullLegit = true;
            }
            else{
                this.nullLegit = false;
            }
            if (theSig.Looptijd_contract_Telfort_Zakelijk_vt__c==null){
                this.nullLoop = true;
            }
            else{
                this.nullLoop = false;
            }
        }
        
        //IP Tracking
        if (ApexPages.currentPage().getHeaders().get('True-Client-IP')!=null)
            this.ip = String.escapeSingleQuotes(ApexPages.currentPage().getHeaders().get('True-Client-IP'));
        else{
            if (ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP')!=null)
                this.ip = String.escapeSingleQuotes(ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP'));
            else
                this.ip = '';
        }
        theSig.Handtekening_IP__c = this.ip;
        Set<String> notValid = new Set<String>();
        notValid.add('billingaddress');
        notValid.add('shippingaddress');
        //Build Account Query
        AccountFieldMap = Schema.SObjectType.Account.fields.getMap();
        AccountFieldNames = new list<String>();
        AccountFieldNames.addAll(AccountFieldMap.keySet());
        theAccountQuery = 'SELECT ';
        for (String s : AccountFieldNames){
            if(!notValid.contains(s)){
                theAccountQuery = theAccountQuery + s;
                if (s!=AccountFieldNames.get(AccountFieldNames.size()-1)){
                    theAccountQuery = theAccountQuery + ', ';
                }
            }
        }
        theAccountQuery = theAccountQuery + ' FROM Account WHERE Id = \''+theSig.EZSign__Parent_Id__c+'\' LIMIT 1';
        
        //Build ORI Query
        ORIFieldMap = Schema.SObjectType.Offerte_regel_item__c.fields.getMap();
        ORIFieldNames = new list<String>();
        ORIFieldNames.addAll(ORIFieldMap.keySet());
        theORIQuery = 'SELECT ';
        for (String s : ORIFieldNames){
            theORIQuery = theORIQuery + s;
            if (s!=ORIFieldNames.get(ORIFieldNames.size()-1)){
                theORIQuery = theORIQuery + ', ';
            }
        }
        theORIQuery = theORIQuery + ' FROM Offerte_regel_item__c WHERE Account__c = \''+theSig.EZSign__Parent_Id__c+'\'';
        
        //this.accountList = [SELECT Id, Name, Aanhef_CP__c, Achternaam_CP__c, Besparingspercentage_offerteBB__c, Abonnementskosten_via_Mobile_Miles_vt__c, Gesprekskosten_2jr_via_Mobile_Miles_vt__c, Gesprekskosten_3jr_via_Mobile_Miles_vt__c, Huidige_abonnementskosten_vt__c, Huidige_gesprekskosten_vt__c, Besparingspercentage__c, Besparing_op_gesprekskosten_3jr_vt__c, Besparing_op_abonnementskosten_vt__c, Totaal_abonnementskosten__c, Netwerkactie__c, Besparing_per_maand__c, MobileMiles_korting__c, Totaal_per_maand__c, Collectief__c, Collectief_logo__c, Aansluiting_1__c, BedrijfsBundel_tbv_offerteMM_1__c, Aantal_minuten_MB_s_1__c, Abonnementskosten_tbv_offerteMM_1__c, Aansluiting_2__c, Bedrijfsbundel_tbv_offerteMM_2__c, Aantal_minuten_MB_s_2__c, Abonnementskosten_tbv_offerteMM_2__c, Aansluiting_3__c, BedrijfsBundel_tbv_offerteMM_3__c, Aantal_minuten_MB_s_3__c, Abonnementskosten_tbv_offerteMM_3__c, Aansluiting_4__c, BedrijfsBundel_4__c, Aantal_minuten_MB_s_4__c, Abonnementskosten_4__c, Aansluiting_5__c, BedrijfsBundel_5__c, Aantal_minuten_MB_s_5__c, Abonnementskosten_5__c, Aansluiting_6__c, BedrijfsBundel_6__c, Aantal_minuten_MB_s_6__c, Abonnementskosten_6__c, Aansluiting_7__c, BedrijfsBundel_7__c, Aantal_minuten_MB_s_7__c, Zelf_invullen_Abonnementskosten_7__c, Aansluiting_8__c, BedrijfsBundel_8__c, Aantal_minuten_MB_s_8__c, Zelf_invullen_Abonnementskosten_8__c, Aansluiting_9__c, BedrijfsBundel_9__c, Aantal_minuten_MB_s_9__c, Zelf_invullen_Abonnementskosten_9__c, Aansluiting_10__c, BedrijfsBundel_10__c, Aantal_minuten_MB_s_10__c, Zelf_invullen_Abonnementskosten_10__c, Maandbedrag_BedrijfsBundels__c, Verkeerskosten_BedrijfsFlexibel__c, MobileMiles_korting_BBofferte__c, Netwerkactie_BB__c, Totaal_per_maand_incl_MM_korting_BB__c, Huidige_kosten_tbv_offerteBB__c, Besparing_per_maand_offerteBB__c, Kortingspercentage__c, Netwerkactie_BedrijfsBundel__c, Verkoopadviseur_MobileMiles__c FROM Account WHERE Id = :theSig.EZSign__Parent_Id__c LIMIT 1];
        this.accountList = Database.Query(theAccountQuery);
        if (accountList!=null && !accountList.isEmpty()){
            this.theAccount = accountList[0];
        }
        //this.oriList = [SELECT Id, Name, Account__c, Aantal_minuten_MB_s__c, Abonnement__c, Modules__c, Prijs__c FROM Offerte_regel_item__c WHERE Account__c = :theSig.EZSign__Parent_Id__c];
        this.oriList = Database.Query(theORIQuery);
        this.isNotEmpty = true;
        if (oriList.isEmpty()){
            this.isNotEmpty = false;
        }
    }
    
    public Boolean getIsNotEmpty(){
        return isNotEmpty;
    }
    
    public list<Offerte_regel_item__c> getOriList(){
        return oriList;
    }
    
    public void updateTheSig(){
        update theSig;
    }
    
    @isTest(seeAllData=true)
    public static void myTest(){
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        EZSign__Signature__c testSig = new EZSign__Signature__c(EZSign__Parent_Id__c = testAccount.Id, EZSign__Signature_Key__c = 'testKey');
        insert testSig;
        ApexPages.StandardController testController = new ApexPages.StandardController(testSig);
        updateSig testExtController = new updateSig(testController);
        testExtController.getIsNotEmpty();
        testExtController.updateTheSig();
        PageReference testPageRef = Page.EZSign_Example;
        Test.setCurrentPage(testPageRef);
        ApexPages.currentPage().getParameters().put('key',testSig.EZSign__Signature_Key__c);
        testExtController = new updateSig(testController);
    }

}