trigger ProductSummary on OpportunityLineItem (after update, after insert, before delete) {
     Map<Id,PricebookEntry> pricebookEntries;
     Set<OpportunityLineItem> oppLItems;
     list<OpportunityLineItem> subjects;
     list<Opportunity> opps;
     
     if (Trigger.isDelete){
        subjects = Trigger.old;
         
     }
     else{
        subjects = Trigger.new;
     }
     
     set<Id> opportunityIds  = new set<Id>();
     
     for (OpportunityLineItem  index : subjects){
        opportunityIds.add(index.OpportunityId);
     }
         
     pricebookEntries = new Map<Id, PricebookEntry>([ SELECT Id, Name FROM PricebookEntry WHERE Id IN (Select PricebookEntryId From OpportunityLineItem WHERE OpportunityId IN: opportunityIds)]);
     opps = new List<Opportunity>([SELECT Id, Products__c, (Select Quantity, Totale_prijs__c, Productfamilie__c, PricebookEntryId From OpportunityLineItems) FROM Opportunity WHERE Id IN: opportunityIds]);
     for (Opportunity o : opps){
        String productlines = '';


        for (OpportunityLineItem oli: o.OpportunityLineItems){
            LSM_Product_Family__c pf = LSM_Product_Family__c.getValues(oli.Productfamilie__c);
            if (pf != null && pf.Active__c){            
                    productlines += '"'+PricebookEntries.get(oli.PricebookEntryId).Name+'", ';
                    productlines += oli.Quantity+', ';
                    productlines += oli.Totale_prijs__c+'\n';
            }
        }
        o.Products__c = productlines;
     }
     update opps;
     
     /*Oude versie:
      for (OpportunityLineItem  index : subjects){
      Opportunity o = [SELECT Id, Products__c  FROM Opportunity WHERE Id in (SELECT OpportunityId FROM OpportunityLineItem WHERE Id = : index.id)];
      pricebookEntries = new Map<Id, PricebookEntry>([ SELECT Id, Name FROM PricebookEntry WHERE Id in (SELECT PricebookEntryId FROM OpportunityLineItem WHERE OpportunityId = : o.id )]);
      oppLItems = new Set<OpportunityLineItem>([ SELECT PricebookEntryId, Quantity, Totale_prijs__c, Productfamilie__c FROM OpportunityLineItem WHERE OpportunityId = :o.Id ]);
      String productlines = '';
      for (OpportunityLineItem oli : oppLItems){
        if (oli.Productfamilie__c  == 'Modules' ||
        oli.Productfamilie__c  == 'Nieuw Mobile Data' ||
        oli.Productfamilie__c  == 'Nieuw Mobile Voice' ||
        oli.Productfamilie__c  == 'Verlengen Mobile Data' ||
        oli.Productfamilie__c  == 'Verlengen Mobile Voice'){
            
            productlines += '"'+PricebookEntries.get(oli.PricebookEntryId).Name+'", ';
            productlines += oli.Quantity+', ';
            productlines += oli.Totale_prijs__c+'\n';
        }
        
      }
      o.Products__c = productlines;
      update o;
     }*/
}