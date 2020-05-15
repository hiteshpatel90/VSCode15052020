public class Opp_Approval_EmailController {
    public string oppId;
    public Opportunity objOpportunity {get; set;}
    public string attachmentBody {get; set;}
    public Attachment objAttachment {get; set;}
    //Opportunity ID
    public String getoppId(){ 
        return oppId;
    }
    public void setoppId(string oppId) {   
        oppId = oppId;
        
        objOpportunity  = [SELECT id, Name, 
                           (SELECT id, Name, ContentType FROM Attachments ORDER BY Createddate DESC LIMIT 1)
                           FROM Opportunity 
                           WHERE id =: oppId];
        if(!objOpportunity.Attachments.isEmpty()){        
            objAttachment  = [SELECT id, name, contentType, body FROM Attachment WHERE id =:  objOpportunity.Attachments[0].id];               
            attachmentBody = EncodingUtil.base64Encode(objAttachment.body);
        }
    }
    public Opp_Approval_EmailController(){
            
    }
}