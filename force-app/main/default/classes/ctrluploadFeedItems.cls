public class ctrluploadFeedItems{
    public transient blob blobContent {get; set;}
    public ctrluploadFeedItems(){
    
    }
    
    public void uploadFeedPost(){
        Attachment objAttachment = [select id, body from attachment where id = '00Pi000000SOAnX'];
        PageReference pageRef = new PageReference('/apex/pdfpage');
        //system.debug('########'+pageRef.getContent().tostring());
        blob base64EncodedFileData = pageRef.getContent();
        
        //Adding a Content post
        FeedItem post = new FeedItem();
        post.ParentId = '500i000000KkbcG'; //eg. Opportunity id, custom object id..
        post.Body = 'Enter post text here';
        post.ContentData = blobContent;
        post.ContentFileName = 'sample23';
        insert post;
        
    }
}