global with sharing class z_SchedulableBatchableMetadataDump3 implements Schedulable {
  
   global void execute(SchedulableContext sc) {
      Id id = z_Util.executeBatchableMetadataDump3();
      // unregister z_BatchableMetadataDump3 here
      System.abortJob(sc.getTriggerId());
   }
   
}