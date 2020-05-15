trigger ContactTrigger_old on Contact (before insert, before update, after insert, after update) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        ContactTriggerHandler.handleBeforeInsert(trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        ContactTriggerHandler.handleBeforeUpdate(trigger.new, trigger.old);
    }
    
    
    if(Trigger.isAfter && Trigger.isInsert){}
    
    if(Trigger.isAfter && Trigger.isUpdate){}

}