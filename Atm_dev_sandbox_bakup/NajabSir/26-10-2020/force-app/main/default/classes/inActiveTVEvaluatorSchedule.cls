public without sharing class inActiveTVEvaluatorSchedule implements Schedulable{
    
    public void execute(SchedulableContext sc) {
        inActiveTVEvaluator b = new  inActiveTVEvaluator(); 
        string jobId= database.executebatch(b);
        system.debug('job id'+ jobId);
    }
}