public without sharing class LiveChat_PostChat_Form {
    public boolean isAgentOnline {get; set;}
    public LiveChat_PostChat_Form(){
        string strChatDetailsJSON = apexpages.currentpage().getparameters().get('chatDetails');
        isAgentOnline = false;
        String strUserId = '';
        if(strChatDetailsJSON != null){
            JSONParser parser = JSON.createParser(strChatDetailsJSON);
        
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'userId')) {
                    parser.nextToken();
                    strUserId = parser.getText();
                }
            }
        }
        if(strUserId != ''){
            List<UserServicePresence> userServicePresence = [select id, IsCurrentState from UserServicePresence where UserId =: strUserId and IsCurrentState = true];
            if(!userServicePresence.isEmpty()){
                
                isAgentOnline = true;
                
            }
        }
    }
    @RemoteAction
    public static void createFeedback(String Scale, String Comment,string visitorChatId,string starttime,string chatKeyId){
        String accId = null;
        try{
            //accId = [SELECT ID FROM ACCOUNT where id='0012300000FdJ8o'].Id;
        }catch(Exception e){
            system.debug('Generic Account Error:'+e);
        }
        /*LiveChat_Visitor_Feedback__c Lcv = new LiveChat_Visitor_Feedback__c();
        Lcv.Comment__c = Comment;
        Lcv.Scale__c = Scale != null?Integer.valueOf(Scale):1;
        lcv.Account__c = accId ;        
        insert Lcv;*/
        
        
        Id surveyRecordTypeId = Schema.SObjectType.Live_Chat_Survey__c
                                  .getRecordTypeInfosByName().get('B2C NA').getRecordTypeId(); 
        Live_Chat_Survey__c survey = new Live_Chat_Survey__c();
        survey.Live_Chat_Transcript_Chat_Key__c = chatKeyId;
        survey.RecordTypeId = surveyRecordTypeId;       
        survey.How_can_we_improve_your_experience__c = Comment;
        survey.Would_you_recommend_Lenovo__c = Scale != null?Integer.valueOf(Scale):1;        
        insert survey;
        
        /*LiveChatVisitor  lcv = [Select SessionKey,Id From LiveChatVisitor limit 1];//WHERE SessionKey=:visitorChatId];
        LiveChatTranscript lc = new LiveChatTranscript();
        lc.Comment__c = Comment;
        lc.LiveChatVisitorId = lcv.Id;
        //lc.chatKey = chatKeyId;
        //lc.Visitor_Unique_Key__c = !String.isBlank(starttime)?ConvertStartDate(starttime):null;
        lc.Scale__c = Scale != null?Integer.valueOf(Scale):1;
        insert lc;
        */
    }
    public static DateTime ConvertStartDate(String Stdt){
        Long longtime = Long.valueOf(Stdt);
        DateTime dt = DateTime.newInstance(longtime);
        system.debug(dt);
        return dt;
    }
}