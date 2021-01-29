public class KoopovereenkomstPDFController {
    public class PriceGroup {
        public String name {get;set;}
        public List<QuoteLineItem> items {get;set;}

       /* public Decimal getTotalMonthly() {
            Decimal d = 0;
            for (QuoteLineItem qli : items) {
                if (qli.Price_Monthly__c != null) {
                    d += qli.Price_Monthly__c;
                }
                if (qli.UnitPrice != null) {
                    d += qli.UnitPrice;
                }
            }
            return d;
        } 
        public Decimal getTotalSetup() {
            Decimal d = 0;
            for (QuoteLineItem qli : items) {
                if (qli.Price_Connect__c != null) {
                    d += qli.Price_Connect__c;
                }
            }
            return d;
        } 
        public Decimal getTotalInstallation() {
            Decimal d = 0;
            for (QuoteLineItem qli : items) {
                if (qli.Price_Installation__c != null) {
                    d += qli.Price_Installation__c;
                }
            }
            return d;
        } */
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
    
    
    public KoopovereenkomstPDFController(ApexPages.StandardController stdController) {
        controller = stdController;
        if (!Test.isRunningTest()) {
            controller.addFields(getFieldsForController());
        }
        this.quote = (Quote)stdController.getRecord();
        this.verkoper = quote.opportunity.owner;
        OpportunityContactRole contactRole = (OpportunityContactRole)Utils.getOneOrNull([Select Id, IsPrimary, Contact.Name, Contact.Email, Contact.Phone From OpportunityContactRole Where IsPrimary=TRUE and OpportunityId = :quote.opportunity.id]); 
        OpportunityContactRole signerRole = (OpportunityContactRole)Utils.getOneOrNull([Select Id, IsPrimary, Contact.Name, Contact.Email, Contact.Phone From OpportunityContactRole Where Role='Tekenbevoegd' and OpportunityId = :quote.opportunity.id]); 
        this.contact = contactRole == null ? null : contactRole.contact;
        this.signer = signerRole == null ? null : signerRole.contact;
        
        
        this.nullGeb = this.quote.Geboortedatum__c==null;
        this.nullLegit = this.quote.Legitimatienummer__c==null;
            
        
        ID qid = this.quote.id;
        System.debug('quote = ' + qid);
//        String soql = 'SELECT ' + String.join(getPrefixedObjectFields('', Schema.SObjectType.Quote), ', ') + 
  //          ' FROM Quote where id = :qid';
        
    //    this.quote = Database.query(soql);
        
        
//        ID aid = quote.AccountID;
//        System.debug('account = ' + aid);
//        String soql = 'SELECT ' + String.join(getPrefixedObjectFields('', Schema.SObjectType.Account), ', ') + 
//            ' FROM Account where id = :aid';
//      this.account = Database.query(soql);
        this.account = quote.account;
        

       String soql = 'SELECT ' + String.join(getPrefixedObjectFields('', Schema.SObjectType.QuoteLineItem), ', ') + 
            ', Quantity' +
            ', UnitPrice' +
            ', TotalPrice' +
            ', Description' +
            ', Product2.Name' +
            ', Product2.Family' +
            ', PricebookEntry.Maandelijkse_Kosten__c' +
            ' FROM QuoteLineItem where QuoteID = :qid ' +
            ' and Product2.Levering_door_KPN__c = true ' +
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
    public void saveQuote(){
        update quote;
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