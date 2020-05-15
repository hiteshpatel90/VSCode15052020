/**@@
#TRIGGER NAME          :    EventTrigger
#HANDLER CLASS NAME    :    Trigger_Event_Handler
#HELPER CLASS NAME     :    Trigger_Event_Helper
#DESCRIPTION           :    This Trigger will handles all the trigger events and make call to the Handler class to handling the appropriate logic.   
@@**/
trigger EventTrigger on Event (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
        if(trigger.isBefore){
           
        }
        else{
            if(trigger.isInsert){
                Trigger_Event_Handler.afterInsertHandler(trigger.new);
            }
            else if(trigger.isUpdate){

            }
            
        }//End of else
   
}//End of trigger