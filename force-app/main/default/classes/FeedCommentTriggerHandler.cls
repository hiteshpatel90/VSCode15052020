///////////////////////////////////////////////////////////////////
//Name                   : FeedCommentTriggerHandler
//Created by             : Serge Kandukuri
//Created date           : 06/02/2017
//Description            : This is handler class to handle all events of Feed comment trigger
/////////////////////////////////////////////////////////////////////
public class FeedCommentTriggerHandler {
    /* 
    #Description: This method is used to send email on chatter comment
    #Parameters: trigger.new
    */
    public static void handleAfterInsert(List<FeedComment> newFeedCommentList) {
        if(FeedCommentTriggerHelper.isCommentPosted == false){
            FeedCommentTriggerHelper.isCommentPosted = true;
            system.debug('########################');
            FeedCommentTriggerHelper.sendEmailonChatterComment(newFeedCommentList);
        }
    }

}