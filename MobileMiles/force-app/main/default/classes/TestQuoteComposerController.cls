@isTest
private class TestQuoteComposerController {
    static testMethod void testVerbinding() {
        // TODO: voice only + glasvezel product
        // Update amounts
        // 1 met productkoppeling
        //ID verbindingRT = QuoteComposerController.verbindingRecordType();
        ID verbindingRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Verbinding').getRecordTypeId();
        
        Product2 verbinding1 = new Product2(name='verbinding1', aantal_kanalen__c=8, recordtypeid=verbindingRT, isactive=true,
                            Family = 'Verbindingen', Voice_Internet__c = 'Voice + Internet',
                            SLA_Level__c = 'Standaard',
                            verbinding__c = 'verbindingpicklist1',
                            EVC__c = 'Geen EVC'
                            //,Router__c = 'ZyXel SBG3300-N000'
        );
        insert verbinding1;
        
        Product2 verbinding2 = new Product2(name='verbinding1', aantal_kanalen__c=8, recordtypeid=verbindingRT, isactive=true,
                            Family = 'Verbindingen', Voice_Internet__c = 'Voice Only',
                            SLA_Level__c = 'Standaard',
                            verbinding__c = 'verbindingpicklist1',
                            EVC__c = 'Geen EVC'
                            //,Router__c = 'ZyXel SBG3300-N000'
        );
        insert verbinding2;
        
        Product2 verbinding3 = new Product2(name='verbinding1', aantal_kanalen__c=8, recordtypeid=verbindingRT, isactive=true,
                            Family = 'Verbindingen', Voice_Internet__c = 'Glasvezel',
                            SLA_Level__c = 'Standaard',
                            verbinding__c = 'verbindingpicklist1',
                            EVC__c = 'Geen EVC',
                            //Router__c = 'ZyXel SBG3300-N000',
                            Gebiedskeuze__c = 'FTTO'
        );
        insert verbinding3;
        
        PriceBookEntry pbe1 = new PriceBookEntry(product2id=verbinding1.id, unitprice=10, isactive=true, pricebook2id=Test.getStandardPricebookId());
        insert pbe1;
        
        Account account = new Account(name='test account');
        insert account;
        
        Opportunity opp = new Opportunity(name='Opp1', accountid=account.id, StageName='WON', CloseDate=Date.today());
        insert opp;
        
        Quote quote = new Quote(name='quote1 opp1', opportunityId=opp.id,Looptijd__c = '1 jaar',heeft_verbinding__c = true);
        quote.Pricebook2Id = Test.getStandardPricebookId();
        insert quote;
        
        QuoteLineItem qutlineitemtest = new QuoteLineItem ();
        qutlineitemtest = new QuoteLineItem(QuoteId = quote.id , Quantity = 3.00,UnitPrice = 12 , PricebookEntryId = pbe1.id);
        
        QuoteComposerController controller = new QuoteComposerController( new Apexpages.Standardcontroller( quote ) );
        
        Apexpages.currentPage().getParameters().put('newStep','1');
        controller.Gebiedskeuze = 'FTTO';
        controller.kanalen = 8;
        controller.init();
        controller.voiceInternet = 'Voice Only';
        controller.getVerbindingPicklistSelectOptions();
        controller.rerenderSelects();
        controller.voiceInternet = 'Glasvezel';
        controller.rerenderSelects();
        controller.voiceInternet = 'Voice + Internet';
        controller.rerenderSelects();
        System.assertEquals(1, controller.getSLASelectOptions().size(), 'Geen SLA opties: ' + controller.getSLASelectOptions());

        controller.sla = 'Standaard';
        controller.rerenderSelects();
        System.assertEquals(1, controller.getVerbindingPicklistSelectOptions().size(), 'Geen verbinding picklist opties: ' + controller.getVerbindingPicklistSelectOptions());

        controller.verbindingPicklist = 'verbindingpicklist1';
        controller.rerenderSelects();
        System.assertEquals(1, controller.getEVCSelectOptions().size(), 'Geen EVC: ' + controller.getEVCSelectOptions());

        controller.evc = 'evc1';
        controller.rerenderSelects();
        //System.assertEquals(1, controller.getRouterSelectOptions().size(), 'Geen Router opties: ' + controller.getRouterSelectOptions());

        controller.router = 'router1';
        controller.rerenderSelects();
        //System.assertEquals(1, controller.verbindingenSelectOptions.size(), 'Verbinding niet gevonden.');
        //System.assertEquals(verbinding1.id, controller.verbindingenSelectOptions.iterator().next().getValue(), 'Verbindingkeuze niet als opgegeven');
        controller.verbindingId = verbinding1.id;
        
        controller.rerenderSelects();
        //System.assertNotEquals(null, controller.verbinding, 'Geen verbinding gekozen');

        controller.selectVerbinding();
        controller.getOptionalBooleanSelectOptions();
        controller.getRouterSelectOptions(); 
        controller.getGebiedsKeuzeSelectOptions();
        controller.saveQuote();
        controller.updateProducts();
        controller.addQuoteLineItem();
        controller.saveQuoteAndProducts();
        controller.wizardStepClicked();
        List<QuoteLineItem> quoteItems = [select id from QuoteLineItem where quoteId = :quote.id];
        //System.assertNotEquals(0, quoteItems.size(), 'Product is toch niet toegevoegd');

        QuotePDFController pdfController = new QuotePDFController( new Apexpages.Standardcontroller( quote ) );
        QuotePDFController.QuoteLineItemWrapper pdfQuoteRec = new QuotePDFController.QuoteLineItemWrapper();
        QuotePDFController.PriceGroup pdfPriceGroupRec = new QuotePDFController.PriceGroup();
        
        pdfQuoteRec.qli = qutlineitemtest; 
        pdfQuoteRec.getPriceTotal();
        pdfQuoteRec.getPricePerMonth();
        pdfQuoteRec.getPriceTotalOneTime();
        pdfQuoteRec.getPriceOneTime();
        pdfPriceGroupRec.addItem(qutlineitemtest);
        pdfPriceGroupRec.getTotalMonthly();
        pdfPriceGroupRec.getTotalSetup();
        pdfPriceGroupRec.getTotalInstallation();
        QuotePDFController.nullToZero(1.0);
        pdfController.getTotalCostOverDuration();
        pdfController.getTotalCostOverDurationPerMonth();
        KoopovereenkomstPDFController contactController = new KoopovereenkomstPDFController( new Apexpages.Standardcontroller( quote ) );
        contactController.getFieldsForController();
        KoopovereenkomstPDFController.PriceGroup koopPriceGroupRec = new KoopovereenkomstPDFController.PriceGroup();
        list<QuoteLineItem> TestItemsLst = new list<QuoteLineItem>();    
        TestItemsLst.add(qutlineitemtest);
        koopPriceGroupRec.items = TestItemsLst;
        //koopPriceGroupRec.getTotalInstallation(); 
        //koopPriceGroupRec.getTotalSetup();
        //koopPriceGroupRec.getTotalMonthly();
        list<sobject> testObjectLst = new list<sobject>();
        testObjectLst.add((sobject)account);
        Utils.getOne(testObjectLst);
        try{
            testObjectLst.clear();
            Utils.getOne(testObjectLst);        
        }catch(Exception e){}
        try{
            testObjectLst.clear();
            testObjectLst.add((sobject)account);
            testObjectLst.add((sobject)quote);
            Utils.getOne(testObjectLst);        
        }catch(Exception e){}
        try{
            testObjectLst.clear();
            testObjectLst.add((sobject)account);
            testObjectLst.add((sobject)quote);
            Utils.getOneOrNull(testObjectLst,'Test');        
        }catch(Exception e){}
        
        WizardComponent wizardRec = new WizardComponent();
        WizardComponent.Step wizardStepRec = new WizardComponent.Step(2,'Test','Test');
        wizardRec.current = wizardStepRec; 
        list<WizardComponent.Step> testStep = new list<WizardComponent.Step>();
        testStep.add(wizardStepRec);
        wizardRec.steps = testStep;  
        wizardRec.getCurrentstep();
        wizardRec.Next();
        wizardRec.Prev();
        wizardRec.newStep = 1;
        wizardRec.wizardStepClicked();
    }
}