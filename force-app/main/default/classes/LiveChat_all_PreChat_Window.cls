global WITHOUT SHARING  class LiveChat_all_PreChat_Window {
    
    public boolean isInsideBusinesshrs {get; set;}
    public String JsonMapButtonIdName{get;set;}
    public string strSMSCFinance {get; set;}
    public string strSMSCClaims {get; set;}
    
    public string strSundayTime {get; set;}    
    public string strMondayTime {get; set;}
    public string strTuesdayTime {get; set;}
    public string strWednesdayTime {get; set;}
    public string strThursdayTime {get; set;}
    public string strFridayTime {get; set;}
    public string strSaturdayTime {get; set;}  
    
    public boolean isSMSCClaimsAgentAvailable {get; set;}
    public boolean isSMSCFinanceAgentAvailable {get; set;}
    
    public LiveChat_all_PreChat_Window(){
        isInsideBusinesshrs = false;
        
        List<businesshours> lstCSCaseHours = [select id, name, 
            SundayStartTime, SundayEndTime, 
            MondayStartTime, MondayEndTime, 
            TuesdayStartTime, TuesdayEndTime, 
            WednesdayStartTime, WednesdayEndTime, 
            ThursdayStartTime, ThursdayEndTime, 
            FridayStartTime, FridayEndTime,
            SaturdayStartTime, SaturdayEndTime 
            FROM businesshours where name = 'B2C CS Chat Hours' and isActive=true LIMIT 1];
            
        if(!lstCSCaseHours.isEmpty()){
            isInsideBusinesshrs = BusinessHours.isWithin(lstCSCaseHours[0].id, system.now());
            
            // show Business Hours for Sunday
            strSundayTime = 'No Hours';
            if(lstCSCaseHours[0].SundayStartTime != null && lstCSCaseHours[0].SundayEndTime != null){
                strSundayTime = populateBusinessDaytime(lstCSCaseHours[0].SundayStartTime, lstCSCaseHours[0].SundayEndTime);
            }
            
            // show Business Hours for Monday
            strMondayTime = 'No Hours';
            if(lstCSCaseHours[0].MondayStartTime != null && lstCSCaseHours[0].MondayEndTime != null){
                strMondayTime = populateBusinessDaytime(lstCSCaseHours[0].MondayStartTime, lstCSCaseHours[0].MondayEndTime);                
            }
            
            // show Business Hours for Tuesday
            strTuesdayTime = 'No Hours';
            if(lstCSCaseHours[0].TuesdayStartTime != null && lstCSCaseHours[0].TuesdayEndTime != null){
                strTuesdayTime = populateBusinessDaytime(lstCSCaseHours[0].TuesdayStartTime, lstCSCaseHours[0].TuesdayEndTime);                
            }
            
            // show Business Hours for Wednesday
            strWednesdayTime = 'No Hours';
            if(lstCSCaseHours[0].WednesdayStartTime != null && lstCSCaseHours[0].WednesdayEndTime != null){
                strWednesdayTime = populateBusinessDaytime(lstCSCaseHours[0].WednesdayStartTime, lstCSCaseHours[0].WednesdayEndTime);                
            }            
            
            // show Business Hours for Thursday
            strThursdayTime = 'No Hours';
            if(lstCSCaseHours[0].ThursdayStartTime != null && lstCSCaseHours[0].ThursdayEndTime != null){
                strThursdayTime = populateBusinessDaytime(lstCSCaseHours[0].ThursdayStartTime, lstCSCaseHours[0].ThursdayEndTime);                
            }
            
            // show Business Hours for Friday
            strFridayTime = 'No Hours';
            if(lstCSCaseHours[0].FridayStartTime != null && lstCSCaseHours[0].FridayEndTime != null){
                strFridayTime = populateBusinessDaytime(lstCSCaseHours[0].FridayStartTime, lstCSCaseHours[0].FridayEndTime);                
            }
            
            // show Business Hours for Saturday
            strSaturdayTime = 'No Hours';
            if(lstCSCaseHours[0].SaturdayStartTime != null && lstCSCaseHours[0].SaturdayEndTime != null){
                strSaturdayTime = populateBusinessDaytime(lstCSCaseHours[0].SaturdayStartTime, lstCSCaseHours[0].SaturdayEndTime);
            }
        }
        pagereference pg = System.Page.LiveChat_Queue_Page_All; 
        Cookie counter = new Cookie('agentPage','LiveChat_Sales_for_US', null,315569260,false);
        pg.setCookies( new Cookie[]{ counter } );
        
        Map<String, String> mapButtonIdName = new Map<String, String>();
        List<LiveChatButton> LiveChatButtonList = [SELECT id, MasterLabel, developerName from LiveChatButton where Type = 'Standard'];
        string strLCBId = '';
        for(LiveChatButton lcb: LiveChatButtonList){
            strLCBId = lcb.id;
            strLCBId = strLCBId.substring(0,15);   
            mapButtonIdName.Put(strLCBId, lcb.developerName);
        }
        JsonMapButtonIdName=JSON.serialize(mapButtonIdName);
        
        List<Skill> lstSkills = [SELECT id, developername from Skill where developername = 'SMSC_Finance' OR developername = 'SMSC_Claims'];
        if(!lstSkills.isEmpty()){
            for(Skill sk: lstSkills){
                if(sk.developername == 'SMSC_Claims'){
                    strSMSCClaims = sk.id;
                }else if(sk.developername == 'SMSC_Finance'){
                    strSMSCFinance = sk.id;
                }
            }
        }
        
        Map<String, set<Id>> mapSMSCUsers = new Map<String, set<Id>>();
        List<SkillUser> lstSkillUser = [SELECT id, SkillId, UserId, Skill.Developername from SkillUser where Skill.Developername = 'SMSC_Claims' Or Skill.Developername = 'SMSC_Finance'];
        for(SkillUser su: lstSkillUser){
            if(!mapSMSCUsers.containsKey(su.Skill.Developername)){
                set<Id> sUsers = new set<Id>();
                sUsers.add(su.UserId);
                mapSMSCUsers.Put(su.Skill.Developername, sUsers);
            }else{
                mapSMSCUsers.get(su.Skill.Developername).add(su.UserId);
            }
        }
        
        List<UserServicePresence> lstSMSCClaimsAgent = [select id from UserServicePresence where IsCurrentState = true and UserId in: mapSMSCUsers.get('SMSC_Claims') LIMIT 1];
        if(!lstSMSCClaimsAgent.isEmpty()){
            isSMSCClaimsAgentAvailable = true;
        }
        
        List<UserServicePresence> lstSMSCFinanceAgent = [select id from UserServicePresence where IsCurrentState = true and UserId in: mapSMSCUsers.get('SMSC_Finance') LIMIT 1];
        if(!lstSMSCFinanceAgent.isEmpty()){
            isSMSCFinanceAgentAvailable = true;
        }
    }
    
    @RemoteAction
    global static boolean checkForSandbox(){
        boolean isSandboxCheck = true;
        List<Organization> lstOrganization = [select Id, IsSandbox from Organization limit 1];
        if(!lstOrganization.isEmpty()){
            isSandboxCheck = lstOrganization[0].IsSandbox;
        }
        return isSandboxCheck;
    }
    
    @RemoteAction
    global static String init(String PersonEmail,String phoneNumber) {
        
             return 'PersonEmail,true';
        
    }
    @RemoteAction
    global static String initService(String orderNo,String PersonEmail,String phoneNumber) {
        system.debug('orderNo------'+orderNo+'PersonEmail-----------------'+PersonEmail+'phoneNumber---------'+phoneNumber);

        /*list<Order_Information__c> oi = [SELECT Accounts__c, Order_No__c FROM Order_Information__c  WHERE RecordTypeid = '012a000000189eY' AND Order_No__c = :orderNo ];

        if(oi.size() > 0)
        {
            return oi.get(0).Accounts__c+'_@_Id,true';
        }
        else if([SELECT id FROM Account WHERE PersonEmail  =: PersonEmail  AND RecordTypeid = '012a000000189eZ' AND ispersonaccount=true].size() > 0)
        {
             return '_@_PersonEmail,true';
        }
        else if(phoneNumber!=null)
        {
            if([SELECT id FROM Account WHERE (PersonMobilePhone =: phoneFormat(phoneNumber)) AND  RecordTypeId= '012a000000189eZ' AND ispersonaccount=true].size() > 0){
                return '_@_PersonMobilePhone,true';   
            }else if([SELECT id FROM Account WHERE (PersonMobilePhone =: phoneNumber) AND  RecordTypeId= '012a000000189eZ' AND ispersonaccount=true].size() > 0){
                return '_@_PersonMobilePhone,true'; 
            }else if([SELECT id FROM Account WHERE (PersonHomePhone =: phoneFormat(phoneNumber)) AND  RecordTypeId= '012a000000189eZ' AND ispersonaccount=true].size() > 0){
                return '_@_PersonHomePhone,true';   
            }else if([SELECT id FROM Account WHERE (PersonHomePhone =: phoneNumber) AND  RecordTypeId= '012a000000189eZ' AND ispersonaccount=true].size() > 0){
                return '_@_PersonHomePhone,true'; 
            }else {
                return '_@_PersonOtherPhone,true'; 
            }  
        }*/
        return '_@_PersonOtherPhone,true';  
    }
    
    public static string phoneFormat(String pnoneN){
        system.debug('##############'+pnoneN);
        if(!String.isEmpty(pnoneN) && pnoneN.length() == 10){
            return '('+pnoneN.substring(0,3)+') '+pnoneN.substring(3,6)+'-'+pnoneN.substring(6,10);
        }
        system.debug('##############'+pnoneN);
        return pnoneN;
    }
    
    public string populateBusinessDaytime(Time dayStartTime, Time dayEndTime){
        string strBusinessDaytime = '';
        integer intStartHour = dayStartTime.hour();
        if(intStartHour > 12){
            intStartHour = intStartHour - 12;
        }
        string strStartMinute = '';
        integer intStartMinute = dayStartTime.minute();
        if(intStartMinute < 10){
            strStartMinute = '0' + string.valueOf(intStartMinute);
        }else{
            strStartMinute = string.valueOf(intStartMinute);
        }
        
        string strStartTime = intStartHour + ':' + strStartMinute;
        if(dayStartTime.hour() > 12){
            strStartTime += ' PM';
        }else{
            strStartTime += ' AM';
        }
        
        
        integer intEndHour = dayEndTime.hour();
        if(intEndHour > 12){
            intEndHour = intEndHour - 12;
        }
        
        string strEndMinute = '';
        integer intEndMinute = dayEndTime.minute();
        if(intEndMinute < 10){
            strEndMinute = '0' + string.valueOf(intEndMinute);
        }else{
            strEndMinute = string.valueOf(intEndMinute);
        }
        
        string strEndTime = intEndHour + ':' + strEndMinute;
        if(dayEndTime.hour() > 12){
            strEndTime += ' PM';
        }else{
            strEndTime += ' AM';
        }
                
        strBusinessDaytime = strStartTime + ' to ' + strEndTime;
        return strBusinessDaytime;
    } 
}