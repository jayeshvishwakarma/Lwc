public class QuoteComponentPDFController {
    public String quoteId;
    public void setquoteId(String quoteRecId){
        quoteId = quoteRecId;        
        if(quoteId != null){
            fillData();         
        }
    }
    public String getquoteId(){
        return quoteId; 
    }
    public class QuoteLineItemWrapper {
        public QuoteLineItem qli {get;set;}
        public Decimal getPricePerMonth() { 
            If(qli != null){        
                if (qli.pricebookEntry.Maandelijkse_kosten__c) {
                    return qli.unitprice;
                }
            }
            return null;
        }
        public Decimal getPriceTotal() {
            if(qli != null){
                if (qli.pricebookEntry.Maandelijkse_kosten__c) {
                    return qli.totalprice;
                } else {
                    return getPriceTotalOneTime();
                }
            }
          return null;
        }
        public Decimal getPriceTotalOneTime() {
            Decimal t = 0;
            If(qli != null){
                if (!qli.pricebookEntry.Maandelijkse_kosten__c) {
                    if (qli.totalprice != null) {
                        t += qli.totalprice;
                    }
                }
                if (qli.Price_Connect__c != null) {
                    t += qli.Price_Connect__c * qli.Quantity;
                }
                if (qli.Price_Installation__c != null) {
                    t += qli.Price_Installation__c * qli.Quantity;
                }
                
                if (t == 0) {
                    return null;
                }
                
            }
            return t;
        }
        
        public Decimal getPriceOneTime() {
            Decimal t = 0;
            if(qli != null){
                if (!qli.pricebookEntry.Maandelijkse_kosten__c) {
                    if (qli.totalprice != null) {
                        t += qli.totalprice;
                    }
                }
                if (qli.Price_Connect__c != null) {
                    t += qli.Price_Connect__c;
                }
                if (qli.Price_Installation__c != null) {
                    t += qli.Price_Installation__c;
                }
                
                if (t == 0) {
                    return null;
                }
            }
            return t;
        }
    }
    
    public class PriceGroup {
        public String name {get;set;}
        public List<QuoteLineItemWrapper> items {get;set;}
        
        public PriceGroup() {
            items = new List<QuoteLineItemWrapper>();
        }
        
        public void addItem(QuoteLineItem qli) {
            QuoteLineItemWrapper w = new QuoteLineItemWrapper();
            w.qli = qli;
            items.add(w);
        }

        public Decimal getTotalMonthly() {
            if(items != null){
                Decimal d = 0;
                for (QuoteLineItemWrapper w : items) {
                    QuoteLineItem qli = w.qli;
                    if (qli.pricebookEntry.Maandelijkse_kosten__c) {
                    //if (qli.Price_Monthly__c != null) {
                        d += qli.TotalPrice;
                    }
                }
                return d;
            }
            return null;
        } 
        public Decimal getTotalSetup() {            
            Decimal d = 0;
            if(items != null){
                for (QuoteLineItemWrapper w : items) {
                    QuoteLineItem qli = w.qli;
                    if (qli.Price_Connect__c != null) {
                        d += qli.Price_Connect__c * qli.Quantity;
                    }
                    if (!qli.pricebookEntry.Maandelijkse_kosten__c) {
                        if (qli.TotalPrice != null) {
                            d += qli.TotalPrice;                        
                        }
                    }
    
                }
            }
            return d;
        } 
        public Decimal getTotalInstallation() {            
            Decimal d = 0;
            if(items!= null){
                for (QuoteLineItemWrapper w : items) {
                    QuoteLineItem qli = w.qli;
                    if (qli.Price_Installation__c != null) {
                        d += qli.Price_Installation__c * qli.Quantity;
                    }
                }
            }
            return d;
        } 
    }
    
    public Quote quote {get;set;}
    public Account account {get;set;}
    public List<PriceGroup> groupedItems {get;set;}
    public PriceGroup total {get;set;}
    public Contact signer {get;set;}
    public Contact contact {get;set;}
    
    
    public Integer getDuration() {
        if(quoteId != null){
            String l = quote.looptijd__c;
            //System.assert(l != null, 'Geen looptijd ingevuld');
            
            String[] parts = l.split(' ');
            //System.assert(parts.size() == 2, 'Looptijd geen geldig formaat:  XX maanden of XX jaar. is: ' + l);
            Integer n = Integer.valueOf(parts[0]);
            if (parts[1] == 'jaar') {
                n = n * 12;
            } else {
                //System.assert(parts[1] == 'maand' || parts[1] == 'maanden', 'Looptijd geen geldig formaat:  XX maanden of XX jaar.  Is: ' + l);
            }
            return n;
        }
        return null;
               
    }
    
    public static Decimal nullToZero(Decimal d) {
        return d == null ? 0 : d;
    }
    
    public Decimal getTotalCostOverDuration() {
        Decimal t = 0;
        if(quoteId != null){
            t += nullToZero(total.getTotalInstallation());
            t += nullToZero(total.getTotalSetup());
            t += nullToZero(total.getTotalMonthly() * getDuration());
        }
        return t;
    }
    
    public Decimal getTotalCostOverDurationPerMonth() {
        if(quoteId != null){
            return getTotalCostOverDuration()/getDuration();
        }
        return null;
    }
 
    
    
    public void fillData(){        
        
        String quoteFields ='';
        for(String fields : getFieldsForController()){
            quoteFields += fields + ',' ;
        }
        quoteFields = quoteFields.substring(0, quoteFields.length()-1);       
        String query = 'Select BillingStreet,BillingPostalCode,BillingCity,ExpirationDate,'+ quoteFields + ' From quote where id =:quoteId';
        
        System.debug(query +'>>>>>>>>');
        this.quote = Database.query(query);
        
        this.verkoper = quote.opportunity.owner;
        // this.signer = quote.opportunity.contactpersoon_tekenbevoegd__r;
        OpportunityContactRole contactRole = (OpportunityContactRole)Utils.getOneOrNull([Select Id, IsPrimary, Contact.Name, Contact.Email, Contact.Phone From OpportunityContactRole Where IsPrimary=TRUE and OpportunityId = :quote.opportunity.id]); 
        OpportunityContactRole signerRole = (OpportunityContactRole)Utils.getOneOrNull([Select Id, IsPrimary, Contact.Name, Contact.Email, Contact.Phone From OpportunityContactRole Where Role='Tekenbevoegd' and OpportunityId = :quote.opportunity.id]); 
        this.contact = contactRole == null ? null : contactRole.contact;
        this.signer = signerRole == null ? null : signerRole.contact;
        
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
            ', Product2.Levering_door_KPN__c ' +
            ', Product2.Family' +
            ', pricebookEntry.Maandelijkse_kosten__c' +
            ' FROM QuoteLineItem where QuoteID = :qid ' +
            ' order by product2.family, product2.product_groepering__c, product2.product_Type__c, product2.name';
        
        this.total = new PriceGroup();
        
        List<QuoteLineItem> queriedItems = Database.query(soql);
        List<List<QuoteLineItem>> items = new List<List<QuoteLineItem>>(); // gegroepeerd
        for (QuoteLineItem qli : queriedItems) {
            
            if (qli.gekoppeld_aan__c == null) {
                List<QuoteLineItem> item = new List<QuoteLineItem>();
                item.add(qli);
                // add gekoppelde producten..
                for (QuoteLineItem linked : queriedItems) {
                    if (linked.gekoppeld_aan__c == qli.id) {
                        item.add(linked);
                    }
                }
                items.add(item);
            }
        }
        
        
        
        List<PriceGroup> groupedItems = new List<PriceGroup>();
        Map<String, PriceGroup> priceGroupMap = new Map<String, PriceGroup>();
        
        if (quote.heeft_verbinding__c) {
            PriceGroup pgVerbinding = new PriceGroup();
            pgVerbinding.name='Verbinding';
            
            groupedItems.add(pgVerbinding);
            priceGroupMap.put(pgVerbinding.name, pgVerbinding);
            QuoteLineItem qli = new QuoteLineItem();
            qli.product2 = new Product2(name='Zonder Verbinding', description=null);
            qli.quantity = 1;
            //qli.unitprice = null;
            //qli.totalprice = null;
            //qli.xxxxx
            pgVerbinding.addItem(qli);
        }

        for (List<QuoteLineItem> qlis : items) {
            QuoteLineItem firstQli = qlis.get(0);
            
            String f = firstQli.product2.family;
            PriceGroup g = priceGroupMap.get(f);
            if (g == null) {
                g = new PriceGroup();
                g.name = f;
                if (f == null) { g.name = 'Overig'; }
                
                priceGroupMap.put(f, g);
                groupedItems.add(g);
            }
            
            for (QuoteLineItem qli : qlis) {
                g.addItem(qli);
                this.total.addItem(qli);
            }
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
            'Opportunity.Owner.Phone',
            'Opportunity.Owner.Email'
        });
//      theFields.addAll(new List<String> {
//          'Opportunity.Contactpersoon_Tekenbevoegd__r.Name'
//      });

        //theFields.addAll(getPrefixedObjectFields('Account.', Schema.SObjectType.Account));
        theFields.addAll(new List<String> {
            'Account.Name',
            'Account.BillingAddress',
            'Account.BillingStreet',
            'Account.BillingPostalCode',
            'Account.BillingCity'
        });
        return theFields;
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