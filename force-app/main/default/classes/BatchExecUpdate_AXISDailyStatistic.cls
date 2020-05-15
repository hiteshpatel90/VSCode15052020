///////////////////////////////////////////////////////////////////
//Name                   :  BatchExecUpdate_AXISDailyStatistic
//Created by             :  
/////////////////////////////////////////////////////////////////////

global class BatchExecUpdate_AXISDailyStatistic implements Database.Batchable<sObject>{
    global final String Query;
    global final Date currentDate;
    global final Date LoginStartTime;
    global final Date LoginEndTime;
    
    global final List<User> ActivePartnerUserList;
    global final Set<Id> ActivePartnerUserIdSet;
    global final Map<Id,User> UserMap;
    global static String PartnerUserId=System.Label.AXIS_Partner_User_Profile;
    global BatchExecUpdate_AXISDailyStatistic(String q, Date loggedInDate){    
        this.query = q;
        this.currentDate = loggedInDate;
        LoginStartTime = this.currentDate + 1;
        LoginEndTime = this.currentDate - 1;
        
        ActivePartnerUserIdSet = new set<Id>();
        UserMap = new Map<Id, User>();
        ActivePartnerUserList = [Select IsActive,Name,Contact.Role_In_Agency__c,Contact.Account.Id from User where IsActive=true and Profile.Id =:PartnerUserId] ;
        for(User u:ActivePartnerUserList){        
            ActivePartnerUserIdSet.add(u.Id);  
            UserMap.put(u.Id,u);
        } 
    }    
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('@@@@@@@@@@'+query);
        return Database.getQueryLocator(query);
    }    
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        Integer ActivePartnerUserCount=0;
        List<Case__c> AllCasesCreatedYesterday=new List<Case__c>();
        List<Practitioner_Procedure__c> AllPrefCardCreatedYesterday=new List<Practitioner_Procedure__c>();

        
        Set<Id> LoginPartnerUserIdSet=new Set<Id>();
        Integer LoginPartnerUserCount=0;
        
       
        List<Case__c> AllCasesCreatedYesterdayEST=new List<Case__c>();
        List<Practitioner_Procedure__c> AllPrefCardCreatedYesterdayEST=new List<Practitioner_Procedure__c>();
        
        ActivePartnerUserCount=ActivePartnerUserList.size();
        
        List<LoginHistory> lstLoginHistory = (List<LoginHistory>)scope;
        for(LoginHistory lh: lstLoginHistory){
            if(!((lh.LoginTime.addHours(-4)).date()==currentDate-2) && (((lh.LoginTime.addHours(-4)).date()==currentDate-1)||(lh.LoginTime).date()==currentDate-1)){
                LoginPartnerUserIdSet.add(lh.UserId);
            }        
        }
        LoginPartnerUserCount=LoginPartnerUserIdSet.size();
        AllCasesCreatedYesterday=[Select createdById,Name,CreatedDate from Case__c where createddate>=:currentDate-1 and createddate<:currentDate+1];
        AllPrefCardCreatedYesterday=[Select createdById,Name,CreatedDate from Practitioner_Procedure__c where createddate>=:currentDate-1 and createddate<:currentDate+1];
        for(Case__c c:AllCasesCreatedYesterday){
            IF(!((C.CreatedDate.AddHours(-4)).date()==currentDate-2)&& (((C.CreatedDate.addHours(-4)).date()==currentDate-1)||(C.CreatedDate).date()==currentDate-1)){
                AllCasesCreatedYesterdayEST.add(c);
            }
        }
        for(Practitioner_Procedure__c P:AllPrefCardCreatedYesterday){
            IF(!((P.CreatedDate.AddHours(-4)).date()==currentDate-2) && (((P.CreatedDate.addHours(-4)).date()==currentDate-1)||(P.CreatedDate).date()==currentDate-1)){
                AllPrefCardCreatedYesterdayEST.add(P);
            }
        }        
        AXIS_Daily_Statistic__c ads=new AXIS_Daily_Statistic__c();
        ads.Active_Partner_Users__c=ActivePartnerUserCount;
        ads.Logged_in_Partner_Users__c=LoginPartnerUserCount;
        ads.Date__c=currentDate-1;
        ads.New_Cases__c=AllCasesCreatedYesterdayEST.size();
        ads.New_Preference_Cards__c=AllPrefCardCreatedYesterdayEST.size();
        insert ads; 
        
        //------------------AXISDailyUserStatistic----------------
        //Insert records into AXISDailyUserStatistic object on a daily basis        
        Integer CasesPerUserCount=0;
        Integer PrefCardPerUserCount=0;      
        List<AXIS_Daily_User_Statistic__c> insertYesterdayStatisticlist=new List<AXIS_Daily_User_Statistic__c>();        
        for(Id activeUserId:ActivePartnerUserIdSet){
            AXIS_Daily_User_Statistic__c ADUS=new AXIS_Daily_User_Statistic__c();
            CasesPerUserCount=0;
            PrefCardPerUserCount=0;
            for(Case__c userCase:AllCasesCreatedYesterdayEST){
                if(userCase.createdById==activeUserId){
                    CasesPerUserCount+=1;
                }
            }
            for(Practitioner_Procedure__c userPrefCard:AllPrefCardCreatedYesterdayEST){
                if(userPrefCard.createdById==activeUserId){
                    PrefCardPerUserCount+=1;
                }
            }
            for(Id Userlogin:LoginPartnerUserIdSet){
                if(Userlogin==activeUserId){
                    ADUS.Logged_in__c=1;        
                }
            }
            ADUS.Date__c=currentDate-1;
            ADUS.User__c=activeUserId;
            ADUS.No_of_Cases__c=CasesPerUserCount;
            ADUS.No_of_Preference_Cards__c=PrefCardPerUserCount;
            if( UserMap.get(activeUserId).Contact.Role_In_Agency__c!=null){
                if(UserMap.get(activeUserId).Contact.Role_In_Agency__c=='None'){
                    ADUS.Role_In_Agency__c=null;
                }else{
                    ADUS.Role_In_Agency__c= UserMap.get(activeUserId).Contact.Role_In_Agency__c;
                }
            }               
            ADUS.Account_Name__c=UserMap.get(activeUserId).Contact.Account.Id;
            insertYesterdayStatisticlist.add(ADUS);        
        }
        System.debug('insertYesterdayStatisticlist------>'+insertYesterdayStatisticlist);
        if(insertYesterdayStatisticlist.size()>0){
            insert insertYesterdayStatisticlist;
        }
    }
    global void finish(Database.BatchableContext BC) {
        Date nextDate = currentDate.adddays(1);
        Date endDate = Date.newInstance(2016, 7, 1);
        if(nextDate < endDate){
            //Date nextDate = Date.newInstance(2015, 8, 1);
             
            String sQuery='SELECT LoginTime,UserId from LoginHistory where LoginTime<: LoginStartTime and LoginTime>=: LoginEndTime and UserId in:ActivePartnerUserIdSet';
            BatchExecUpdate_AXISDailyStatistic batchApex = new BatchExecUpdate_AXISDailyStatistic(sQuery, nextDate);      
            Database.executeBatch(batchApex,200);
        }
    }      
}