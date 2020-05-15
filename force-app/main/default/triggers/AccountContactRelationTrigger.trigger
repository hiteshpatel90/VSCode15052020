trigger AccountContactRelationTrigger on AccountContactRelation (before insert, before update, before delete, after insert, after update, after delete, after undelete) {    
    if(trigger.isBefore){
        if(trigger.isInsert){
            system.assertEquals(1,2);
        }
    }
}