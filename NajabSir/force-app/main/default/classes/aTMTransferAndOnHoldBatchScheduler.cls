/**
     * @File Name          : mcCommunicationSchedular.cls
     * @Description        : Update the Status when the Type is Bulk Hold Un Hold & Transfer Escalations and Escalation Date time is Today  . 
     * @Author             : Mohd Zakir 
     * @Last Modified By   : Mohd Zakir 
     * @Last Modified On   : 13-10-2020
     * @Modification Log   :
     *==============================================================================
    * Ver         Date                     Author                    Modification
    *==============================================================================
    * 1.0        13-10-2020                Zakir               Initial Version
**/
global class aTMTransferAndOnHoldBatchScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      aTMTransferAndOnHoldReminderBatch b = new aTMTransferAndOnHoldReminderBatch();
      Database.executeBatch(b);
   }
}