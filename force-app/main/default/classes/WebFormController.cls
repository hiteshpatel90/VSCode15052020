public class WebFormController {

     @AuraEnabled Public Static List<Product_Question__c> getProductFormQuestions(String productName)
    {
        String Product = productName;
        
        List<Product_Question__c> questionList = [SELECT id, Question__r.Name, Question__r.Full_Question__c, Product__c, Name FROM Product_Question__c WHERE Product__c IN (SELECT ID FROM Product2 WHERE Name = :Product)];
             
     Return questionList;
    }
    
    @AuraEnabled Public Static Case insertCase(String teacherOrStudent, String primaryIssue, String secondaryIssue, String product, String description, String strSubject, String participantEmails)
    {
        system.debug('#######'+primaryIssue);
        system.debug('#######'+secondaryIssue);
        system.debug('#######'+description);
        system.debug('#######'+strSubject);
        
        User currentUser = [SELECT Id, Contact.Account.Id 
                                FROM User 
                                WHERE Id = :UserInfo.getUserId()
                                LIMIT 1];
        Case newCase = new Case(
            Subject = strSubject,
            AccountId = currentUser.Contact.Account.Id,
            Origin= 'Web',
            ContactId = currentUser.Contact.Id,
            Description = description,
            Primary_Issues__c = primaryIssue,
            Secondary_Issues__c = secondaryIssue,
            Tell_us_a_little_about_yourself__c = teacherOrStudent,
            Web_Case__c = True,
            ISBN__c = product,
            Participant_Emails_new__c = participantEmails,
            Status = 'Open'
            );
        system.debug('newCase=='+newCase);
        try{
                   insert newCase; 
        }
        catch(DmlException e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        Return newCase;
    }
    
    @AuraEnabled Public Static List<Answer__c> insertAnswers(String caseID, Map<String, String> answerMap){
        Answer__c newAnswer = new Answer__c();
        List<Answer__c> AnswerList = new List<Answer__c>();
        system.debug(answerMap.keySet());
        for(Id questionID : answerMap.keySet()){
            newAnswer.Case__c = caseId;
            newAnswer.Product_Question__c = questionId;
            newAnswer.Answer_text__c = answerMap.get(questionId);
            AnswerList.add(newAnswer);
        }
        try{
            insert Answerlist;
        }
        catch(DmlException e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        Return AnswerList;
    }
    
}