public with sharing class QuoteComposerController {
    public WizardComponent wizard {get;set;}

    public class ProductGroupWrapper {
        public String name {get;set;}
        public List<ProductWrapper> products {get;set;}
    }
    
    public class ProductWrapper {
        public Decimal amount {get;set;}
        public Product2 product {get;set;}
        public Boolean editable {get;set;}
        public PriceBookEntry priceBookEntry {get;set;}
        
        public Decimal unitPrice {get;set;}
        public Decimal Price_Connect {get;set;}
        public Decimal Price_Installation {get;set;}
        
        // Voor custom producten
        public String productName {get;set;}
        
        public void setProductAndPriceBookEntry(Product2 product, PriceBookEntry pbe) {
            this.product = product;
            this.priceBookEntry = pbe;
            this.UnitPrice = pbe.UnitPrice;
            this.Price_Connect = pbe.Eenmalige_aansluitkosten__c;
            this.Price_Installation = pbe.Eenmalige_installatiekosten__c;
        }
    }
    
    private ApexPages.standardController controller {get;set;}

    public String voiceInternet {get; set;}
    
    public Integer kanalen {get;set;}
    public String verbindingId {get;set;}
    public Quote quote {get;set;}
    
    public List<ProductGroupWrapper> producten {get;set;}
    
    public PageReference init() {
        if (quote.pricebook2id == null) {
            // -- or redirect to pricebook selection?
            Pricebook2 priceBook = [select id from PriceBook2 where name = 'KPN EEN'];
            quote.pricebook2id = priceBook.id;
            update quote;
        }
        return null;
    }

    public QuoteComposerController(ApexPages.StandardController stdController) {
        controller = stdController;
        
        quote = (Quote)controller.getRecord();
        quote = [select id, name, pricebook2id, Heeft_Verbinding__c from Quote where id = :quote.id];
        kanalenSelectOptions = initKanalenSelectOptions();
        verbindingenSelectOptions = initVerbindingenSelectOptions();

        kanalen = null;

        producten = new List<ProductGroupWrapper>();
        
        wizard = new WizardComponent();
        wizard.steps.add(new WizardComponent.step(1, 'Verbinding', 'Verbinding')); 
        wizard.steps.add(new WizardComponent.step(2, 'Profielen', 'Profielen')); 
        wizard.steps.add(new WizardComponent.step(3, 'Nummers', 'Nummers')); 
        wizard.steps.add(new WizardComponent.step(4, 'Cloud', 'Cloud')); 
        wizard.steps.add(new WizardComponent.step(5, 'Hardware', 'Hardware')); 
        wizard.steps.add(new WizardComponent.step(6, 'Service & diensten', 'Service & diensten')); 
        wizard.setCurrent(1);
  
        queryProductLists();
    }
    
    public List<SelectOption> getOptionalBooleanSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('true', 'Ja'));
        options.add(new SelectOption('false', 'Nee'));
        return options;
    }
    
    public List<SelectOption> kanalenSelectOptions {get;set;}
    public List<SelectOption> initKanalenSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();

        ID verbindingRT = verbindingRecordType();
//      for (AggregateResult ar : [select Aantal_Kanalen__c, count(recordtypeid) from Product2 where recordtypeid = :verbindingRT group by Aantal_Kanalen__c]){
        //}
        
        if (voiceInternet == 'Voice Only') {
            Set<String> kanalenDone = new Set<String>();
            //and Voice_Internet__c = :voiceInternet 
            for (Product2 product : [select id, Aantal_Kanalen__c from Product2 where recordtypeid = :verbindingRT and Family = 'Verbindingen' and Aantal_Kanalen__c != null and Voice_Internet__c = :voiceInternet order by Aantal_Kanalen__c]){
                String kanalen = ''+product.Aantal_Kanalen__c;
                if (!kanalenDone.contains(kanalen)) {
                    kanalenDone.add(kanalen);
                    options.add(new SelectOption(kanalen, kanalen));                
                }
            }
        }
 
        
        if (voiceInternet == 'Glasvezel') {
            Set<String> kanalenDone = new Set<String>();
            for (Product2 product : [select id, Aantal_Kanalen__c from Product2 where recordtypeid = :verbindingRT and Family = 'Verbindingen' and Voice_Internet__c = :voiceInternet and gebiedskeuze__c = :gebiedsKeuze and Aantal_Kanalen__c != null order by Aantal_Kanalen__c]){
                String kanalen = ''+product.Aantal_Kanalen__c;
                if (!kanalenDone.contains(kanalen)) {
                    kanalenDone.add(kanalen);
                    options.add(new SelectOption(kanalen, kanalen));                
                }
            }
        }       
        return options;
    }

    public List<SelectOption> verbindingenSelectOptions {get;set;}
    public List<SelectOption> initVerbindingenSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();


        ID verbindingRT = verbindingRecordType();
        if (voiceInternet == 'Voice Only' && kanalen != null && verbindingPicklist != null && router != null) {
            for (Product2 product : [select id, Name from Product2 where 
                                     recordtypeid = :verbindingRT and Aantal_Kanalen__c = :kanalen and
                                     Family = 'Verbindingen' and 
                                     Voice_Internet__c = :voiceInternet and
                                     Aantal_Kanalen__c = :kanalen and
                                     Router__c = :router
                                     order by Name]) {
                options.add(new SelectOption(product.Id, product.Name));
            }
        }


        if (voiceInternet == 'Voice + Internet' && sla != null && verbindingPicklist != null && evc != null && router != null) {
            for (Product2 product : [select id, Name from Product2 where 
                                     recordtypeid = :verbindingRT and 
                                     Family = 'Verbindingen' and 
                                     Voice_Internet__c = :voiceInternet and 
                                     SLA_Level__c = :sla and 
                                     Verbinding__c = :verbindingPicklist 
                                     and EVC__c = :evc
                                     and Router__c = :router 
                                     order by Name]) {
                options.add(new SelectOption(product.Id, product.Name));
            }
        }
        
        if (voiceInternet == 'Glasvezel' && gebiedsKeuze != null && kanalen != null) {
            for (Product2 product : [select id, Name from Product2 where 
                                     recordtypeid = :verbindingRT and 
                                     Family = 'Verbindingen' and
                                     Gebiedskeuze__c = :gebiedsKeuze and 
                                     Voice_Internet__c = :voiceInternet and 
                                     Aantal_Kanalen__c = :kanalen 
                                     order by Name]) {
                options.add(new SelectOption(product.Id, product.Name));
            }
        }
        
        return options;
    }

    
    public String sla {get; set;}
    public List<SelectOption> getSlaSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        ID verbindingRT = verbindingRecordType();
        for(AggregateResult ar : [SELECT SLA_Level__c FROM Product2 WHERE recordtypeid = :verbindingRT and Voice_Internet__c = :voiceInternet GROUP BY SLA_Level__c]) {
            String value = (String)ar.get('SLA_Level__c');
            value = value == null ? '' : value;
            options.add(new SelectOption(value, value));
        }
        return options;
    }

    public String verbindingPicklist {get; set;}
    public List<SelectOption> getVerbindingPicklistSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        ID verbindingRT = verbindingRecordType();

        if (voiceInternet == 'Voice Only' && kanalen != null) {
            for(AggregateResult ar : [SELECT Verbinding__c FROM Product2 WHERE recordtypeid = :verbindingRT and Aantal_Kanalen__c = :kanalen and Verbinding__c != null and Verbinding__c != '' GROUP BY Verbinding__c]) {
                String value = (String)ar.get('Verbinding__c');
                value = value == null ? '' : value;
                options.add(new SelectOption(value, value));
            }
        }

        if (voiceInternet == 'Voice + Internet' && sla != null) {
            for(AggregateResult ar : [SELECT Verbinding__c FROM Product2 WHERE recordtypeid = :verbindingRT and Voice_Internet__c = :voiceInternet and SLA_Level__c = :sla and Verbinding__c != null and Verbinding__c != '' GROUP BY Verbinding__c]) {
                String value = (String)ar.get('Verbinding__c');
                value = value == null ? '' : value;
                options.add(new SelectOption(value, value));
            }
        }

        return options;
    }
    
    public String evc {get; set;}
    public List<SelectOption> getEvcSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        ID verbindingRT = verbindingRecordType();
        for(AggregateResult ar : [SELECT EVC__c FROM Product2 WHERE recordtypeid = :verbindingRT and Voice_Internet__c = :voiceInternet and SLA_Level__c = :sla and Verbinding__c = :verbindingPicklist and EVC__c != null and EVC__c != '' GROUP BY EVC__c]) {
            String value = (String)ar.get('EVC__c');
            value = value == null ? '' : value;
            options.add(new SelectOption(value, value));
        }
        return options;
    }
    

    public String router {get; set;}
    public List<SelectOption> getRouterSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        ID verbindingRT = verbindingRecordType();
        for(AggregateResult ar : [SELECT Router__c FROM Product2 WHERE recordtypeid = :verbindingRT and Voice_Internet__c = :voiceInternet and SLA_Level__c = :sla and Verbinding__c = :verbindingPicklist and EVC__c = :evc and Router__c != null and Router__c != '' GROUP BY Router__c]) {
            String value = (String)ar.get('Router__c');
            value = value == null ? '' : value;
            options.add(new SelectOption(value, value));
        }
        return options;
    }



    public String gebiedsKeuze {get; set;}
    public List<SelectOption> getGebiedsKeuzeSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        ID verbindingRT = verbindingRecordType();
        for(AggregateResult ar : [SELECT GebiedsKeuze__c FROM Product2 WHERE recordtypeid = :verbindingRT and Voice_Internet__c = :voiceInternet GROUP BY GebiedsKeuze__c]) {
            String value = (String)ar.get('GebiedsKeuze__c');
            value = value == null ? '' : value;
            options.add(new SelectOption(value, value));
        }
        return options;
    }

    // Dit is de verbinding, of de gekozen bundel.
    public Product2 verbinding {get;set;}
    
    public PageReference rerenderSelects() {
        verbindingenSelectOptions = initVerbindingenSelectOptions();
        kanalenSelectOptions = initKanalenSelectOptions();
        if (verbindingenSelectOptions.isEmpty()) {
            verbindingId = null;
        }

        if (String.isBlank(verbindingId) && verbindingenSelectOptions.size() == 1) {
            verbindingId = verbindingenSelectOptions.iterator().next().getValue();
        }

        if (!String.isBlank(verbindingId)) {
            verbinding = [select id
                ,name
                ,Aantal_Kanalen__c
                ,Looptijd_mnd__c
                ,ProductCode
                ,Product_code_KPN_VT__c
                ,Product_Familie_KPN_VT__c
                ,IRMA_Productcode__c
                ,keuzenaam__c
                from Product2 where id = :verbindingId];
        } else {
            System.debug('VerbindingId is null');
            verbinding = null;
        }
        return null;
    }
    
    public PageReference wizardStepClicked() {
        Integer newStep = Integer.valueOf(Apexpages.currentPage().getParameters().get('newStep'));
        wizard.setCurrent(newStep);
        queryProductLists();
        return null;
    }
    
    public void queryProductLists() {
        String[] familiesForSteps = new List<String> {
            'null',
            'Verbindingen', // verbinding
            'Profielen', // profielen
            'Nummers', // nummers
            'Cloud', // Cloud
            'Hardware', // Hardware
            'Service & Diensten'
        };
        String family = familiesForSteps[wizard.current.step];
        
        List<QuoteLineItem> mainItems;
        if (wizard.current.step == 1) {
            ID verbindingRT = verbindingRecordType();
            mainItems = [select id, Quantity,
                          Price_Monthly__c, Price_Installation__c, Price_Connect__c, UnitPrice,
                          product2.name, product2.family, product2.Aantal_Kanalen__c,
                          product2.remarks__c, product2.aanpasbaar__c,
                          product2.Product_Type__c, product2.Product_Groepering__c, 
                          priceBookEntry.name, priceBookEntry.UnitPrice, description, gekoppeld_aan__c,
                          KBit_Up__c, KBit_Down__c, Product2.voice_internet__c
                          from QuoteLineItem 
                          where quoteId = :quote.id and product2.family = :family and product2.recordtypeid = :verbindingRT
                          order by product2.product_groepering__c, product2.product_Type__c, product2.name];
        } else {
            mainItems = [select id, Quantity,
                          Price_Monthly__c, Price_Installation__c, Price_Connect__c, UnitPrice,
                          product2.name, product2.family, product2.Aantal_Kanalen__c,
                          product2.remarks__c, product2.aanpasbaar__c,
                          product2.Product_Type__c, product2.Product_Groepering__c, 
                          priceBookEntry.name, priceBookEntry.UnitPrice, description, gekoppeld_aan__c,
                          KBit_Up__c, KBit_Down__c, Product2.voice_internet__c
                          from QuoteLineItem 
                          where quoteId = :quote.id and product2.family = :family
                          order by product2.product_groepering__c, product2.product_Type__c, product2.name];
        }           
                          
        // Query linked products too
        List<ID> hoofdItemIds = new List<ID>();
        for (QuoteLineItem qli : mainItems) {
            hoofdItemIds.add(qli.id);
        }
        Map<ID, List<QuoteLineItem>> linkedProductsPerProduct = new Map<ID, List<QuoteLineItem>>();
        for (QuoteLineItem qli : [
            select id, Quantity,
            Price_Monthly__c, Price_Installation__c, Price_Connect__c, UnitPrice,
            product2.name, product2.family, product2.Aantal_Kanalen__c,
            product2.remarks__c, product2.aanpasbaar__c,
            product2.Product_Type__c, product2.Product_Groepering__c, 
            priceBookEntry.name, priceBookEntry.UnitPrice, description, gekoppeld_aan__c,
            KBit_Up__c, KBit_Down__c, Product2.voice_internet__c
            from QuoteLineItem 
            where quoteId = :quote.id and gekoppeld_aan__c in :hoofdItemIds]) {
            
            
            if (!linkedProductsPerProduct.containsKey(qli.gekoppeld_aan__c)) {
                linkedProductsPerProduct.put(qli.gekoppeld_aan__c, new List<QuoteLineItem>());
            }
            
            List<QuoteLineItem> itemsForThisProduct = linkedProductsPerProduct.get(qli.gekoppeld_aan__c);
            itemsForThisProduct.add(qli);
        }
//      System.assert(false, '' + linkedProductsPerProduct);
                
        quoteItems = new List<QuoteLineItem>();
        // Add in orde (below the linked product)
        for (QuoteLineItem qli : mainItems) {
            quoteItems.add(qli);
            List<QuoteLineItem> itemsForThisProduct = linkedProductsPerProduct.get(qli.id);
            if (itemsForThisProduct != null) {
                quoteItems.addAll(itemsForThisProduct);
            }
        }
        
        producten = queryProducts(quote, family, quoteItems);
    }
    
    public List<QuoteLineItem> quoteItems {get;set;}
    
    public static List<ProductGroupWrapper> queryProducts(Quote quote, String family, List<QuoteLineItem> productsInQuote) {
        Set<ID> productIds = new Set<ID>();
        // Except editable products
        for (QuoteLineItem w : productsInQuote) {
            if (w.product2.aanpasbaar__c == null || w.product2.aanpasbaar__c == false) {
                productIds.add(w.product2.id);
            }
        }
        
        List<ProductGroupWrapper> productGroups = new List<ProductGroupWrapper>();
        Map<String, ProductGroupWrapper> productGroupNameToGroup = new Map<String, ProductGroupWrapper>();

        // For sorting: Query the picklist options, add them in that order
        // Afterwards remove the empty ones.
        
        for (Schema.PicklistEntry ple : Product2.Product_Groepering__c.getDescribe().getPicklistValues()) {
            ProductGroupWrapper pgw = new ProductGroupWrapper();
            pgw.name = ple.getValue();
            pgw.products = new List<ProductWrapper>();
            productGroupNameToGroup.put(ple.getValue(), pgw);
            productGroups.add(pgw);
        }               
         
        //SELECT UnitPrice FROM PricebookEntry WHERE Pricebook2.isStandard = true and Id = 'yourId'
        for (PriceBookEntry pbe : [select id, UnitPrice, product2.name, product2.Family, product2.Product_Type__c, product2.Product_Groepering__c,
                                   product2.remarks__c,  product2.aanpasbaar__c,
                                   Maandelijkse_kosten__c, Eenmalige_aansluitkosten__c, Eenmalige_installatiekosten__c
                                   from PriceBookEntry where 
                                   PriceBook2Id = :quote.pricebook2id and product2.family = :family
                                   and product2.id not in :productIds
                                   order by product2.product_groepering__c, product2.product_Type__c, product2.name]) {
            ProductWrapper pw = new ProductWrapper();
            Product2 product = pbe.product2;
            pw.setProductAndPriceBookEntry(product, pbe);
            pw.editable = false;
            if (product.aanpasbaar__c != null && product.aanpasbaar__c == true) {
                pw.editable = true;
                pw.productName = product.name;
            }
            
            if (!productGroupNameToGroup.containsKey(product.Product_Groepering__c)) {
                ProductGroupWrapper pgw = new ProductGroupWrapper();
                pgw.name = product.Product_Groepering__c;
                pgw.products = new List<ProductWrapper>();
                
                productGroupNameToGroup.put(product.Product_Groepering__c, pgw);
                productGroups.add(pgw);
            }
            ProductGroupWrapper pgw = productGroupNameToGroup.get(product.Product_Groepering__c);
            pgw.products.add(pw);
        }
        
        // Clean up empty ones
        for (String groupName : productGroupNameToGroup.keySet()) {
            ProductGroupWrapper pgw = productGroupNameToGroup.get(groupName);
            if (pgw.products.isEmpty()) {
                for (Integer i = productGroups.size() - 1; i >= 0; i--) {
                    if (productGroups.get(i) == pgw) {
                        productGroups.remove(i);
                    }
                }
                productGroupNameToGroup.remove(groupName);
            }
        }
        
        return productGroups;
    }
    
    public PageReference saveQuote() {
        update quote;
        return null;
    }
    
    public PageReference updateProducts() {
        // From top to bottom
        List<QuoteLineItem> itemsToInsert = new List<QuoteLineItem>();
        for (ProductGroupWrapper pg : producten) {
            for (ProductWrapper w : pg.products) {
                if (w.amount != null && w.amount > 0) {
                    QuoteLineItem qli = new QuoteLineItem();
                    qli.QuoteId = quote.Id;
                    qli.PricebookEntryId = w.priceBookEntry.Id;
                    qli.Product2Id = w.product.id;
                    qli.Quantity = w.amount;
                    qli.UnitPrice = w.unitPrice;
                    qli.Price_Connect__c = w.Price_Connect;//w.priceBookEntry.Eenmalige_aansluitkosten__c;
                    qli.Price_Installation__c = w.Price_Installation;//w.priceBookEntry.Eenmalige_installatiekosten__c;
                    
                    if (w.product.aanpasbaar__c != null && w.product.aanpasbaar__c == true) {
                        qli.description = w.productName;
                    }
                    itemsToInsert.add(qli);
                }
            }
        }
        if (!itemsToInsert.isEmpty()) {
            insert itemsToInsert;
        }
        
        // Update bottom list
        List<QuoteLineItem> itemsToUpdate = new List<QuoteLineItem>();
        List<QuoteLineItem> itemsToDelete = new List<QuoteLineItem>();
        for (QuoteLineItem w : quoteItems) {
            if (w.quantity != null && w.quantity > 0) {
                itemsToUpdate.add(w);
                for (QuoteLineItem w2 : quoteItems) {
                    if (w2.gekoppeld_aan__c == w.id) {
                        w2.quantity = w.quantity;
//                      itemsToUpdate.add(w2);
                    }
                }
            } else {
                itemsToDelete.add(w);
                for (QuoteLineItem w2 : quoteItems) {
                    if (w2.gekoppeld_aan__c == w.id) {
                        itemsToDelete.add(w2);
                    }
                }
            }
        }
        if (!itemsToUpdate.isEmpty()) {
            // update, of als het handmatige items zijn insert
            upsert itemsToUpdate;
        }
        
        if (!itemsToDelete.isEmpty()) {
            // delete
            delete itemsToDelete;
        }
        
        queryProductLists();
        return null;
    }
    
    public PageReference addQuoteLineItem() {
/*      QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = quote.Id;
        qli.PricebookEntryId = w.priceBookEntry.Id;
        qli.Product2Id = w.product.id;
        qli.Quantity = w.amount;
        qli.UnitPrice = w.priceBookEntry.unitPrice;*/
        return null;
    }
    
    // TODO: checkbox:  heeft al een verbinding.
    public PageReference selectVerbinding() {
        Quote q2 = [select Pricebook2Id from Quote where id = :quote.id];
        /*System.assertNotEquals(null, verbinding);
        System.assertNotEquals(null, q2);
        System.assertNotEquals(null, q2.pricebook2id);*/
        
        // Als we te maken hebben met een bundel, dan hoeven we die niet toe te voegen
        // Die hebben ook geen pricebook entry. Als er wel een pricebook entry voor gemaakt is
        // Dan komt hij wel er op.
        // Het "Hoofdproduct" wordt dan gekozen op basis van het eerste subproduct. (volgorde)
        QuoteLineItem qli = null;
        if(verbinding == null){
            verbinding = new Product2();
        }
        List<PricebookEntry> pes = [Select id, UnitPrice, Eenmalige_aansluitkosten__c, Eenmalige_installatiekosten__c from PricebookEntry WHERE Product2Id = :verbinding.id and Pricebook2Id = :q2.Pricebook2Id ];
        if (!pes.isEmpty()) {
            // We hebben een prijs.
            PricebookEntry pe = pes.iterator().next();
        
            qli = new QuoteLineItem();
            // description
    //      qli.discount = null;
            qli.QuoteID = quote.id;
            qli.PricebookEntryId = pe.id;
            qli.Product2Id = verbinding.id;
            qli.Quantity = 1;
            qli.UnitPrice = pe.UnitPrice;
            qli.Price_Connect__c = pe.Eenmalige_aansluitkosten__c;
            qli.Price_Installation__c = pe.Eenmalige_installatiekosten__c;
            
            insert qli;
        }

        // Kijk of er een gekoppeld product aan zit.
        // En link deze erbij.
        for (ProductKoppeling__c koppeling : [Select id, gekoppeld_product__c 
                from ProductKoppeling__c WHERE hoofd_product__c = :verbinding.id order by volgorde__c ]) {
            
            
            // Query pricebook entries voor dit product.
            for (PricebookEntry pbe : [select id,
                UnitPrice, Eenmalige_aansluitkosten__c, Eenmalige_installatiekosten__c, Maandelijkse_kosten__c 
                from PricebookEntry where product2id = :koppeling.gekoppeld_product__c and pricebook2id = :q2.pricebook2id]) {
                QuoteLineItem qli2 = new QuoteLineItem();
                // description
        //      qli2.discount = null;

                qli2.QuoteId = quote.Id;
                qli2.PricebookEntryId = pbe.Id;
                qli2.Product2Id = koppeling.gekoppeld_product__c;
                qli2.Quantity = 1;
                qli2.UnitPrice = pbe.unitPrice;
                qli2.Price_Connect__c = pbe.Eenmalige_aansluitkosten__c;
                qli2.Price_Installation__c = pbe.Eenmalige_installatiekosten__c;
                
                if (qli != null) {
                    qli2.gekoppeld_aan__c = qli.id;
                }

                // Nu toevoegen aan
                insert qli2;
                // Eerste product wordt het hoofproduct.
                if (qli == null) {
                    qli = qli2;
                }
            }
        }
         
        
        //Price Book Entry, Sales Price
        
        
        quote.Heeft_Verbinding__c = false;
        update quote;
        
        //qli.UnitPrice
        // Voeg verbinding toe aan quote.
        // En update de huidige verbinding!

//        PageReference redirectPage = new PageReference('/' + quote.id);
//        redirectPage.setRedirect(true);
//        return redirectPage;
 
        queryProductLists();
        
        return null;
    }


    public PageReference saveQuoteAndProducts() {
        saveQuote();
        updateProducts();
        return null;
    }

    public static ID recordTypeId(Schema.DescribeSObjectResult o, String name) {
        RecordTypeinfo rt = o.getRecordTypeInfosByName().get(name);
        if (rt == null) {
            //throw new GuidionException('Kan RecordType ' + name + ' niet vinden voor ' + o.getName() + ': ' + o.getRecordTypeInfosByName());
        }
        return rt.getRecordTypeId();
    }

    public static ID verbindingRecordType() {
        return recordTypeId(Schema.Sobjecttype.Product2, 'Verbinding');
    }
}