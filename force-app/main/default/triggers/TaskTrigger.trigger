/**@@
#TRIGGER NAME          :    TaskTrigger
#HANDLER CLASS NAME    :    Trigger_Task_Handler
#HELPER CLASS NAME     :    Trigger_Task_Helper
#DESCRIPTION           :    This Trigger will handles all the trigger events and make call to the Handler class to handling the appropriate logic.   
@@**/
trigger TaskTrigger on Task (before insert, before update, before delete, after insert, after update, after delete) {

    if(trigger.isBefore){
        
    }
    else{
        if(trigger.isInsert){
            //Trigger_Task_Handler.afterInsertHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
        }
        else if(trigger.isUpdate){
            //Trigger_Task_Handler.afterUpdateHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
        }
        
    }//End of else
   
}//End of trigger