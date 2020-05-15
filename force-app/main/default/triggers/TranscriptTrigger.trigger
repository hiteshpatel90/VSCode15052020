trigger TranscriptTrigger on LiveChatTranscript (after insert) {
    system.debug('>>>>>>>>>>>>>>>>>'+trigger.new);
    if(Trigger.isAfter){        
        if(Trigger.isInsert){
            //to tie visitor feddback           
            /*map<DateTime,LiveChatTranscript> lct = new map<DateTime,LiveChatTranscript>();
            for(LiveChatTranscript lc: [select id, name, scale__c ,comment__c,visitor_Unique_Key__C,startTime from LiveChatTranscript where visitor_Unique_Key__C != null and startTime = null]){
              lct.put(lc.startTime,lc);              
            }
            list<LiveChatTranscript> toUpdate = new list<LiveChatTranscript>();
            list<LiveChatTranscript> todelete = new list<LiveChatTranscript>();
            for(LiveChatTranscript lc: [select id, name, visitor_Unique_Key__C,startTime from LiveChatTranscript where startTime IN :lct.keyset()]){
                 LiveChatTranscript l = lc;
                 if(lct.containsKey(lc.visitor_Unique_Key__C)){
                     l.scale__c = lct.get(lc.visitor_Unique_Key__C) != null?lct.get(lc.visitor_Unique_Key__c).scale__c:l.scale__c;
                     l.comment__c = lct.get(lc.visitor_Unique_Key__C) != null?lct.get(lc.visitor_Unique_Key__c).comment__c:l.comment__c;
                     toUpdate.add(l);
                     todelete.add(lct.get(lc.visitor_Unique_Key__C));
                 }                 
            }
            if(!toUpdate.isEmpty()) update toUpdate;
            if(!todelete.isEmpty()) update todelete;*/
        
            //bind relation ship between transcript and other sub data
            /*new Triggers()
            .bind(Triggers.Evt.afterinsert,new LiveAgentDataConnectionHandler())
            .manage();
            
            //added by Serge Kandukuri - 09/28/2016 - Link Live_Agent_Disposition__c with LiveChatTranscript
            new Triggers()
            .bind(Triggers.Evt.afterinsert,new LiveChatTranscriptHandler())
            .manage();*/
            
        }
        
    }
    
}