/**
    * @Autho:- Nishant Prajapati
    * @Company-: Techmatrix Consulting
    * @Description-: scheduled to run only once at that particular time.
    * =============================================================
    * Version   Date            Author      Modification
    * =============================================================
    * 1.0       01 Oct 2019    Nishant     Intial Version
   **/
public class ScheduleApexJob{
     /**
        Author: Nishant Prajapati
        Company: Techmatrix
        Description: method to schedule APEX class only once at particular time  
        Inputs: string(1), decimal(1)
        Returns: void
        ====================================================
        1.0     01 OCT 2019  NISHANT  Initial Version
    **/
    
    public static void findBatchApex(string batchClassName, string scheduleClassName, integer minutes){
        try{
            //query Async job
            if(String.isNotBlank(batchClassName)){
                    Integer jobInfo= [SELECT count() FROM AsyncApexJob WHERE  ApexClass.Name =: scheduleClassName AND JobType= 'ScheduledApex' AND
                                      Status IN: System.Label.Batch_APEX_Status.split(',')];
                
                if(jobInfo == 0){
                    String hour= String.valueOf(Datetime.now().hour());
                    String min = String.valueOf(Datetime.now().minute()+ minutes); 
                    String ss = String.valueOf(Datetime.now().second());
                    String dom= String.valueOf(Datetime.now().day());
                    String month= String.valueOf(Datetime.now().month());
                    String year= String.valueOf(Datetime.now().year());
                    //parse to cron expression
                    String nextFireTime = ss + ' ' + min + ' ' + hour + ' '+ dom + ' '+ month +' '+'?'+' '+year;
                    
                    Type class2Schedule= Type.forName(scheduleClassName);
                    String jobID= System.schedule(batchClassName+'_'+String.valueOf(Datetime.now()), nextFireTime, (Schedulable)class2Schedule.newInstance());
                }
        }
        
        }catch(Exception ex){
            system.debug('error>>>'+ex.getMessage());
            
        }
        
    }
}