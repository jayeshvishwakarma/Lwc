public class caseCloneController {
    
    @AuraEnabled
    public static case getCaseDetails(string recordId){ 
        list<case> caseRecord = [select Case_type__c,isClosed from case Where id=:recordId];
        if(caseRecord.size()>0){
            return caseRecord[0];
        }
        else{
            return null;
        }  
    }
    @AuraEnabled
    public static string insertCase(string recordId,string recordTypeDevName,String description){
        try{
            DescribeSObjectResult describeResult = Id.valueof(recordId).getSObjectType().getDescribe();      
            Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
            
            // Get all of the fields on the object
            set<String> fieldNames = fieldMap.keySet();
            list<String> fieldNamesList = new list<string>();
            fieldNamesList.addall(fieldNames) ;
            // Build a Dynamic Query String.
            list<case> caseRecord = Database.query('select ' + string.join(fieldNamesList, ',') + ' from case Where id=:recordId');
            if(caseRecord.size()>0){
                Case caseCloneCopy  = caseRecord[0].clone(false, true, false, false);
                caseCloneCopy.ParentId=recordId;
                caseCloneCopy.Description =description;
                caseCloneCopy.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
                caseCloneCopy.ClosedDate=null;
                caseCloneCopy.Status='Open';
                System.debug('caseCloneCopy '+caseCloneCopy);
                System.debug('ok '+caseCloneCopy);
                insert caseCloneCopy;
                return 'SUCCESS'+';'+caseCloneCopy.id;
            }
            else{
                return 'No Case Found';
            }
        }
        catch(exception e){
            return e.getMessage();
        }
    }
    
}