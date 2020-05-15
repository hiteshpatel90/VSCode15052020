global with sharing class z_SchedulableBatchableMetadataDump1 implements Schedulable {

    global void execute(SchedulableContext sc) {
        z_Util.executeBatchableMetadataDump1(true);
   }
}