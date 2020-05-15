global with sharing class LiveChat_Queue_All_ctrl {
    public QueueInfo objQueueInfo{get;set;}
    public static boolean isAllAway {get; set;}
    public LiveChat_Queue_All_ctrl(){   
        isAllAway = false;
        List<UserServicePresence> lstUSP = [SELECT id FROM UserServicePresence WHERE IsAway = true and IsCurrentState = true];
        if(!lstUSP.isEmpty()){
            isAllAway = true;
        }
        objQueueInfo = new QueueInfo();
        objQueueInfo.countryCode = 'us';          
        objQueueInfo.team = 'Sales';
        objQueueInfo.urlModifier = 'existing_order_help';
        objQueueInfo.otherDepartment = 'If you need assistance with an order you placed with us previously, click here:';//+objQueueInfo.urlModifier;
    }
    public class QueueInfo{
        public string team{get;set;}
        public string countryCode{get;set;}
        public string otherDepartment{get;set;}
        public string urlModifier{get;set;}
    }
    
    @RemoteAction
    global static boolean checkForAway(){
        List<UserServicePresence> lstUSP = [SELECT id FROM UserServicePresence WHERE IsAway = true and IsCurrentState = true];
        if(!lstUSP.isEmpty()){
            isAllAway = true;
            return true;
        }else{
            isAllAway = false;
            return false;
        }
    }
    
}