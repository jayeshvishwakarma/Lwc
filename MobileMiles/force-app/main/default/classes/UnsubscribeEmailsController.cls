public class UnsubscribeEmailsController {
@AuraEnabled   
    public static void turnOnOffFlag(string objectName, string fieldName, string recordId, boolean flag){
        system.debug('-' + objectName + '-'+fieldName +'-' + recordId);
        sObject record = Database.query('select id from ' + objectName + ' where id=:recordId');
        
        record.put(fieldName, flag);
        update record;
    }
}