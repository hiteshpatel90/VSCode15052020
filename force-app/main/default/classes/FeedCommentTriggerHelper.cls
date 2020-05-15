///////////////////////////////////////////////////////////////////
//Name                   : FeedCommentTriggerHelper
//Created by             : 
//Created date           : 06/02/2017
//Description            : This is helper class to handle logic of Feed comment trigger
/////////////////////////////////////////////////////////////////////
public class FeedCommentTriggerHelper {
    public static boolean isCommentPosted = false;
    /* 
    #Description: This method is used to send email on chatter comment
    #Parameters: trigger.new
    */
    public static void sendEmailonChatterComment(List<FeedComment> newFeedCommentList) {
        set<Id> sCommentId = new set<Id>();
        for(FeedComment fi: newFeedCommentList){
            sCommentId.add(fi.id);
        }
        mentionGroupinComment(sCommentId);
        
        
        
        /*set<Id> sCommnetId = new set<Id>();
        set<Id> sUpdateCommnetId = new set<Id>();
        
        isCommentPosted = true;
        
        string[] sendingTo = new string[]{};
        set<Id> sGroupId = new set<Id>();
        for(FeedComment fi: newFeedCommentList){
            sGroupId.add(fi.ParentId);
        }
        List<CollaborationGroupMember> lstCollaborationGroupMember = [SELECT id, MemberId, Member.Email from CollaborationGroupMember where CollaborationGroupId IN: sGroupId];
        
        for(FeedComment fi: newFeedCommentList){
                            
            // -- ---------- 1 to 25 -------- START ---------------->
            ConnectApi.CommentInput commentInput = new ConnectApi.CommentInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            
            if(fi.commentBody.contains('@')){
                string[] arrCommentBody = fi.commentBody.split('@');
                textSegmentInput.text = arrCommentBody[0];
            }else{
                textSegmentInput.text = fi.commentBody;
            }
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            for(integer i=0; i < lstCollaborationGroupMember.size(); i++){
                if(i > 24){
                    break;
                }                                    
                ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                mentionSegmentInput.id = lstCollaborationGroupMember[i].MemberId;                    
                messageBodyInput.messageSegments.add(mentionSegmentInput);                    
                commentInput.body = messageBodyInput;
            }
            
            ConnectApi.Comment editedComment = ConnectApi.ChatterFeeds.updateComment(null, fi.id, commentInput);
            //sUpdateCommnetId.add(editedComment.id);
            //------------ 1 to 25 -------- END ---------------->
            //------------ 25 to 50 -------- START ---------------->
            ConnectApi.CommentInput commentInputnew = new ConnectApi.CommentInput();
            if(lstCollaborationGroupMember.size() > 25){
            
                ConnectApi.TextSegmentInput textSegmentInputNew = new ConnectApi.TextSegmentInput();
                ConnectApi.MessageBodyInput messageBodyInputNew = new ConnectApi.MessageBodyInput();
                messageBodyInputNew.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                
                //textSegmentInputNew.text = fi.commentBody;
                if(fi.commentBody.contains('@')){
                    string[] arrCommentBody = fi.commentBody.split('@');
                    textSegmentInputNew.text = arrCommentBody[0];
                }else{
                    textSegmentInputNew.text = ' ';
                }
                messageBodyInputNew.messageSegments.add(textSegmentInputNew);
            
            
                for(integer i=25; i < lstCollaborationGroupMember.size(); i++){
                    if(i > 49){
                        break;
                    }                                    
                    ConnectApi.MentionSegmentInput mentionSegmentInputNew = new ConnectApi.MentionSegmentInput();
                    mentionSegmentInputNew.id = lstCollaborationGroupMember[i].MemberId;                    
                    messageBodyInputNew.messageSegments.add(mentionSegmentInputNew);                    
                    commentInputnew.body = messageBodyInputNew;
                }
            
                ConnectApi.Comment commentRep = ConnectApi.ChatterFeeds.postCommentToFeedElement(null, fi.feedItemid, commentInputnew, null);
                //sCommnetId.add(commentRep.id);
            }
            
            //------------ 25 to 50 -------- END ---------------->
            
            //------------ 50 to 75 -------- START ---------------->
            ConnectApi.CommentInput commentInputnew75 = new ConnectApi.CommentInput();
            if(lstCollaborationGroupMember.size() > 25){
            
                ConnectApi.TextSegmentInput textSegmentInputNew75 = new ConnectApi.TextSegmentInput();
                ConnectApi.MessageBodyInput messageBodyInputNew75 = new ConnectApi.MessageBodyInput();
                messageBodyInputNew75.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                
                //textSegmentInputNew75.text = fi.commentBody;
                if(fi.commentBody.contains('@')){
                    string[] arrCommentBody = fi.commentBody.split('@');
                    textSegmentInputNew75.text = arrCommentBody[0];
                }else{
                    textSegmentInputNew75.text = ' ';
                }
                messageBodyInputNew75.messageSegments.add(textSegmentInputNew75);
            
            
                for(integer i=50; i < lstCollaborationGroupMember.size(); i++){
                    if(i > 74){
                        break;
                    }                                    
                    ConnectApi.MentionSegmentInput mentionSegmentInputNew75 = new ConnectApi.MentionSegmentInput();
                    mentionSegmentInputNew75.id = lstCollaborationGroupMember[i].MemberId;                    
                    messageBodyInputNew75.messageSegments.add(mentionSegmentInputNew75);                    
                    commentInputnew75.body = messageBodyInputNew75;
                }
            
                ConnectApi.Comment commentRep = ConnectApi.ChatterFeeds.postCommentToFeedElement(null, fi.feedItemid, commentInputnew75, null);
                sCommnetId.add(commentRep.id);
            }         
            //------------ 50 to 75 -------- END ---------------->
            
            //------------ 76 to 100 -------- START ---------------->
            ConnectApi.CommentInput commentInputnew100 = new ConnectApi.CommentInput();
            if(lstCollaborationGroupMember.size() > 25){
            
                ConnectApi.TextSegmentInput textSegmentInputNew100 = new ConnectApi.TextSegmentInput();
                ConnectApi.MessageBodyInput messageBodyInputNew100 = new ConnectApi.MessageBodyInput();
                messageBodyInputNew100.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                
                //textSegmentInputNew100.text = fi.commentBody;
                if(fi.commentBody.contains('@')){
                    string[] arrCommentBody = fi.commentBody.split('@');
                    textSegmentInputNew100.text = arrCommentBody[0];
                }else{
                    textSegmentInputNew100.text = ' ';
                }
                
                messageBodyInputNew100.messageSegments.add(textSegmentInputNew100);
                            
                for(integer i=75; i < lstCollaborationGroupMember.size(); i++){
                    if(i > 100){
                        break;
                    }
                    ConnectApi.MentionSegmentInput mentionSegmentInputNew100 = new ConnectApi.MentionSegmentInput();
                    mentionSegmentInputNew100.id = lstCollaborationGroupMember[i].MemberId;
                    messageBodyInputNew100.messageSegments.add(mentionSegmentInputNew100);
                    commentInputnew100.body = messageBodyInputNew100;
                }
            
                ConnectApi.Comment commentRep = ConnectApi.ChatterFeeds.postCommentToFeedElement(null, fi.feedItemid, commentInputnew100, null);
                sCommnetId.add(commentRep.id);
            }                
            //------------ 76 to 100 -------- END ---------------->
            
        }
        
        if(!sCommnetId.isEmpty()){
            deleteFeedComments(sCommnetId);
        }    
        if(!sUpdateCommnetId.isEmpty()){
            removeMentionfromFeedComments(sUpdateCommnetId);
        }*/
    }
    
    /*@future
    public static void deleteFeedComments(set<Id> sCommnetId){
        List<FeedComment> lstFeedCommentDel = [SELECT id FROM FeedComment where id in: sCommnetId];
        delete lstFeedCommentDel;
    }
    
    @future
    public static void removeMentionfromFeedComments(set<Id> sUpdateCommnetId){
        List<FeedComment> lstFeedCommentUpdate = [SELECT id, commentBody FROM FeedComment where id in: sUpdateCommnetId];
        if(!lstFeedCommentUpdate.isEmpty()){
            for(FeedComment fc: lstFeedCommentUpdate){
                if(fc.commentBody.contains('@')){
                    string[] arrCommentBody = fc.commentBody.split('@');
                    fc.commentBody = arrCommentBody[0];
                }
            }
            update lstFeedCommentUpdate;
        }
    }*/
    
    @future
    public static void mentionGroupinComment(set<Id> sCommnetId){
        List<FeedComment> newFeedCommentList = [select id, ParentId, CommentBody from FeedComment where id in: sCommnetId];

        for(FeedComment fi: newFeedCommentList){
            ConnectApi.CommentInput commentInput = new ConnectApi.CommentInput();
            
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            textSegmentInput.text = fi.commentBody;
            
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            
            mentionSegmentInput.id = fi.ParentId;                    
            messageBodyInput.messageSegments.add(mentionSegmentInput);                    
            commentInput.body = messageBodyInput;
            
            ConnectApi.Comment editedComment = ConnectApi.ChatterFeeds.updateComment(null, fi.id, commentInput);
        }
    }
}