/****************************************************************************
* Type               : Apex Class
* Name               : LiveChatTranscriptTriggerHandler 
* Created by         : 
* Created Date       : 1st Nov 2016
* Last Modified By   : 
* Purpose            : This is handler class for LiveChatTranscriptTrigger Trigger
****************************************************************************/
public class LiveChatTranscriptTriggerHandler {
    public static void lctTriggerHandlerMethod(LiveChatTranscript[] LiveChatTranscriptNew) {
        LiveChatTranscriptTriggerHelper helper = new LiveChatTranscriptTriggerHelper();
        helper.scrubCreditCardInformation(LiveChatTranscriptNew);
    }
}