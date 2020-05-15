public class opportunityTriggerHandler{
    public static void sendEmailonInitialSubmission(List<Opportunity> lstOppnew, Map<Id, Opportunity> mapOldOpp){
        set<Id> sOppId = new set<Id>();
        for(Opportunity opp: lstOppnew){
            if(opp.Record_Sent_for_Approval__c == true && opp.Record_Sent_for_Approval__c != mapOldOpp.get(opp.id).Record_Sent_for_Approval__c){
                sOppId.add(opp.id);
            }
        }
        
        if(!sOppId.isEmpty()){
            // Currently hard-coded for testing
            List<User> lstUser = [Select ID,Email FROM User Where id ='0051g000000cFVL']; 
            
            List<Opportunity> lstOpportunity  = [SELECT id, Name, 
                           (SELECT id, Name, ContentType FROM Attachments ORDER BY Createddate DESC LIMIT 1)
                           FROM Opportunity 
                           WHERE id IN: sOppId];
                           
            for(Opportunity opp: lstOpportunity){
                
                // Define the email
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                // Sets the paramaters of the email
                email.setSubject('Deal Approval Email');
                String addresses;
                
                for(User u: lstUser){
                    addresses = u.Email;
                }
                String[] toAddresses = addresses.split(':', 0);
                email.setToAddresses( toAddresses );
                email.setPlainTextBody('Test');

                
                // Create the email attachment
                List<Attachment> lstLatestAttachment = [SELECT id, name, contentType, body FROM Attachment WHERE id =: opp.Attachments[0].id LIMIT 1];               
                if(!lstLatestAttachment.isEmpty()){
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(lstLatestAttachment[0].name);
                    efa.setBody(lstLatestAttachment[0].body);
                    
                    email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                }
                
                //system.assertEquals(1,2);
                // Sends the email
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
            }
        }
    }
}