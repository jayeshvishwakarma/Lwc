trigger AutoNumbering on OpportunityLineItem (after update) {
    Set<ID> ids = new Set<ID>();
    Set<ID> oprIDs = new Set<ID>();
    Set<ID> acntIDs = new Set<ID>();
        
    for(OpportunityLineItem line:Trigger.new){
        if(Trigger.isUpdate && (line.Factuurnummer_MM__c ==null || line.Factuurnummer_MM__c =='' )){    
            if(trigger.oldMap.get(line.id).Status_bestelling_MobileMiles_product__c  !='Gefactureerd'  && trigger.newMap.get(line.id).Status_bestelling_MobileMiles_product__c=='Gefactureerd'){
                ids.add(line.id);
                oprIDs.add(line.OpportunityID);
            }
        }
    }
    
    if(ids <> null && ids.size()>0){
        Map<Id, Account> acntMap = new Map<Id, Account>();        
        List<Opportunity> opr = new List<Opportunity>();    
        opr = [Select id,AccountID from Opportunity where ID IN: oprIDs];
        for(Opportunity o:opr){
            acntIDs.add(o.AccountID);
        }
        
        List<OpportunityLineItem> oprLine = [Select id,Factuurnummer_MM__c,OpportunityID, Opportunity.AccountID, Opportunity.Account.Debiteurennummer_Mobile_Miles__c from OpportunityLineItem where id IN: ids];
        if(acntIDs.size()>0){
            acntMap = new Map<Id, Account>([Select id,Debiteurennummer_Mobile_Miles__c from Account where id IN:acntIDs]);
        }

        //AggregateResult maxFact = [Select max(Factuurnummer_MM__c) from OpportunityLineItem where ID != null];
        List<OpportunityLineItem> o = [Select Factuurnummer_MM__c from OpportunityLineItem  where Factuurnummer_MM__c !=null order by Factuurnummer_MM__c desc  limit 1];
        String maxFact='';
        if(o <>null && o.size()>0)
            maxFact = String.valueOf(o[0].Factuurnummer_MM__c);
            
        Integer i=0;
        Integer temp = -1;
        if(maxFact <>'' && maxFact <> null){
            try{
                //String t1=String.valueOf(maxFact.get('expr0'));
                String t1 = maxFact;
                if(t1 !=null && t1.length() >1){
                    t1 = t1.substring(1,t1.length());
                    temp =Integer.valueOf(t1); 
                }
                else
                    temp=1000188;
                
            }catch(Exception e){}
            if(temp >-1)
                i = temp+1;
        }
        else{
            i=1000189;
        }

        List<AggregateResult> maxAccount = [Select max(Debiteurennummer_Mobile_Miles__c) from Account where Debiteurennummer_Mobile_Miles__c != null];
        integer j = 10430;        
        if(maxAccount <> null && maxAccount.size()>0){
            String t1 = String.valueOf(maxAccount[0].get('expr0'));
            if(t1<>null){
                j = Integer.valueof(t1);
                j++;
            }
            else
                j = 10430;

        }
        
        
        List<OpportunityLineItem> updateLineItem = new List<OpportunityLineItem> ();    
        List<Account> updateAccount = new List<Account>();
     
        for(OpportunityLineItem it:oprLine){
            if(i>0){
                it.Factuurnummer_MM__c = 'F'+String.valueOf(i);
                updateLineItem.add(it);           
                if(acntMap <> null && acntMap.size()>0){
                    Account acnt = acntMap.get(it.opportunity.AccountID);
                    if(acnt.Debiteurennummer_Mobile_Miles__c == null){
                        acnt.Debiteurennummer_Mobile_Miles__c = String.valueOf(j);
                        updateAccount.add(acnt);
                    }
                }
                i++;
                j++;
            }
    
        }
        if(updateLineItem.size() > 0)
            update updateLineItem;
        if(updateAccount.size() > 0)
            update updateAccount;
        
    }
}