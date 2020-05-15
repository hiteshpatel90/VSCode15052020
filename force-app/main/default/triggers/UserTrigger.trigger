trigger UserTrigger on User (after insert, after update) {
    
    UserTriggerHandler handler = new UserTriggerHandler();
    
    if(trigger.isAfter && trigger.isInsert){
        
        handler.onAfterInsert(trigger.new);
        
    }else if(trigger.isAfter && trigger.isUpdate){
        
        handler.onAfterInsert(trigger.new, trigger.oldMap);
        
    }

}