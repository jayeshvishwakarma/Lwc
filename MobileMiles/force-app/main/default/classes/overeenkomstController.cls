public class overeenkomstController{
    public class PriceGroup{
        public String name {get;set;}
        public List<QuoteLineItem> items {get;set;}       
    }
    
    private ApexPages.standardController controller {get;set;}
    
    public Quote quote {get;set;}
    public Account account {get;set;}
    public List<PriceGroup> groupedItems {get;set;}
    public PriceGroup total {get;set;}
    public Contact signer {get;set;}
    public Contact contact {get;set;}
    public boolean nullGeb{get;set;}
    public boolean nullLegit{get;set;}    
    
    public EZSign__Signature__c theSig{get;set;}
    
    public overeenkomstController(ApexPages.StandardController stdController) {
        Map<String, Schema.SObjectField> SigFieldMap;
        
        Map<String, Schema.SObjectField> QuoteFieldMap;
        list<String> QuoteFieldNames;
        String theQuoteQuery;
        Map<String, Schema.SObjectField> QLIFieldMap;
        list<String> QLIFieldNames;
        String theQLIQuery;
        
        list<String> SigFieldNames;
        String theSigQuery;
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
            this.theSig = Database.Query(theSigQuery);                        
        }
        else{
            this.theSig = (EZSign__Signature__c)stdController.getRecord();
            theSigQuery = theSigQuery + ' FROM EZSign__Signature__c WHERE Id = \''+theSig.Id+'\' LIMIT 1';            
            this.theSig = Database.Query(theSigQuery);
        }
        String quoteId = theSig.EZSign__Parent_Id__c;
        String quoteFields ='';
        for(String fields : getFieldsForController()){
            quoteFields += fields + ',' ;
        }
        quoteFields = quoteFields.substring(0, quoteFields.length()-1);       
        String query = 'Select BillingStreet,BillingPostalCode,BillingCity,ExpirationDate,ShippingStreet,ShippingPostalCode,ShippingCity,'+ quoteFields + ' From quote where id =:quoteId';
        
        System.debug(query +'>>>>>>>>');
        this.quote = Database.query(query);
        theQuoteQuery = theQuoteQuery + ' FROM Quote WHERE Id = \''+theSig.EZSign__Parent_Id__c+'\' LIMIT 1';
        
        this.verkoper = quote.opportunity.owner;
        OpportunityContactRole contactRole = (OpportunityContactRole)Utils.getOneOrNull([Select Id, IsPrimary, Contact.Name, Contact.Email, Contact.Phone From OpportunityContactRole Where IsPrimary=TRUE and OpportunityId = :quote.opportunity.id]); 
        OpportunityContactRole signerRole = (OpportunityContactRole)Utils.getOneOrNull([Select Id, IsPrimary, Contact.Name, Contact.Email, Contact.Phone From OpportunityContactRole Where Role='Tekenbevoegd' and OpportunityId = :quote.opportunity.id]); 
        this.contact = contactRole == null ? null : contactRole.contact;
        this.signer = signerRole == null ? null : signerRole.contact;
        
        this.nullGeb = this.theSig.Geboortedatum__c==null;
        this.nullLegit = this.theSig.Legitimatienummer__c==null;
            
        
        ID qid = this.quote.id;
        System.debug('quote = ' + qid);
        this.account = quote.account;
        

       String soql = 'SELECT ' + String.join(getPrefixedObjectFields('', Schema.SObjectType.QuoteLineItem), ', ') + 
            ', Quantity' +
            ', UnitPrice' +
            ', TotalPrice' +
            ', Description' +
            ', Product2.Name' +
            ', Product2.Family' +
            ', Product2.Levering_door_KPN__c' +
            ', PricebookEntry.Maandelijkse_Kosten__c' +
            ' FROM QuoteLineItem where QuoteID = :qid ' +
            ' order by product2.family, product2.name';
        
        this.total = new PriceGroup();
        this.total.items = new List<QuoteLineItem>();
        
        List<QuoteLineItem> items = Database.query(soql);
        
        List<PriceGroup> groupedItems = new List<PriceGroup>();
        Map<String, PriceGroup> priceGroupMap = new Map<String, PriceGroup>();
        
        if (quote.heeft_verbinding__c) {
            PriceGroup pgVerbinding = new PriceGroup();
            pgVerbinding.name='Verbinding';
            pgVerbinding.items = new List<QuoteLineItem>();
            groupedItems.add(pgVerbinding);
            priceGroupMap.put(pgVerbinding.name, pgVerbinding);
            QuoteLineItem qli = new QuoteLineItem();
            qli.product2 = new Product2(name='Zonder Verbinding', description=null);
            qli.quantity = 1;
            //qli.unitprice = null;
            //qli.totalprice = null;
            //qli.xxxxx
            pgVerbinding.items.add(qli);
        }

        for (QuoteLineItem qli : items) {
            String f = qli.product2.family;
            PriceGroup g = priceGroupMap.get(f);
            if (g == null) {
                g = new PriceGroup();
                g.name = f;
                if (f == null) { g.name = 'Overig'; }
                g.items = new List<QuoteLineItem>();
                
                priceGroupMap.put(f, g);
                groupedItems.add(g);
            }
            
            g.items.add(qli);
            this.total.items.add(qli);
        }
        this.groupedItems = groupedItems;
    }
    
    public User verkoper {get;set;}

    public List<String> getFieldsForController() {
        List<String> theFields = new List<String>();
        theFields.addAll(getPrefixedObjectFields('', Schema.SObjectType.Quote));
        theFields.addAll(getPrefixedObjectFields('Opportunity.', Schema.SObjectType.Opportunity));
        theFields.addAll(new List<String> {
            'Opportunity.Owner.Name',
            'Opportunity.Owner.Title',
            'Opportunity.Owner.Email',
            'Opportunity.Owner.Phone',
            'Opportunity.Owner.Functie__c',
            'Opportunity.Owner.Signature__c'
        });

        //theFields.addAll(getPrefixedObjectFields('Account.', Schema.SObjectType.Account));
        theFields.addAll(new List<String> {
            'Account.Name',
            'Account.BillingAddress',
            'Account.BillingStreet',
            'Account.BillingPostalCode',
            'Account.BillingCity',
            'Account.KvK_nummer__c'
        });
        return theFields;
    }
    public void saveSig(){
        update theSIg;
    }
        
    public static List<String> getPrefixedObjectFields(String prefix, Schema.DescribeSObjectResult objDef) {
        List<String> result = new List<String>();

        Map<String, SObjectField> fields = objDef.fields.getMap(); 
        Set<String> fieldSet = fields.keySet();
        for(String s : fieldSet) {
            SObjectField fieldToken = fields.get(s);
            DescribeFieldResult selectedField = fieldToken.getDescribe();
            String fieldName = selectedField.getName();
            if (fieldName.endsWith('__c') || 
                fieldName.equalsIgnoreCase('Name') || 
                fieldName.equalsIgnoreCase('Id')) {
                result.add(prefix + fieldName);
            } 
        }
        return result;
    }
}