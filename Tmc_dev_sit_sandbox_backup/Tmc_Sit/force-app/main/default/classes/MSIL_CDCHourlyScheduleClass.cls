/**
* @File Name          : ScheduleClass.cls
* @Description        : This utility class is to schedule the class
* @Author             : Satish Kumar
* @Group              : Maruti
* @Last Modified By   : 
* @Last Modified On   : 
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================

*/ 

public class MSIL_CDCHourlyScheduleClass implements Schedulable{
    public static String CRON_EXP='0 59 * * * ?';
    public  void execute(SchedulableContext ctx) {
        DateTime customTime=UtilityHelper.retrievTimeCDC();    
        DateTime newCustomTime = customTime.addHours(24);
        //CronTrigger cronj=[SELECT  id,CronJobDetail.Name,TimesTriggered,PreviousFireTime,CronExpression FROM CronTrigger where CronJobDetail.Name='CDCAlert' limit 1];
        List<CronTrigger> cron =[SELECT  id,CronJobDetail.Name,TimesTriggered,PreviousFireTime,CronExpression FROM CronTrigger where CronJobDetail.Name='CDCAlert'];        
            if(cron.size() > 0)
            {
                DateTime schedularTime=cron[0].PreviousFireTime;
                System.debug('Scheduled:== 23'+ customTime + '' + schedularTime + '' + newCustomTime);
                if(customTime<schedularTime  && schedularTime<newCustomTime){
                    System.debug('Scheduled:== 23'+ customTime + '' + schedularTime + '' + newCustomTime);
                    MSIL_CdcCountOverMail.getCDCData(customTime);
                    System.debug('Scheduled:== 23'+ customTime + '' + schedularTime + '' + newCustomTime);        
                } 
            } 
       } 
   }