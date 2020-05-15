/****************************************************************************
* Type               : Apex Trigger
* Name               : LiveChatTranscriptTrigger 
* Created by         : 
* Created Date       : 1st Nov 2016
* Last Modified By   : 
* Purpose            : This trigger is used for scrubbing of credit card information
****************************************************************************/
trigger LiveChatTranscriptTrigger on LiveChatTranscript (before insert, before update) {
    // call Trigger Handler controller method
    LiveChatTranscriptTriggerHandler.lctTriggerHandlerMethod(trigger.new);
}