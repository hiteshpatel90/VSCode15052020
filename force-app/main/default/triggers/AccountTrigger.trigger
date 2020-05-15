trigger AccountTrigger on Account (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    AccountTriggerHandler handler = new AccountTriggerHandler();
    if(trigger.isInsert && trigger.isBefore){    
        handler.onBeforeInsert(trigger.new);
        
           
    }else if (trigger.isUpdate && trigger.isBefore){    
        handler.onBeforeUpdate(trigger.new, trigger.oldMap);    
    }else if (trigger.isInsert && trigger.isAfter){    
        handler.onAfterInsert(trigger.new);    
    }else if (trigger.isUpdate && trigger.isAfter){    
        handler.onAfterUpdate(trigger.new, trigger.oldMap);    
    }
    
    set<Id> sUserId = new set<Id>();
    for(Account acc: trigger.new){
        sUserId.add(acc.ownerId);
    }
    List<User> l = [SELECT id from user where id in: sUserId];
    //List<User> lstUser = [SELECT id from User whre id in: sUserId];
    for(User u: l){
        u.of_Diamond_Accounts__c = 100;
    }
    update l;
    /*else if(trigger.isDelete && trigger.isBefore){
    
    handler.onBeforeDelete(trigger.old);
    
    }else if(trigger.isUnDelete & trigger.isAfter){
    
    handler.onBeforeDelete(trigger.old);
    
    }*/
}