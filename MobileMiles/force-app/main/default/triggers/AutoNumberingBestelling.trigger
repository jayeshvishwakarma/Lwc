trigger AutoNumberingBestelling on Bestelling_MM__c (after insert, after update) {

    List<Trigger_Settings__c> lstTriggerSettings = [SELECT Bestelling_MM_Trigger__c From Trigger_Settings__c];
    if(lstTriggerSettings.size()>0 && lstTriggerSettings [0].Bestelling_MM_Trigger__c){
    Set<ID> ids = new Set<ID>();
    Set<ID> bIDs = new Set<ID>();
    Set<ID> acntIDs = new Set<ID>();
    Set<Id> bestellingIdSet = new Set<Id>();
        
    for(Bestelling_MM__c line:Trigger.new){
        if(Trigger.isUpdate && (line.Factuurnummer__c ==null || line.Factuurnummer__c =='' )){    
            if(trigger.oldMap.get(line.id).Status__c  !='Gefactureerd'  && trigger.newMap.get(line.id).Status__c=='Gefactureerd'){
                ids.add(line.id);
                bIDs.add(line.id);
            }
        }
        // Auto generate Pay.nl transaction id and update to Bestelling_MM__c.Paynl_Transaction_Id__c field 
        if(line.Paynl_Payment__c && (trigger.isInsert || (trigger.isUpdate && line.Paynl_Payment__c!=trigger.oldMap.get(line.id).Paynl_Payment__c))){
            bestellingIdSet.add(line.Id); 
        }
    }
    
    // Updating to Bestelling_MM__c.Paynl_Transaction_Id__c field from Pay.NL transaction id
    if(bestellingIdSet.size()>0){
        BestellingTriggerHelper.UpdatePayNLTransactionId(bestellingIdSet);    
    }
    
    if(ids <> null && ids.size()>0){
        Map<Id, Account> acntMap = new Map<Id, Account>();        
        List<Bestelling_MM__c> opr = new List<Bestelling_MM__c>();    
        opr = [Select id,Bedrijf__c from Bestelling_MM__c where ID IN: bIDs];
        for(Bestelling_MM__c o:opr){
            acntIDs.add(o.Bedrijf__c);
        }
        
        List<Bestelling_MM__c> oprLine = [Select id,Factuurnummer__c,Bedrijf__c from Bestelling_MM__c where id IN: ids];
        if(acntIDs.size()>0){
            acntMap = new Map<Id, Account>([Select id,Debiteurennummer_Mobile_Miles__c from Account where id IN:acntIDs]);
        }

        //AggregateResult maxFact = [Select max(Factuurnummer_MM__c) from OpportunityLineItem where ID != null];
        List<Bestelling_MM__c> o = [Select Factuurnummer__c from Bestelling_MM__c  where Factuurnummer__c !=null order by Factuurnummer__c desc  limit 1];
        String maxFact='';
        if(o <>null && o.size()>0)
            maxFact = String.valueOf(o[0].Factuurnummer__c);
            
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
        
        
        List<Bestelling_MM__c> updateLineItem = new List<Bestelling_MM__c> ();    
        List<Account> updateAccount = new List<Account>();
     
        for(Bestelling_MM__c it:oprLine){
            if(i>0){
                it.Factuurnummer__c = 'F'+String.valueOf(i);
                updateLineItem.add(it);           
                if(acntMap <> null && acntMap.size()>0){
                    System.debug('The acnt map is'+acntMap);
                    System.debug('the value to put in map is'+it.Bedrijf__c);
                    Account acnt = acntMap.get(it.Bedrijf__c);
                    System.debug('the acnt map get is'+acntMap.get(it.Bedrijf__c));
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
}