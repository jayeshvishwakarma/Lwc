public with sharing class UtilityHelper {
    
    //public static   List<UserEvaluatorFlag__c > mcs3=UserEvaluatorFlag__c.getAll().values();
    public static  String fetch = 'fetch';
    public static  String updat = 'update';
    public static  String Inactive_Batch_Run = 'Inactive_Batch_Run';
    public static  String isInsert = 'isInsert';
    public static  Boolean isTriggerRun = true;

    public static dateTime retrievTimeCDC(){
    List<CDC_TimeSet__c> mcs=CDC_TimeSet__c.getAll().values();  
    return mcs[0].TimeSetUp__c;    
    }
    
    public  static boolean updateAndRetreiveEvalFlag(boolean flag,String mode,String flagName){
    List<UserEvaluatorFlag__c > mcs3=UserEvaluatorFlag__c.getAll().values();
    system.debug('mcs3 - 16 - '+mcs3);
    if(!mcs3.isEmpty())
    {
        if(mode=='Fetch'){
            if(flagName=='inactiveBatch')
                return mcs3[0].Inactive_Batch_Run__c;
            
            if(flagName=='Isinsert')
                return mcs3[0].isInsert__c;
        }
        
        if(mode=='update'){
            if(flagName=='inactiveBatch'){
                mcs3[0].Inactive_Batch_Run__c=flag;
                update mcs3[0];
                return mcs3[0].Inactive_Batch_Run__c;
            }
            
            if(flagName=='Isinsert'){
                mcs3[0].isInsert__c=flag;
                update mcs3[0];
                return mcs3[0].isInsert__c;
            }
        }
    }
    return false;
    
    }
    
    @future
    public static void updateEvalSetting(boolean flag,String flagName){
     List<UserEvaluatorFlag__c > mcs3=UserEvaluatorFlag__c.getAll().values();
     if(!mcs3.isEmpty())
     {
        if(flagName=='inactiveBatch'){
            mcs3[0].Inactive_Batch_Run__c=flag;
            update mcs3[0];
        }
        
        if(flagName=='Isinsert'){
            mcs3[0].isInsert__c=flag;
            update mcs3[0];
        }
    }    
   }
}