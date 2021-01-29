public class OnholdCasesToOpenScheduler implements Schedulable {
   public void execute(SchedulableContext sc) {
      OnholdCasesToOpenBatch b = new OnholdCasesToOpenBatch();
      Database.executeBatch(b);
   }
}