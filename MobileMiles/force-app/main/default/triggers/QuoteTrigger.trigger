/*
        Name            :    QuoteTrigger
        Author          :    Ranu Bari
        Date            :    01/23/2018
        Description     :    Used to perform action on Quote records
*/
trigger QuoteTrigger on Quote (before delete, after insert, after update) {
    List<Trigger_Settings__c> lstTriggerSettings = [SELECT Quote_Trigger__c From Trigger_Settings__c];
   
   if(lstTriggerSettings.size()>0 && lstTriggerSettings[0].Quote_Trigger__c){
    //To prevent ‘porteringen_mobiel__c’ records to be deleted when ‘IRMA_Id__c’ field is populated.
    if(Trigger.isDelete && Trigger.isBefore){
        QuoteTriggerHelper.deletePorteringMobiels(Trigger.old);
    }
    if(Trigger.isAfter){
        //To update Recordtype of Portering mobile based on quote record type by ranu 27th may 2019
        List<Quote> quoteRecordTypes = new List<Quote>();
        //List<Quote> porteergegevensQuotes = new List<Quote>();
        for(Quote quot : Trigger.new){
            if(quot.recordtypeID != null && Trigger.isUpdate && quot.recordtypeID != Trigger.oldMap.get(quot.id).recordtypeID){
                quoteRecordTypes.add(quot);
            }
            /*if(quot.Porteergegevens_ophalen__c == true && 
               (Trigger.isInsert || (Trigger.isUpdate && quot.Porteergegevens_ophalen__c != Trigger.oldMap.get(quot.id).Porteergegevens_ophalen__c))){
                porteergegevensQuotes.add(quot);
            }*/
        }
        if(quoteRecordTypes.size() > 0)
            QuoteTriggerHelper.updatePorteringRecordType(quoteRecordTypes);
            
        /*if(porteergegevensQuotes.size() > 0)
            QuoteTriggerHelper.updatePorteringPorteergegevens(porteergegevensQuotes);*/
    }
    }
}