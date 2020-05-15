/*
    @Author             : Loven Reyes (CloudSherpas)
    @Date Created       : 21-DEC-2015
    @Date Modified      : 
    @Description        : controller class for ARTemplate.page
*/

public with sharing class CS_ARTemplateCC {

    @RemoteAction
    public static Map<String,Object> retrieveUserProperties() {
        return CS_ARProfileService.retrieveUserProperties();
    }

    @RemoteAction
    public static List<SelectOption> retrieveHelpTypeOptions() {
        return CS_ARContactsService.getPickValues(new Case(), 'Type', null);
    }

    @RemoteAction
    public static void acceptEula() {
        CS_ARProfileService.acceptEula();
    }

    @RemoteAction
    public static void submitHelp(Map<String,Object> submission ) {

        CS_ARCasesService.submitHelp(submission);
    }    

    @RemoteAction
    public static List<ProcedureProduct__c> retrieveProductsByProcedure(String procedureId) {
        return CS_ARContactsService.retrieveProductsByProcedure(procedureId);

    }
    
    @RemoteAction
    public static List<Procedure_Relationships__c> searchSurgicalTechniques(String q) {
        return CS_ARCasesService.searchSurgicalTechniques(q);
    }

    @RemoteAction
    public static Integer retrieveUnreadMessages() {
        return CS_NotificationService.getUnreadMsgCountByUser(UserInfo.getUserId());
    }    

    @RemoteAction
    public static Integer retrieveOpenTaskCount() {
        return CS_ARTasksService.getOpenTaskCount();
    }    

    // added by chad


    @RemoteAction
    public static list<CS_AROpportunityService.CS_AROpportunityWrapper> retrieveOpportunitiesInMyTeamTerritory() {
        return CS_AROpportunityService.retrieveOpportunitiesInMyTeamTerritory();
    } 

    @RemoteAction
    public static List<CS_ARCalendarEventDTO> retrieveCalendarEvents() {
        return CS_ARCasesCC.retrieveCalendarEvents();
    } 

    @RemoteAction
    public static List<User> retrieveUsersInTerritory(String territoryId) {

        return CS_ARTasksService.getCandiateTaskOwners(territoryId);
    } 

    // end added by chad
}