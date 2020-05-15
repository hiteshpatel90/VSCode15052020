global with sharing class z_SchedulableBatchableMetadataDump2 implements Schedulable {
  
   global void execute(SchedulableContext sc) {
      Id id = z_Util.executeBatchableMetadataDump2(true);
      // unregister z_BatchableMetadataDump2 here
      System.abortJob(sc.getTriggerId());
   }
}