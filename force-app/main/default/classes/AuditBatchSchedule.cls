global class AuditBatchSchedule implements Schedulable {
   global void execute(SchedulableContext SC) {
      AuditBatchClass abc = new AuditBatchClass(); 
       Database.executeBatch(abc, 200);
   }
}