trigger CaseTrigger on Case (before insert, after insert) {
    CaseTriggerHandler objCTHandler = new CaseTriggerHandler();
    objCTHandler.execute(Trigger.oldMap, Trigger.new);
}