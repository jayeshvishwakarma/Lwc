public without sharing class inActiveTVEvaluatorSchedule implements Schedulable{
   
    public set<String> uIds;
    public boolean isInsert = true;
    public void execute(SchedulableContext sc) {
        system.debug(uIds);
        boolean isInactiveBatch=UtilityHelper.updateAndRetreiveEvalFlag(true,'update','inactiveBatch');
        inActiveTVEvaluator b = new  inActiveTVEvaluator(uIds,isInsert); 
        string jobId= database.executebatch(b);
    }
    
    public inActiveTVEvaluatorSchedule (set<String> userIds) {
        if ( userIds != null && uIds == null) {
            uIds = userIds;
        } 
    }
    
}