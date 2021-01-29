global without sharing class twod_GenericForceCntrl {
    
    public static List<DMLOutputLockWrapper> UpdateForceSObjects( List<SObject> inputSObjectList){
        List<DMLOutputLockWrapper> wrapDMLObjList = new List<DMLOutputLockWrapper>();
        
        
        Map<Id, SObject> sObjMap = new Map<Id, SObject>();
        Set<Id> idSet = new Set<Id>();
        List<Id> lockedIdList= new List<Id>();
        Map<Id,DMLOutputLockWrapper> idMapper=new Map<Id,DMLOutputLockWrapper>();
        List<Id> inputIdList=new List<Id>();
       
        // get input sObjects Ids into a seperate list
        for(SObject obj:inputSObjectList){
           inputIdList.add(obj.Id); 
        }
        
        Boolean success = TRUE;
        Id sObjID = null  ;
        
        Map<Id,Boolean> lockedstatusMap=Approval.isLocked(inputIdList);
        
        system.debug('lockedMap');
        system.debug(lockedstatusMap);
        
        // get all locked status true Ids
        for(Id inputId : inputIdList){
            if(lockedstatusMap.get(inputId)){
                lockedIdList.add(inputId);
            }
        }
        
        // unlock all locked records
        Approval.unlock(lockedIdList);
        
        // do update operation
        Database.SaveResult[] srList = Database.update(inputSObjectList, false);
        
        // save the result to wrapper
        for(Database.SaveResult sr : srList){
            
            DMLOutputLockWrapper wrapDMLObj = new DMLOutputLockWrapper();
            List<String> errorCodeList = new List<String>();
            success = TRUE;
            if(sr.isSuccess()){
                sObjID = sr.getId();
                idSet.add(sObjID );
            }
            else{
                success = FALSE;
                sObjID = null;
                for(Database.Error err : sr.getErrors()){
                    errorCodeList.add(err.getMessage());
                }
            }
            
            wrapDMLObj.sObjID = sObjID;
            wrapDMLObj.success = success;
            wrapDMLObj.errorCodeList =errorCodeList;
            idMapper.put(wrapDMLObj.sObjID, wrapDMLObj);
            wrapDMLObjList.add(wrapDMLObj);
        }
        
        // again lock the unlocked records
        List<Approval.LockResult> lockResultList = Approval.lock(lockedIdList);
        
        return wrapDMLObjList;
    }
    
    public class DMLOutputLockWrapper{
        
        @AuraEnabled
        public Id sObjID;
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public List<String> errorCodeList ;
        @AuraEnabled
        public sObject record ;
        
    }
}