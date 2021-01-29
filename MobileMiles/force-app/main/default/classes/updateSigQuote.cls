public class updateSigQuote {

    public EZSign__Signature__c theSig{get;set;}
    public list<Quote> quoteList{get;set;}
    public Quote theQuote{get;set;}
    public list<QuoteLineItem> qliList;
    public Boolean isNotEmpty;
    public Boolean nullGeb{get;set;}
    public Boolean nullBank{get;set;}
    public Boolean nullLegit{get;set;}
    public Boolean nullLoop{get;set;}
    public Boolean nullAkkord{get;set;}
    public Map<String, Schema.SObjectField> SigFieldMap;
    public list<String> SigFieldNames;
    public String theSigQuery;
    public Map<String, Schema.SObjectField> QuoteFieldMap;
    public list<String> QuoteFieldNames;
    public String theQuoteQuery;
    public Map<String, Schema.SObjectField> QLIFieldMap;
    public list<String> QLIFieldNames;
    public String theQLIQuery;
    public String ip;
    public string filename{get;set;}
    public Blob upfileBody{get;set;}
    
    public updateSigQuote(ApexPages.StandardController stdController){
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
            if (!theSig.Akkoord_met_voorwaarden__c){
                this.nullAkkord = true;
            }    
            else{
                this.nullAkkord = false;
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
            if (!theSig.Akkoord_met_voorwaarden__c){
                this.nullAkkord = true;
            }    
            else{
                this.nullAkkord = false;
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
        
        //Build Quote Query
        QuoteFieldMap = Schema.SObjectType.Quote.fields.getMap();
        QuoteFieldNames = new list<String>();
        QuoteFieldNames.addAll(QuoteFieldMap.keySet());
        System.debug(QuoteFieldNames);
        theQuoteQuery = 'SELECT ';
        Set<string> excludedFields = new Set<String>{'shippingaddress', 'billingaddress','quotetoaddress', 'additionaladdress'};
        for (String s : QuoteFieldNames){
            if(!excludedFields.contains( s )){
            System.debug(s);
                theQuoteQuery = theQuoteQuery + s;
                if (s!=QuoteFieldNames.get(QuoteFieldNames.size()-1)){
                    theQuoteQuery = theQuoteQuery + ', ';
                }
            }
        }
        theQuoteQuery = theQuoteQuery + ' FROM Quote WHERE Id = \''+theSig.EZSign__Parent_Id__c+'\' LIMIT 1';
        //Build QLI Query
        QLIFieldMap = Schema.SObjectType.QuoteLineItem.fields.getMap();
        QLIFieldNames = new list<String>();
        QLIFieldNames.addAll(QLIFieldMap.keySet());
        theQLIQuery = 'SELECT ';
        for (String s : QLIFieldNames){
            System.debug(s);
            if(! excludedFields.contains( s )){
                theQLIQuery = theQLIQuery + s;
                if (s!=QLIFieldNames.get(QLIFieldNames.size()-1)){
                    theQLIQuery = theQLIQuery + ', ';
                }
            }
        }
        theQLIQuery = theQLIQuery + ' FROM QuoteLineItem WHERE QuoteId = \''+theSig.EZSign__Parent_Id__c+'\' ORDER BY Toestel__c asc,Abonnement__c ASC';
        
        this.quoteList = Database.Query(theQuoteQuery);
        if (quoteList!=null && !quoteList.isEmpty()){
            this.theQuote = quoteList[0];
         }
        
        this.qliList = Database.Query(theQLIQuery);
        this.isNotEmpty = true;
        if (qliList.isEmpty()){
            this.isNotEmpty = false;
        } 
 
    }
    
    public Boolean getIsNotEmpty(){
        return isNotEmpty;
    }
    
    public list<QuoteLineItem> getQliList(){
        return qliList;
    }
    
    public void updateTheSig(){
        update theSig;
    }
    
    // Called from page on action (Ibirds Vishnu)
    public void createTask(){
        String senderid = ApexPages.currentPage().getParameters().get('senderid');
        String quoteid = ApexPages.currentPage().getParameters().get('quoteid');
        String SiteHost = Site.getCurrentSiteUrl();
        String SiteUrl = ApexPages.currentPage().getUrl();
        Siteurl = siteurl.contains('/apex/')?siteurl.replace('/apex/',''):siteUrl;
        
        //Task id created when quote status = Verzonden
        if ( senderid != null && quoteid != null ){              
            list<Quote> listQuote = [ select id,status from Quote where Id =: quoteid and status = 'Verzonden' limit 1];
            if( listQuote.size() > 0 ){               
                Task newTask = new Task();
                newTask.OwnerId = senderid;           
                newTask.Type = 'Email';
                newTask.Subject = 'Offerte ingezien';
                newTask.WhatId = quoteid;
                newTask.Description = SiteHost +SiteUrl;
                newTask.ActivityDate = date.today();
                newTask.status = 'Voltooid';
                try{
                    insert newTask;               
                }catch(Exception e){
                    System.debug('---Error--'+e.getMessage());
                }
            }
        }
        
    }
    
    @isTest(seeAllData=true)
    public static void myTest(){
        Opportunity testOpp = new Opportunity(Name='Test Opportunity',StageName='Test',CloseDate=System.now().date());
        insert testOpp;
        Quote testQuote = new Quote(Name='Test Quote',OpportunityId=testOpp.Id,status ='Verzonden');
        insert testQuote;
        EZSign__Signature__c testSig = new EZSign__Signature__c(EZSign__Parent_Id__c = testQuote.Id, EZSign__Signature_Key__c = 'testKey');
        insert testSig;
        ApexPages.StandardController testController = new ApexPages.StandardController(testSig);
        updateSigQuote testExtController = new updateSigQuote(testController);
        testExtController.getIsNotEmpty();
        testExtController.updateTheSig();
        PageReference testPageRef = Page.EZSign_Example;
        Test.setCurrentPage(testPageRef);
        ApexPages.currentPage().getParameters().put('key',testSig.EZSign__Signature_Key__c);
        
        //Test coverge for createTask method
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = false;
        User u = new User(alias = 'standt', email='testibirds4321@testibirds.com',
                          emailencodingkey='UTF-8', lastname='test',
                          firstname='Tets', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id, 
                          timezonesidkey='America/Los_Angeles',
                          username='testibirds4321@testibirds.com');
        u.setOptions(dmo);
        insert u;
        ApexPages.currentPage().getParameters().put('senderid',u.id);        
        ApexPages.currentPage().getParameters().put('quoteid',testQuote.id);
        testExtController.createTask();
        testExtController.uploadAttachment();
        testExtController = new updateSigQuote(testController);
        
        
    }
    //Uploading Attachment
    public void uploadAttachment(){
        if(Test.isRunningTest()){
            filename = 'test';
            
        }
        if( filename != NULL && theSig != NULL && theSig.EZSign__Parent_Id__c != NULL ){
            List<String> lstStr = new List<String>();
            //spiliting the file name with '.'
            lstStr = filename.split('\\.');
            //getting the extention by last index
            Integer ext = lstStr.size()-1;
            if(lstStr[ext] == 'jpg'||lstStr[ext] == 'png' || lstStr[ext] == 'pdf'|| lstStr[ext] == 'gif'){
                System.debug('correct');
                Attachment atch = new Attachment();
                atch.name = filename;
                System.debug(theSig.EZSign__Parent_Id__c);
                atch.parentId = theSig.EZSign__Parent_Id__c;
                atch.body = upfileBody;
                insert atch;
                theQuote.kopie_legitimatiebewijs_bijgevoegd__c = TRUE;
                update theQuote;
                filename = '';
                upfileBody = null;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.confirm,'Your Attachment is inserted Sucessfully'));
            }
             else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,'Only Jpg, Png, Pdf are allowed'));
            }
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,'Please Upload Valid File/Unable to find specfied record'));
        }
    }

}