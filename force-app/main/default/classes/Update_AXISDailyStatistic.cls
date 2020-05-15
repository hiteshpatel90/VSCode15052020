public class Update_AXISDailyStatistic implements Schedulable {
    // Partner User profile
    public static String PartnerUserId=System.Label.AXIS_Partner_User_Profile;
    public void execute(SchedulableContext sc){
        // Variable Initialization
        Integer ActivePartnerUserCount=0;
        List<Case__c> AllCasesCreatedYesterday=new List<Case__c>();
        List<Practitioner_Procedure__c> AllPrefCardCreatedYesterday=new List<Practitioner_Procedure__c>();
        List<User> ActivePartnerUserList =new List<User>(); 
        Set<Id> ActivePartnerUserIdSet=new Set<Id>();
        Set<Id> LoginPartnerUserIdSet=new Set<Id>();
        Integer LoginPartnerUserCount=0;
        
        ActivePartnerUserList  =[Select IsActive,Name,Contact.Role_In_Agency__c,Contact.Account.Id from User where IsActive=true and Profile.Id =:PartnerUserId] ;
        ActivePartnerUserCount=ActivePartnerUserList.size();
        
        Map<Id,User> UserMap=new Map<Id,User>();
        List<Case__c> AllCasesCreatedYesterdayEST=new List<Case__c>();
        List<Practitioner_Procedure__c> AllPrefCardCreatedYesterdayEST=new List<Practitioner_Procedure__c>();
        for(User u:ActivePartnerUserList){        
            ActivePartnerUserIdSet.add(u.Id);  
            UserMap.put(u.Id,u);
        }        
        List<LoginHistory> DailyPartnerLoginList=[SELECT LoginTime,UserId from LoginHistory where LoginTime<:Date.today()+1 and LoginTime>=:Date.today()-1 and UserId in:ActivePartnerUserIdSet];
        
        
    }    
}