public class MCallTriggerHandler extends TriggerHandler {

    private Map<Id, MCall_Event__c> newMCallMap;
    private List<MCall_Event__c> newMCallList;
    private Map<Id,MCall_Event__c> oldCallMap;

  //constructor
    public MCallTriggerHandler() {
        this.newMCallMap      = (Map<Id, MCall_Event__c>) Trigger.newMap;
        this.newMCallList     = (list<MCall_Event__c>) Trigger.New;
        this.oldCallMap       = (Map<Id,MCall_Event__c>) Trigger.oldMap;
    }
    
    public override void afterInsert(){
        updateCaseWithEVentTrigger();
    }
    
    public void updateCaseWithEVentTrigger(){
        
       map<id,MCall_Event__c> caseToMCallMap = new map<id,MCall_Event__c>(); //Variable used to store the mCall to case Id mappings.
       list<Case> MOSCases = new list<Case>(); //List to be updated.
       
        
       for(MCall_Event__c mCall :newMCallList){
           //iterate throught list
           
           if((!(caseToMCallMap.containsKey(mCall.Case__c))) && 
               (string.isNotEmpty(mCall.Event_Trigger_Info__c))){
               caseToMCallMap.put(mCall.Case__c,mCall);
           }
       }    
        
        //Iterate through the map and update the case
       if(caseToMCallMap.KeySet().size() > 0){
           for(Id caseID :caseToMCallMap.KeySet()){
               MOSCases.add(new Case(id = caseID, Event_Trigger_Info__c = caseToMCallMap.get(CaseID).Event_Trigger_Info__c));
           } 
           
           update MOSCases;
       }
           
    }
    
}