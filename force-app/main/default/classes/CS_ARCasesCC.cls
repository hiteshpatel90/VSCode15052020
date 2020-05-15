/*
    @Author             : Jason Bandojo, Loven Reyes (CloudSherpas)
    @Date Created       : 7-DEC-2015
    @Date Modified      : 
    @Description        : controller class for ARCases.page
*/

public with sharing class CS_ARCasesCC {

    @RemoteAction
    public static List<CS_ARCalendarEventDTO> retrieveCalendarEvents() {
        
        String caseListSoql = CS_ARCalendarEventDTO.getCaseBuildSoql();
        set<Id> setCaseParticipantCaseIds = new set<Id>();
        caseListSoql += ' WHERE Event_Start_Date__c != NULL and ';
        
        // any case 30 days ago or in the next 60 days
        caseListSoql += ' (Event_Start_Date__c = LAST_N_DAYS:30 OR Event_Start_Date__c = NEXT_N_DAYS:60) ';
        caseListSoql += ' AND Event_End_Date__c != NULL ';
        
        // filter for health care provides in this user's team territory
        List<Id> healthCareProvidersInMyTerritory = CS_ARTerritoryService.retrieveHealthCareProvidersInMyTeamTerritory();
        
        //filter for cases in the users team territory
        list<User> lstUsers = CS_ARTerritoryService.retrieveUsersInMyTerritory();
        
        if(lstUsers.size() > 0){
             setCaseParticipantCaseIds = retrieveCaseParticipantCaseIds(lstUsers);
        }
        setCaseParticipantCaseIds.remove(null);
        system.debug('##--healthCareProvidersInMyTerritory: '+ healthCareProvidersInMyTerritory);
        
        String myHcps = '(\''+String.join(healthCareProvidersInMyTerritory,'\',\'')+'\')';

        // for now, ignore territory based providers when a unit test is running - Chad
        /*if ( !Test.isRunningTest() ) {
            caseListSoql += ' AND Health_Care_Provider__c in '+myHcps;
        }*/
        
        
        
        if(setCaseParticipantCaseIds.size() > 0){
            caseListSoql += ' AND ( (OwnerId IN :lstUsers ) OR (Id IN :setCaseParticipantCaseIds) )'; 
        }else{
            caseListSoql += ' AND OwnerId IN: lstUsers ';
        }
            
        caseListSoql += ' ORDER BY Event_Start_Date__c DESC';
        system.debug('-******************** '+caseListSoql);
        
        return cases2CalendarEventDTOs( Database.query(caseListSoql) );

    }
   
    public static List<CS_ARCalendarEventDTO> cases2CalendarEventDTOs(List<Case__c> caseList) {
        system.debug('##--cases2CalendarEventDTOs.caseList.size(): '+ caseList.size());
        List<CS_ARCalendarEventDTO> calendarEvents = new List<CS_ARCalendarEventDTO>();

        if ( caseList != null ) {

            // retrieve the current user's territory ids
            Set<Id> userTerritoryIds = new Set<Id>(CS_ARTerritoryService.retrieveMyTerritoryIds(true));
            
            system.debug('##--cases2CalendarEventDTOs.userTerritoryIds: '+ userTerritoryIds);
            // map acount territories to the case list
           // List<Id> caseIds = new List<Id>();
            List<Id> CaseOwnerIds = new List<Id>();
            for ( Case__c c : caseList ) { 
                system.debug('##--cases2CalendarEventDTOs.c: '+ c);
                //caseIds.add(c.Health_Care_Provider__r.Id); 
                CaseownerIds.add(c.OwnerId);
                for( CaseParticipant__c  objCaseParticipant: c.Case_Participants__r){
                    CaseownerIds.add(objCaseParticipant.Participant__c);
                }
            }
           // Map<Id,List<ObjectTerritory2Association>> territoryMap = CS_ARTerritoryService.mapObjectIdsToTerritories(caseIds);
            system.debug('##--CaseownerIds: '+ CaseownerIds);
            Map<Id,List<UserTerritory2Association>> userTerritoryMap = CS_ARTerritoryService.mapUserIdsToTerritories(CaseownerIds);
            system.debug('##--cases2CalendarEventDTOs.userTerritoryMap: '+ userTerritoryMap);

            for ( Case__c c : caseList ) {

                CS_ARCalendarEventDTO caseDTO = CS_ARCalendarEventDTO.buildFromCase(c);
                
                //system.debug('##--caseDTO: '+ caseDTO);
                
                //look up user territories
                List<UserTerritory2Association> userTerritoryAssciations = userTerritoryMap.get(c.ownerId);
                if(userTerritoryAssciations.size() > 0){
                    
                    caseDTO.ownerProviderTerritory = userTerritoryAssciations[0].Territory2.Name;
                    caseDTO.ownerProviderTerritoryId = userTerritoryAssciations[0].Territory2Id;
                    caseDTO.ownerProviderParentTerritoryId = userTerritoryAssciations[0].Territory2.ParentTerritory2Id;
                    
                }
                
                for(map<string, string> mapParticipant : caseDTO.participants){
                    string participantId = mapParticipant.get('Id');
                    system.debug('##-- participantId: '+ participantId);
                    system.debug('##-- userTerritoryMap.get(participantId): '+ userTerritoryMap.get(participantId));
                    if(userTerritoryMap.get(participantId) == null || userTerritoryMap.get(participantId).isEmpty()){
                        break;
                    }
                    
                    UserTerritory2Association participantTerritory = userTerritoryMap.get(participantId).get(0);    //  getting the first Territory
                    mapParticipant.put('participantTerritory', participantTerritory.Territory2.Name);
                    mapParticipant.put('participantTerritoryId', participantTerritory.Territory2Id);
                    mapParticipant.put('participantParentTerritoryId', participantTerritory.Territory2.ParentTerritory2Id);
                    
                }   //  end of for-each participant
                system.debug('##--caseDTO: '+ caseDTO);
                calendarEvents.add( caseDTO );
            }
        }
        
        system.debug('##--calendarEvents: '+ calendarEvents);

        return calendarEvents;
    }

    // For future use (drag/drop calendar events to a new time)
    @RemoteAction
    public static CS_ARCalendarEventDTO updateCaseDateTime(String id, Long startDateMs, Long endDateMs) {

        CS_ARCalendarEventDTO caseDTO = CS_ARCasesService.updateCaseDateTime(id, startDateMs, endDateMs);                        
        return caseDTO;

    }
    
    @RemoteAction
    public static CS_ARCalendarEventDTO saveCaseStage(String caseId, String nextStatus) {
        CS_ARCasesService.updateCaseStage(caseId, nextStatus);
        return CS_ARCasesService.retrieveCalendarEventDTOByCaseId(caseId);
    }   //  end of saveCaseStage
    
    @RemoteAction
    public static List<UserTerritoryWrapper> retrieveUserTerritories() {
        list<UserTerritoryWrapper> lstUserTerritoryWrapper = new list<UserTerritoryWrapper>();
        list<Id> lstUserIds = new list<Id>();
         //filter for cases in the users team territory
        list<User>lstUsers = CS_ARTerritoryService.retrieveUsersInMyTerritory();
        list<User>lstActiveUsers= new list<User>();
        system.debug('##--lstUsers: '+ lstUsers);
        for(User objUser :lstUsers){
            
            if(objUser.IsActive){
                lstUserIds.add(objUser.Id);
                lstActiveUsers.add(objUser);
            }
        }
        system.debug('##--lstUserIds: '+ lstUserIds);
        map<Id,List<UserTerritory2Association>> userTerritoryMap = CS_ARTerritoryService.mapUserIdsToTerritories(lstUserIds);
        system.debug('##--userTerritoryMap: '+ userTerritoryMap);
        
        for(User objUser :lstActiveUsers){
            
            List<UserTerritory2Association> userTerritoryAssciations = userTerritoryMap.get(objUser.Id);
            lstUserTerritoryWrapper.add(new UserTerritoryWrapper(objUser,
                                                                 userTerritoryAssciations[0].Territory2Id,
                                                                 userTerritoryAssciations[0].Territory2.Name,
                                                                 userTerritoryAssciations[0].Territory2.ParentTerritory2Id) );
        }
       
        system.debug('##--lstUserTerritoryWrapper: '+ lstUserTerritoryWrapper);
        return lstUserTerritoryWrapper;
        
    }// end of retrieveUserTerritories
    
    @RemoteAction
    public static CS_ARCalendarEventDTO retrieveCalendarEventDTOByCaseId(String caseId) {
        return CS_ARCasesService.retrieveCalendarEventDTOByCaseId(caseId);
    }
    
    @RemoteAction
    public static  CS_ARContactsService.CS_PreferenceCardWrapper retrievePractitionerPrefCard(String practitionerId) {
        system.debug('##--PractitionerProcedure' + CS_ARContactsService.retrievePractitionerPrefCard(practitionerId));
        return CS_ARContactsService.retrievePractitionerPrefCard(practitionerId);

    }
    
    @RemoteAction
    public static List<Practitioner_Procedure__c> retrievePractitionerPrefCards(String practitionerId) {

        return CS_ARContactsService.retrievePractitionerPrefCards(practitionerId);

    }
    
    @RemoteAction
    public static List<Practitioner_Procedure__c> retrievePractitionerPrefCardsFromCal(String practitionerId, string caseId) {

        return CS_ARContactsService.retrievePractitionerPrefCardsFromCal(practitionerId, caseId);

    }

    @RemoteAction
    public static List<Practitioner_Procedure_Products__c> retrievePractitionerPrefCardProducts(String cardId) {
        return CS_ARContactsService.retrievePractitionerPrefCardProducts(cardId);
    } 
    
    @RemoteAction
    public static void createNote(string caseId,
                                         string noteBody, string noteid){
        
       CS_AROpportunityService.createNote(caseId,
                                           noteBody, noteid);
    }

    @RemoteAction
    public static list<CS_ARCasesService.CaseWrapper> retreiveActivities(string activityType,
                                                                                    string caseId){
        
        return CS_ARCasesService.retrieveCaseActivity(activityType,
                                                                    caseId);
    }// end of retreiveActivities
    
    @RemoteAction
    public static Case_Pref_Card__c addCasePreferenceCard(String caseId, string prefcardId) {
        return CS_ARCasesService.addCasePreferenceCard(caseId, prefcardId);
    }
    
    @RemoteAction
    public static list<CS_ARCasesService.CS_OpportunityCase> getCasesToBeLinked(Id surgeonId){
        return CS_ARCasesService.retrieveCasesToBeLinked(surgeonId); 
    }   //  end of getCasesToBeLinked
    
     @RemoteAction
    public static CaseParticipant__c saveCaseParticipant(string caseId,
                                                                string salesRepId){
    
        return CS_ARCasesService.cSaveCaseParticipant(caseId,
                                                        salesRepId);
    }
    
    @RemoteAction
    public static list<CS_ARCasesService.CS_LinkOpportunity> getOpportunitiesToBeLinked(Id surgeonId,
                                                                                        Id caseId){
        return CS_ARCasesService.retrieveOpportunitiesToBeLinked(surgeonId, caseId);
    }   //  end of getOpportunitiesToBeLinked
    
    @RemoteAction
    public static list<Opportunity_Case__c> saveLinkedOpportunities(string caseId, 
                                                                                         list<string> lstLinkedOpportunityIds){
        
        return CS_ARCasesService.cSaveLinkedOpportunities(caseId,
                                                         lstLinkedOpportunityIds);
    }
    
    @RemoteAction
    public static list<Linked_Case__c> saveLinkedCases(string caseId, 
                                                                list<string> lstLinkedCaseIds){
        
       return CS_ARCasesService.cSaveLinkedCases(caseId,
                                                         lstLinkedCaseIds);
    }
    
    @RemoteAction
    public static void deleteCaseParticipant(string caseParticipantId){
        
        CS_ARCasesService.cDeleteCaseParticipant(caseParticipantId);
    }
    
    @RemoteAction
    public static void deletePreferenceCard(string casePreferenceCardId){
        
        CS_ARCasesService.cDeletePreferenceCard(casePreferenceCardId);
    }
    
    @RemoteAction
    public static void deleteLinkedOpportunityCase(string linkedOpportunityCaseId){
        
        CS_ARCasesService.cDeleteLinkedOpportunityCase(linkedOpportunityCaseId);
    }
    
    
    public String getCurrentUserTimeZone(){
        return UserInfo.getTimeZone().getID();
    }   //  end of getCurrentUserTimeZone
    
    /*
    Added By Srinivas Sattoor, 08.16.2016
    Give a list of User Ids, this method returns all the case Ids
    where the users are case participants.
    */
    
    private static set<Id> retrieveCaseParticipantCaseIds(list<User> lstCasePartcipants){
        
        set<Id> setCaseParticipantCaseIds =  new set<Id>();
        for(CaseParticipant__c objCaseParticipant :[SELECT Id, Case__c FROM CaseParticipant__c
                                                        WHERE Participant__c IN :lstCasePartcipants]){
            
            if(objCaseParticipant.Case__c != null){
                setCaseParticipantCaseIds.add(objCaseParticipant.Case__c);
            }
        }// end of for-each
        
        return setCaseParticipantCaseIds;
        
    }// end of retrieveCaseParticipantCaseIds
    
    public class UserTerritoryWrapper{
        
        public User objUser {get;set;}
        public string territoryId {get;set;}
        public string territoryName {get;set;}
        public string parentTerritoryName {get;set;}
        
        public UserTerritoryWrapper(User p_objUser,
                                    string p_territoryId,
                                    string p_territoryName,
                                    string p_parentTerritoryName){
            
            objUser = p_objUser;
            territoryId = p_territoryId;
            territoryName = p_territoryName;
            parentTerritoryName = p_parentTerritoryName;
        }
    }// end of territoryNameWrapper
    
    @RemoteAction    
    public static List<SelectOption> retrieveUserTimeZoneValues() {
        return CS_ARContactsService.getPickValues(new User(), 'TimeZoneSidKey', null);        
    } 
    
    @RemoteAction
    public static Map<String,Object> retrieveProfile() {
        return CS_ARProfileService.retrieveProfile(UserInfo.getUserId());
    }
    

}