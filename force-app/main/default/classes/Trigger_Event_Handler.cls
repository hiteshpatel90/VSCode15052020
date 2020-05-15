/**@@
#TRIGGER NAME        :    EventTrigger
#HANDLER CLASS NAME  :    Trigger_Event_Handler
#HELPER CLASS NAME   :    Trigger_Event_Helper
#TEST CLASS          :    EventTriggerTest
#DESCRIPTION         :    This Handler class will handles all the trigger events and make call to the Helper class to handling the appropriate logic.   
@@**/
public class Trigger_Event_Handler{
    /**@@
        #DESCRIPTION   : After Insert Hanlder
        #Paramaters    : trigger.newList, trigger.newMap, trigger.oldList, trigger.oldMap
    @@**/    
    public static void afterInsertHandler(List<Event> newList){

        Trigger_Event_Helper.createEventinGoogleCalendar(newList);

    }//END OF AFTER INSERT HANDLER


}//END OF CLASS