//Name                   :  BatchExecUpdateBusinessHoursDepartment
//Created by             :  
/////////////////////////////////////////////////////////////////////
global class BatchExecUpdateBusinessHoursDepartment implements Database.Batchable<sObject>{    
    global final String Query; 
    global final string strB2CSalesChatbusinesshour; 
    global final set<Id> sChatButtons;
    global BatchExecUpdateBusinessHoursDepartment(String q){    
        this.query = q;
        List<Businesshours> lstbusinesshours = [SELECT id, name from businesshours where Name = 'B2C Sales Chat'];
        if(!lstbusinesshours.isEmpty()){
            strB2CSalesChatbusinesshour = lstbusinesshours[0].id;
        }        
        sChatButtons = new set<Id>();
        List<LiveChatButton> lstLiveChatButtons = [SELECT id,DeveloperName from LiveChatButton where DeveloperName Like '%Sales%'];
        for(LiveChatButton lcb: lstLiveChatButtons){
            sChatButtons.add(lcb.id);
        }
    }    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }    
    global void execute(Database.BatchableContext BC, List<sObject> scope){    
        UpdateBusinessHoursDepartment(scope);
    }   
    
    public void UpdateBusinessHoursDepartment(List<LiveChatTranscript> scope) {
        //List<LiveChatTranscript> lstLiveChat = [select id, LiveChatButtonId, Requesttime  from LiveChatTranscript];
        
        if(!scope.isEmpty()){
            Boolean isWithinBusinessHours = true;
            for(LiveChatTranscript lc: scope){
                
                if(strB2CSalesChatbusinesshour != '' && strB2CSalesChatbusinesshour != null && sChatButtons.contains(lc.LiveChatButtonId)){
                    lc.Business_Hours__c = strB2CSalesChatbusinesshour;
                }
                if(lc.Requesttime != null){
                    isWithinBusinessHours = BusinessHours.isWithin(strB2CSalesChatbusinesshour, lc.Requesttime);
                    if(isWithinBusinessHours == true){
                        lc.Department__c = 'Sales';
                    }else{                        
                        lc.Department__c = 'Sales 24x7';
                    }
                }
            }
            try{
                update scope;
            }catch (Exception ex){
                system.debug('Exception Message :- '+ ex.getMessage());
            }
        }        
    }
     
    global void finish(Database.BatchableContext BC){
    
    }
}