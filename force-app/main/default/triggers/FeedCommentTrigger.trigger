///////////////////////////////////////////////////////////////////
//Name                   : FeedCommentTrigger
//Created by             : Serge Kandukuri
//Created date           : 06/02/2017
//Description            : This trigger will handles all the trigger events and make call to the Hanlder class
//Handler Class          : FeedCommentTriggerHandler
//Helper Class           : FeedItemTriggerHelper
/////////////////////////////////////////////////////////////////////
trigger FeedCommentTrigger on FeedComment (after insert) {
    if(trigger.isAfter){
        if(trigger.isInsert){
            FeedCommentTriggerHandler.handleAfterInsert(Trigger.new);
        }
    }
}